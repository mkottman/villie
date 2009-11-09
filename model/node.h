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

    QString name();
    QString type();

    virtual Value * value();
    virtual void setValue(Value *val);
    virtual bool ready();
};

#endif /* NODE_H_ */
