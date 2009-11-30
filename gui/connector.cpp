/* 
 * File:   connector.cpp
 * Author: miky
 * 
 * Created on October 26, 2009, 5:16 PM
 */

#include "connector.h"

#include <QtGui>

#include "connector.h"
#include <math.h>

const qreal Pi = 3.14;

Connector::Connector(VElement *startItem, VElement *endItem, const QString &name) {
    myStartItem = startItem;
    myEndItem = endItem;
    _name = name;
    //setFlag(QGraphicsItem::ItemIsSelectable, true);
    myColor = Qt::black;
    setZValue(10000);
    setPen(QPen(myColor, 1, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
}

QRectF Connector::boundingRect() const {
    qreal extra = (pen().width() + 40) / 2.0;

    return QRectF(line().p1(), QSizeF(line().p2().x() - line().p1().x(),
            line().p2().y() - line().p1().y()))
            .normalized()
            .adjusted(-extra, -extra, extra, extra);
}

void Connector::updatePosition() {
    QLineF line(mapFromItem(myStartItem, 0, 0), mapFromItem(myEndItem, 0, 0));
    setLine(line);
}

QPainterPath Connector::shape() const {
    QPainterPath path = QGraphicsLineItem::shape();
    path.addPolygon(arrowHead);
    return path;
}

void Connector::paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *) {
    return;
    if (!myStartItem || !myEndItem) {
        Q_ASSERT_X(myStartItem && myEndItem, "connector ends missing", "error");
        return;
    }

    if (myStartItem->collidesWithItem(myEndItem))
        return;

    QPen myPen = pen();
    myPen.setColor(myColor);
    painter->setPen(myPen);
    painter->setBrush(myColor);

    QLineF centerLine(myStartItem->pos(), myEndItem->pos());
    setLine(centerLine);

    QPointF center = (myStartItem->pos() + myEndItem->pos()) / 2;
    float dx = abs(myEndItem->pos().x() - myStartItem->pos().x());
    float dy = abs(myEndItem->pos().y() - myStartItem->pos().y());

    if (dx > dy) {
        painter->drawText(center.x(), center.y() - 15, _name);
    } else {
        painter->drawText(center.x() + 15, center.y(), _name);
    }

    painter->drawLine(line());
}
