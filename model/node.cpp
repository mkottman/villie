/*
 * Node.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "node.h"

QString Node::name() {
    return QString("node %1").arg(_id);
}

QString Node::type() {
    return "Generic node";
}

Value * Node::value() {
    return _value;
}

void Node::setValue(Value * val) {
    _value = val;
}

bool Node::ready() {
    return _value != NULL;
}

const EdgeList Node::connectedEdges() {
    return _edges;
}
