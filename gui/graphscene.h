/* 
 * File:   graphscene.h
 * Author: miky
 *
 * Created on October 26, 2009, 4:03 PM
 */

#ifndef _GRAPHSCENE_H
#define	_GRAPHSCENE_H

#include <QGraphicsScene>
#include "../core/graph.h"

class GraphScene : public QGraphicsScene {
public:
    GraphScene() {}

    void setGraph(Graph *g);
    Graph *graph() { return _graph; }

private:
    Graph * _graph;
};

#endif	/* _GRAPHSCENE_H */

