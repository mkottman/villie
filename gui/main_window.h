#ifndef VILLIE_H
#define VILLIE_H

#include <QtGui/QMainWindow>
#include "ui_main_window.h"

#include "../core/graph.h"

class main_window: public QMainWindow
{
Q_OBJECT

public:
	main_window(QWidget *parent = 0);
	~main_window();

public:
	void setGraph(Graph *graph)
	{
            ui.graphPanel->setGraph(graph);
	}

private:
	Ui::mainWindowClass ui;
};

#endif // VILLIE_H
