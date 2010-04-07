local base = _G

module(..., package.clean, package.strict)

local mainWindow
local actions
local menu
local toolbar
local desktopSize

local central
local errlog
local scene

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

	local layout = QMenu.new(Q"Layout")
	layout:addAction(actions["Layout"])

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
	end)

	makeAction("Load", function()
		scene:clear()
		local g = Graph()
		TODO "Load - file select dialog"
		g:load('graph.graphml')
		scene:reload(g)
	end)

	makeAction("Save", function()
		TODO "Save - file select dialog"
		g:save('graph.graphml')
	end)
	
	makeAction("Import", function()
		scene:clear()
		local g = base.language.import(scene.graph)
		scene:reload(g)
	end)
	
	makeAction("Export", function()
		base.language.export(scene.graph)
	end)
	
	makeAction("Quit", function()
		app.exit()
	end)

	makeAction("Layout", function()
		scene:fullLayout()
	end)
end

local function createWindow()
	mainWindow = QMainWindow.new()
	mainWindow:setWindowTitle(Q"Villie")
	mainWindow:setMinimumSize(640, 480)
	mainWindow:resize(800,desktopSize:height())
	mainWindow:move(0, 0)

	central = QSplitter.new('Horizontal', mainWindow)

	mainWindow:setCentralWidget(central)
	--mainWindow:setWindowState({'WindowMaximized'})
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

	mainWindow:addToolBar(toolbar)
end

local function createScene()
	scene = View(mainWindow)
	function mainWindow:keyPressEvent(e)
		if e:key() == 32 then
			scene.layouter:stop()
		end
	end
	central:addWidget(scene.view)
end

local function createLog()
	errlog = QTextEdit.new()
	errlog:setReadOnly(true)

	local font = QFont.new_local(Q"DejaVu Sans Mono", 8)
	errlog:setFont(font)
	errlog:setLineWrapMode('NoWrap')
	errlog:setTabStopWidth(20)
	--errlog:setWindowFlags({'Tool', 'WindowStaysOnTopHint'})
	errlog:show()
	errlog:raise()
	
	errlog:resize(desktopSize:width() - 800, desktopSize:height())
	
	local p = mainWindow:pos()
	p:setX(p:x() + mainWindow:width())
	errlog:move(p:x(), p:y())
	--central:addWidget(errlog)

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
		local oldcol = errlog:textColor()
		errlog:setTextColor(colors[level])
		errlog:append(Q(s))
		errlog:setTextColor(oldcol)
		return true
	end)
end

function selectLanguage()
--[[
	local dir = QDir.new_local(Q"lang")
	local langs = dir:entryList({'Dirs','NoDotAndDotDot'})
	
	local dlg = QDialog.new_local()
	dlg:setWindowTitle(Q"Select language")
	
	local combo = QComboBox.new_local()
	combo:addItems(langs)
	
	local ok = QPushButton.new_local(Q"Ok")
	ok:connect('2pressed()', dlg, '1accept()')
	
	local layout = QHBoxLayout.new_local()
	layout:addWidget(combo)
	layout:addWidget(ok)
	dlg:setLayout(layout)
	
	if dlg:exec() then
		local sel = S(combo:currentText())
		base.language = require(sel)
	end
]]
	base.language = require('vlua')
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
end
