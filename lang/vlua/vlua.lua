module("vlua", package.seeall)

package.path = './lang/vlua/ast/?.lua;' .. package.path

require 'ast'

local vlua_types = {
	nodes = {
		Number = { color = "red" };
		String = { color = "yellow" };
		Boolean = { color = "blue" };
		Id = { color = "green" };
		Nil = { color = "white" };
		Dots = { color = "purple" };
	};
	egdes = {
		
	};
}

function initialize(graph)
	graph:registerTypes(vlua_types)
end

local function translate(ast, graph)
	local function process(t)
		local tag = t.tag
		if tag == "Number" then
			local n = graph:createNode(t)
		end
	end
end

function import(graph)
	local name = QFileDialog.getOpenFileName(nil, Q"Select Lua source", 
		Q".", Q"Lua source (*.lua)")
	if not name:isEmpty() then
		graph = Graph()
		local ast = ast.compile(io.open(S(name)))
		graph.ast = ast
		--translate(ast, graph)
		log(repr(ast, 'ast'))
	end
	return graph
end

function export(graph)
	local src = ast.decompile(graph.ast)
	log(STR, 'Source', src)
end


return _M
