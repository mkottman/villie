#include <QPainter>
#include <QPen>
#include <QGraphicsScene>

#include "vnode.h"

#include <QDebug>

#include "graphscene.h"

static QRadialGradient *nilGradient = NULL;
static QRadialGradient *numGradient = NULL;
static QRadialGradient *stringGradient = NULL;

VNode::VNode(GraphScene *scene, Node* n) : VElement(scene), _node(n) {
    n->setVisual(this);
    setFlag(QGraphicsItem::ItemIsSelectable, true);
    setFlag(QGraphicsItem::ItemIsMovable, true);
    text = new QGraphicsSimpleTextItem(this, scene);
    text->setPos(10, -5);
    if (!nilGradient) {
        nilGradient = new QRadialGradient(QPointF(0,0), boundingRect().height(), QPointF(0,0));
        nilGradient->setColorAt(0, Qt::white);
        nilGradient->setColorAt(1, Qt::blue);
    }
    if (!numGradient) {
        numGradient = new QRadialGradient(QPointF(0,0), boundingRect().height(), QPointF(0,0));
        numGradient->setColorAt(0, Qt::white);
        numGradient->setColorAt(1, Qt::red);
    }
    if (!stringGradient) {
        stringGradient = new QRadialGradient(QPointF(0,0), boundingRect().height(), QPointF(0,0));
        stringGradient->setColorAt(0, Qt::white);
        stringGradient->setColorAt(1, Qt::yellow);
    }
}

#define SIZE 10

void VNode::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget) {
    UNUSED(option);
    UNUSED(widget);
    switch (_node->valueType()) {
    case NIL: painter->setBrush(*nilGradient); break;
    case NUMBER: painter->setBrush(*numGradient); break;
    case STRING: painter->setBrush(*stringGradient); break;
    }
    text->setText(_node->value().toString());
    if (isSelected()) {
        painter->setPen(QPen(Qt::black, 2));
    }
    if (_node->isConst()) {
        painter->setPen(QPen(Qt::red, 4));
    }
    painter->drawEllipse(QRectF(-SIZE/2, -SIZE/2, SIZE, SIZE));
    //painter->drawText(boundingRect(), name(), QTextOption(Qt::AlignCenter));
}

inline QRectF VNode::boundingRect() const {
    float border = _node->isConst() ? 4 : isSelected() ? 2 : 1;
    return QRectF(-SIZE/2 - border, -SIZE/2 - border, SIZE + 2*border, SIZE + 2*border);
}

VNode * asNode(QGraphicsItem *item) {
    return qgraphicsitem_cast<VNode*>(item);
}

void VNode::mouseDoubleClickEvent(QGraphicsSceneMouseEvent *event) {
    _scene->configNode(this);
}
