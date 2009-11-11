/* 
 * File:   connector.h
 * Author: miky
 *
 * Created on October 26, 2009, 5:16 PM
 */

#ifndef _CONNECTOR_H
#define	_CONNECTOR_H

#include <QGraphicsLineItem>

#include "velement.h"

class Connector : public QGraphicsLineItem {
public:

    Connector(VElement *startItem, VElement *endItem);

    QRectF boundingRect() const;

    void setColor(const QColor &color) {
        myColor = color;
    }

    VElement *startItem() const {
        return myStartItem;
    }

    VElement *endItem() const {
        return myEndItem;
    }

    void setStartItem(VElement *e) {
        myStartItem = e;
    }

    void setEndItem(VElement *e) {
        myEndItem = e;
    }

    enum {
        Type = UserType + 4
    };

    int type() const {
        return Type;
    }

    QPainterPath shape() const;

public slots:
    void updatePosition();

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
            QWidget *widget = 0);

private:
    VElement *myStartItem;
    VElement *myEndItem;
    QColor myColor;
    QPolygonF arrowHead;
};
#endif	/* _CONNECTOR_H */

