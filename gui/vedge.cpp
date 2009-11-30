#include "vedge.h"

#include <QRadialGradient>
#include "connector.h"
#include "graphscene.h"

#include <QDebug>

static QRadialGradient *gradient = NULL;

VEdge::VEdge(GraphScene *scene, Edge* e) : VElement(scene), _edge(e) {
    e->setVisual(this);
    if (!gradient) {
        gradient = new QRadialGradient(QPointF(0,0), boundingRect().height(), QPointF(0,0));
        gradient->setColorAt(0, Qt::white);
        gradient->setColorAt(1, e->edgeType()->color());
    }
}

void VEdge::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    UNUSED(option);
    UNUSED(widget);
    painter->setBrush(*gradient);
    painter->drawRoundedRect(boundingRect(), 8, 8, Qt::AbsoluteSize);
    painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

#define SIZE 15

inline QRectF VEdge::boundingRect() const {
    return QRectF(-SIZE*2, -SIZE, SIZE*4, SIZE*2);
}

void VEdge::mouseDoubleClickEvent(QGraphicsSceneMouseEvent *e) {
    _scene->configEdge(this);
    VElement::mouseDoubleClickEvent(e);
}

void VEdge::moveConnector(VNode *from, VNode *to) {
    foreach (Connector *c, _connectors) {
        if (c->endItem() == from) {
            c->setEndItem(to);
        }
    }
}

VEdge * asEdge(QGraphicsItem *item) {
    return qgraphicsitem_cast<VEdge*>(item);
}

Connector * VEdge::disconnect(VNode *n) {
    Connector *sel = NULL;
    foreach (Connector *c, _connectors) {
        if (c->startItem() == n || c->endItem() == n) {
            sel = c;
            break;
        }
    }
    qDebug() << "Failed to disconnect node" << n << "from" << this;
    if (sel) {
        _connectors.removeOne(sel);
    }
    return sel;
}
