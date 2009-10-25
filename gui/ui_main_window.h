/********************************************************************************
** Form generated from reading ui file 'main_window.ui'
**
** Created: Sun Oct 25 01:22:33 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_MAIN_WINDOW_H
#define UI_MAIN_WINDOW_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QMainWindow>
#include <QtGui/QMenu>
#include <QtGui/QMenuBar>
#include <QtGui/QStatusBar>
#include <QtGui/QToolBar>
#include <QtGui/QWidget>
#include "grapheditorpanel.h"

QT_BEGIN_NAMESPACE

class Ui_mainWindowClass
{
public:
    QAction *actionExit;
    QAction *actionUpdate;
    QWidget *centralwidget;
    QHBoxLayout *horizontalLayout;
    GraphEditorPanel *graphPanel;
    QMenuBar *menubar;
    QMenu *menuFile;
    QMenu *menuEdit;
    QMenu *menuTools;
    QMenu *menuHelp;
    QStatusBar *statusbar;
    QToolBar *toolBar;

    void setupUi(QMainWindow *mainWindowClass)
    {
        if (mainWindowClass->objectName().isEmpty())
            mainWindowClass->setObjectName(QString::fromUtf8("mainWindowClass"));
        mainWindowClass->resize(543, 537);
        actionExit = new QAction(mainWindowClass);
        actionExit->setObjectName(QString::fromUtf8("actionExit"));
        actionUpdate = new QAction(mainWindowClass);
        actionUpdate->setObjectName(QString::fromUtf8("actionUpdate"));
        centralwidget = new QWidget(mainWindowClass);
        centralwidget->setObjectName(QString::fromUtf8("centralwidget"));
        QSizePolicy sizePolicy(QSizePolicy::Maximum, QSizePolicy::Maximum);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(centralwidget->sizePolicy().hasHeightForWidth());
        centralwidget->setSizePolicy(sizePolicy);
        horizontalLayout = new QHBoxLayout(centralwidget);
        horizontalLayout->setObjectName(QString::fromUtf8("horizontalLayout"));
        graphPanel = new GraphEditorPanel(centralwidget);
        graphPanel->setObjectName(QString::fromUtf8("graphPanel"));

        horizontalLayout->addWidget(graphPanel);

        mainWindowClass->setCentralWidget(centralwidget);
        menubar = new QMenuBar(mainWindowClass);
        menubar->setObjectName(QString::fromUtf8("menubar"));
        menubar->setGeometry(QRect(0, 0, 543, 21));
        menuFile = new QMenu(menubar);
        menuFile->setObjectName(QString::fromUtf8("menuFile"));
        menuEdit = new QMenu(menubar);
        menuEdit->setObjectName(QString::fromUtf8("menuEdit"));
        menuTools = new QMenu(menubar);
        menuTools->setObjectName(QString::fromUtf8("menuTools"));
        menuHelp = new QMenu(menubar);
        menuHelp->setObjectName(QString::fromUtf8("menuHelp"));
        mainWindowClass->setMenuBar(menubar);
        statusbar = new QStatusBar(mainWindowClass);
        statusbar->setObjectName(QString::fromUtf8("statusbar"));
        mainWindowClass->setStatusBar(statusbar);
        toolBar = new QToolBar(mainWindowClass);
        toolBar->setObjectName(QString::fromUtf8("toolBar"));
        mainWindowClass->addToolBar(Qt::TopToolBarArea, toolBar);

        menubar->addAction(menuFile->menuAction());
        menubar->addAction(menuEdit->menuAction());
        menubar->addAction(menuTools->menuAction());
        menubar->addAction(menuHelp->menuAction());
        menuFile->addAction(actionExit);
        menuEdit->addAction(actionUpdate);

        retranslateUi(mainWindowClass);
        QObject::connect(actionExit, SIGNAL(activated()), mainWindowClass, SLOT(close()));
        QObject::connect(actionUpdate, SIGNAL(activated()), centralwidget, SLOT(repaint()));

        QMetaObject::connectSlotsByName(mainWindowClass);
    } // setupUi

    void retranslateUi(QMainWindow *mainWindowClass)
    {
        mainWindowClass->setWindowTitle(QApplication::translate("mainWindowClass", "MainWindow", 0, QApplication::UnicodeUTF8));
        actionExit->setText(QApplication::translate("mainWindowClass", "Exit", 0, QApplication::UnicodeUTF8));
        actionUpdate->setText(QApplication::translate("mainWindowClass", "Update", 0, QApplication::UnicodeUTF8));
        menuFile->setTitle(QApplication::translate("mainWindowClass", "File", 0, QApplication::UnicodeUTF8));
        menuEdit->setTitle(QApplication::translate("mainWindowClass", "Edit", 0, QApplication::UnicodeUTF8));
        menuTools->setTitle(QApplication::translate("mainWindowClass", "Tools", 0, QApplication::UnicodeUTF8));
        menuHelp->setTitle(QApplication::translate("mainWindowClass", "Help", 0, QApplication::UnicodeUTF8));
        toolBar->setWindowTitle(QApplication::translate("mainWindowClass", "toolBar", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class mainWindowClass: public Ui_mainWindowClass {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAIN_WINDOW_H
