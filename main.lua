package.path = './?.lua;./?/?.lua;./lang/?/?.lua;'..package.path

-- lqt
require 'qtcore'
require 'qtgui'
require 'qtxml'

-- utility library
require 'util'

-- MVC
require 'model'
require 'view'
require 'gui'

language = require('vlua')

DEBUG = true

app = QApplication.new(1 + select('#', ...), {arg[0], ...})

gui.run(...)

app.exec()
