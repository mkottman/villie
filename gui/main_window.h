#ifndef VILLIE_H
#define VILLIE_H

#include <QMainWindow>
#include "ui_main_window.h"

#include "../model/graph.h"
#include "layouter.h"
#include "../exec/executor.h"

class main_window : public QMainWindow {
    Q_OBJECT

public:
    main_window(QWidget *parent = 0);
    ~main_window();

public:

    void setGraph(Graph *graph);

    void keyReleaseEvent ( QKeyEvent * keyEvent );

public Q_SLOTS:
    void reloadGraph();
    void addNode();
    void addEdge(const QString &type);
    void connectElements();
    void randomize();
    void graphPrint(const QString &str);
    void graphError(const QString &str);

    void save();
    void load();

private:
    void createToolbar();

private:
    Graph * _graph;
    Executor * _executor;
    Layouter * _layouter;
    GraphScene _graphScene;
    Ui::mainWindowClass ui;
};

#endif // VILLIE_H
