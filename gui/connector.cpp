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
#include <QDebug>

const qreal Pi = 3.1415;

Connector::Connector(VElement *startItem, VElement *endItem, const QString &name) {
    myStartItem = startItem;
    myEndItem = endItem;
    _name = name;
    //setFlag(QGraphicsItem::ItemIsSelectable, true);
    myColor = Qt::black;
    setZValue(1);
    setPen(QPen(myColor, 1, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    text = new QGraphicsSimpleTextItem(name, this);
    center = (myStartItem->pos() + myEndItem->pos()) / 2;
    text->setPos(center.x(), center.y()-20);
}

QRectF Connector::boundingRect() const {
    return shape().boundingRect().adjusted(-5, -5, 5, 5);
}

QPainterPath Connector::shape() const {
    QPainterPath path = QGraphicsLineItem::shape();
    return path;
}

void Connector::paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *) {
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

    center = (myStartItem->pos() + myEndItem->pos()) / 2;
    float dx = abs(myEndItem->pos().x() - myStartItem->pos().x());
    float dy = abs(myEndItem->pos().y() - myStartItem->pos().y());

    text->setPos(center.x(), center.y()-20);
    /*
    if (dx > dy) {
        text->setPos(center.x(), center.y() - 15);
    } else {
        text->setPos(center.x() + 15, center.y());
    }
    */

    double angle = ::acos(line().dx() / line().length());
    if (line().dy() >= 0)
        angle = (Pi * 2) - angle;

    const double arrowSize = 10;

    QPointF arrowP1 = center - QPointF(sin(angle + Pi / 3) * arrowSize,
                                            cos(angle + Pi / 3) * arrowSize);
    QPointF arrowP2 = center - QPointF(sin(angle + Pi - Pi / 3) * arrowSize,
                                            cos(angle + Pi - Pi / 3) * arrowSize);

    QPolygonF arrowHead;
    arrowHead << center << arrowP1 << arrowP2;
    painter->drawPolygon(arrowHead);
    painter->drawLine(line());
}
