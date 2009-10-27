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
#include "vector.h"
#include "graphscene.h"

class Layouter : public QObject {

    Q_OBJECT

public:
    Layouter(GraphScene *scene) :  _scene(scene), _layoutTimer(0), _running(false) {}

    bool isRunning() {
        return _running;
    }

protected:
    void timerEvent(QTimerEvent * e);

public slots:
    void startLayouter();
    void stopLayouter();
    void reloadLayouter();

protected:
    void layoutStep();
    int findCenter();
    void addAttractive();
    void addRepulsive();
    void moveElements();

protected:
    GraphScene * _scene;
    int _layoutTimer;
    bool _running;
    vector2 _centroid;
};

#endif	/* _LAYOUTER_H */

