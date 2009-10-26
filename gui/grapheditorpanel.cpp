#include "grapheditorpanel.h"

#include <stdlib.h>

#include <QMouseEvent>
#include <QPainter>
#include <QList>
#include <QPointF>
#include <QDebug>


#include <math.h>

#include "velement.h"
#include "vedge.h"
#include "vnode.h"

#define ZOOM_FACTOR 2

GraphEditorPanel::GraphEditorPanel(QWidget *parent)
: QWidget(parent), _graph(0) {
    ui.setupUi(this);
    connect(this, SIGNAL())
    setMouseTracking(true);
}

GraphEditorPanel::~GraphEditorPanel() {

}

void GraphEditorPanel::setGraph(Graph* gr) {
    _graph = gr;
    _layouter = new Layouter(gr);
    _layouter.start();
    update();
}


double K = 1;

static void computeCalm(int nElements) {
    double R = 1;
    K = pow((4.0 * R * R * R * M_PI) / (nElements * 3), 1.0 / 3);
}

static inline double length(const QPointF &p) {
    double x = p.x();
    double y = p.y();
    return sqrt(x * x + y * y) / 100;
}

static inline double dist(const QPointF &p1, const QPointF &p2) {
    return length(p2 - p1);
}

static inline float rep(double distance) {
    return (double) (-(K * K) / distance);
}

static QPointF repulsive(const VElement *v1, const VElement *v2) {
    QPointF force(v2->center() - v1->center());
    double dist = length(force);
    if (dist == 0)
        return QPointF();
    force *= rep(dist) / dist;
    return force;
}

static inline float attr(double distance) {
    return (double) ((distance * distance) / K);
}

static QPointF attractive(const VElement *v1, const VElement *v2) {
    QPointF force(v2->center() - v1->center());
    double dist = length(force);
    if (dist == 0)
        return QPointF();
    force *= attr(dist) / dist;
    return force;
}

void GraphEditorPanel::layoutStep() {
    int count = 0;

    // vypocitaj stred
    _centroid = QPointF();

    foreach(VElement *v, _vElements) {
        v->_force = QPointF();
        _centroid += v->center();
        count++;
    }

    _centroid /= count;

    computeCalm(count);

    // qDebug() << "Mam " << count << " bodov, K = " << K;

    // qDebug() << "Pocitam odpudive sily";

    // odpudiva sila medzi vsetkymi prvkami

    foreach(VElement *v, _vElements) {

        foreach(VElement *u, _vElements) {
            if (v != u)
                v->_force += repulsive(v, u);
        }
    }

    // qDebug() << "Pocitam pritazlive sily";

    // pritazliva sila na hranach

    foreach(Edge *e, _graph->edges()) {
        VElement *v = e->visual();

        foreach(Node *n, e->connectedNodes()) {
            VElement *u = n->visual();
            QPointF force = attractive(v, u);
            v->_force += force;
            u->_force -= force;
        }
    }

    // qDebug() << "Aplikujem silu";

    // aplikovanie sil

    foreach(VElement *v, _vElements) {
        v->_force *= 0.05;
        v->moveBy(v->_force);
    }

    // prekreslenie
    update();
}

void GraphEditorPanel::timerEvent(QTimerEvent* e) {
    if (e->timerId() == _layoutTimer && !qApp->hasPendingEvents())
        layoutStep();
}

int i = 0;

void GraphEditorPanel::mousePressEvent(QMouseEvent *e) {
    qDebug() << "Press" << i++ << e->type();
}

void GraphEditorPanel::mouseMoveEvent(QMouseEvent *e) {
    _mx = e->x();
    _my = e->y();
    update();
}

void GraphEditorPanel::wheelEvent(QWheelEvent* e) {
    qDebug() << "Wheel" << i++ << e->delta();
    if (e->delta() > 0) {
        _zoom *= ZOOM_FACTOR;
    } else {
        _zoom /= ZOOM_FACTOR;
    }
}

void GraphEditorPanel::paintEvent(QPaintEvent *event) {
    QPainter p(this);

    p.drawRect(event->rect().adjusted(0, 0, -1, -1));
    p.setPen(QColor(255, 0, 0));
    p.drawEllipse(_mx - 5, _my - 5, 10, 10);

    p.setPen(Qt::black);

    if (!_graph)
        return;

    foreach(Edge *e, _graph->edges()) {
        VElement *ve = e->visual();

        foreach(Node *n, e->connectedNodes()) {
            VElement *vn = n->visual();
            p.drawLine(vn->center(), ve->center());
        }
        ve->render(p);
    }

    foreach(Node *n, _graph->nodes()) {
        VElement *vn = n->visual();
        vn->render(p);
    }
}
