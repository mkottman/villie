#include "executor.h"

#include "../model/graph.h"
#include "../model/edge.h"
#include "../model/node.h"

#include <QDebug>

Executor::Executor(Graph *graph) {
    this->graph = graph;
}

void Executor::run(bool stepping) {
    initialRun();
    if (!stepping) {
        while (!isFinished()) {
            step();
        }
    }
}

bool Executor::isFinished() {
    return agenda.isEmpty();
}

void Executor::schedule(Edge *e) {
    agenda.append(e);
}

void Executor::initialRun() {
    // empty the variables
    foreach (Node * n, graph->nodes()) {
        n->prepareFor(this);
    }

    // constant folding
    foreach (Edge * e, graph->edges()) {
        if (e->hasAllInputs()) {
            schedule(e);
        }
    }
}

void Executor::step() {
    Edge *e = agenda.takeFirst();
    qDebug() << "Executing" << e->name();
    graph->execute(e);
}

void Executor::pause() {

}

// called when value of a node changes
void Executor::valueChanged(Node *n) {
    // check if any outgoing edges are ready for scheduling
    foreach (Edge *e, n->connectedEdges()) {
        Incidence i = e->incidenceToNode(n);
        if (i.dir == IN && e->hasAllInputs())
            schedule(e);
    }
}
