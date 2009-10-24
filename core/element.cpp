#include "element.h"

static int elementIdGenerator = 0;

Element::Element() : _id(++elementIdGenerator) {

}
