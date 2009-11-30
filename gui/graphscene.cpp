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

#define PP_NARG(...) \
         PP_NARG_(__VA_ARGS__,PP_RSEQ_N())
#define PP_NARG_(...) \
         PP_ARG_N(__VA_ARGS__)
#define PP_ARG_N( \
          _1, _2, _3, _4, _5, _6, _7, _8, _9,_10, \
         _11,_12,_13,_14,_15,_16,_17,_18,_19,_20, \
         _21,_22,_23,_24,_25,_26,_27,_28,_29,_30, \
         _31,_32,_33,_34,_35,_36,_37,_38,_39,_40, \
         _41,_42,_43,_44,_45,_46,_47,_48,_49,_50, \
         _51,_52,_53,_54,_55,_56,_57,_58,_59,_60, \
         _61,_62,_63,N,...) N
#define PP_RSEQ_N() \
         63,62,61,60,                   \
         59,58,57,56,55,54,53,52,51,50, \
         49,48,47,46,45,44,43,42,41,40, \
         39,38,37,36,35,34,33,32,31,30, \
         29,28,27,26,25,24,23,22,21,20, \
         19,18,17,16,15,14,13,12,11,10, \
         9,8,7,6,5,4,3,2,1,0

#define LOG(...)        qDebug() << __PRETTY_FUNCTION__

void GraphScene::setGraph(Graph* g) {
    LOG(g);

    _graph = g;

    clear();

    foreach(Node *n, _graph->nodes()) {
        createVisualNode(n, QPointF(0,0));
    }

    foreach(Edge *e, _graph->edges()) {
        createVisualEdge(e, QPointF(0,0));
    }
}

VNode * GraphScene::createVisualNode(Node *n, const QPointF &pos) {
    LOG(n, n->name(), pos);

    qDebug() << "createVisualNode" << n << pos;
    VNode *vn = new VNode(this, n);
    vn->setPos(pos);
    addItem(vn);
    return vn;
}

void GraphScene::addConnector(VEdge *edge, VNode *node) {
    LOG(edge->name(), node->name());

    Incidence i = edge->_edge->incidenceToNode(node->_node);
    QString name = i.name;
    IncidenceDirection dir = i.dir;
    Connector *conn = NULL;
    if (dir == IN) {
        conn = new Connector(node, edge, name);
    } else if (dir == OUT) {
        conn = new Connector(edge, node, name);
    }
    Q_ASSERT(conn);
    edge->_connectors.append(conn);
    addItem(conn);
}

VEdge * GraphScene::createVisualEdge(Edge *e, const QPointF &pos) {
    LOG(e->name(), pos);

    VEdge *ve = new VEdge(this, e);
    ve->setPos(pos);
    addItem(ve);

    foreach(Node *n, e->connectedNodes()) {
        VNode *vn = (VNode*) n->visual();
        if (!vn) {
            vn =  createVisualNode(n, pos);
        }
        qDebug() << "Visual for " << n->name() << " is " << vn;
        addConnector(ve, vn);
    }

    return ve;
}

Node * GraphScene::removeVisualNode(VNode *n) {
    LOG(n->name());

    Node * ret = n->_node;
    foreach (Edge * e, ret->connectedEdges()) {
        VEdge *ve = asEdge(e->visual());
        Q_ASSERT(ve);
        Connector *c = ve->disconnect(n);
        removeItem(c);
        delete c;
    }
    removeItem(n);
    delete n;
    return ret;
}

Edge * GraphScene::removeVisualEdge(VEdge *e) {
    LOG(e->name());

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
    LOG(e->name());

    QPointF pos = e->pos();
    createVisualEdge(removeVisualEdge(e), pos);
}

VElement * GraphScene::createItemByType(int type, const QPointF &pos) {
    LOG(type, pos);

    switch (type) {
    case VNode::Type: {
            Node *n = _graph->createNode();
            return createVisualNode(n, pos);
        }

    case VEdge::Type: {
            Edge *e = _graph->createEdge(_typeName);
            VEdge *ve = createVisualEdge(e, pos);
            Q_ASSERT(ve);
            return ve;
        }
    }
    return NULL;
}

void GraphScene::mousePressEvent(QGraphicsSceneMouseEvent *e) {
    LOG(e);

    if (e->button() == Qt::LeftButton && _type) {
        VElement *item = createItemByType(_type, e->scenePos());
        if (item) {
            itemChanged();
        } else {
            qDebug() << "Unknown item type:" << _type;
        }
        _type = 0;
    } else {
        QGraphicsScene::mousePressEvent(e);
    }
}

void GraphScene::itemChanged() {
    emit needsUpdate();
    //_moved = true;
}

#define TOLERANCE 5

void GraphScene::mouseReleaseEvent(QGraphicsSceneMouseEvent *e) {
    LOG(e);

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

void GraphScene::configEdge(VEdge *e) {
    qDebug() << e->name();
    _graph->runConfig(e->_edge);
}

void GraphScene::removeSelectedItems() {
    LOG();

    foreach (QGraphicsItem *item, selectedItems()) {
        VNode *node = asNode(item);
        if (node) {
            Node *n = removeVisualNode(node);
            _graph->removeNode(n);
            return;
        }
        VEdge *edge = asEdge(item);
        if (edge) {
            Edge *e = removeVisualEdge(edge);
            _graph->removeEdge(e);
            return;
        }
    }
}

void GraphScene::keyPressEvent(QKeyEvent *e) {
    LOG(e);

    if (e->key() == Qt::Key_Delete) {
        removeSelectedItems();
    }
}

void GraphScene::dump() {
    qDebug() << "Rect: " << sceneRect();
    foreach (QGraphicsItem *item, items()) {
        VElement *e = asElement(item);
        if (e) {
            VNode *n = asNode(item);
            if (n) {
                qDebug() << "Node" << n->name() << e->pos();
            } else {
                VEdge *ee = asEdge(item);
                if (ee) {
                    qDebug() << "Edge" << ee->name() << e->pos();
                } else {
                    qDebug() << "unknown (VElement)" << e->name() << e->pos();
                }
            }
        } else {
            qDebug() << "unknown (connector?) " << item;
        }
    }
}
