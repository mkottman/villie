TEMPLATE = app
TARGET = villie
CONFIG -= release
CONFIG += debug
win32:INCLUDEPATH += C:\lua\include
unix:INCLUDEPATH += /usr/include/lua5.1/
QT += core \
    webkit \
    gui \
    xml
HEADERS += gui/main_window.h \
    model/common.h \
    model/edge.h \
    model/graph.h \
    model/node.h \
    model/element.h \
    model/incidence.h \
    gui/velement.h \
    gui/vnode.h \
    gui/vedge.h \
    gui/vector.h \
    gui/layouter.h \
    gui/graphscene.h \
    gui/graphview.h \
    gui/connector.h \
    exec/executor.h \
    model/lunar.h \
    model/edgetype.h \
    gui/configwindow.h
SOURCES += gui/main_window.cpp \
    model/edge.cpp \
    model/graph.cpp \
    model/node.cpp \
    model/element.cpp \
    model/incidence.cpp \
    main.cpp \
    gui/velement.cpp \
    gui/vnode.cpp \
    gui/vedge.cpp \
    gui/vector.cpp \
    gui/layouter.cpp \
    gui/graphscene.cpp \
    gui/graphview.cpp \
    gui/connector.cpp \
    exec/executor.cpp \
    model/edgetype.cpp \
    gui/configwindow.cpp
FORMS += gui/main_window.ui
RESOURCES += 
LIBS += -llua5.1 \
    -lqscintilla2
UI_DIR = gui/
MOC_DIR = moc/
OBJECTS_DIR = build/
