/* 
 * File:   graphview.h
 * Author: miky
 *
 * Created on October 26, 2009, 9:03 PM
 */

#ifndef _GRAPHVIEW_H
#define	_GRAPHVIEW_H

#include <QGraphicsView>

class GraphView : public QGraphicsView {
public:
    GraphView(QWidget *parent = 0) : QGraphicsView(parent), _zoom(1) {}

public:
    void wheelEvent(QWheelEvent *e);

private:
    double _zoom;
};

#endif	/* _GRAPHVIEW_H */

