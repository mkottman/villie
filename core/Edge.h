/*
 * Edge.h
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#ifndef EDGE_H_
#define EDGE_H_

#include "common.h"

#include <QHash>
#include <QString>



class Edge : public Element
{
public:
    Edge() : _unnamedCounter(0) {}
    virtual ~Edge() {}

public:
    NodeList connectedNodes();
    Node * nodeByName(const QString & name) {
        return _nodes.value(name);
    }
    
    QString name() {
        return QString("edge %1").arg(_id);
    }

    QString type() {
        return "Generic Edge";
    }

    void connect(Node *node, const QString &name);
    
private:
    QHash<QString, Node*> _nodes;
    int _unnamedCounter;
};

#endif /* EDGE_H_ */
