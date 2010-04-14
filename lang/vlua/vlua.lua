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

		Exp = { color = "black" };
		Stat = { color = "white" };
	};
	edges = {
		Index = { color = "white" };
		Function = { color = "blue" };
		If = {
			color = "skyblue";
			meta = {
				["do"] = V{-20, 0};
				body = V{20, 20};
				condition = V{20, -20};
			}
		};
		Fornum = { color = "yellow" };
		Forin = { color = "orange" };
		While = {
			color = "brown";
			meta = {
				["do"] = V{-20, 0};
				body = V{20, 20};
				condition = V{20, -20};
			}
		};
		Repeat = { color = "brown" };

		Op = { color = "green" };
		Local = { color = "wheat" };
		Return = { color = "lightgray", icon = "lang/vlua/icons/return.png" };
		Break = { color = "gray" };
		
		Block = { color = "green" };
		Call = { color = "lightblue" };
		Invoke = { color = "blue" };
		Set = { color = "white", icon = "lang/vlua/icons/assign.gif" };
		
		Unknown = { color = "red" }; -- placeholder
	};
}

function initialize(graph)
	graph:registerTypes(vlua_types)
end


function import(graph)
--	local name = QFileDialog.getOpenFileName(nil, Q"Select Lua source",  Q".", Q"Lua source (*.lua)")
	local name = Q("model/graph.lua")
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



return _M
