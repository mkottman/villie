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
#include "lunar.h"

#include <QObject>
#include <QMap>

class Graph : public QObject {
    Q_OBJECT;

public:
    Graph();
    virtual ~Graph();

public:
    NodeList nodes();
    EdgeList edges();

    Node * createNode(const QString &type = "");
    void removeNode(Node *node);
    Edge * createEdge(const QString &type = "");
    void removeEdge(Edge *edge);
    void connect(Node *node, Edge *edge, const QString &name = "", IncidenceDirection dir = IN);
    void disconnect(Node *node, Edge *edge);

    void mergeNode(Node *from, Node* to);

    // Graph serialization
    void save();
    void load();

    void runConfig(Edge *e);

signals:
    void printed(const QString &str);
    void error(const QString &err);

public:
    // Lua functions - graph instance
    static int luaNodes(lua_State *L);
    static int luaEdges(lua_State *L);

    // Lua functions - global
    static int luaPrint(lua_State *L);

    // Aux functions
    void registerFunctions();
    void registerEdgeType(const QString &fileName);
    EdgeTypeMap types() {
        return _types;
    }

private:
    // Member variables
    EdgeList _edges;
    NodeList _nodes;
    lua_State *L;
    EdgeTypeMap _types;
};

#endif /* GRAPH_H_ */
