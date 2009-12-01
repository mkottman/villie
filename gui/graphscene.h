/* 
 * File:   graphscene.h
 * Author: miky
 *
 * Created on October 26, 2009, 4:03 PM
 */

#ifndef _GRAPHSCENE_H
#define	_GRAPHSCENE_H

#include <QGraphicsScene>
#include <QGraphicsSceneMouseEvent>
#include <QKeyEvent>

#include "../model/graph.h"
#include "velement.h"
#include "vedge.h"
#include "vnode.h"


class GraphScene : public QGraphicsScene {

    Q_OBJECT

public:
    GraphScene() : _type(0), _graph(0), _moved(false) {}
    virtual ~GraphScene() {}

    void setGraph(Graph *g);
    Graph *graph() { return _graph; }

    void setType(int type) { _type = type; }
    void setTypeName(const QString &name) { _typeName = name; }

    void startConnector();

    void configEdge(VEdge *e);
    void configNode(VNode *vn);
    void keyPressEvent(QKeyEvent *e);

    void removeSelectedItems();

public slots:
    void dump();

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *e);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *e);
    void itemChanged();

    VNode * createVisualNode(Node *n, const QPointF &pos);
    VEdge * createVisualEdge(Edge *e, const QPointF &pos);
    Node * removeVisualNode(VNode *n);
    Edge * removeVisualEdge(VEdge *e);
    void reloadEdge(VEdge *e);
    void addConnector(VEdge *edge, VNode *node);

    VElement * createItemByType(int type, const QPointF &pos);
    friend class VElement;
    
signals:
    void needsUpdate();

private:
    int _type;
    QString _typeName;
    Graph * _graph;
    bool _moved;
};

#endif	/* _GRAPHSCENE_H */

