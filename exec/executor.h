#ifndef EXECUTOR_H
#define EXECUTOR_H

#include <QObject>
#include <QLinkedList>

#include "../model/common.h"

class Executor : public QObject
{
    Q_OBJECT

public:
    Executor(Graph *graph);

    void initialRun();
    void schedule(Edge *e);
    bool isFinished();
    void valueChanged(Node *n);

public slots:
    void run(bool stepping = false);
    void pause();
    void step();

private:
    Graph *graph;
    QLinkedList<Edge*> agenda;
};

#endif // EXECUTOR_H
