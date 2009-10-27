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
#include "velement.h"

class GraphScene : public QGraphicsScene {

    Q_OBJECT

public:
    GraphScene() {}
    virtual ~GraphScene() {}

    void setGraph(Graph *g);
    Graph *graph() { return _graph; }

protected:
    void itemChanged();
    friend class VElement;
    
signals:
    void needsUpdate();

private:
    Graph * _graph;
};

#endif	/* _GRAPHSCENE_H */

