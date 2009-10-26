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

    Connector(VElement *startItem, VElement *endItem,
            QGraphicsItem *parent = 0, QGraphicsScene *scene = 0);

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

    enum {
        Type = UserType + 2
    };

    int type() const {
        return Type;
    }


    public
slots:
    void updatePosition();

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
            QWidget *widget = 0);

private:
    VElement *myStartItem;
    VElement *myEndItem;
    int myId;
    QColor myColor;
    QPolygonF arrowHead;
};
#endif	/* _CONNECTOR_H */

