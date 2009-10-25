#include "vedge.h"

void VEdge::render(QPainter &p) {
    QRadialGradient rg(_rect.center(), _rect.height(), _rect.center());
    rg.setColorAt(0, Qt::white);
    rg.setColorAt(1, Qt::yellow);
    p.setBrush(rg);
    p.setPen(QPen(Qt::black, 2));
    p.drawRect(_rect);
    p.drawText(_rect, name(), QTextOption(Qt::AlignCenter));
}
