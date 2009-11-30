#ifndef EXECUTOR_H
#define EXECUTOR_H

#include <QObject>
#include <QLinkedList>

#include "../model/common.h"

class Executor : public QObject
{
    Q_OBJECT

public slots:
    void run();
    void stop();
    void pause();

private:
    QLinkedList<Edge*> agenda;
};

#endif // EXECUTOR_H
