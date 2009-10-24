#ifndef VNODE_H
#define VNODE_H

#include "velement.h"
#include "../core/node.h"

class VNode : public VElement
{
public:
    VNode(Node *n) : VElement(), _node(n) { n->setVisual(this); }

public:
    void render(QPainter &p);

    QString type() {
        return "Generic Node";
    }

    QString name() {
        return QString::fromUtf8("node %1").arg(_node->id());
    }

private:
    Node * _node;
};

#endif // VNODE_H
