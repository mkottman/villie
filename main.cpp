#include "gui/main_window.h"
#include "model/graph.h"

#include <cstdlib>

#include <QtGui>
#include <QApplication>

#include <qdebug.h>

int main(int argc, char *argv[]) {
    QApplication a(argc, argv);

    srand(time(NULL));

    main_window w;
    w.show();

    return a.exec();
}
