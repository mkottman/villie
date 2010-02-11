-- setup package path to include 'init.lua'
package.path = './?/init.lua;'..package.path

-- lqt
require 'qtcore'
require 'qtgui'
require 'qtxml'

-- utility libraries
require 'util'
require 'pl'

-- model
require 'model'
require 'view'
require 'gui'

function log(...)
	print(string.format(...))
end

app = QApplication.new(1 + select('#', ...), {arg[0], ...})

gui.run(...)

app.exec()
