#ifndef VEDGE_H
#define VEDGE_H

#include "velement.h"
#include "../core/edge.h"

class VEdge : public VElement
{
public:
    VEdge(Edge *e) : VElement(), _edge(e) { e->setVisual(this); }

public:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);
    QRectF boundingRect() const;

    QString name() { return _edge->name(); }
    QString type() { return _edge->type(); }

private:
    Edge * _edge;
};

#endif // VEDGE_H
