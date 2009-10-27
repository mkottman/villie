/* 
 * File:   graphscene.cpp
 * Author: miky
 * 
 * Created on October 26, 2009, 4:03 PM
 */

#include "graphscene.h"

#include "vnode.h"
#include "vedge.h"
#include "connector.h"

#include <QDebug>

void GraphScene::setGraph(Graph* g) {
    if (g == _graph)
        return;

    _graph = g;

    clear();

    foreach(Node *n, _graph->nodes()) {
        VNode *vn = new VNode(this, n);
        addItem(vn);
    }

    foreach(Edge *e, _graph->edges()) {
        VEdge *ve = new VEdge(this, e);
        addItem(ve);

        foreach(Node *n, e->connectedNodes()) {
            Connector *conn = new Connector(e->visual(), n->visual());
            addItem(conn);
        }
    }
}


void GraphScene::itemChanged() {
    emit needsUpdate();
}