#ifndef VELEMENT_H
#define VELEMENT_H

#include <QGraphicsItem>
#include <QString>
#include <QPainter>
#include "vector.h"

class GraphScene;

class VElement : public QGraphicsItem {
public:

    VElement(GraphScene* scene, QGraphicsItem *parent = 0) :
        QGraphicsItem(parent), _scene(scene)
    {
        setZValue(1);
        setFlag(QGraphicsItem::ItemIsSelectable, true);
        setFlag(QGraphicsItem::ItemIsMovable, true);
    }

public:
    virtual QString name() = 0;

    enum {
        Type = UserType + 1
    };

    int type() const {
        return Type;
    }

    void updatePos() {
        _pos = pos();
    }

    void applyPos() {
        setPos(_pos.x, _pos.y);
    }

    QVariant itemChange(GraphicsItemChange change, const QVariant &value);

public:
    double _FRspeed;
    vector2 _force;
    vector2 _pos;
    GraphScene * _scene;
};

#endif // VELEMENT_H
