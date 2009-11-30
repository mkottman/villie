#ifndef EDGETYPE_H
#define EDGETYPE_H

#include <QObject>
#include <QColor>
#include <QList>
#include <QMap>

class EdgeType : public QObject
{
    Q_OBJECT

public:
    EdgeType(const QString &name, const QColor &color, int protoref, int runref, int configref) :
            _typeName(name), _color(color), _protoref(protoref), _runref(runref), _configref(configref)
    {}

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

    void setProto(int proto) {
        _protoref = proto;
    }
    int proto() {
        return _protoref;
    }

public Q_SLOTS:
    void trigger() {
        emit activate(name());
    }

Q_SIGNALS:
    void activate(const QString &name);

private:
    QString _typeName;
    QColor _color;
    int _protoref;
    int _runref;
    int _configref;
};

typedef QList<EdgeType*> EdgeTypeList;
typedef QMap<QString, EdgeType*> EdgeTypeMap;

#endif // EDGETYPE_H
