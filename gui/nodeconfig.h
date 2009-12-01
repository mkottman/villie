#ifndef NODECONFIG_H
#define NODECONFIG_H

#include <QDialog>

#include "../model/node.h"

namespace Ui {
    class NodeConfig;
}

class NodeConfig : public QDialog {
    Q_OBJECT
public:
    NodeConfig(Node *n, QWidget *parent = 0);
    ~NodeConfig();

    QString value();
    bool isConst();

protected:
    void changeEvent(QEvent *e);

private:
    Ui::NodeConfig *ui;
};

#endif // NODECONFIG_H
