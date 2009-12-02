/*
 * Edge.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "edge.h"
#include "node.h"

#include <qalgorithms.h>
#include <QVector>
#include <QDebug>

#include <lua.hpp>

#define EDGE_META "EdgeMeta"

typedef QHash<Incidence, Node*>::const_iterator NodeIterator;


const luaL_Reg methods[] = {
    {"node", &Edge::luaNode},
    {0,0}
};

int Edge::registerMethods(lua_State *L) {
    luaL_newmetatable(L, EDGE_META);
    lua_pushvalue(L, -1);
    lua_setfield(L, -1, "__index");
    luaL_register(L, NULL, methods);
    return 0;
}

int Edge::luaNode(lua_State *L) {
    dumpStack(L);
    Edge **pe = (Edge**) lua_touserdata(L, 1);
    Edge *e = *pe;

    size_t len = 0;
    const char *str = lua_tolstring(L, 2, &len);
    QString key = QString::fromUtf8(str, len);
    qDebug() << "LUA: edge::node" << key;

    Node *n = e->nodeByName(key);
    if (n) {
        n->push();
        return 1;
    } else {
        return 0;
    }
}


Edge::Edge(lua_State *L, EdgeType *type) : Element(L), _unnamedCounter(0), _type(type) {
    push();
    luaL_getmetatable(L, EDGE_META);
    lua_setmetatable(L, -2);
}

NodeList Edge::connectedNodes()
{
    QVector<Node*> ret(_nodes.count());
    qCopy(_nodes.constBegin(), _nodes.constEnd(), ret.begin());
    return NodeList::fromVector(ret);
}

void Edge::connect(Node* node, const QString& name, IncidenceDirection dir) {
    if (node->_edges.contains(this)) {
        qDebug() << "Already connected!";
        return;
    }
    QString key = name;
    if (name.isEmpty())
        key = QString("%1").arg(++_unnamedCounter);
    _nodes.insert(Incidence(key, dir), node);
    Q_ASSERT(_nodes.contains(Incidence(key, dir)));
    node->_edges.append(this);
}

Incidence Edge::disconnect(Node *node) {
    Incidence key;
    for (NodeIterator i = _nodes.constBegin(); i != _nodes.constEnd(); i++) {
        if (i.value() == node) {
            key = i.key();
            break;
        }
    }
    _nodes.remove(key);
    return key;
}

NodeList Edge::gather(IncidenceDirection dir) {
    QVector<Node*> ret;
    for (NodeIterator i = _nodes.constBegin(); i != _nodes.constEnd(); i++) {
        if (i.key().dir == dir) {
            ret.append(i.value());
        }
    }
    return NodeList::fromVector(ret);
}

NodeList Edge::inNodes() {
    return gather(IN);
}

NodeList Edge::outNodes() {
    return gather(OUT);
}

Node * Edge::nodeByName(const QString &name) {
    for (NodeIterator i = _nodes.constBegin(); i != _nodes.constEnd(); i++) {
        if (i.key().name == name) {
            return i.value();
        }
    }
    return NULL;
}

QString Edge::name() {
    return QString("%1 (_%2)").arg(_type->name()).arg(_id);
}

QString Edge::type() {
    return "generic edge";
}

bool Edge::hasAllInputs() {
    foreach (Node *n, gather(IN)) {
        if (!n->ready())
            return false;
    }
    return true;
}


Incidence Edge::incidenceToNode(Node *node) {
    return _nodes.key(node);
}
