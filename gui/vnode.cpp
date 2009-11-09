#include <QPainter>
#include <QPen>
#include <qt4/QtGui/qgraphicsscene.h>

#include "vnode.h"

#include <QDebug>

static QRadialGradient *gradient = NULL;

VNode::VNode(GraphScene *scene, Node* n) : VElement(scene), _node(n) {
    n->setVisual(this);
    setFlag(QGraphicsItem::ItemIsSelectable, true);
    setFlag(QGraphicsItem::ItemIsMovable, true);
    if (!gradient) {
        gradient = new QRadialGradient(QPointF(0,0), boundingRect().height(), QPointF(0,0));
        gradient->setColorAt(0, Qt::white);
        gradient->setColorAt(1, Qt::blue);
    }
}

#define TOLERANCE 5

void VNode::mouseReleaseEvent(QGraphicsSceneMouseEvent* e) {
    QPointF pos = e->scenePos();
    pos -= QPointF(TOLERANCE, TOLERANCE);

    VElement *current = qgraphicsitem_cast<VElement*>(scene()->mouseGrabberItem());

    if (current) {
        QRectF rectf(pos, QSizeF(TOLERANCE*2, TOLERANCE*2));
        QList<QGraphicsItem*> items = scene()->items(rectf, Qt::IntersectsItemBoundingRect);

        foreach (QGraphicsItem *gi, items) {
            if (gi == current)
                continue;
            
            VElement *ve = qgraphicsitem_cast<VElement*>(gi);
            if (ve) {
                qDebug() << ve->name();
            }
        }
    }
    VElement::mouseReleaseEvent(e);
}


#define SIZE 10

void VNode::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    painter->setBrush(*gradient);
    if (isSelected()) {
        painter->setPen(QPen(Qt::black, 2));
    }
    painter->drawEllipse(QRectF(-SIZE/2, -SIZE/2, SIZE, SIZE));
    //painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

inline QRectF VNode::boundingRect() const {
    float border = isSelected() ? 2 : 1;
    return QRectF(-SIZE/2 - border, -SIZE/2 - border, SIZE + 2*border, SIZE + 2*border);
}
