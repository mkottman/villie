#include "velement.h"
#include <QDebug>

#include "graphscene.h"

QVariant VElement::itemChange(GraphicsItemChange change, const QVariant& value) {
    switch (change) {
        case ItemPositionHasChanged:
            _pos = value.toPointF();
            _scene->itemChanged();
    }
    return QGraphicsItem::itemChange(change, value);
}