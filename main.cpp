#include "gui/main_window.h"
#include "core/Graph.h"

#include <cstdlib>

#include <QtGui>
#include <QApplication>

#include <qdebug.h>

#include "core/Graph.h"

int main(int argc, char *argv[])
{
	QApplication a(argc, argv);
	Graph *g = new Graph();

    Edge *lastEdge = 0;
    for (int i=0; i<10; i++) {
        Edge *e = new Edge();
        g->addEdge(e);
        int nodes = rand() % 5 + 1;
        for (int j = 0; j < nodes; j++) {
            Node *n = new Node();
            g->addNode(n);
            if (j==0 && lastEdge) {
                g->connect(n, lastEdge);
            }
            g->connect(n, e);
        }
        lastEdge = e;
    }

	main_window w;
	w.setGraph(g);
	w.show();

	return a.exec();
}
