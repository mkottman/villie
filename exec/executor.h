#ifndef EXECUTOR_H
#define EXECUTOR_H

#include <QObject>

class Executor : public QObject
{
    Q_OBJECT

public slots:
    void run();
    void stop();
    void pause();
};

#endif // EXECUTOR_H
