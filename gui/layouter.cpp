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
}

void Layouter::reloadLayouter() {
    if (_running)
        stopLayouter();

    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *ve = asElement(item);
        if (ve) {
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
        for (int i = 0; i < LAYOUT_STEPS; i++)
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
    K = 30;
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

    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *ve = asElement(item);
        if (ve) {
            ve->updatePos();
            _centroid += ve->_pos;
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
    foreach(QGraphicsItem *item1, _scene->items()) {
        VElement *u = asElement(item1);
        if (u && !u->_ignored) {
            foreach(QGraphicsItem *item2, _scene->items()) {
                VElement *v = asElement(item2);
                if (v && !v->_ignored) {
                    if (u != v)
                        u->_force += repulsive(u, v);
                }
            }
        }
    }
}

const double MAX_FORCE = 20;
const double MIN_FORCE = 0.5;
const double ALPHA = 0.05;
const int MIN_PORTION = 25;

void Layouter::moveElements() {
    int moved=0;
    int total=0;
    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *v = asElement(item);
        if (v && !v->_ignored) {
            total++;
            v->_force *= ALPHA;
            double len = v->_force.length();
            if (len > MAX_FORCE) {
                v->_force.normalize();
                v->_force *= MAX_FORCE;
            }
            if (len > MIN_FORCE) {
                v->_pos += v->_force;
                moved++;
            }
            v->_force = vector2();
        }
    }
    // stop if less than MIN_PORTION % of items moved
    if (100*moved/total < MIN_PORTION) {
        stopLayouter();
    }
}

void Layouter::updatePositions() {
    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *v = asElement(item);
        if (v && !v->_ignored) {
            v->applyPos();
        }
    }
}
