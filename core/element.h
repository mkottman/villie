#ifndef ELEMENT_H
#define ELEMENT_H

class VElement;

#include <QString>

class Element
{
public:
    Element();
    virtual ~Element() {}

    virtual QString type() = 0;
    virtual QString name() = 0;
    virtual int id() {
        return _id;
    }

    VElement * visual() {
        return _visual;
    }

    void setVisual(VElement * visual) {
        _visual = visual;
    }
    
protected:
    VElement * _visual;
    int _id;
};

#endif // ELEMENT_H
