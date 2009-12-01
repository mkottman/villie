#include "nodeconfig.h"
#include "ui_nodeconfig.h"

NodeConfig::NodeConfig(Node *n, QWidget *parent) :
    QDialog(parent),
    ui(new Ui::NodeConfig)
{
    ui->setupUi(this);

    if (n->isConst()) {
        ui->constant->setCurrentIndex(1);
    } else {
        ui->constant->setCurrentIndex(0);
    }

    Value val = n->value();
    switch (val.type) {
    case NIL: ui->valueEdit->setText(""); break;
    case NUMBER: ui->valueEdit->setText(QString("%1").arg(val.number)); break;
    case STRING: ui->valueEdit->setText(val.string); break;
    }
}

NodeConfig::~NodeConfig()
{
    delete ui;
}

QString NodeConfig::value() {
    return ui->valueEdit->text();
}

bool NodeConfig::isConst() {
    return ui->constant->currentIndex() == 1;
}

void NodeConfig::changeEvent(QEvent *e)
{
    QDialog::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        ui->retranslateUi(this);
        break;
    default:
        break;
    }
}
