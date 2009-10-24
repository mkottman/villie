TEMPLATE = app
TARGET = villie
QT += core \
    webkit \
    gui
HEADERS += gui/grapheditorpanel.h \
    gui/main_window.h \
    core/common.h \
    core/Edge.h \
    core/Graph.h \
    core/Node.h \
    gui/velement.h \
    gui/vnode.h \
    core/element.h \
    gui/vedge.h
SOURCES += gui/grapheditorpanel.cpp \
    gui/main_window.cpp \
    core/Edge.cpp \
    core/Graph.cpp \
    core/Node.cpp \
    main.cpp \
    gui/velement.cpp \
    gui/vnode.cpp \
    core/element.cpp \
    gui/vedge.cpp
FORMS += gui/grapheditorpanel.ui \
    gui/main_window.ui
RESOURCES += 
UI_DIR = gui/
