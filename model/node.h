/*
 * Node.h
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#ifndef NODE_H_
#define NODE_H_

class Value;

#include "common.h"

class Node : public Element
{
public:
    Node(lua_State *L) : Element(L), _value(0) {}
    virtual ~Node() {}

    const EdgeList connectedEdges();

    QString name();
    QString type();

    virtual Value * value();
    virtual void setValue(Value *val);
    virtual bool ready();

    friend class Edge;

private:
    Value * _value;
    EdgeList _edges;
};

#endif /* NODE_H_ */
