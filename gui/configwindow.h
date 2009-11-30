#ifndef CONFIGWINDOW_H
#define CONFIGWINDOW_H

#include <QDialog>
#include <QFormLayout>
#include <QVariant>


class ConfigWindow : public QDialog
{
public:
    ConfigWindow(const QString &name);
    void addVariable(const QString &name, const QString &type);
private:
    QFormLayout * _layout;
};

#endif // CONFIGWINDOW_H
