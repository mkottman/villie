#include <QPainter>
#include <QPen>

#include "vnode.h"


void VNode::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    QRadialGradient rg(QPointF(0,0), 50, QPointF(0,0));
    rg.setColorAt(0, Qt::white);
    rg.setColorAt(1, Qt::darkBlue);
    painter->setBrush(rg);
    painter->setPen(QPen(Qt::black, 2));
    painter->drawEllipse(boundingRect());
    painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

QRectF VNode::boundingRect() const {
    return QRectF(-51, -26, 102, 52);
}