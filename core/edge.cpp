/*
 * Edge.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "edge.h"

#include <qalgorithms.h>
#include <QVector>

NodeList Edge::connectedNodes()
{
    QVector<Node*> ret(_nodes.count());
    qCopy(_nodes.constBegin(), _nodes.constEnd(), ret.begin());
    return NodeList::fromVector(ret);
}

void Edge::connect(Node* node, const QString& name) {
    QString key = name;
    if (name.isEmpty())
        key = QString("%1").arg(++_unnamedCounter);
    _nodes.insert(key, node);
}
