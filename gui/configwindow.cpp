#include "configwindow.h"

#include <QLabel>
#include <QTextEdit>
#include <QSpinBox>

ConfigWindow::ConfigWindow(const QString &name)
{
    QString tmp = name;
    tmp.prepend("Configuring ");
    setWindowTitle(tmp);
    setVisible(true);
    _layout = new QFormLayout(this);
    setLayout(_layout);
}

void ConfigWindow::addVariable(const QString &name, const QString &type) {
    QLabel *label = new QLabel(name, this);
    QWidget *editor = NULL;
    if (type == "string") {
        editor = new QTextEdit(this);
    } else if (type == "number") {
        editor = new QSpinBox(this);
    } else {
        editor = new QLabel(QString("Unknown type: %1").arg(type), this);
    }
    _layout->addWidget(label);
    _layout->addWidget(editor);
}
