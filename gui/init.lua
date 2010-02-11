local base = _G

module(..., package.clean, package.strict)

local mainWindow
local actions
local menu
local toolbar

local central
local errlog
local sceneview
local scene

local function createMenus()
	local menubar = QMenuBar.new()

	local file = QMenu.new(Q"File")
	file:addAction(actions["New"])
	file:addSeparator()
	file:addAction(actions["Load"])
	file:addAction(actions["Save"])
	file:addSeparator()
	file:addAction(actions["Quit"])

	local edit = QMenu.new(Q"Edit")

	local layout = QMenu.new(Q"Layout")

	local tools = QMenu.new(Q"Tools")

	local help = QMenu.new(Q"Help")

	menubar:addMenu(file)
	menubar:addMenu(edit)
	menubar:addMenu(layout)
	menubar:addMenu(tools)
	menubar:addMenu(help)

	mainWindow:setMenuBar(menubar)
end


local function createActions()
	actions = {}

	local function makeAction(name, func)
		local action = QAction.new(Q(name), mainWindow)
		local aname = 'action'..name..'()'
		mainWindow:__addmethod(aname, function()
			-- log('Action: %s', name)
			local ok, err = xpcall(func, debug.traceback)
			if not ok then
				errlog:append(Q(string.format("error in action handler for '%s': %s", name, tostring(err))))
			end
		end)
		action:connect('2triggered()', mainWindow, '1'..aname)
		actions[name] = action
	end

	makeAction("New", function()
		TODO "New - create new graph"
	end)

	makeAction("Load", function()
		local g = Graph()
		TODO "Load - file select dialog"
		g:load('graph.graphml')
	end)

	makeAction("Save", function()
		TODO "Save - file select dialog"
		g:save('graph.graphml')
	end)

	makeAction("Quit", function()
		app.exit()
	end)
end

local function createWindow()
	mainWindow = QMainWindow.new()
	mainWindow:setWindowTitle(Q"Villie")
	mainWindow:setMinimumSize(640, 480)

	central = QSplitter.new('Horizontal', mainWindow)

	mainWindow:setCentralWidget(central)
	mainWindow:show()
end

local function createToolbar()

end

local function createScene()
	scene = QGraphicsScene.new(mainWindow)
	sceneview = QGraphicsView.new(scene)
	central:addWidget(sceneview)
end

local function createLog()
	errlog = QTextEdit.new(mainWindow)
	errlog:setReadOnly(true)

	local font = QFont.new_local(Q"DejaVu Sans Mono", 8)
	errlog:setFont(font)

	central:addWidget(errlog)

	-- overwrite the global 'log' function
	base.log = function(...)
		errlog:append(Q(string.format(...)))
	end
end

function run(...)
	createWindow()
	createActions()
	createMenus()
	createToolbar()

	createScene()
	createLog()
end
