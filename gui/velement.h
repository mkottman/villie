#ifndef VELEMENT_H
#define VELEMENT_H

#include <QGraphicsItem>
#include <QString>
#include <QPainter>
#include "vector.h"

class VElement : public QGraphicsItem {
public:

    VElement(QGraphicsItem *parent = 0) : QGraphicsItem(parent) {
    }

public:
    virtual QString name() = 0;

    enum {
        Type = UserType + 1
    };

    int type() const {
        return Type;
    }

public:
    double _FRspeed;
    vector2 _force;
};

#endif // VELEMENT_H
