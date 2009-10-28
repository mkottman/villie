#ifndef VILLIE_H
#define VILLIE_H

#include <QtGui/QMainWindow>
#include "ui_main_window.h"

#include "../core/graph.h"
#include "layouter.h"

class main_window : public QMainWindow {
    Q_OBJECT

public:
    main_window(QWidget *parent = 0);
    ~main_window();

public:

    void setGraph(Graph *graph);
    
public slots:
    void reloadGraph();
    void addNode();
    void addEdge();
    void connectElements();

private:
    void createToolbar();

private:
    Graph * _graph;
    Layouter * _layouter;
    GraphScene _graphScene;
    Ui::mainWindowClass ui;
};

#endif // VILLIE_H
