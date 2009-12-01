#ifndef VNODE_H
#define VNODE_H

#include "velement.h"
#include "../model/node.h"

class VNode : public VElement {
public:

    VNode(GraphScene *scene, Node *n);

    enum {
        Type = UserType + 2
    };

    int type() const {
        return Type;
    }

    void mouseDoubleClickEvent(QGraphicsSceneMouseEvent *event);

public:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);
    QRectF boundingRect() const;

    QString name() {
        return _node->name();
    }

    Node * _node;
};

VNode * asNode(QGraphicsItem *item);

#endif // VNODE_H
