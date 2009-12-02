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
    Edge(lua_State *L, EdgeType * type);
    virtual ~Edge() {}

public:
    NodeList connectedNodes();
    Node * nodeByName(const QString & name);
    Incidence incidenceToNode(Node *node);
    
    QString name();
    QString type();

    EdgeType * edgeType() {
        return _type;
    }

    NodeList inNodes();
    NodeList outNodes();

    bool hasAllInputs();

    void connect(Node *node, const QString &name, IncidenceDirection dir);
    Incidence disconnect(Node *node);

    static int registerMethods(lua_State *L);
    static int luaNode(lua_State *L);
    
public:
    NodeList gather(IncidenceDirection dir);
    QHash<Incidence, Node*> _nodes;
    int _unnamedCounter;
    EdgeType * _type;
};

#endif /* EDGE_H_ */
