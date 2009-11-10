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
    Node() : _value(0) {}
    virtual ~Node() {}

    QString name();
    QString type();

    virtual Value * value();
    virtual void setValue(Value *val);
    virtual bool ready();

private:
    Value * _value;
};

#endif /* NODE_H_ */
