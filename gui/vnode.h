#ifndef VNODE_H
#define VNODE_H

#include "velement.h"
#include "../core/node.h"

class VNode : public VElement
{
public:
    VNode(Node *n) : VElement(), _node(n) { n->setVisual(this); }

public:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);
    QRectF boundingRect() const;
    
    QString name() { return _node->name(); }
    QString type() { return _node->type(); }
    
private:
    Node * _node;
};

#endif // VNODE_H
