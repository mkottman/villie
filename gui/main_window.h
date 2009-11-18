#ifndef VILLIE_H
#define VILLIE_H

#include <QtGui/QMainWindow>
#include "ui_main_window.h"

#include "../model/graph.h"
#include "layouter.h"

class main_window : public QMainWindow {
    Q_OBJECT

public:
    main_window(QWidget *parent = 0);
    ~main_window();

public:

    void setGraph(Graph *graph);

    void keyReleaseEvent ( QKeyEvent * keyEvent );

public slots:
    void reloadGraph();
    void addNode();
    void addEdge();
    void connectElements();
    void randomize();
    void graphPrint(const QString &str);
    void graphError(const QString &str);

private:
    void createToolbar();

private:
    Graph * _graph;
    Layouter * _layouter;
    GraphScene _graphScene;
    Ui::mainWindowClass ui;
};

#endif // VILLIE_H
