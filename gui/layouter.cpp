/* 
 * File:   layouter.cpp
 * Author: miky
 * 
 * Created on October 25, 2009, 11:15 PM
 */

#include <QGraphicsItem>
#include <QTimerEvent>

#include <QDebug>

#include "layouter.h"
#include "velement.h"

#define TIMER_INTERVAL 50
#define LAYOUT_STEPS 10

void Layouter::startLayouter() {
    if (!_running && _scene->graph() && !_paused) {
        _layoutTimer = startTimer(TIMER_INTERVAL);
        _running = true;
    }
}

void Layouter::stopLayouter() {
    if (_running) {
        killTimer(_layoutTimer);
        _running = false;
    }
}

void Layouter::pause() {
    _paused = true;
}

void Layouter::cont() {
    _paused = false;
    initialize();
    startLayouter();
}

void Layouter::trigger() {
    if (_paused)
        cont();
    else
        pause();
}

void Layouter::reloadLayouter() {
    if (_running)
        stopLayouter();

    _workingSet.clear();
    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *ve = asElement(item);
        if (ve) {
            _workingSet.append(ve);
            ve->_force = vector2(0, 0);
            ve->setPos(qrand() % 100, qrand() % 100);
        }
    }

    startLayouter();
}

void Layouter::timerEvent(QTimerEvent* e) {
    if (!_scene->graph()) {
        stopLayouter();
        return;
    }
    if (e->timerId() == _layoutTimer) {
        initialize();
        for (int i = 0; _running && i < LAYOUT_STEPS; i++)
            layoutStep();
        updatePositions();
    }
}


const double MAX_DISTANCE = 300;


double K = 1;

static void computeCalm(int nElements) {
    UNUSED(nElements);
    // double R = 50;
    // K = pow((4.0 * R * R * R * M_PI) / (nElements * 3), 1.0 / 3);
    K = 50;
}

static inline float rep(double distance) {
    return (double) (-(K * K) / distance);
}

static vector2 repulsive(VElement *v1, VElement *v2) {
    vector2 force = v2->_pos - v1->_pos;
    double dist = force.length();
    if (dist < 5) {
        v2->_pos += vector2(rand() % 10, rand() % 10);
        force = v2->_pos - v1->_pos;
    } else if (dist > MAX_DISTANCE) {
        return vector2();
    }
    force.normalize();
    force *= rep(dist);
    return force;
}

static inline double attr(double distance) {
    return (double) ((distance * distance) / K);
}

static vector2 attractive(const VElement *v1, const VElement *v2) {
    vector2 force(v2->_pos - v1->_pos);
    double dist = force.length();
    if (dist == 0)
        return vector2();
    force.normalize();
    force *= attr(dist);
    return force;
}

void Layouter::initialize() {
    int count = 0;
    _centroid = vector2();
    _workingSet.clear();

    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *ve = asElement(item);
        if (ve) {
            ve->updatePos();
            _centroid += ve->_pos;
            _workingSet.append(ve);
            count++;
        }
    }

    _centroid /= count;

    computeCalm(count);
}

void Layouter::layoutStep() {
    addRepulsive();
    addAttractive();
    moveElements();
}

void Layouter::addAttractive() {
    foreach(Edge *e, _scene->graph()->edges()) {
        VElement *v = e->visual();
        foreach(Node *n, e->connectedNodes()) {
            VElement *u = n->visual();
            vector2 force = attractive(v, u);
            v->_force += force;
            u->_force -= force;
        }
    }
}

void Layouter::addRepulsive() {
    foreach(VElement *u, _workingSet) {
        if (!u->_ignored) {
            foreach(VElement *v, _workingSet) {
                if (!v->_ignored && u != v) {
                    u->_force += repulsive(u, v);
                }
            }
        }
    }
}

const double MAX_FORCE = 10;
const double MIN_FORCE = 1;
const double ALPHA = 0.05;
const int MIN_PORTION = 25;

void Layouter::moveElements() {
    int moved=0;
    int total=0;
    foreach(VElement *v, _workingSet) {
        if (!v->_ignored) {
            total++;
            vector2 *force = &(v->_force);

            *force *= ALPHA;

            double len = force->length();
            if (len > MAX_FORCE) {
                force->normalize();
                *force *= MAX_FORCE;
            }
            if (len > MIN_FORCE) {
                v->_pos += *force;
                moved++;
            }
            *force = vector2();
        }
    }
    // stop if less than MIN_PORTION % of items moved
    if (total == 0 || 100*moved/total < MIN_PORTION) {
        stopLayouter();
    }
}

void Layouter::updatePositions() {
    foreach(VElement *v, _workingSet) {
        if (!v->_ignored) {
            v->applyPos();
        }
    }
}
