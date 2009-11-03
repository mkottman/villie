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

Connector::Connector(VElement *startItem, VElement *endItem,
        QGraphicsItem *parent, QGraphicsScene *scene)
: QGraphicsLineItem(parent, scene) {
    myStartItem = startItem;
    myEndItem = endItem;
    //setFlag(QGraphicsItem::ItemIsSelectable, true);
    myColor = Qt::black;
    setZValue(10000);
    setPen(QPen(myColor, 1, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
}

QRectF Connector::boundingRect() const {
    qreal extra = (pen().width() + 20) / 2.0;

    return QRectF(line().p1(), QSizeF(line().p2().x() - line().p1().x(),
            line().p2().y() - line().p1().y()))
            .normalized()
            .adjusted(-extra, -extra, extra, extra);
}

void Connector::updatePosition() {
    QLineF line(mapFromItem(myStartItem, 0, 0), mapFromItem(myEndItem, 0, 0));
    setLine(line);
}

void Connector::paint(QPainter *painter, const QStyleOptionGraphicsItem *,
        QWidget *) {
    if (!myStartItem || !myEndItem)
        return;

    if (myStartItem->collidesWithItem(myEndItem))
        return;

    QPen myPen = pen();
    myPen.setColor(myColor);
    painter->setPen(myPen);
    painter->setBrush(myColor);

    QLineF centerLine(myStartItem->pos(), myEndItem->pos());
    setLine(centerLine);

    painter->drawLine(line());
    /*
    if (isSelected()) {
        painter->setPen(QPen(myColor, 1, Qt::DashLine));
        QLineF myLine = line();
        myLine.translate(0, 4.0);
        painter->drawLine(myLine);
        myLine.translate(0, -8.0);
        painter->drawLine(myLine);
    }
    */
}