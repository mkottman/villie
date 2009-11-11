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
    _graph = g;

    clear();

    foreach(Node *n, _graph->nodes()) {
        createVisualNode(n);
    }

    foreach(Edge *e, _graph->edges()) {
        createVisualEdge(e);
    }
}

void GraphScene::createVisualNode(Node *n) {
    VNode *vn = new VNode(this, n);
    addItem(vn);
}

void GraphScene::createVisualEdge(Edge *e) {
    VEdge *ve = new VEdge(this, e);
    addItem(ve);

    foreach(Node *n, e->connectedNodes()) {
        Connector *conn = new Connector(e->visual(), n->visual());
        addItem(conn);
        ve->_connectors.append(conn);
    }
}

Node * GraphScene::removeVisualNode(VNode *n) {
    Node * ret = n->_node;
    removeItem(n);
    delete n;
    return ret;
}

Edge * GraphScene::removeVisualEdge(VEdge *e) {
    Edge * ret = e->_edge;
    removeItem(e);
    foreach (Connector *c, e->_connectors) {
        removeItem(c);
        delete c;
    }
    delete e;
    return ret;
}

void GraphScene::reloadEdge(VEdge *e) {
    createVisualEdge(removeVisualEdge(e));
}

VElement * GraphScene::createItemByType(int type) {
    switch (type) {
        case VNode::Type: {
            Node *n = _graph->createNode();
            VNode *vn = new VNode(this, n);
            addItem(vn);
            return vn;
        }

        case VEdge::Type: {
            Edge *e = _graph->createEdge();
            VEdge *ve = new VEdge(this, e);
            addItem(ve);

            // create a few nodes around
            int cnt = rand() % 5 + 1;
            for (int i=0; i<cnt; i++) {
                Node *n = _graph->createNode();
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

#define TOLERANCE 5

void GraphScene::mouseReleaseEvent(QGraphicsSceneMouseEvent *e) {
    QPointF pos = e->scenePos();
    pos -= QPointF(TOLERANCE, TOLERANCE);

    VNode *current = asNode(mouseGrabberItem());

    if (current) {
        QRectF rectf(pos, QSizeF(TOLERANCE*2, TOLERANCE*2));
        QList<QGraphicsItem*> vitems = items(rectf, Qt::IntersectsItemBoundingRect);

        foreach (QGraphicsItem *gi, vitems) {
            if (gi == current)
                continue;

            VNode *target = asNode(gi);
            if (target) {
                qDebug() << "Merging" << current->name() << "with" << target->name();
                
                Node *from = current->_node;
                Node *to = target->_node;
                
                foreach (Edge * e, from->connectedEdges()) {
                    VEdge *ve = asEdge(e->visual());
                    ve->moveConnector(current, target);
                }
                removeVisualNode(current);

                _graph->mergeNode(from, to);

                break;
            }
        }
    }

    QGraphicsScene::mouseReleaseEvent(e);
}

void GraphScene::startConnector() {

}
