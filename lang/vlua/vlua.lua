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
		Repeat = { color = "brown", icon = "lang/vlua/icons/loop.png", iconRight = true };

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
	end
	return graph
end

function export(graph)
	local a = translator.toAst(graph)
	local src = ast.decompile(a)
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

function edit(view, edge)
	if edge:is_a(Edge) then
		if edge.type.name ~= "Block" then
			local expressions = List()
			for inc, node in pairs(edge.nodes) do
				if node.type.name == "Expression" then
					expressions:append { name = inc.name, node = node }
				end
			end
			if #expressions > 0 then
				table.sort(expressions, function(a,b) return a.name < b.name end)

				local dialog = QDialog.new_local()
				
				local form = QFormLayout.new(dialog)
				for _,item in ipairs(expressions) do
					local edit = QLineEdit.new(Q(item.node.value), dialog)
					item.edit = edit
					form:addRow(Q(item.name), edit)
				end
				
				local w = QWidget.new(dialog)
				w:setLayout(form)
				
				local boxes = QHBoxLayout.new(dialog)
				local ok = QPushButton.new(Q"Change", dialog)
				local cancel = QPushButton.new(Q"Cancel", dialog)
				ok:connect('2pressed()', dialog, '1accept()')
				cancel:connect('2pressed()', dialog, '1reject()')
				boxes:addWidget(ok)
				boxes:addWidget(cancel)
				local w2 = QWidget.new(dialog)
				w2:setLayout(boxes)

				local layout = QVBoxLayout.new(dialog)
				layout:addWidget(w)
				layout:addWidget(w2)
				dialog:setLayout(layout)
				
				local done = false
				dialog:__addmethod('changeValues()', function()
					if done then return end
					for _,item in ipairs(expressions) do
						local value = S(item.edit:text())
						if value ~= item.node.value then
							local ok, err = pcall(ast.compile, value, true)
							trace(STR, ok, repr(err, "err"), value)
							if ok then
								item.node.value = value
								if edge.update then edge:update() end
								edge.visual.item:update()
							else
								QMessageBox.critical(dialog, Q"Syntax error", Q(err))
							end
						end
					end
					done = true
				end)
				dialog:connect('2accepted()', dialog, '1changeValues()')
				dialog:exec()
				
				return true
			end
		end
	end
end

function execute(graph)
	graph:dump()
	TODO "Graph execution"
end


return _M
