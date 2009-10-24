/*
 * Node.h
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#ifndef NODE_H_
#define NODE_H_

#include "common.h"

class Node : public Element
{
public:
    Node() {}
    virtual ~Node() {}

    QString name() {
        return QString("node %1").arg(_id);
    }

    QString type() {
        return "Generic Node";
    }
};

#endif /* NODE_H_ */
