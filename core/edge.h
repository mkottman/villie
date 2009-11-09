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

#include "incidence.h"


class Edge : public Element
{
public:
    Edge() : _unnamedCounter(0) {}
    virtual ~Edge() {}

public:
    NodeList connectedNodes();
    Node * nodeByName(const QString & name);
    
    QString name() {
        return QString("edge %1").arg(_id);
    }

    QString type() {
        return "Generic Edge";
    }

    NodeList inNodes();
    NodeList outNodes();

    void connect(Node *node, const QString &name, IncidenceDirection dir);
    
private:
    NodeList gather(IncidenceDirection dir);
    QHash<Incidence, Node*> _nodes;
    int _unnamedCounter;
};

#endif /* EDGE_H_ */
