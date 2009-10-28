#include "main_window.h"

#include <QToolButton>

#include "vnode.h"
#include "vedge.h"

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

    createToolbar();
}

main_window::~main_window() {

}

void main_window::addNode() {
    _graphScene.setType(VNode::ItemType);
}

void main_window::addEdge() {
    _graphScene.setType(VEdge::ItemType);
}

void main_window::connectElements() {
    _graphScene.startConnector();
}

void main_window::reloadGraph() {
    _graphScene.setGraph(_graph);
    _layouter->reloadLayouter();
}

void main_window::setGraph(Graph* graph) {
    if (_layouter->isRunning())
        _layouter->stopLayouter();
    _graph = graph;
    reloadGraph();
}

void main_window::createToolbar() {
    ui.toolBar->addAction(ui.actionAdd_Node);
    ui.toolBar->addAction(ui.actionAdd_Edge);
}
