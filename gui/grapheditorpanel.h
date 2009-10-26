#ifndef GRAPHEDITORPANEL_H
#define GRAPHEDITORPANEL_H

#include <QtGui/QWidget>
#include "ui_grapheditorpanel.h"

#include "../core/graph.h"
#include "layouter.h"

class GraphEditorPanel : public QWidget
{
    Q_OBJECT

public:
    GraphEditorPanel(QWidget *parent = 0);
    ~GraphEditorPanel();

    void setGraph(Graph *gr);
    
public slots:
    void reloadGraph();
    void updateViewport();

protected:
    virtual void mousePressEvent(QMouseEvent *e);
    virtual void wheelEvent(QWheelEvent *e);
    virtual void mouseMoveEvent(QMouseEvent *e);
    virtual void paintEvent(QPaintEvent *e);
    virtual void timerEvent(QTimerEvent *e);
    
    void layoutStep();

private:
    Graph * _graph;
    Layouter * _layouter;
    QPointF _centroid;
    int _mx, _my;
    Ui::GraphEditorPanelClass ui;
};

#endif // GRAPHEDITORPANEL_H
