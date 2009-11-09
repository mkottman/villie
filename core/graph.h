/*
 * Graph.h
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#ifndef GRAPH_H_
#define GRAPH_H_

#include "common.h"
#include "edge.h"
#include "node.h"

class Graph
{
public:
    Graph();
    virtual ~Graph();

public:
    NodeList nodes();
    EdgeList edges();

    void addNode(Node *node);
    void removeNode(Node *node);
    void addEdge(Edge *edge);
    void removeEdge(Edge *edge);
    void connect(Node *node, Edge *edge, const QString &name = "", IncidenceDirection dir = IN);
    void disconnect(Node *node, Edge *edge);


    void disconnect(Node *src, Node *destination);
    void disconnect(Node *node);
    /*
    void connect(NodeList *sources, Edge *edge, EdgeList *destinations);
    */

private:
    EdgeList _edges;
    NodeList _nodes;
};

#endif /* GRAPH_H_ */
