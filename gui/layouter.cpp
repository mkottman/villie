/* 
 * File:   layouter.cpp
 * Author: miky
 * 
 * Created on October 25, 2009, 11:15 PM
 */

#include <QGraphicsItem>
#include <QTimerEvent>

#include "layouter.h"
#include "velement.h"

#define TIMER_INTERVAL 10

void Layouter::startLayouter() {
    if (!_running) {
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

void Layouter::reloadLayouter() {
    if (_running)
        stopLayouter();

    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *ve = qgraphicsitem_cast<VElement*>(item);
        if (ve) {
            ve->_force = vector2(0, 0);
            ve->setPos(qrand() % 100, qrand() % 100);
        }
    }

    startLayouter();
}

void Layouter::timerEvent(QTimerEvent* e) {
    if (e->timerId() == _layoutTimer) {
        layoutStep();
    }
}


double K = 1;

static void computeCalm(int nElements) {
    double R = 50;
    K = pow((4.0 * R * R * R * M_PI) / (nElements * 3), 1.0 / 3);
}

static inline float rep(double distance) {
    return (double) (-(K * K) / distance);
}

static vector2 repulsive(const VElement *v1, const VElement *v2) {
    vector2 force(v2->pos() - v1->pos());
    double dist = force.length();
    if (dist == 0)
        return QPointF();
    force.normalize();
    force *= rep(dist);
    return force;
}

static inline double attr(double distance) {
    return (double) ((distance * distance) / K);
}

static vector2 attractive(const VElement *v1, const VElement *v2) {
    vector2 force(v2->pos() - v1->pos());
    double dist = force.length();
    if (dist == 0)
        return vector2();
    force.normalize();
    force *= attr(dist);
    return force;
}

void Layouter::layoutStep() {
    int count = 0;

    // vypocitaj stred
    _centroid = vector2();

    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *ve = qgraphicsitem_cast<VElement*>(item);
        if (ve) {
            ve->_force = vector2();
            _centroid += ve->pos();
            count++;
        }
    }

    _centroid /= count;

    computeCalm(count);

    // odpudiva sila medzi vsetkymi prvkami

    foreach(QGraphicsItem *item1, _scene->items()) {
        VElement *u = qgraphicsitem_cast<VElement*>(item1);
        if (u) {

            foreach(QGraphicsItem *item2, _scene->items()) {
                VElement *v = qgraphicsitem_cast<VElement*>(item2);
                if (v) {
                    if (u != v)
                        u->_force += repulsive(u, v);
                }
            }
        }
    }

    // qDebug() << "Pocitam pritazlive sily";

    // pritazliva sila na hranach

    foreach(Edge *e, _scene->graph()->edges()) {
        VElement *v = e->visual();

        foreach(Node *n, e->connectedNodes()) {
            VElement *u = n->visual();
            vector2 force = attractive(v, u);
            v->_force += force;
            u->_force -= force;
        }
    }

    // qDebug() << "Aplikujem silu";

    // aplikovanie sil

    foreach(QGraphicsItem *item, _scene->items()) {
        VElement *v = qgraphicsitem_cast<VElement*>(item);
        if (v) {
            v->_force *= 0.05;
            v->moveBy(v->_force.x, v->_force.y);
        }
    }
}
