module("vlua", package.seeall)

package.path = './lang/vlua/?.lua;./lang/vlua/ast/?.lua;' .. package.path

require 'ast'
require 'visual'
require 'translator'

local function loadTypes()
	local func, err = loadfile("lang/vlua/types.lua")
	if not func then fatal("Error while loading types: %s", err)
	else
		local ok, res = pcall(func)
		if not ok then fatal("Error while loading types: %s", res)
		else
			return res
		end
	end
end

vlua_types = loadTypes()

--- Reloads visual type definitions from file lang/vlua/types.lua.
function reload(graph)
	vlua_types = loadTypes()
	graph:registerTypes(vlua_types)
	gui.updateScene()
end

--- Initiatizes the graph by registering visual types and creating main program block.
function initialize(graph)
	reload(graph)
	local main = graph:createEdge("Block")
	main.title = 'Main program'
	graph.elements.__Main = main
end

--- Imports the graph from Lua. When a file is chosen, it's source is translated to graph representation.
function import(graph)
	local name = QFileDialog.getOpenFileName(nil, Q"Select Lua source",  Q".", Q"Lua source (*.lua)")
	if not name:isEmpty() then
		graph = Graph()
		initialize(graph)
		local ast = ast.compile(io.open(S(name)))
		if DEBUG then io.open('ast.txt', 'w'):write(repr(ast, 'ast', {maxlevel=999})) end
		vlua.translator.fromAst(ast, graph)
	end
	return graph
end

--- Exports the graph as Lua. When a file is chosen, the graph representation is translated to Lua source.
function export(graph)
	local name = QFileDialog.getSaveFileName(nil, Q"Select output file",  Q".", Q"Lua source (*.lua)")
	if not name:isEmpty() then
		local a = translator.toAst(graph)
		local src = ast.decompile(a)
		local f = assert(io.open(S(name), 'w'))
		f:write(src)
		f:close()
	end
end

-- recursively removes connected items and blocks from view
local function remove(view, block)
	local done = {}
	local function rec(item, first)
		if done[item] then return end
		done[item] = true
		for inc,e in pairs(item.nodes or item.edges) do
			if (first and (inc.name == "do" or inc.name =="info")) or inc.name == "references" then
			else
				rec(e)
			end
		end
		if item.visual then
			view:removeItem(item)
		end
	end
	rec(block, true)
end

-- finds the block in which the item resides
local function edgeParent(item)
	local d = item.nodes["do"]
	if not d then return end
	for inc, edge in pairs(d.edges) do
		if inc.name ~= "do" and inc.name ~= "next" then
			assert(edge.type.name == "Block", tostring(edge).." is not a block!")
			return edge, inc.name
		end
	end
end

-- finds the previous edge in block
local function previousEdge(edge, block)
	if block.count == 0 then return end
	local prev = block.nodes["1"].edges["do"]
	if prev == edge then return end
	local curr
	for i=2, block.count do
		curr = block.nodes[tostring(i)].edges["do"]
		if curr == edge then
			return prev
		end
		prev = curr
	end
end

--- Handle doubleclick of an item. If the clicked item has child blocks, they are shown/hidden.
-- @param view Current view.
-- @param item Doubleclicked item.
function toggle(view, item)
	trace(STR, "Toggle", item)
	if item.type.name == "Funcdef" then
		local name = item.nodes['name'].value
		local func = view.graph.elements[name]
		doLater(function()
			trace(STR, 'Opening function', func)
			view:display(func)
		end)
	elseif item.type.name ~= "Block" and item.nodes then
		local blocks = List()
		local parent = edgeParent(item) or item

		for inc, node in pairs(item.nodes) do
			local ndo = node.edges["do"]
			if ndo and ndo ~= item and ndo ~= parent and ndo.type.name == "Block" then
				blocks:append(ndo)
				ndo.inc = inc.name
			end
		end

		table.sort(blocks, function(a,b)
			return a.inc < b.inc
		end)

		local lastBlock
		for i,block in ipairs(blocks) do
			if item.expanded then
				remove(view, block)
			else
				view:addItem(block)
				block.visual.item:setZValue(item.visual.item:zValue() + 3)
				view:connect(item, block)
				view:connectLayoutItems(parent, block)
				if lastBlock then
					view:connectLayoutItems(lastBlock, block)
				end
				lastBlock = block
				local pos = item.visual.item:pos()
				local x, y = pos:x(), pos:y()
				block.visual.item:setPos(x + 300, y + 40*i)
			end
		end

		item.expanded = not item.expanded
	end
end

local function hasArguments(e)
	return e.type.name == "Call"
		or e.type.name == "Invoke"
		or e.type.name == "Function"
end

function edit(edge)
	local graph = gui.view.graph
	
	if edge:is_a(Edge) then
		if edge.type.name ~= "Block" then
			local expressions = List()
			local hasArgs = hasArguments(edge)
			
			-- collect existing nodes and values
			for inc, node in pairs(edge.nodes) do
				if node.type.name == "Expression" then
					expressions:append { name = inc.name, value = node.value,
						oldvalue = node.oldvalue}
				end
			end
			
			-- remove nodes from graph (will be reconstructed later)
			for exp in expressions:iter() do
				graph:disconnect(edge.nodes[exp.name], edge)
			end
			
			-- create dummy arguments up to arg9
			if hasArgs then
				for i=edge.count+1,9 do
					expressions:append { name = "arg"..i, value = '' }
				end
			end
			if #expressions > 0 then
				table.sort(expressions, function(a,b) return a.name < b.name end)

				local dialog = QDialog.new_local()
				dialog:setWindowTitle(Q"Edit values")
				dialog:setMinimumWidth(450)
				
				local form = QFormLayout.new(dialog)
				for _,item in ipairs(expressions) do
					local edit = QLineEdit.new(Q(item.value), dialog)
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
				
				-- function that will recreate the nodes with previous values if save==false,
				-- or new values if save==true
				local function update(save)
					if done then return end
					local shouldSave = true
					for _,item in ipairs(expressions) do
						local value = item.value
						if save then
							local newValue = S(item.edit:text())
							if newValue ~= value then
								local ok, err = pcall(ast.compile, newValue, true)
								if not ok then
									QMessageBox.critical(dialog, Q"Syntax error", Q(err))
								end
								value = newValue
							end
						end
						-- special handling of argN parameters
						if hasArgs and item.name:match("^arg%d+$") then
							-- stop saving at first empty argument
							if shouldSave and value == "" then
								edge.count = tonumber(item.name:match("^arg(%d+)$")) - 1
								shouldSave = false
							elseif shouldSave then
								local node = graph:createNode("Expression")
								node.value = value
								graph:connect(node, edge, item.name, "in")
							end
						else
							local node = graph:createNode("Expression")
							node.value = value
							node.oldvalue = item.oldvalue
							graph:connect(node, edge, item.name, "in")
						end
					end
					if edge.update then edge:update() end
					edge.visual.item:update()
					done = true
				end
				
				dialog:__addmethod('saveValues()', function() update(true) end)
				dialog:__addmethod('cancelChanges()', function () update(false) end)
				dialog:connect('2accepted()', dialog, '1saveValues()')
				dialog:connect('2rejected()', dialog, '1cancelChanges()')
				dialog:exec()
				
				if edge.update then edge:update() end
				
				return true
			end
		end
	end
end


--- Delete an item. Removes the operation <code>item</code> from it's parent block.
-- @param graph Current graph.
-- @param view Current view.
-- @param item Edge, which should be deleted.
function delete(graph, view, item)
	if item.type.name ~= "Block" then
		if item.expanded then toggle(view, item) end
		
		local ndo = item.nodes["do"]
		local block, order = edgeParent(item)
		local prev = previousEdge(item, block)
		local nxt = item.nodes["next"]
		trace(STR, item, block, order, prev, nxt)

		if prev then
			-- disconnect from previous
			graph:disconnect(ndo, prev)
			if nxt then
				-- connect previous to next
				graph:connect(nxt, prev, "next", "out")
			end
		end

		-- disconnect activator
		graph:disconnect(ndo, item)
		graph:disconnect(ndo, block)
		graph:removeNode(ndo)

		if nxt then
			-- disconnect item from next
			graph:disconnect(nxt, item)
		end

		view:removeItem(item)
		graph:removeEdge(item)

		-- reorder the operations
		order = assert(tonumber(order), "order nonnumeric: " .. order)
		for i=order+1, block.count do
			local inc = block.nodes['@'..i]
			inc.name = tostring(i-1)
		end
		block.count = block.count - 1
		block:update()
		view.scene:update()
	end
	return true
end

--- Executes the graph. Converts the graph to Lua source and executes it.
-- @param graph Graph to be executed
function execute(graph)
	local a = translator.toAst(graph)
	local src = ast.decompile(a)
	
	local dialog = QDialog.new_local()
	dialog:setWindowTitle(Q"Execution")
	
	local font = QFont.new_local(Q'Courier New', 10)
	
	local layout = QVBoxLayout.new_local()
	
	local sp = QSplitter.new_local()
	local srct = QTextEdit.new_local()
	local text = QTextEdit.new_local()
	
	srct:setPlainText(Q(src))
	srct:setFont(font)
	text:setFont(font)
	
	sp:addWidget(srct)
	sp:addWidget(text)

	local w = QWidget.new_local()
	local l2 = QHBoxLayout.new_local()
	local exec = QPushButton.new_local(Q"Execute")
	dialog:__addmethod('do()', function()
		-- prepare a custom print function
		local env = {}
		function env.print(...)
			local n = select('#', ...)
			local a = {...}
			for i=1,n do
				a[i] = tostring(a[i])
			end
			text:append(Q(table.concat(a, '\t') .. '\n'))
		end
		env.keys = pairs
		-- setup environment
		setmetatable(env, {__index = _G})
		local src = S(srct:toPlainText())
		
		trace("Executing: %s", src)
		
		local f, err = loadstring(src, 'main')
		if not f then 
			QMessageBox.critical(dialog, Q"Parse error", Q(err))
		else
			setfenv(f, env)
			local ok, err = pcall(f)
			if not ok then
				QMessageBox.critical(dialog, Q"Runtime error", Q(err))
			end
		end
	end)
	exec:connect('2pressed()', dialog, '1do()')
	
	local close = QPushButton.new_local(Q"Close")
	close:connect('2pressed()', dialog, '1accept()')
	
	l2:addWidget(exec)
	l2:addWidget(close)
	w:setLayout(l2)
	
	layout:addWidget(sp)
	layout:addWidget(w)
	
	dialog:setLayout(layout)
	dialog:exec()
end

--- Creates an item in a block.
-- @param type Type of item to be created
-- @param block Block, in which it will be created
-- @param pos Position (0-based) in which the operation will be placed
function create(type, block, pos)
	local graph = gui.view.graph
	vlua.isCreating = false
	
	-- change the order of all operations following pos
	for i=pos+1, block.count do
		local inc = block.nodes['@'..i]
		inc.name = tostring(i+1)
	end
	block.count = block.count + 1
	
	-- create the operation in graph
	local edge = graph:createEdge(type)
	local ndo = graph:createNode("Stat")
	graph:connect(ndo, edge, "do", "in")
	graph:connect(ndo, block, tostring(pos+1), "out")
	
	block:update()
	
	local edgePos = edge.visual.item:pos()
	local x, y = edgePos:x(), edgePos:y()
	
	local needEdit = false
	-- add prototype incidences
	local proto = vlua_types.edges[type].proto
	if proto then
		for _,key in pairs(proto) do
			local typ = key:sub(1,1)
			local name = key:sub(2)
			trace(STR, "Incidence", typ, name)
			
			if typ == "B" then
				local ndo2 = graph:createNode("Stat")
				local newBlock = graph:createEdge("Block")
				graph:connect(ndo2, newBlock, "do", "in")
				graph:connect(ndo2, edge, name, "out")

				newBlock.count = 0
				gui.view:addItem(newBlock)
				newBlock.visual.item:setZValue(edge.visual.item:zValue() + 3)
				newBlock.visual.item:setPos(x + 200, y)

				gui.view:connect(edge, newBlock)
				gui.view:connectLayoutItems(block, newBlock)
				
				edge.expanded = true
			elseif typ == "I" or typ == "O" then
				local node = graph:createNode("Expression")
				node.value = '?'
				local dir = typ == "I" and "in" or "out"
				graph:connect(node, edge, name, dir)
				needEdit = true
			else
				warn("Bad prototype incidence (key %s) for %s; %s not one of B, I, O",
					key, type, typ)
			end
		end
	end
	
	-- funcdef is a special case - also add new function element
	if type == "Funcdef" then
		local func = graph:createEdge("Function")
		local body = graph:createEdge("Block")
		local ndo = graph:createNode("Stat")
		graph:connect(ndo, func, "body", "out")
		graph:connect(ndo, body, "do", "in")
		graph.elements["?"] = func
		func.count = 0
		body.count = 0
		func.funcdef = edge
		func.update = translator.updaters.Function
		edge.nodes.name.oldvalue = "?"
	end
	
	if translator.updaters[type] then
		edge.update = translator.updaters[type]
		edge:update()
	end
	
	if needEdit then
		edit(edge)
	end
end

--- Defines a custom toolbar for Vlua.
function toolbar(window)
	local toolbar = QToolBar.new(window)
	window:addToolBar('RightToolBarArea', toolbar)
	
	local function addAction(name, func)
		local action = QAction.new(Q(name), window)
		local aname = 'action'..name..'()'
		window:__addmethod(aname, function()
			local ok, err = xpcall(func, debug.traceback)
			if not ok then
				fatal("error in action handler for '%s': %s", name, tostring(err))
			end
		end)
		action:connect('2triggered()', window, '1'..aname)
		toolbar:addAction(action)
	end
	
	local ignore = {Ref = true, Locals = true, Unknown = true, Function = true, Block = true}
	for k in sortedpairs(vlua_types.edges) do
		if not ignore[k] then
			addAction(k, function() vlua.isCreating = k end)
		end
	end
end

return _M
