#include "main_window.h"

#include <QToolButton>

#include "vnode.h"
#include "vedge.h"

#include <QKeyEvent>

main_window::main_window(QWidget *parent) :
QMainWindow(parent) {
    ui.setupUi(this);
    ui.graphView->setScene(&_graphScene);

    _layouter = new Layouter(&_graphScene);

    connect(ui.actionStart, SIGNAL(triggered()), _layouter, SLOT(startLayouter()));
    connect(ui.actionStop, SIGNAL(triggered()), _layouter, SLOT(stopLayouter()));
    connect(ui.actionReset, SIGNAL(triggered()), _layouter, SLOT(reloadLayouter()));

    connect(&_graphScene, SIGNAL(needsUpdate()), _layouter, SLOT(startLayouter()));

    connect(ui.actionAdd_Node, SIGNAL(triggered()), this, SLOT(addNode()));
    connect(ui.actionAdd_Edge, SIGNAL(triggered()), this, SLOT(addEdge()));

    connect(ui.actionRandomize, SIGNAL(triggered()), this, SLOT(randomize()));

    createToolbar();
}

main_window::~main_window() {

}

void main_window::addNode() {
    _graphScene.setType(VNode::Type);
}

void main_window::addEdge() {
    _graphScene.setType(VEdge::Type);
}

void main_window::connectElements() {
    _graphScene.startConnector();
}

void main_window::reloadGraph() {
    _graphScene.setGraph(_graph);
    _layouter->reloadLayouter();
}

void main_window::randomize() {
    Graph *g = new Graph();

    setGraph(g);

    srand(time(0));
    Edge *lastEdge = 0;
    for (int i = 0; i < 10; i++) {
        Edge *e = g->createEdge();
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
    ui.toolBar->addAction(ui.actionAdd_Node);
    ui.toolBar->addAction(ui.actionAdd_Edge);
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

void main_window::keyPressEvent(QKeyEvent * e) {
    if (e->modifiers() & Qt::ControlModifier) {
        graphPrint("Pressed!");
        _layouter->pause();
    }
    QMainWindow::keyPressEvent(e);
}

void main_window::keyReleaseEvent(QKeyEvent * e) {
    // TODO: do it the right way
    if (e->key() == 16777249 ) {
        graphPrint("Released!");
        _layouter->cont();
    }
    QMainWindow::keyReleaseEvent(e);
}
