local AST = ast

module('vlua.translator', package.seeall)



function translate(ast, graph)
	local processBlock, processExpression, processStatement, handleFunctionDefinition

	function handleFunctionDefinition(s)
		if #s[2] == 1 and s[2][1].tag == "Function" then
			local func = graph:createEdge("Function")
			return true
		end
	end

	function processStatement(s)
		local tag = s.tag
		if not tag then error(STR("Error in processing statement", repr(s))) end

		local edge
		if tag == "Set" then
			if handleFunctionDefinition(graph, s) then
				return
			else
				edge = graph:createEdge("Set")
				if #s[1] > 1 or #s[2] > 1 then
					fatal("Unhandled multiple assignment")
				else
					local lhs = processExpression(s[1][1])
					local rhs = processExpression(s[2][1])
					graph:connect(lhs, edge, "to", "out")
					graph:connect(rhs, edge, "value", "in")
				end
			end
		elseif tag == "If" then
			edge = graph:createEdge("If")
			local cond = processExpression
		elseif tag == "Call" then
			edge = graph:createEdge("Call")
			local func = processExpression(s[1])
			graph:connect(func, edge, "function", "in")
			for i=2,#s do
				local arg = processExpression(s[i])
				graph:connect(arg, edge, "arg"..(i-1), "in")
			end
		else
			fatal("Unhandled statement %s", tag)
			edge = graph:createEdge("Place")
		end
		
		local ndo = graph:createNode("Stat")
		graph:connect(ndo, edge, "do", "in")
		return ndo
	end
	
	local simpleNode = {Number=true, String=true, Id=true, Dots="...", True="true", False="false", Nil="nil"}
	
	function processExpression(e)
		local tag = e.tag
		if not tag then error(STR("Error in processing expression", repr(e))) end
		if simpleNode[tag] then
			local n = graph:createNode(tag)
			n.value = type(simpleNode[tag]) == "string" and simpleNode[tag] or e[1]
			return n
		else
			local n = graph:createNode("Expression")
			n.value = AST.decompile(e)
			log(STR, e.tag, n.value)
			return n
		end
	end

	function processBlock(b)
		local ndo = graph:createNode("Stat")
		local block = graph:createEdge("Block")
		for i=1, #b do
			local s = processStatement(b[i])
			if s then
				graph:connect(s, block, tostring(i), "out")
			end
		end
		graph:connect(ndo, block, "do", "in")
		return ndo
	end

	graph.elements.Main = processBlock(ast)
end
