local function incidenceNames(t)
	local res = List()
	for inc in pairs(t) do
		res:append(inc.name)
	end
	table.sort(res)
	return res
end

--- Finds a connected node or edge by string key. Used as an __index
-- metamethod in shortcutTable. Iterates through table's incidences,
-- and if finds one with the name equal to key, returns the other side
-- of incidence. It the key starts with '@', returns the incidence instead.
-- If the key is "__names", returns a List containing all incidence names.
function shortcutIndex(t, key)
	if key == "__names" then return incidenceNames(t)
	elseif key:sub(1,1) == '@' then
		key = key:sub(2)
		for k,v in pairs(t) do
			if k.name == key then return k end
		end
	else
		for k,v in pairs(t) do
			if k.name == key then return v end
		end
	end
end

local shortcutMt = {__index = shortcutIndex}

--- Creates a lookup table for incidences. Uses shortcutIndex to lookup up
-- nodes and edges based on string keys.
function shortcutTable()
	return setmetatable({}, shortcutMt)
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
function Node:__tostring()
	return 'Node: ' .. self.type.name .. ' ' .. self.id
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
function Edge:__tostring()
	return 'Edge: '.. self.type.name .. ' ' .. self.id
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

local function resolveType(typ, where)
	if not where[typ] then fatal("Trying to create unknown type: %s", typ)
	else return where[typ]
	end
end

function Graph:registerTypes(types)
	-- register new node types
	self.node_types = types.nodes
	for k, v in pairs(self.node_types) do
		v.name = k
	end
	-- refresh nodes with new type definitions
	for n in self.nodes:iter() do
		n.type = resolveType(n.type.name, self.node_types)
	end

	-- register new edge types
	self.edge_types = types.edges
	for k, v in pairs(self.edge_types) do
		v.name = k
	end
	-- refresh edges with new type definitions
	for e in self.edges:iter() do
		e.type = resolveType(e.type.name, self.edge_types)
	end
end

local next_id = 0
local function gen_id()
	next_id = next_id + 1
	return next_id
end

function Graph:createNode(typ)
	if type(typ) == "string" then typ = resolveType(typ, self.node_types) end
	local n = Node(gen_id(), typ)
	self.nodes:append(n)
	evAdded(self, n)
	return n
end

function Graph:removeNode(node)
	self.nodes:remove(node)
	evRemoved(self, node)
end

function Graph:createEdge(typ)
	if type(typ) == "string" then typ = resolveType(typ, self.edge_types) end
	local e = Edge(gen_id(), typ)
	self.edges:append(e)
	evAdded(self, e)
	return e
end

function Graph:removeEdge(edge)
	self.edges:remove(edge)
	evRemoved(self, edge)
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
	local inc
	for i,e in pairs(node.edges) do
		if e == edge then
			inc = i
			break
		end
	end

	if not inc then fatal(STR, 'Node and edge not connected!', node, edge)
	else
		node.edges[inc] = nil
		edge.nodes[inc] = nil
		evDisconnected(self, node, edge, inc)
	end
end

function Graph:dump()
	trace("Graph:")

	local f = io.open('graph.dot', 'w')
	f:write('digraph g {\n')
	f:write('edge [len=2]\n')

	for n in self.nodes:iter() do
		-- trace(" N %s", tostring(n))
		if n.type.name == "Stat" or n.type.name == "Exp" or n.type.name == "Info" then
			f:write(' n', n.id, ' [shape=point]\n')
		else
			f:write(' n', n.id, ' [shape=box, label=', string.format("%q", n.value or '?'), ']\n')
		end
	end
	for e in self.edges:iter() do
		-- trace(" E %s", tostring(e))
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
