#include "velement.h"
#include <QDebug>

#include "graphscene.h"

QVariant VElement::itemChange(GraphicsItemChange change, const QVariant& value) {
    if (change == ItemPositionHasChanged) {
        _pos = value.toPointF();
        _scene->itemChanged();
    }
    return QGraphicsItem::itemChange(change, value);
}

void VElement::mousePressEvent(QGraphicsSceneMouseEvent *e) {
    _ignored = true;
    _scene->itemChanged();
    QGraphicsItem::mousePressEvent(e);
}

void VElement::mouseReleaseEvent(QGraphicsSceneMouseEvent *e) {
    _ignored = false;
    QGraphicsItem::mouseReleaseEvent(e);
}
