/* 
 * File:   layouter.cpp
 * Author: miky
 * 
 * Created on October 25, 2009, 11:15 PM
 */

#include "layouter.h"

#define TIMER_INTERVAL 10

void Layouter::start() {
    if (!_running) {
        _layoutTimer = startTimer(TIMER_INTERVAL);
        _running = true;
    }
}

void Layouter::stop() {
    if (_running) {
        killTimer(_layoutTimer);
        _running = false;
    }
}

void Layouter::reload() {
    if (_running)
        stop();

    _elements.clear();

    foreach(Node *n, _graph->nodes()) {
        VNode *vn = new VNode(n);
        _elements.append(vn);
    }

    foreach(Edge *e, _graph->edges()) {
        VEdge *ve = new VEdge(e);
        _elements.append(ve);
    }
}