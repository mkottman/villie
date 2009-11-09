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
