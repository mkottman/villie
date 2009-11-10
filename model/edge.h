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
    Edge() : _unnamedCounter(0), _typeRef(0), _nameRef(0), _runRef(0), _configRef(0) {}
    virtual ~Edge() {}

public:
    NodeList connectedNodes();
    Node * nodeByName(const QString & name);
    
    QString name();
    QString type();

    NodeList inNodes();
    NodeList outNodes();

    void connect(Node *node, const QString &name, IncidenceDirection dir);
    
private:
    NodeList gather(IncidenceDirection dir);
    QHash<Incidence, Node*> _nodes;
    int _unnamedCounter;

    int _typeRef;
    int _nameRef;
    int _runRef;
    int _configRef;
};

#endif /* EDGE_H_ */