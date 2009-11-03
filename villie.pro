TEMPLATE = app
TARGET = villie
CONFIG -= release

debug {
DESTDIR = build/Debug
    message("Debug build...")
}

release {
DESTDIR = build/Release
    message("Release build...")
}

QT += core \
    webkit \
    gui
HEADERS += gui/main_window.h \
    core/common.h \
    core/edge.h \
    core/graph.h \
    core/node.h \
    core/element.h \
    core/incidence.h \
    gui/velement.h \
    gui/vnode.h \
    gui/vedge.h \
    gui/vector.h \
    gui/layouter.h \
    gui/graphscene.h \
    gui/graphview.h \
    gui/connector.h
SOURCES += gui/main_window.cpp \
    core/edge.cpp \
    core/graph.cpp \
    core/node.cpp \
    core/element.cpp \
    core/incidence.cpp \
    main.cpp \
    gui/velement.cpp \
    gui/vnode.cpp \
    gui/vedge.cpp \
    gui/vector.cpp \
    gui/layouter.cpp \
    gui/graphscene.cpp \
    gui/graphview.cpp \
    gui/connector.cpp
FORMS += gui/main_window.ui
RESOURCES +=
LIBS += -llua5.1 -lqscintilla2
UI_DIR = gui/
MOC_DIR = moc/
OBJECTS_DIR = build/
