local AST = ast

module('vlua.translator', package.seeall)

local simpleNode = {Number=true, String=true, Id=true, Dots="...", True="true", False="false", Nil="nil"}
function isSimpleNode(tag)
	return simpleNode[tag]
end

function translate(ast, graph)
	local processBlock, processExpression, processStatement, handleFunctionDefinition

	function handleFunctionDefinition(s)
		if s.tag == "Set" and s[1] and s[2] and #s[1] == 1 and #s[2] == 1 and s[2][1].tag == "Function"
		or s.tag == "Localrec" and #s == 2 and s[2][1].tag == "Function" and s[1][1].tag == "Id"
		then
			local f = s[2][1]
			log('Handling function')
			local name = AST.decompile(s[1][1])
			local func = graph:createEdge("Function")
			local body = processBlock(f[#f])
			graph:connect(body, func, "body", "out")
			
			graph.elements[name] = func
			return true
		end
	end

	function processStatement(s)
		local tag = s.tag
		if not tag then error(STR("Error in processing statement", repr(s))) end
		
		if handleFunctionDefinition(s) then
			return
		end
				
		local edge
		if tag == "Set" then
			edge = graph:createEdge(tag)
			if #s[1] > 1 or #s[2] > 1 then
				fatal("Unhandled multiple assignment")
			else
				local lhs = processExpression(s[1][1])
				local rhs = processExpression(s[2][1])
				graph:connect(lhs, edge, "to", "out")
				graph:connect(rhs, edge, "value", "in")
			end
		elseif tag == "If" then
			edge = graph:createEdge(tag)
			local cond = processExpression(s[1])
			local body = processBlock(s[2])
			TODO "Handle rest of conditions"
			graph:connect(cond, edge, "condition", "in")
			graph:connect(body, edge, "body", "out")
		elseif tag == "Fornum" then
			edge = graph:createEdge(tag)
			local var = processExpression(s[1])
			local from = processExpression(s[2])
			local to = processExpression(s[3])
			local body = processBlock(s[4])
			graph:connect(var, edge, "variable", "in")
			graph:connect(from, edge, "from", "in")
			graph:connect(to, edge, "to", "in")
			graph:connect(body, edge, "body", "out")
		elseif tag == "Forin" then
			edge = graph:createEdge(tag)
			TODO "Forin"
		elseif tag == "While" then
			edge = graph:createEdge(tag)
			TODO "While"
		elseif tag == "Repeat" then
			edge = graph:createEdge(tag)
			TODO "Repeat"
		elseif tag == "Return" then
			edge = graph:createEdge(tag)
			
			TODO "Return"
		elseif tag == "Break" then
			edge = graph:createEdge(tag)
			TODO "Break"
		elseif tag == "Local" then
			edge = graph:createEdge(tag)
			TODO "Local"
		elseif tag == "Call" then
			edge = graph:createEdge(tag)
			local func = processExpression(s[1])
			graph:connect(func, edge, "function", "in")
			for i=2,#s do
				local arg = processExpression(s[i])
				graph:connect(arg, edge, "arg"..(i-1), "in")
			end
		elseif tag == "Invoke" then
			edge = graph:createEdge(tag)
			local obj = processExpression(s[1])
			local func = processExpression(s[2])
			graph:connect(obj, edge, "object", "in")
			graph:connect(func, edge, "method", "in")
			for i=3,#s do
				local arg = processExpression(s[i])
				graph:connect(arg, edge, "arg"..(i-2), "in")
			end
		else
			fatal("Unhandled statement %s", tag)
			edge = graph:createEdge("Unknown")
		end
		
		local ndo = graph:createNode("Stat")
		graph:connect(ndo, edge, "do", "in")
		return ndo
	end
	
	function processExpression(e)
		local tag = e.tag
		if not tag then error(STR("Error in processing expression", repr(e))) end
		local simple = isSimpleNode(tag)
		if simple then
			local n = graph:createNode(tag)
			n.value = type(simple) == "string" and simple or e[1]
			return n
		else
			local n = graph:createNode("Expression")
			n.value = AST.decompile(e)
			return n
		end
	end

	function processBlock(b)
		local ndo = graph:createNode("Stat")
		local block = graph:createEdge("Block")
		local last
		local count = 0
		for i=1, #b do
			local s = processStatement(b[i])
			if s then
				count = count + 1
				graph:connect(s, block, tostring(count), "out")
				if last then
					graph:connect(s, last.edges["do"], "next", "out")
				end
				last = s
			end
		end
		graph:connect(ndo, block, "do", "in")
		return ndo
	end

	local main = processBlock(ast)
	io.open('ast', 'w'):write(repr(ast, 'ast', {maxlevel=999}))
	graph.elements.Main = main.edges["do"]
end

function toAst(graph)
	local ast = {}
	
	for name, func in pairs(graph.elements) do 
		if name ~= "Main" then
		
		end
	end
	
	return ast
end
