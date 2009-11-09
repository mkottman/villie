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

VElement * GraphScene::createItemByType(int type) {
    switch (type) {
        case VNode::ItemType: {
            Node *n = new Node();
            _graph->addNode(n);
            VNode *vn = new VNode(this, n);
            addItem(vn);
            return vn;
        }

        case VEdge::ItemType: {
            Edge *e = new Edge();
            _graph->addEdge(e);
            VEdge *ve = new VEdge(this, e);
            addItem(ve);

            // create a few nodes around
            int cnt = rand() % 5 + 1;
            for (int i=0; i<cnt; i++) {
                Node *n = new Node();
                _graph->addNode(n);
                VNode *vn = new VNode(this, n);
                addItem(vn);
                _graph->connect(n, e);
            }

            return ve;
        }
    }
    return NULL;
}

void GraphScene::mousePressEvent(QGraphicsSceneMouseEvent *e) {
    if (e->button() == Qt::LeftButton && _type) {
        VElement *item = createItemByType(_type);
        if (item) {
           _type = 0;
            addItem(item);
            item->setPos(e->scenePos());
            itemChanged();
        } else {
            qDebug() << "Unknown item type:" << _type;
        }
    }
    QGraphicsScene::mousePressEvent(e);
}

void GraphScene::itemChanged() {
    emit needsUpdate();
    //_moved = true;
}

void GraphScene::mouseReleaseEvent(QGraphicsSceneMouseEvent *e) {
//    if (_moved)
//        emit needsUpdate();
//    _moved = false;
    qDebug() << "Released!";
    QGraphicsScene::mouseReleaseEvent(e);
}

void GraphScene::startConnector() {

}
