/*
 * Node.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "node.h"

#include "../exec/executor.h"

#define NODE_META "NodeMeta"

Node::Node(lua_State *L) : Element(L), _value(), _valueGiven(false), _constant(false), _exec(0) {
    push();
    luaL_getmetatable(L, NODE_META);
    lua_setmetatable(L, -2);
}

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
    if (_exec)
        _exec->valueChanged(this);
}

bool Node::ready() {
    return _constant || _valueGiven;
}

const EdgeList Node::connectedEdges() {
    return _edges;
}


const luaL_Reg methods[] = {
    {"value", &Node::luaValue},
    {"setValue", &Node::luaSetValue},
    {0,0}
};

int Node::registerMethods(lua_State *L) {
    luaL_newmetatable(L, NODE_META);
    lua_pushvalue(L, -1);
    lua_setfield(L, -1, "__index");
    luaL_register(L, NULL, methods);
    return 0;
}

int Node::luaValue(lua_State *L) {
    dumpStack(L);

    Node **pn = (Node**) lua_touserdata(L, 1);
    Node *n = *pn;

    Value val = n->takeValue();
    switch (val.type) {
    case NUMBER: lua_pushnumber(L, val.number); return 1;
    case STRING: {
            QByteArray u8 = val.string.toUtf8();
            lua_pushlstring(L, u8.data(), u8.length());
            return 1;
        }
    }

// nil + other
    return 0;
}

int Node::luaSetValue(lua_State *L) {
    dumpStack(L);

    Node **pn = (Node**) lua_touserdata(L, 1);
    Node *n = *pn;

    switch(lua_type(L, 2)) {
    case LUA_TNUMBER:
        n->setValue(Value(lua_tonumber(L, 2)));
        break;
    case LUA_TSTRING:
        // TODO
        n->setValue(Value(lua_tostring(L, 2)));
        break;
    default:
        lua_pushliteral(L, "Unexpected argument: ");
        lua_pushstring(L, luaL_typename(L, 2));
        lua_concat(L, 2);
        lua_error(L);
    }

    return 0;
}


void Node::prepareFor(Executor *exec) {
    if (!_constant)
        _valueGiven = false;
    _exec = exec;
}
