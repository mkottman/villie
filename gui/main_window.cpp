#include "main_window.h"

#include <QToolButton>

#include "vnode.h"
#include "vedge.h"

#include <QKeyEvent>
#include <QDebug>

main_window::main_window(QWidget *parent) :
QMainWindow(parent) {
    ui.setupUi(this);
    ui.graphView->setScene(&_graphScene);

    _layouter = new Layouter(&_graphScene);

    connect(ui.actionStart, SIGNAL(triggered()), _layouter, SLOT(startLayouter()));
    connect(ui.actionStop, SIGNAL(triggered()), _layouter, SLOT(stopLayouter()));
    connect(ui.actionReset, SIGNAL(triggered()), _layouter, SLOT(reloadLayouter()));

    connect(ui.actionDump, SIGNAL(triggered()), &_graphScene, SLOT(dump()));

    connect(&_graphScene, SIGNAL(needsUpdate()), _layouter, SLOT(startLayouter()));

    connect(ui.actionRandomize, SIGNAL(triggered()), SLOT(randomize()));

    ui.actionRandomize->trigger();
}

main_window::~main_window() {

}

void main_window::addNode() {
    _graphScene.setType(VNode::Type);
}

void main_window::addEdge(const QString &type) {
    qDebug() << "About to create edge: " << type;
    _graphScene.setTypeName(type);
    _graphScene.setType(VEdge::Type);
}

void main_window::connectElements() {
    _graphScene.startConnector();
}

void main_window::reloadGraph() {
    _graphScene.setGraph(_graph);
    _layouter->reloadLayouter();
    createToolbar();
}

void main_window::randomize() {
    Graph *g = new Graph();
    setGraph(g);

/*
    EdgeTypeMap typeMap = g->types();
    int typeCount = typeMap.count();

    srand(time(0));
    Edge *lastEdge = 0;
    for (int i = 0; i < 10; i++) {
        QString typeStr = (typeMap.begin() + (rand() % typeCount)).value()->name();
        qDebug() << "Creating new edge:" << typeStr;
        Edge *e = g->createEdge(typeStr);
        int nodes = rand() % 5 + 1;
        for (int j = 0; j < nodes; j++) {
            Node *n = g->createNode();
            if (j == 0 && lastEdge) {
                g->connect(n, lastEdge);
            }
            g->connect(n, e);
        }
        lastEdge = e;
    }
*/

    reloadGraph();
}

void main_window::setGraph(Graph* graph) {
    if (_layouter->isRunning())
        _layouter->stopLayouter();

    if (_graph) {
        disconnect(this, SLOT(graphPrint(QString)));
        disconnect(this, SLOT(graphError(QString)));
    }

    _graph = graph;

    connect(graph, SIGNAL(printed(QString)), this, SLOT(graphPrint(QString)));
    connect(graph, SIGNAL(error(QString)), this, SLOT(graphError(QString)));

    reloadGraph();
}

void main_window::createToolbar() {
    if (_graph) {
        ui.toolBar->clear();
        foreach (EdgeType * t, _graph->types()) {
            QAction *act = new QAction(t->name(), this);
            connect(act, SIGNAL(triggered()), t, SLOT(trigger()));
            connect(t, SIGNAL(activate(QString)), this, SLOT(addEdge(QString)));
            ui.toolBar->addAction(act);
        }
    }
    ui.toolBar->addAction(ui.actionDump);
}

void main_window::graphPrint(const QString &str) {
    ui.log->setTextColor(Qt::black);
    ui.log->setFontWeight(QFont::Normal);
    ui.log->moveCursor(QTextCursor::End);
    ui.log->insertPlainText(str + "\n");
}

void main_window::graphError(const QString &str) {
    ui.log->setTextColor(Qt::red);
    ui.log->setFontWeight(QFont::Bold);
    ui.log->moveCursor(QTextCursor::End);
    ui.log->insertPlainText(str + "\n");
}

void main_window::keyReleaseEvent(QKeyEvent * e) {
    if (e->key() == Qt::Key_Space ) {
        _layouter->trigger();
    }
    QMainWindow::keyReleaseEvent(e);
}
