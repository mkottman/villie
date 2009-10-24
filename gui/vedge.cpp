#include "vedge.h"

void VEdge::render(QPainter &p) {
    p.setBrush(Qt::yellow);
    p.drawRect(_rect);
    p.drawText(_rect, name());
}
