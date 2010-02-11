module(..., package.clean, package.strict)

local mainWindow
local actions
local menu
local toolbar

local function createMenus()
	local menu = QMenuBar.new()
	menu:addAction(Q"Ahojky!")
	mainWindow:setMenuBar(menu)
end

local function createActions()

end

local function createWindow()
	mainWindow = QMainWindow.new()
	mainWindow:setWindowTitle(Q"Villie")
	mainWindow:show()
end

local function createToolbar()

end

function run(...)
	createWindow()
	createActions()
	createMenus()
	createToolbar()
end
