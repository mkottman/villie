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

Graph::Graph()
{
    // TODO Auto-generated constructor stub
    L = luaL_newstate();
    luaL_openlibs(L);

    QDir lib("lib");
    foreach(QString file, lib.entryList("*.lua", QDir::Files)) {
        qDebug() << "Loading: " << file;

        int ok = luaL_loadfile(L, qPrintable(file));
        if (ok == 0) {
            lua_newtable(L);
            lua_pushvalue(L, -1);
            lua_setfenv(L, -3);
            ok = lua_pcall(L, 0, 0, 0);
            if (ok == 0) {
                // TODO
            } else {
                QString err = "Error while loading definitions: ";
                err += lua_tostring(L, -1);
                QMessageBox::warning(0, "Edge type error", err, QMessageBox::Ok);
            }
        } else {
            QString err = "Error while loading definitions: ";
            err += lua_tostring(L, -1);
            QMessageBox::warning(0, "Edge type error", err, QMessageBox::Ok);
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

void Graph::addNode(Node *node) {
    _nodes.append(node);
}

void Graph::connect(Node *node, Edge *edge, const QString &name, IncidenceDirection dir) {
    edge->connect(node, name, dir);
}

EdgeList Graph::edges() {
    return _edges;
}

void Graph::removeEdge(Edge *edge) {
    // TODO
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

