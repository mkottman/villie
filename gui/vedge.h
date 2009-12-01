#ifndef VEDGE_H
#define VEDGE_H

#include "velement.h"
#include "../model/edge.h"
#include "vnode.h"
#include "connector.h"

class VEdge : public VElement {
public:

    VEdge(GraphScene *scene, Edge *e);

    enum {
        Type = UserType + 3
    };

    int type() const {
        return Type;
    }

public:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);
    QRectF boundingRect() const;

    QString name() {
        return _edge->name();
    }

    void mouseDoubleClickEvent(QGraphicsSceneMouseEvent *e);

    void moveConnector(VNode *from, VNode *to);

    Connector * disconnect(VNode *n);

    Edge * _edge;
    QList<Connector*> _connectors;

private:
    QRadialGradient *gradient;
};

extern VEdge * asEdge(QGraphicsItem *item);

#endif // VEDGE_H
