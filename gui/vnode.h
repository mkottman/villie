#ifndef VNODE_H
#define VNODE_H

#include "velement.h"
#include "../model/node.h"

class VNode : public VElement {
public:

    VNode(GraphScene *scene, Node *n);

    enum { ItemType = 1 };
public:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);
    QRectF boundingRect() const;

    QString name() {
        return _node->name();
    }

protected:
    void mouseReleaseEvent(QGraphicsSceneMouseEvent* e);

private:
    Node * _node;
};

#endif // VNODE_H
