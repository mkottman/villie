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

Value Node::takeValue() {
    if (!_constant)
        _valueGiven = false;
    return _value;
}

void Node::setValue(const Value &val) {
    _value = val;
    _valueGiven = true;
}

bool Node::ready() {
    return _constant || _valueGiven;
}

const EdgeList Node::connectedEdges() {
    return _edges;
}
