#include <QPainter>
#include <QPen>

#include "vnode.h"

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

#define SIZE 15

void VNode::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    painter->setBrush(*gradient);
    if (isSelected()) {
        painter->setPen(QPen(Qt::black, 2));
    }
    painter->drawEllipse(QRectF(-SIZE*2, -SIZE, SIZE*4, SIZE*2));
    painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

inline QRectF VNode::boundingRect() const {
    float border = isSelected() ? 2 : 1;
    return QRectF(-SIZE*2 - border, -SIZE - border, SIZE*4 + 2*border, SIZE*2 + 2*border);
}