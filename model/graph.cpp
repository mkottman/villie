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
#include "configwindow.h"

#define OP_PATH "ops"

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
        registerEdgeType(file);
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
    _edges.removeOne(edge);
}


void dumpStack(lua_State *L) {
    int top = lua_gettop(L);
    for (int i=1; i<=top; i++) {
        qDebug() << i << " : " << luaL_typename(L, i) << " = " << lua_topointer(L, i);
    }
}



void Graph::createNodesForEdge(Edge *edge, EdgeType *type) {
    qDebug() << "createNodesForEdge" << edge->name() << type->name();

    int top = lua_gettop(L);

    lua_rawgeti(L, LUA_REGISTRYINDEX, type->proto());
    lua_pushnil(L);
    while (lua_next(L, -2)) {
        // dumpStack(L);
        int tab = lua_gettop(L);

        lua_rawgeti(L, tab, 1);
        size_t len = 0;
        const char *pName = lua_tolstring(L, -1, &len);
        QString name = QString::fromUtf8(pName, len);


        lua_rawgeti(L, tab, 2);
        int d = lua_tonumber(L, -1);
        IncidenceDirection dir;
        if (d == 1) {
            dir = IN;
        } else {
            dir = OUT;
        }

        qDebug() << "Creating node " << name << " in direction: " << dir;
        Node *n = createNode("");
        edge->connect(n, name, dir);

        lua_settop(L, tab - 1);
    }

#define IT QHash<Incidence,Node*>
    for (IT::const_iterator it = edge->_nodes.constBegin(); it != edge->_nodes.constEnd(); it++) {
        qDebug() << it.key().name << " : " << it.value();
    }

    lua_settop(L, top);
}

Edge * Graph::createEdge(const QString &type) {
    qDebug() << "createEdge" << type;

    EdgeType *tp = _types.value(type, _types.value("unknown"));
    Edge * edge = new Edge(L, tp);
    _edges.append(edge);

    createNodesForEdge(edge, tp);

    return edge;
}

NodeList Graph::nodes()
{
    return _nodes;
}

void Graph::removeNode(Node *node)
{
    foreach (Edge *e, node->connectedEdges()) {
        e->disconnect(node);
    }
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

const luaL_Reg globals[] = {
    {"print", &Graph::luaPrint},
    {0,0}
};

const luaL_Reg methods[] = {
    {"nodes", &Graph::luaNodes},
    {"edges", &Graph::luaEdges},
    {0,0}
};

void Graph::registerFunctions() {
    lua_createtable(L, 0, 0);
    int indexTable = lua_gettop(L);

    const luaL_Reg *l;

    for (l = methods; l->name; l++) {
        lua_pushstring(L, l->name);
        lua_pushlightuserdata(L, (void*)this);
        lua_pushcclosure(L, l->func, 1);
        lua_settable(L, indexTable);
    }

    for (l = globals; l->name; l++) {
        lua_pushlightuserdata(L, (void*)this);
        lua_pushcclosure(L, l->func, 1);
        lua_setglobal(L, l->name);
    }

    lua_pushnumber(L, 1);
    lua_setfield(L, LUA_GLOBALSINDEX, "IN");

    lua_pushnumber(L, 2);
    lua_setfield(L, LUA_GLOBALSINDEX, "OUT");
}

void Graph::runConfig(Edge *e) {
    EdgeType *type = e->edgeType();
    lua_rawgeti(L, LUA_REGISTRYINDEX, type->configFunction());
    e->push();
    lua_pcall(L, 1, 2, 0);

    // 1 - hodnoty a ich typy
    // 2 - navratova funkcia

    if (lua_type(L, -2) != LUA_TTABLE) {
        emitError(QString("Config: Table expected as result 1, got %1").arg(lua_typename(L, -2)));
    } else {
        ConfigWindow *conf = new ConfigWindow(type->name());
        lua_pushnil(L);
        while (lua_next(L, -3)) {
            size_t len = 0;
            QString name = QString::fromUtf8(lua_tolstring(L, -2, &len), len);
            QString type = QString::fromUtf8(lua_tolstring(L, -1, &len), len);
            conf->addVariable(name, type);
            lua_pop(L, 1);
        }
        conf->exec();
    }
}


/** Registers an edge type from file.

  \param fileName Name of file, which contains definitions of edge

Assumes the source file is already loaded on top of Lua stack.
Retrieves all relevant info from the return value of the Lua source. Handles errors by notifying through
the error(QString) signal if there are any receivers, or by showing QMessageBox
*/
void Graph::registerEdgeType(const QString &fileName) {
    int top = lua_gettop(L);

    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");

    int err = luaL_loadfile(L, qPrintable(fileName));
    if (err == 0) {
        err = lua_pcall(L, 0, 1, -2);
        if (err == 0) {
            if (lua_type(L, -1) == LUA_TTABLE) {
                int table = lua_gettop(L);

                lua_getfield(L, table, "name");
                QString name = lua_tostring(L, -1);

                lua_getfield(L, table, "color");
                QColor color(lua_tostring(L, -1));

                lua_getfield(L, table, "run");
                int runref = luaL_ref(L, LUA_REGISTRYINDEX);

                lua_getfield(L, table, "config");
                int configref = luaL_ref(L, LUA_REGISTRYINDEX);

                lua_getfield(L, table, "proto");
                int protoref = luaL_ref(L, LUA_REGISTRYINDEX);

                qDebug() << "Registering type" << name << color << protoref << runref << configref;

                EdgeType *type = new EdgeType(name, color, protoref, runref, configref);
                _types.insert(name, type);
            } else {
                err = 1;
                lua_pushliteral(L, "Error while loading ");
                lua_pushstring(L, qPrintable(fileName));
                lua_pushliteral(L, ": table expected, got ");
                lua_pushstring(L, lua_typename(L, lua_type(L, -1)));
                lua_concat(L, 4);
            }
        }
    }

    if (err != 0) {
        QString err = "Error while loading definitions: ";
        err += lua_tostring(L, -1);
        emitError(err);
    }

    lua_settop(L, top);
}


void Graph::emitError(const QString &err) {
    if (receivers(SIGNAL(error(QString))) > 0)
        emit error(err);
    else
        QMessageBox::warning(0, "Operations error", err);
}
