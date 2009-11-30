#include "element.h"

static int elementIdGenerator = 0;

Element::Element(lua_State *L) : L(L), _id(++elementIdGenerator) {
    _visual = 0;
    Element **p = (Element**) lua_newuserdata(L, sizeof(Element*));
    *p = this;
    _ref = luaL_ref(L, LUA_REGISTRYINDEX);
}

void Element::push() {
    lua_rawgeti(L, LUA_REGISTRYINDEX, _ref);
}

Element::~Element() {
    luaL_unref(L, LUA_REGISTRYINDEX, _ref);
}
