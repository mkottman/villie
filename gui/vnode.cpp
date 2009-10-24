#include "vnode.h"

void VNode::render(QPainter &p) {
    p.setBrush(Qt::white);
    p.drawEllipse(_rect);
    p.drawText(_rect, name());
}

