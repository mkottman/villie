#ifndef EDGETYPE_H
#define EDGETYPE_H

#include <QColor>

class EdgeType
{
public:
    EdgeType();

    void setName(const QString &name) {
        _typeName = name;
    }
    QString name() {
        return _typeName;
    }

    void setRunFunction(int ref) {
        _runref = ref;
    }
    int runFunction() {
        return _runref;
    }

    void setConfigFunction(int ref) {
        _configref = ref;
    }
    int configFunction() {
        return _configref;
    }

    void setColor(const QColor &color) {
        _color = color;
    }
    QColor color() {
        return _color;
    }

private:
    QString _typeName;
    int _runref;
    int _configref;
    QColor _color;
};

#endif // EDGETYPE_H
