
class.Graph()

local evCreated         = event "graphCreated"
local evLoaded          = event "graphLoaded"
local evSaved           = event "graphSaved"

local evNodeAdded       = event "nodeAdded"
local evNodeDeleted     = event "nodeDeleted"
local evEdgeAdded       = event "edgeAdded"
local evEdgeDeleted     = event "edgeDeleted"

local evConnected       = event "connected"
local evDisconnected    = event "disconnected"

function Graph:_init()
	self.nodes = List()
	self.edges = List()
	evCreated(self)
end


local next_id = 0
local function gen_id()
	next_id = next_id + 1
	return next_id
end


function Graph:createNode(type)
	local n = Node(gen_id(), type)
	self.nodes:append(n)
	evNodeAdded(self, n)
	return n
end


function Graph:createEdge(type)
	local e = Edge(gen_id(), type)
	self.edges:append(e)
	evEdgeAdded(self, e)
	return e
end

function Graph:connect(node, edge, name, dir)
	assert(node and node:is_a(Node), "node is nil or not a Node")
	assert(edge and edge:is_a(Edge), "edge is nil or not an Edge")
	assert(type(name) == "string", "name is nil or not a string")
	assert(type(dir) == "string", "dir is nil or not a string")
	
	TODO "connect node and edge"
	
	evConnected(self, node, edge, name, dir)
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

				self.nodes:append(nn)
				nodeMap[S(name)] = n
			elseif name:startsWith(Q"edge") then
				local e = self:createEdge()

				TODO "Determine edge type" --[[
				QDomNode fc = e.firstChild();
				QDomNode sc = fc.firstChild();
				QString type = sc.toText().data();
				]]

				self.edges:append(ee)
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
	self.nodes:foreach(function(n) trace(" N %s", tostring(n)) end)
	self.edges:foreach(function(e) trace(" E %s", tostring(e)) end)
end
