#ifndef VELEMENT_H
#define VELEMENT_H

#include <QRect>
#include <QPainter>

class VElement
{
public:
    VElement() {}

public:
    virtual void render(QPainter &p) = 0;

    virtual QRectF rect() const {
        return _rect;
    }

    virtual void setRect(const QRectF &rect) {
        _rect = rect;
    }

    virtual QPointF center() const {
        return _rect.center();
    }

    virtual void moveBy(const QPointF &offset) {
        _rect.adjust(offset.x(), offset.y(), offset.x(), offset.y());
    }
public:
    double _FRspeed;
    QPointF _force;

protected:
    QRectF _rect;
};

#endif // VELEMENT_H
