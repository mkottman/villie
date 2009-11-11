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

    void startConnector();

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *e);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *e);
    void itemChanged();

    void createVisualNode(Node *n);
    void createVisualEdge(Edge *e);
    Node * removeVisualNode(VNode *n);
    Edge * removeVisualEdge(VEdge *e);
    void reloadEdge(VEdge *e);

    VElement * createItemByType(int type);
    friend class VElement;
    
signals:
    void needsUpdate();

private:
    int _type;
    Graph * _graph;
    bool _moved;
};

#endif	/* _GRAPHSCENE_H */

