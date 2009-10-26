/* 
 * File:   layouter.h
 * Author: miky
 *
 * Created on October 25, 2009, 11:15 PM
 */

#ifndef _LAYOUTER_H
#define	_LAYOUTER_H

#include <QObject>
#include <QTimer>

#include "../core/graph.h"

class Layouter : public QObject{
    Q_OBJECT
    
public:
    Layouter(Graph *g) : _graph(g), _layoutTimer(0) {}
    ~Layouter() {}

    bool isRunning() { return _running; }

protected:
    void timerEvent(QTimerEvent *e);
    
public slots:
    void start();
    void stop();
    void reload();

protected:
    Graph * _graph;
    QList<VElement*> _elements;
    int _layoutTimer;
    bool _running;
};

#endif	/* _LAYOUTER_H */

