module("vlua", package.seeall)

package.path = './lang/vlua/?.lua;./lang/vlua/ast/?.lua;' .. package.path

require 'ast'
require 'visual'
require 'translator'

local vlua_types = {
	nodes = {
		Number = { color = "red" };
		String = { color = "yellow" };
		Boolean = { color = "blue" };
		Id = { color = "green" };
		Nil = { color = "white" };
		Dots = { color = "purple" };
		
		Exp = { color = "black" };
		Stat = { color = "white" };
	};
	edges = {
		Index = { color = "white" };
		Function = { color = "blue" };
		Op = { color = "green" };
		
		Block = { color = "green" };
		Call = { color = "white" };
		Set = { color = "white" };
		
		Place = { color = "red" }; -- placeholder
	};
}

function initialize(graph)
	graph:registerTypes(vlua_types)
end


function import(graph)
--	local name = QFileDialog.getOpenFileName(nil, Q"Select Lua source",  Q".", Q"Lua source (*.lua)")
	local name = Q("main.lua")
	if not name:isEmpty() then
		graph = Graph()
		initialize(graph)
		local ast = ast.compile(io.open(S(name)))
		graph.ast = ast
		vlua.translator.translate(ast, graph)
		graph:dump()
	end
	return graph
end

function canConnect()

end

function export(graph)
	local src = ast.decompile(graph.ast)
	log(STR, 'Source', src)
end


return _M
