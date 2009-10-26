#include "vedge.h"

#include <QRadialGradient>

static QRadialGradient rg;

void VEdge::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    QRadialGradient rg(QPointF(0,0), 50, QPointF(0,0));
    rg.setColorAt(0, Qt::white);
    rg.setColorAt(1, Qt::yellow);
    painter->setBrush(rg);
    painter->setPen(QPen(Qt::black, 2));
    painter->drawRect(boundingRect());
    painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

QRectF VEdge::boundingRect() const {
    return QRectF(-51, -26, 102, 52);
}