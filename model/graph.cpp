/*
 * Graph.cpp
 *
 *  Created on: Oct 22, 2009
 *      Author: MKottman
 */

#include "graph.h"

#include <QFile>
#include <QDir>
#include <QMessageBox>
#include <QDomDocument>
#include <QDebug>
#include "configwindow.h"

#define OP_PATH "ops"

Graph::Graph() {
    L = luaL_newstate();
    luaL_openlibs(L);

    registerFunctions();

    QDir lib(OP_PATH);
    QStringList filters;
    filters << "*.lua";
    foreach(QString file, lib.entryList(filters, QDir::Files)) {
        qDebug() << "Loading: " << file;
        file.prepend(OP_PATH "/");
        registerEdgeType(file);
    }
}

Graph::~Graph()
{
    foreach (Edge *e, _edges) {
        delete e;
    }
    foreach (Node *n, _nodes) {
        delete n;
    }
}

Node * Graph::createNode(const QString &type) {
    // TODO: create custom node by type
    Node * node = new Node(L);
    _nodes.append(node);
    return node;
}

void Graph::connect(Node *node, Edge *edge, const QString &name, IncidenceDirection dir) {
    edge->connect(node, name, dir);
}

EdgeList Graph::edges() {
    return _edges;
}

void Graph::removeEdge(Edge *edge) {
    _edges.removeOne(edge);
}


void dumpStackX(const char *func, lua_State *L) {
    qDebug() << "Stack for " << func;
    int top = lua_gettop(L);
    for (int i=1; i<=top; i++) {
        QString val;
        switch(lua_type(L, i)) {
        case LUA_TNIL: val = "nil"; break;
        case LUA_TNUMBER: val = QString("%1").arg(lua_tonumber(L, i)); break;
        case LUA_TSTRING: val = lua_tostring(L, i); break;
        default: val = QString("0x%1").arg((long)lua_topointer(L, i), 8, 16);
        }

        qDebug() << i << " : " << luaL_typename(L, i) << " = " << val;
    }
}



void Graph::createNodesForEdge(Edge *edge, EdgeType *type) {
    qDebug() << "createNodesForEdge" << edge->name() << type->name();

    int top = lua_gettop(L);

    lua_rawgeti(L, LUA_REGISTRYINDEX, type->proto());
    lua_pushnil(L);
    while (lua_next(L, -2)) {
        // dumpStack(L);
        int tab = lua_gettop(L);

        lua_rawgeti(L, tab, 1);
        size_t len = 0;
        const char *pName = lua_tolstring(L, -1, &len);
        QString name = QString::fromUtf8(pName, len);


        lua_rawgeti(L, tab, 2);
        int d = lua_tonumber(L, -1);
        IncidenceDirection dir;
        if (d == 1) {
            dir = IN;
        } else {
            dir = OUT;
        }

        qDebug() << "Creating node " << name << " in direction: " << dir;
        Node *n = createNode("");
        edge->connect(n, name, dir);

        lua_settop(L, tab - 1);
    }

#define IT QHash<Incidence,Node*>
    for (IT::const_iterator it = edge->_nodes.constBegin(); it != edge->_nodes.constEnd(); it++) {
        qDebug() << it.key().name << " : " << it.value();
    }

    lua_settop(L, top);
}

Edge * Graph::createEdge(const QString &type) {
    qDebug() << "createEdge" << type;

    EdgeType *tp = _types.value(type);
    Edge * edge = new Edge(L, tp);
    _edges.append(edge);

    createNodesForEdge(edge, tp);

    return edge;
}

NodeList Graph::nodes()
{
    return _nodes;
}

void Graph::removeNode(Node *node)
{
    foreach (Edge *e, node->connectedEdges()) {
        e->disconnect(node);
    }
    _nodes.removeOne(node);
}

void Graph::mergeNode(Node *from, Node *to) {
    foreach (Edge * e, from->connectedEdges()) {
        Incidence i = e->disconnect(from);
        qDebug() << "Disconnected" << from->name() << "from" << e->name() << "as" << i.name;
        e->connect(to, i.name, i.dir);
    }
    removeNode(from);
}

int Graph::luaEdges(lua_State *L) {
    Graph *g = (Graph*) lua_touserdata(L, lua_upvalueindex(1));
    int len = g->_edges.size();
    lua_createtable(L, len, 0);
    for (int i=0; i<len; i++) {
        g->_edges.at(i)->push();
        lua_rawseti(L, -2, i+1);
    }
    return 1;
}

int Graph::luaNodes(lua_State *L) {
    Graph *g = (Graph*) lua_touserdata(L, lua_upvalueindex(1));
    int len = g->_nodes.size();
    lua_createtable(L, len, 0);
    for (int i=0; i<len; i++) {
        g->_nodes.at(i)->push();
        lua_rawseti(L, -2, i+1);
    }
    return 1;
}

int Graph::luaPrint(lua_State *L) {
    Graph *g = (Graph*) lua_touserdata(L, lua_upvalueindex(1));
    QString str;
    int top = lua_gettop(L);

    lua_getglobal(L, "tostring");

    dumpStack(L);

    for (int i=1; i<=top; i++) {
        lua_pushvalue(L, -1);           // p1 p2 p3 tostring tostring
        lua_pushvalue(L, i);            // p1 p2 p3 tostring tostring pi
        dumpStack(L);
        lua_pcall(L, 1, 1, 0);              // p1 p2 p3 tostring si
        str += lua_tostring(L, -1);
        lua_pop(L, 1);
        if (i<top) str += "\t";
    }
    lua_settop(L, top);

    emit g->printed(str);

    return 0;
}

const luaL_Reg globals[] = {
    {"print", &Graph::luaPrint},
    {0,0}
};

const luaL_Reg methods[] = {
    {"nodes", &Graph::luaNodes},
    {"edges", &Graph::luaEdges},
    {0,0}
};

void Graph::registerFunctions() {
    lua_createtable(L, 0, 0);
    int indexTable = lua_gettop(L);

    const luaL_Reg *l;

    for (l = methods; l->name; l++) {
        lua_pushstring(L, l->name);
        lua_pushlightuserdata(L, (void*)this);
        lua_pushcclosure(L, l->func, 1);
        lua_settable(L, indexTable);
    }

    for (l = globals; l->name; l++) {
        lua_pushlightuserdata(L, (void*)this);
        lua_pushcclosure(L, l->func, 1);
        lua_setglobal(L, l->name);
    }

    lua_pushnumber(L, 1);
    lua_setfield(L, LUA_GLOBALSINDEX, "IN");

    lua_pushnumber(L, 2);
    lua_setfield(L, LUA_GLOBALSINDEX, "OUT");

    Edge::registerMethods(L);
    Node::registerMethods(L);
}

void Graph::runConfig(Edge *e) {
    EdgeType *type = e->edgeType();
    lua_rawgeti(L, LUA_REGISTRYINDEX, type->configFunction());
    e->push();
    lua_pcall(L, 1, 2, 0);

    // 1 - hodnoty a ich typy
    // 2 - navratova funkcia

    if (lua_type(L, -2) != LUA_TTABLE) {
        emitError(QString("Config: Table expected as result 1, got %1").arg(lua_typename(L, -2)));
    } else {
        ConfigWindow *conf = new ConfigWindow(type->name());
        lua_pushnil(L);
        while (lua_next(L, -3)) {
            size_t len = 0;
            QString name = QString::fromUtf8(lua_tolstring(L, -2, &len), len);
            QString type = QString::fromUtf8(lua_tolstring(L, -1, &len), len);
            conf->addVariable(name, type);
            lua_pop(L, 1);
        }
        conf->exec();
    }
}

void Graph::execute(Edge *e) {
    EdgeType *type = e->edgeType();
    lua_rawgeti(L, LUA_REGISTRYINDEX, type->runFunction());
    e->push();
    lua_pcall(L, 1, 0, 0);
}


/** Registers an edge type from file.

  \param fileName Name of file, which contains definitions of edge

Assumes the source file is already loaded on top of Lua stack.
Retrieves all relevant info from the return value of the Lua source. Handles errors by notifying through
the error(QString) signal if there are any receivers, or by showing QMessageBox
*/
void Graph::registerEdgeType(const QString &fileName) {
    int top = lua_gettop(L);

    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");

    int err = luaL_loadfile(L, qPrintable(fileName));
    if (err == 0) {
        err = lua_pcall(L, 0, 1, -2);
        if (err == 0) {
            if (lua_type(L, -1) == LUA_TTABLE) {
                int table = lua_gettop(L);

                lua_getfield(L, table, "name");
                QString name = lua_tostring(L, -1);

                lua_getfield(L, table, "color");
                QColor color(lua_tostring(L, -1));

                lua_getfield(L, table, "run");
                int runref = luaL_ref(L, LUA_REGISTRYINDEX);

                lua_getfield(L, table, "config");
                int configref = luaL_ref(L, LUA_REGISTRYINDEX);

                lua_getfield(L, table, "proto");
                int protoref = luaL_ref(L, LUA_REGISTRYINDEX);

                qDebug() << "Registering type" << name << color << protoref << runref << configref;

                EdgeType *type = new EdgeType(name, color, protoref, runref, configref);
                _types.insert(name, type);
            } else {
                err = 1;
                lua_pushliteral(L, "Error while loading ");
                lua_pushstring(L, qPrintable(fileName));
                lua_pushliteral(L, ": table expected, got ");
                lua_pushstring(L, lua_typename(L, lua_type(L, -1)));
                lua_concat(L, 4);
            }
        }
    }

    if (err != 0) {
        QString err = "Error while loading definitions: ";
        err += lua_tostring(L, -1);
        emitError(err);
    }

    lua_settop(L, top);
}


void Graph::emitError(const QString &err) {
    if (receivers(SIGNAL(error(QString))) > 0)
        emit error(err);
    else
        QMessageBox::warning(0, "Error", err);
}


void Graph::save(const QString &fileName) {
    QFile f(fileName);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emitError(QString("Failed to save file %1").arg(fileName));
        return;
    }

    f.write(
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
"<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\"\n"
"    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
"    xsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns\n"
"     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">\n"
"  <graph id=\"G\" edgedefault=\"directed\">\n"
"<key id=\"type\" for=\"node\" attr.name=\"type\" attr.type=\"string\"/>\n"
"<key id=\"const\" for=\"node\" attr.name=\"const\" attr.type=\"string\"/>\n"
"<key id=\"val\" for=\"node\" attr.name=\"val\" attr.type=\"string\"/>\n"
"<key id=\"name\" for=\"edge\" attr.name=\"name\" attr.type=\"string\"/>\n"
);

    foreach (Node* n, _nodes) {
        f.write(QString("<node id=\"node_%1\">\n").arg(n->id()).toUtf8());
        f.write(QString(" <data key=\"val\">%1</data>\n").arg(n->value().toString()).toUtf8());
        f.write(QString(" <data key=\"const\">%1</data>\n").arg(n->isConst()).toUtf8());
        f.write("</node>\n");
    }

    foreach (Edge* e, _edges) {
        f.write(QString("<node id=\"edge_%1\">").arg(e->id()).toUtf8());
        f.write(QString("<data key=\"type\">%1</data>\n").arg(e->edgeType()->name()).toUtf8());
        f.write("</node>\n");

        foreach (Node* n, e->inNodes()) {
            Incidence i = e->incidenceToNode(n);
            f.write(QString("<edge source=\"node_%1\" target=\"edge_%2\">\n").arg(n->id()).arg(e->id()).toUtf8());
            f.write(QString(" <data key=\"name\">%1</data>\n").arg(i.name).toUtf8());
            f.write("</edge>\n");
        }
        foreach (Node* n, e->outNodes()) {
            Incidence i = e->incidenceToNode(n);
            f.write(QString("<edge source=\"edge_%1\" target=\"node_%2\">\n").arg(e->id()).arg(n->id()).toUtf8());
            f.write(QString(" <data key=\"name\">%1</data>\n").arg(i.name).toUtf8());
            f.write("</edge>\n");
        }
    }

    f.write(
"  </graph>\n"
"</graphml>\n"
);

    f.close();
}

void Graph::load(const QString &fileName) {
    QFile *f = new QFile(fileName);
    if (!f->open(QIODevice::ReadOnly | QIODevice::Text)) {
        emitError(QString("Failed to load file %1").arg(fileName));
        return;
    }

    QString errorStr;
    int errorLine;
    int errorColumn;

    QDomDocument domDocument;
    if (!domDocument.setContent(f, true, &errorStr, &errorLine,
                                &errorColumn)) {
        emitError(tr("Parse error at line %1, column %2:\n%3")
                                 .arg(errorLine)
                                 .arg(errorColumn)
                                 .arg(errorStr));
        return;
    }

    _nodes.clear();
    _edges.clear();

    QHash<QString, Edge*> edgeMap;
    QHash<QString, Node*> nodeMap;
    QDomElement root = domDocument.documentElement();
    QDomNode graph = root.firstChild();

    QDomNodeList children = graph.childNodes();

    // 1st step - gather nodes and edges
    for (int i=0; i<children.count(); i++) {
        QDomNode n = children.at(i);
        if (n.isElement() && n.nodeName().startsWith("node")) {
            QDomElement e = n.toElement();
            QString name = e.attribute("id");
            if (name.startsWith("node")) {
                Node *nn = new Node(L);
                QDomNodeList nl = e.childNodes();
                for (int j=0; j<nl.count(); j++) {
                    QDomNode data = nl.at(j);
                    if (data.isElement()) {
                        QString type = data.toElement().attribute("key");
                        if (type == "val") {
                            nn->setValue(Value::parse(data.firstChild().toText().data()));
                        } else if (type == "const") {
                            nn->setConst(data.firstChild().toText().data() == "1");
                        }
                    }
                }
                _nodes.append(nn);
                nodeMap[name] = nn;
            } else if (name.startsWith("edge")) {
                QDomNode fc = e.firstChild();
                QDomNode sc = fc.firstChild();
                QString type = sc.toText().data();
                Edge *ee = new Edge(L, _types[type]);
                _edges.append(ee);
                edgeMap[name] = ee;
            }
        }
    }

    // 2nd step - connect them
    for (int i=0; i<children.count(); i++) {
        QDomNode n = children.at(i);
        if (n.isElement() && n.nodeName().startsWith("edge")) {
            QDomElement e = n.toElement();            
            QString source = e.attribute("source");
            QString target = e.attribute("target");
            QString name = e.firstChild().firstChild().toText().data();
            qDebug() << source << target;
            if (source.startsWith("node")) {
                Node *n = nodeMap[source];
                Edge *e = edgeMap[target];
                e->connect(n,name, IN);
            } else {
                Edge *e = edgeMap[source];
                Node *n = nodeMap[target];
                e->connect(n, name, OUT);
            }
        }
    }

    delete f;
}
