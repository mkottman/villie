#ifndef VELEMENT_H
#define VELEMENT_H

#include <QGraphicsItem>
#include <QGraphicsSceneMouseEvent>
#include <QString>
#include <QPainter>
#include "vector.h"

class GraphScene;

class VElement : public QGraphicsItem {
public:

    VElement(GraphScene* scene, QGraphicsItem *parent = 0) :
        QGraphicsItem(parent), _force(vector2(0,0)), _pos(vector2(0,0)), _scene(scene), _ignored(false)
    {
        setZValue(1);
        setVisible(true);
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
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *e);
    void mousePressEvent(QGraphicsSceneMouseEvent *e);

public:
    vector2 _force;
    vector2 _pos;
    GraphScene * _scene;
    bool _ignored;
};

extern VElement * asElement(QGraphicsItem *item);

#endif // VELEMENT_H
