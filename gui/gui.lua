local base = _G

module(..., package.clean)

local mainWindow
local actions
local menu
local toolbar
local desktopSize

local central
local errlog
view = nil

local function createMenus()
	local menubar = QMenuBar.new()

	local file = QMenu.new(Q"File")
	file:addAction(actions["New"])
	file:addSeparator()
	file:addAction(actions["Load"])
	file:addAction(actions["Save"])
	file:addSeparator()
	file:addAction(actions["Import"])
	file:addAction(actions["Export"])
	file:addSeparator()
	file:addAction(actions["Quit"])

	local edit = QMenu.new(Q"Edit")
	edit:addAction(actions["Back"])
	edit:addSeparator()
	edit:addAction(actions["Delete"])

	local tools = QMenu.new(Q"Tools")
	tools:addAction(actions["Reload"])
	tools:addAction(actions["Layout"])
	tools:addAction(actions["Execute"])

	local help = QMenu.new(Q"Help")

	menubar:addMenu(file)
	menubar:addMenu(edit)
	menubar:addMenu(tools)
	menubar:addMenu(help)

	mainWindow:setMenuBar(menubar)
end


local function createActions()
	actions = {}

	local function makeAction(name, func)
		local icon = QIcon.new(Q("gui/icons/"..name..".png"))
		local action = QAction.new(icon, Q(name), mainWindow)
		local aname = 'action'..name..'()'
		mainWindow:__addmethod(aname, function()
			-- log('Action: %s', name)
			local ok, err = xpcall(func, debug.traceback)
			if not ok then
				fatal("error in action handler for '%s': %s", name, tostring(err))
			end
		end)
		action:connect('2triggered()', mainWindow, '1'..aname)
		actions[name] = action
	end

	makeAction("New", function()
		TODO "New - create new graph"
		view:clear()
		local g = Graph()
		base.language.initialize(g)
		view:reload(g)
	end)

	makeAction("Load", function()
		view:clear()
		local g = Graph()
		TODO "Load - file select dialog"
		g:load('graph.graphml')
		view:reload(g)
	end)

	makeAction("Save", function()
		TODO "Save - file select dialog"
		g:save('graph.graphml')
	end)
	
	makeAction("Import", function()
		view:clear()
		local g = base.language.import(view.graph)
		view:reload(g)
	end)
	
	makeAction("Export", function()
		base.language.export(view.graph)
	end)
	
	makeAction("Quit", function()
		app.exit()
	end)

	makeAction("Layout", function()
		view:fullLayout()
	end)
	
	makeAction("Back", function()
		view:back()
	end)
	
	makeAction("Execute", function()
		base.language.execute(view.graph)
	end)

	makeAction("Delete", function()
		view:startDeleting()
	end)
	
	makeAction("Reload", function()
		base.language.reload(view.graph)
	end)
end

local function createWindow()
	mainWindow = QMainWindow.new()
	mainWindow:setWindowTitle(Q"Villie2")
	mainWindow:setMinimumSize(640, 480)
	mainWindow:move(0, 0)

	central = QSplitter.new('Vertical', mainWindow)

	mainWindow:setCentralWidget(central)
	mainWindow:setWindowState({'WindowMaximized'})
	mainWindow:show()
end

local function createToolbar()
	local toolbar = QToolBar.new(mainWindow)
	toolbar:addAction(actions['New'])
	toolbar:addAction(actions['Load'])
	toolbar:addAction(actions['Save'])
	toolbar:addSeparator()
	toolbar:addAction(actions['Import'])
	toolbar:addAction(actions['Export'])
	toolbar:addSeparator()
	toolbar:addAction(actions['Layout'])
	toolbar:addAction(actions['Reload'])
	toolbar:addAction(actions['Back'])
	toolbar:addAction(actions['Execute'])
	
	toolbar:addAction(actions['Delete'])

	if base.language.toolbar then base.language.toolbar(mainWindow) end

	mainWindow:addToolBar(toolbar)
end

local function createScene()
	view = View(mainWindow)
	function mainWindow:keyPressEvent(e)
		if e:key() == 32 then
			view.layouter:stop()
		end
	end
	central:addWidget(view.widget)
end

local function createLog()
	errlog = QTextEdit.new()
	errlog:setReadOnly(true)

	local font = QFont.new_local(Q"DejaVu Sans Mono", 8)
	errlog:setFont(font)
	errlog:setLineWrapMode('NoWrap')
	errlog:setTabStopWidth(20)
	errlog:setMaximumHeight(150)
	central:addWidget(errlog)

	-- setup a new logger
	local colors = {
		DEBUG = QColor.new_local(Q'blue'),
		INFO  = QColor.new_local(Q'green'),
		WARN  = QColor.new_local(Q'orange'),
		ERROR = QColor.new_local(Q'red'),
		FATAL = QColor.new_local(Q'red'),
	}
	base.setlogger(function(self, level, message)
		local s = logging.prepareLogMsg('[%level] %message', os.date(), level, message)
		io.stderr:write(s, '\n')
		local oldcol = errlog:textColor()
		errlog:setTextColor(colors[level])
		errlog:append(Q(s))
		errlog:setTextColor(oldcol)
		return true
	end)
end

function updateScene()
	view.scene:update()
end

function run(...)
	local desktop = app.desktop()
	desktopSize = desktop:availableGeometry()

	createWindow()
	createActions()
	createMenus()
	createToolbar()

	createScene()
	createLog()
	
	actions.New:trigger()
	
	--[[
	view:clear()
	local g = base.language.import(scene.graph)
	view:reload(g)
	]]
end
