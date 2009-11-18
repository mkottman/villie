#include "configwindow.h"

ConfigWindow::ConfigWindow(const QString &name)
{
    QString tmp = name;
    tmp.prepend("Configuring ");
    setWindowTitle(tmp);
    setVisible(true);
}
