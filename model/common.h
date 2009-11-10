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

#include "element.h"

class Edge;
class Node;
class Graph;
class Value;

typedef QList<Node*> NodeList;
typedef QList<Edge*> EdgeList;

#define UNUSED(x) ((void)x)

#endif /* COMMON_H_ */
