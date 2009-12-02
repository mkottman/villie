/*
 * Node.h
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#ifndef NODE_H_
#define NODE_H_

enum ValueType {
    NIL=0, NUMBER, STRING
};

#include <QString>

struct Value {
    Value() : type(NIL) {}
    Value(double num) : type(NUMBER), number(num) {}
    Value(const QString &str) : type(STRING), string(str) {}

    QString toString() {
        switch (type) {
        case NIL: return QString();
        case NUMBER: return QString("%1").arg(number);
        case STRING: return string;
        default: return QString("TYPE ERROR");
        }
    }

    static Value parse(const QString &in) {
        bool isNum = false;
        double num = in.toDouble(&isNum);
        if (isNum) {
            return Value(num);
        } else if (!in.isEmpty()) {
            return Value(in);
        } else {
            return Value();
        }
    }

    ValueType type;
    QString string;
    double number;
};

#include "common.h"

class Executor;

class Node : public Element
{
public:
    Node(lua_State *L);
    virtual ~Node() {}

    const EdgeList connectedEdges();

    QString name();
    QString type();

    Value takeValue();
    Value value() { return _value; }
    void setValue(const Value &val);
    void setConst(bool c) { _constant = c; }
    bool isConst() { return _constant; }
    bool ready();
    ValueType valueType() { return _value.type; }

    void prepareFor(Executor * exec);

    static int registerMethods(lua_State *L);
    static int luaValue(lua_State *L);
    static int luaSetValue(lua_State *L);

    friend class Edge;

private:
    Value _value;
    EdgeList _edges;
    bool _valueGiven;
    bool _constant;
    Executor * _exec;
};

#endif /* NODE_H_ */
