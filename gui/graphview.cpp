/* 
 * File:   graphview.cpp
 * Author: miky
 * 
 * Created on October 26, 2009, 9:03 PM
 */

#include "graphview.h"
#include <QWheelEvent>
#include <QDebug>

#include "graphscene.h"

#define ZOOM_FACTOR 1.5

void GraphView::wheelEvent(QWheelEvent* e) {
    if (e->modifiers() & Qt::ControlModifier) {
        if (e->delta() > 0) {
            scale(ZOOM_FACTOR, ZOOM_FACTOR);
        } else {
           scale(1/ZOOM_FACTOR, 1/ZOOM_FACTOR);;
        }
        
    }
    QGraphicsView::wheelEvent(e);
}

void GraphView::keyPressEvent(QKeyEvent *e) {
    ((GraphScene*)scene())->keyPressEvent(e);
    QGraphicsView::keyPressEvent(e);
}
