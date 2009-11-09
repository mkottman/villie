/*
 * Graph.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "graph.h"

Graph::Graph()
{
	// TODO Auto-generated constructor stub

}

Graph::~Graph()
{
    foreach (Edge *e, _edges) {
        delete e;
    }
    foreach (Node *n, _nodes) {
        delete n;
    }
}

void Graph::addNode(Node *node) {
    _nodes.append(node);
}

void Graph::disconnect(Node *src, Node *edge)
{
}

void Graph::connect(Node *node, Edge *edge, const QString &name, IncidenceDirection dir)
{
    edge->connect(node, name, dir);
}

EdgeList Graph::edges()
{
	return _edges;
}

void Graph::disconnect(Node *node)
{
}

void Graph::removeEdge(Edge *edge)
{
}

void Graph::addEdge(Edge *edge)
{
	_edges.append(edge);
}

NodeList Graph::nodes()
{
	return _nodes;
}

void Graph::removeNode(Node *node)
{
    _nodes.removeOne(node);
}

