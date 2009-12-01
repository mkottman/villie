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

typedef QHash<Incidence, Node*>::const_iterator NodeIterator;

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

int Edge::registerMethods(lua_State *L) {
    // TODO:
    return 0;
}

Incidence Edge::incidenceToNode(Node *node) {
    return _nodes.key(node);
}
