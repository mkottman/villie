/*
 * Graph.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "graph.h"

#include <QFile>
#include <QDir>
#include <QMessageBox>
#include <QDebug>

#define OP_PATH "ops"

const char * loadingCode = "return function(name)\n"
                           ""
                           "end\n";

Graph::Graph() {
    L = luaL_newstate();
    luaL_openlibs(L);

    registerFunctions();

    QDir lib(OP_PATH);
    QStringList filters;
    filters << "*.lua";
    foreach(QString file, lib.entryList(filters, QDir::Files)) {
        qDebug() << "Loading: " << file;

        file.prepend(OP_PATH "/");

        int err = 0;

        err = luaL_loadfile(L, qPrintable(file));

        if (err != 0) {
            QString err = "Error while loading definitions: ";
            err += lua_tostring(L, -1);
            if (receivers(SIGNAL(error(QString))) > 0)
                emit error(err);
            else
                QMessageBox::warning(0, "Operations error", err);
        }
    }
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

Node * Graph::createNode(const QString &type) {
    // TODO: create custom node by type
    Node * node = new Node(L);
    _nodes.append(node);
    return node;
}

void Graph::connect(Node *node, Edge *edge, const QString &name, IncidenceDirection dir) {
    edge->connect(node, name, dir);
}

EdgeList Graph::edges() {
    return _edges;
}

void Graph::removeEdge(Edge *edge) {
    // TODO
    UNUSED(edge);
}

Edge * Graph::createEdge(const QString &type) {
    // TODO: create custom edge by type
    Edge * edge = new Edge(L);
    _edges.append(edge);
    return edge;
}

NodeList Graph::nodes()
{
    return _nodes;
}

void Graph::removeNode(Node *node)
{
    _nodes.removeOne(node);
}

void Graph::mergeNode(Node *from, Node *to) {
    foreach (Edge * e, from->connectedEdges()) {
        Incidence i = e->disconnect(from);
        qDebug() << "Disconnected" << from->name() << "from" << e->name() << "as" << i.name;
        e->connect(to, i.name, i.dir);
    }
    removeNode(from);
}

int Graph::luaEdges(lua_State *L) {
    Graph *g = (Graph*) lua_touserdata(L, lua_upvalueindex(1));
    int len = g->_edges.size();
    lua_createtable(L, len, 0);
    for (int i=0; i<len; i++) {
        g->_edges.at(i)->push();
        lua_rawseti(L, -2, i+1);
    }
    return 1;
}

int Graph::luaNodes(lua_State *L) {
    Graph *g = (Graph*) lua_touserdata(L, lua_upvalueindex(1));
    int len = g->_nodes.size();
    lua_createtable(L, len, 0);
    for (int i=0; i<len; i++) {
        g->_nodes.at(i)->push();
        lua_rawseti(L, -2, i+1);
    }
    return 1;
}

int Graph::luaPrint(lua_State *L) {
    Graph *g = (Graph*) lua_touserdata(L, lua_upvalueindex(1));
    QString str;
    int top = lua_gettop(L);

    lua_getglobal(L, "tostring");
    for (int i=1; i<=top; i++) {
        lua_pushvalue(L, -1);           // p1 p2 p3 tostring tostring
        lua_pushvalue(L, i);            // p1 p2 p3 tostring tostring pi
        lua_call(L, 1, 1);              // p1 p2 p3 tostring si
        str += lua_tostring(L, -1);
    }
    lua_settop(L, top);

    emit g->printed(str);

    return 0;
}

typedef struct { const char *name; lua_CFunction mfunc; } RegType;

const RegType globals[] = {
    {"print", &Graph::luaPrint},
    {0,0}
};

const RegType methods[] = {
    {"nodes", &Graph::luaNodes},
    {"edges", &Graph::luaEdges},
    {0,0}
};

void Graph::registerFunctions() {
    lua_createtable(L, 0, 0);
    int indexTable = lua_gettop(L);

    const RegType *l;

    for (l = methods; l->name; l++) {
        lua_pushstring(L, l->name);
        lua_pushlightuserdata(L, (void*)this);
        lua_pushcclosure(L, l->mfunc, 1);
        lua_settable(L, indexTable);
    }

    for (l = globals; l->name; l++) {
        lua_pushlightuserdata(L, (void*)this);
        lua_pushcclosure(L, l->mfunc, 1);
        lua_setglobal(L, l->name);
    }
}


