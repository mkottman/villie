#ifndef VEDGE_H
#define VEDGE_H

#include "velement.h"
#include "../core/edge.h"

class VEdge : public VElement
{
public:
    VEdge(Edge *e) : VElement(), _edge(e) { e->setVisual(this); }

public:
    void render(QPainter &p);

    QString type() {
        return "Generic Edge";
    }

    QString name() {
        return QString::fromUtf8("edge %1").arg(_edge->id());
    }

private:
    Edge * _edge;
};

#endif // VEDGE_H
