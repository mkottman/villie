/********************************************************************************
** Form generated from reading ui file 'grapheditorpanel.ui'
**
** Created: Sun Oct 25 01:22:33 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_GRAPHEDITORPANEL_H
#define UI_GRAPHEDITORPANEL_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QHeaderView>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_GraphEditorPanelClass
{
public:

    void setupUi(QWidget *GraphEditorPanelClass)
    {
        if (GraphEditorPanelClass->objectName().isEmpty())
            GraphEditorPanelClass->setObjectName(QString::fromUtf8("GraphEditorPanelClass"));
        GraphEditorPanelClass->resize(400, 300);

        retranslateUi(GraphEditorPanelClass);

        QMetaObject::connectSlotsByName(GraphEditorPanelClass);
    } // setupUi

    void retranslateUi(QWidget *GraphEditorPanelClass)
    {
        GraphEditorPanelClass->setWindowTitle(QApplication::translate("GraphEditorPanelClass", "GraphEditorPanel", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(GraphEditorPanelClass);
    } // retranslateUi

};

namespace Ui {
    class GraphEditorPanelClass: public Ui_GraphEditorPanelClass {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_GRAPHEDITORPANEL_H
