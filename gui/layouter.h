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

#include "../model/graph.h"
#include "vector.h"
#include "graphscene.h"

class Layouter : public QObject {

    Q_OBJECT

public:
    Layouter(GraphScene *scene) :  _scene(scene), _layoutTimer(0), _running(false), _paused(false) {}

    bool isRunning() {
        return _running;
    }

protected:
    void timerEvent(QTimerEvent * e);

public slots:
    void startLayouter();
    void stopLayouter();
    void reloadLayouter();
    void pause();
    void cont();
    void trigger();

protected:
    void initialize();
    void layoutStep();
    void addAttractive();
    void addRepulsive();
    void moveElements();
    void updatePositions();

protected:
    GraphScene * _scene;
    int _layoutTimer;
    bool _running;
    vector2 _centroid;
    bool _paused;
    QList<VElement*> _workingSet;
};

#endif	/* _LAYOUTER_H */

