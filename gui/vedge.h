#ifndef VEDGE_H
#define VEDGE_H

#include "velement.h"
#include "../model/edge.h"

class VEdge : public VElement {
public:

    VEdge(GraphScene *scene, Edge *e);

    enum { ItemType = 2 };
public:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);
    QRectF boundingRect() const;

    QString name() {
        return _edge->name();
    }

private:
    Edge * _edge;
};

#endif // VEDGE_H
