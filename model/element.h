#ifndef ELEMENT_H
#define ELEMENT_H

class VElement;

#include <QObject>
#include <QString>
#include <lua.hpp>

class Element {

public:
    Element(lua_State *L);
    ~Element();

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

    virtual void push();
    
protected:
    VElement * _visual;
    lua_State *L;
    int _id;
    int _ref;
};

#endif // ELEMENT_H
