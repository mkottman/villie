-- setup package path to include 'init.lua'
package.path = './?.lua;./?/?.lua;./lang/?/?.lua;'..package.path

-- lqt
require 'qtcore'
require 'qtgui'
require 'qtxml'

-- utility libraries
require 'pl'
require 'util'

-- MVC
require 'model'
require 'view'
require 'gui'

DEBUG=1

app = QApplication.new(1 + select('#', ...), {arg[0], ...})

gui.selectLanguage()

gui.run(...)

app.exec()
