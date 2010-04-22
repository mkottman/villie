module("vlua", package.seeall)

package.path = './lang/vlua/?.lua;./lang/vlua/ast/?.lua;' .. package.path

require 'ast'
require 'visual'
require 'translator'

assert(Vector, 'vector class not loaded')
local function V(t)
	t.x, t.y = t[1], t[2]
	t[1], t[2] = nil, nil
	return setmetatable(t, Vector)
end

local vlua_types = {
	nodes = {
		Number = { color = "red" };
		String = { color = "yellow" };
		Boolean = { color = "blue" };
		True = { color = "blue" };
		False = { color = "blue" };
		Id = { color = "green" };
		Nil = { color = "white" };
		Dots = { color = "purple" };
		Expression = { color = "orange" };
		
		Info = { color = "white" };
		Exp = { color = "black" };
		Stat = { color = "white" };
	};
	edges = {
		Function = { color = "blue", icon = "lang/vlua/icons/function.png" };
		Funcdef = { color = "plum", icon = "lang/vlua/icons/function.png" };

		If = { color = "skyblue" };
		Fornum = { color = "yellow", icon = "lang/vlua/icons/loop.png" };
		Forin = { color = "orange", icon = "lang/vlua/icons/loop.png" };
		While = { color = "brown", icon = "lang/vlua/icons/loop.png" };
		Repeat = { color = "brown", icon = "lang/vlua/icons/loop.png" };

		Set = { color = "white", icon = "lang/vlua/icons/assign.gif" };
		Local = { color = "wheat", icon = "lang/vlua/icons/assign.gif" };

		Return = { color = "lightgray", icon = "lang/vlua/icons/return.png" };
		Break = { color = "gray", icon = "lang/vlua/icons/break.png" };
		
		Call = { color = "lightblue" };
		Invoke = { color = "blue" };

		Block = { color = "white" };		
		Locals = { color = "cyan" };
		Ref = { color = "cyan" };
		Unknown = { color = "red" }; -- placeholder
	};
}

function initialize(graph)
	graph:registerTypes(vlua_types)
end


function import(graph)
--	local name = QFileDialog.getOpenFileName(nil, Q"Select Lua source",  Q".", Q"Lua source (*.lua)")
	local name = Q("test.lua")
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
	local src = ast.decompile(translator.toAst(graph))
	log(STR, 'Source', src)
end

local function remove(view, block)
	local done = {}
	local function rec(item, first)
		if done[item] then return end
		done[item] = true
		for inc,e in pairs(item.nodes or item.edges) do
			if first and inc.name == "do" then
			else
				rec(e)
			end
		end
		view:removeItem(item)
	end
	rec(block, true)
end

function toggle(view, item)
	if item.nodes and item.nodes["body"] then
		local block = item.nodes["body"].edges["do"]
		assert(block.type.name == "Block")
		if item.expanded then
			remove(view, block)
		else
			view:addItem(block)
			view:connect(item, block)
			view.attract[item] = true
			view.attract[block] = true
			local pos = item.visual.item:pos()
			local x, y = pos:x(), pos:y()
			block.visual.item:setPos(x + 200, y)
		end
		item.expanded = not item.expanded
	elseif item.type.name == "Funcdef" then
		doLater(function()
			view:display(item.func)
		end)
	elseif item.type.name == "Expression" then
		local value = item.value
		local res = QInputDialog.getText(view.view, Q"Enter expression", Q"Expression", 'Normal', Q(value))
		local lres = S(res)
		if lres ~= value then
			local a, err = pcall(ast.compile, lres, true)
			if not a then fatal("Not a valid expression: %s", err)
			else
				item.value = lres
				item.visual.item:setText(res)
			end
		end
	end
end

function execute(graph)
	TODO "Graph execution"
end


return _M
