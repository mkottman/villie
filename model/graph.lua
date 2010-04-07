

local function shortcutTable()
	return setmetatable({}, {__index = function(t,key)
		for k,v in pairs(t) do
			if k.name == key then return v end
		end
	end})
end


-------------------------------------------------
-- Node class
-------------------------------------------------

class.Node()

function Node:_init(id, type)
	self.id = id
	self.type = type
	self.edges = shortcutTable()
end

-------------------------------------------------
-- Edge class
-------------------------------------------------

class.Edge()

function Edge:_init(id, type)
	self.id = id
	self.type = type
	self.nodes = shortcutTable()
end

-------------------------------------------------
-- Incidence class
-------------------------------------------------

class.Incidence()

function Incidence:_init(name, dir)
	self.name = name
	self.dir = dir
end

-------------------------------------------------
-- Graph class
-------------------------------------------------

class.Graph()

local evCreated         = event "graphCreated"
local evLoaded          = event "graphLoaded"
local evSaved           = event "graphSaved"

local evAdded           = event "added"
local evRemoved         = event "removed"

local evConnected       = event "connected"
local evDisconnected    = event "disconnected"

function Graph:_init()
	self.nodes = List()
	self.edges = List()
	self.elements = {}
	evCreated(self)
end

function Graph:registerTypes(types)
	self.node_types = types.nodes
	for k, v in pairs(self.node_types) do
		v.name = k
	end
	self.edge_types = types.edges
	for k, v in pairs(self.edge_types) do
		v.name = k
	end
end

local next_id = 0
local function gen_id()
	next_id = next_id + 1
	return next_id
end


local function resolveType(typ, where)
	if not where[typ] then fatal("Trying to create unknown type: %s", typ)
	else return where[typ]
	end
end

function Graph:createNode(typ)
	if type(typ) == "string" then typ = resolveType(typ, self.node_types) end
	local n = Node(gen_id(), typ)
	self.nodes:append(n)
	evAdded(self, n)
	return n
end


function Graph:createEdge(typ)
	if type(typ) == "string" then typ = resolveType(typ, self.edge_types) end
	local e = Edge(gen_id(), typ)
	self.edges:append(e)
	evAdded(self, e)
	return e
end

--- Connects a <code>node</code> with an <code>edge</code> with incidence named <code>name</code> and
-- direction <code>dir</code>. Direction is always in relation to <code>edge</code> and can have value
-- either 'in' or 'out'. Creates and Incidence object from <code>name</code> and <code>dir</code> and
-- uses it as a key for <code>node.edges</code> and <code>edge.nodes</code>. As a shortcut,
-- <code>name</code> can also be used as a key in <code>edge.nodes</code> and <code>node.edges</code>.
-- Fires the "connected" event.
function Graph:connect(node, edge, name, dir)
	assert(node and node:is_a(Node), type(node) .. " is nil or not a Node")
	assert(edge and edge:is_a(Edge), type(edge) .. " is nil or not an Edge")
	assert(type(name) == "string", "name is nil or not a string")
	assert(type(dir) == "string", "dir is nil or not a string")
	
	local inc = Incidence(name, dir)
	node.edges[inc] = edge
	edge.nodes[inc] = node
	
	evConnected(self, node, edge, inc)
end

function Graph:disconnect(node, edge)
	TODO "disconnect node and edge"
	
	evDisconnected(self, node, edge)
end

--- Loads a graph from a GraphML file
-- @param filename Filename of
-- @return true on success, nil,errmsg on error
function Graph:load(filename)
	local f = QFile.new_local(Q(filename))
	if not f:open(QIODevice.OpenModeFlag.ReadOnly + QIODevice.OpenModeFlag.Text) then
		return nil, "failed to open file"
	end

	local doc = QDomDocument.new_local()
	if not doc:setContent(f, true) then
		return nil, "parse error"
	end

	local edgeMap = {}
	local nodeMap = {}

	local root = doc:documentElement()
	local graph = root:firstChild()
	local children = graph:childNodes()

	for i=1,children:count() do
		local n = children:at(i-1)
		if n:isElement() and n:nodeName():startsWith(Q"node") then
			local e = n:toElement()
			local name = e:attribute(Q"id")
			if name:startsWith(Q"node") then
				local n = self:createNode()

				TODO "Handle attributes" --[[
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
				]]
				
				nodeMap[S(name)] = n
			elseif name:startsWith(Q"edge") then
				local e = self:createEdge()

				TODO "Determine edge type" --[[
				QDomNode fc = e.firstChild();
				QDomNode sc = fc.firstChild();
				QString type = sc.toText().data();
				]]
				
				edgeMap[S(name)] = e
			end
		end
	end

	for i=1,children:count() do
		local n = children:at(i-1)
		if n:isElement() and n:nodeName():startsWith(Q"edge") then
			local e = n:toElement()
			local source = e:attribute(Q"source")
			local target = e:attribute(Q"target")
			local name = e:firstChild():firstChild():toText():data()

			local n, e, d
			if source:startsWith(Q"node") then
				n, e, d = nodeMap[S(source)], edgeMap[S(target)], 'in'
			else
				n, e, d = nodeMap[S(target)], edgeMap[S(source)], 'out'
			end

			self:connect(n, e, S(name), d)
		end
	end

	self:dump()
	
	evLoaded(self)
	
	return true
end

--- Saves a graph into a GraphML file
function Graph:save(filename)
	TODO "save graph"
	
	evSaved(self)
end

function Graph:dump()
	trace("Graph:")

	local f = io.open('graph.dot', 'w')
	f:write('digraph g {\n')
	f:write('edge [len=2]\n')

	for n in self.nodes:iter() do
		trace(" N %s", tostring(n))
		f:write(' n', n.id, ' [label=', string.format("%q", (n.value or '?') .. ':' .. n.type.name), ']\n')
	end
	for e in self.edges:iter() do
		trace(" E %s", tostring(e))
		f:write(' e', e.id, ' [label="', e.type and e.type.name or 'unknown', '"]\n')
	end
	
	for e in self.edges:iter() do
		for i, n in pairs(e.nodes) do
			if type(i) ~= "string" then
				if i.dir == "out" then
					f:write(' e', e.id, ' -> n', n.id, ' [label=', i.name,']\n')
				else
					f:write(' n', n.id, ' -> e', e.id, ' [label=', i.name,']\n')
				end
			end
		end
	end
	
	f:write('}\n')
end
