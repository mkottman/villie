#include <QPainter>
#include <QPen>
#include <QGraphicsScene>

#include "vnode.h"

#include <QDebug>

static QRadialGradient *gradient = NULL;

VNode::VNode(GraphScene *scene, Node* n) : VElement(scene), _node(n) {
    n->setVisual(this);
    setFlag(QGraphicsItem::ItemIsSelectable, true);
    setFlag(QGraphicsItem::ItemIsMovable, true);
    if (!gradient) {
        gradient = new QRadialGradient(QPointF(0,0), boundingRect().height(), QPointF(0,0));
        gradient->setColorAt(0, Qt::white);
        gradient->setColorAt(1, Qt::blue);
    }
}

#define SIZE 10

void VNode::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    UNUSED(option);
    UNUSED(widget);
    painter->setBrush(*gradient);
    if (isSelected()) {
        painter->setPen(QPen(Qt::black, 2));
    }
    painter->drawEllipse(QRectF(-SIZE/2, -SIZE/2, SIZE, SIZE));
    //painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

inline QRectF VNode::boundingRect() const {
    float border = isSelected() ? 2 : 1;
    return QRectF(-SIZE/2 - border, -SIZE/2 - border, SIZE + 2*border, SIZE + 2*border);
}

VNode * asNode(QGraphicsItem *item) {
    return qgraphicsitem_cast<VNode*>(item);
}
