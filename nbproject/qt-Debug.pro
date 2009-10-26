TEMPLATE = app
DESTDIR = build/Debug
TARGET = villie
VERSION = 1.0.0
CONFIG -= debug_and_release app_bundle lib_bundle
CONFIG += debug 
QT = core gui
SOURCES += gui/vedge.cpp main.cpp core/edge.cpp gui/layouter.cpp gui/vector.cpp gui/connector.cpp core/node.cpp gui/vnode.cpp gui/velement.cpp core/graph.cpp gui/main_window.cpp core/element.cpp gui/graphscene.cpp gui/graphview.cpp
HEADERS += core/element.h gui/main_window.h core/edge.h gui/graphscene.h gui/velement.h core/common.h core/node.h gui/connector.h gui/layouter.h gui/vedge.h gui/vnode.h core/graph.h gui/vector.h gui/graphview.h
FORMS += gui/main_window.ui
RESOURCES +=
TRANSLATIONS +=
OBJECTS_DIR = build/Debug/GNU-Linux-x86
MOC_DIR = 
RCC_DIR = 
UI_DIR = 
QMAKE_CC = gcc
QMAKE_CXX = g++
DEFINES += __GNUC__ 
INCLUDEPATH += 
LIBS += 
