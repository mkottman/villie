#include "velement.h"
#include <QDebug>

#include "graphscene.h"

VElement::VElement(GraphScene *scene, QGraphicsItem *parent) :
        QGraphicsItem(parent), _force(vector2(0,0)), _pos(vector2(0,0)), _scene(scene), _ignored(false)
{
    setZValue(100);
    setVisible(true);
    setFlag(QGraphicsItem::ItemIsSelectable, true);
    setFlag(QGraphicsItem::ItemIsMovable, true);
}

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

extern VElement * asElement(QGraphicsItem *item) {
    // not nice
    int type = item->type() - QGraphicsItem::UserType;
    if (type == 2 || type == 3) {
        return static_cast<VElement*>(item);
    }
    return 0;
}
