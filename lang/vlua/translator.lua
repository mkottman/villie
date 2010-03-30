module('vlua.translator', package.seeall)

function translate(ast, graph)
	local processBlock, processExpression, processStatement

	function processStatement(s)
		local tag = s.tag
		if not tag then error(STR("Error in processing statement", repr(s))) end
		
		local edge
		if tag == "Set" then
			edge = graph:createEdge("Set")
			if #s[1] > 1 or #s[2] > 1 then
				fatal("Unhandled multiple assignment")
			else
				local lhs = processExpression(s[1][1])
				local rhs = processExpression(s[2][1])
				graph:connect(lhs, edge, "to", "out")
				graph:connect(rhs, edge, "value", "in")
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
		elseif tag == "Index" then
			local table = processExpression(e[1])
			local key = processExpression(e[2])
			local index = graph:createEdge("Index")
			local res = graph:createNode("Exp")
			graph:connect(table, index, "table", "in")
			graph:connect(key, index, "key", "in")
			graph:connect(res, index, "result", "out")
			return res
		elseif tag == "Function" then
			local func = graph:createEdge("Function")
			local res = graph:createNode("Exp")
			local body = processBlock(e[2])
			graph:connect(res, func, "result", "out")
			graph:connect(body, func, "body", "in")
			return res
		elseif tag == "Call" then
			local call = graph:createEdge("Call")
			local func = processExpression(e[1])
			local res = graph:createNode("Exp")
			graph:connect(func, call, "function", "in")
			for i=2,#e do
				local arg = processExpression(e[i])
				graph:connect(arg, call, "arg"..(i-1), "in")
			end
			graph:connect(res, call, "result", "out")
			return res
		elseif tag == "Op" then
			local op = graph:createEdge("Op")
			op.op = e[1]
			local res = graph:createNode("Exp")
			TODO "zvysok operacie"
			graph:connect(res, op, "result", "out")
			return res
		elseif tag == "" then
		else
			fatal("Unhandled expression %s", tag)
			return graph:createNode("Exp")
		end
	end 

	function processBlock(b)
		local ndo = graph:createNode("Stat")
		local block = graph:createEdge("Block")
		for i=1, #b do
			local s = processStatement(b[i])
			graph:connect(s, block, tostring(i), "out")
		end
		graph:connect(ndo, block, "do", "in")
		return ndo
	end

	processBlock(ast)
end
