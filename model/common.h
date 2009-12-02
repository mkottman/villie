/*
 * common.h
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#ifndef COMMON_H_
#define COMMON_H_

#include <QString>
#include <QList>

#include <lua.hpp>

void dumpStackX(const char *func, lua_State *L);
#define dumpStack(L) dumpStackX(__PRETTY_FUNCTION__, L)

#include "edgetype.h"
#include "element.h"

class Edge;
class Node;
class Graph;
class Value;

typedef QList<Node*> NodeList;
typedef QList<Edge*> EdgeList;

#define UNUSED(x) ((void)x)

#endif /* COMMON_H_ */
