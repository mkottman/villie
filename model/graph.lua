
class.Graph()

function Graph:_init()
    self._nodes = List()
    self._edges = List()
end

function Graph:nodes()

end


function Graph:edges()

end


function Graph:createNode(type)

end


function Graph:createEdge(type)

end

function Graph:connect(node, edge, name, dir)
    log("[GRAPH] connecting '%s' into '%s' as '%s' (%s)", tostring(node), tostring(edge), name, dir)
	assert(node:is_a(Node) and edge:is_a(Edge))
end

function Graph:disconnect(node, edge)

end

--- Loads a graph from a GraphML file
-- @param filename Filename of
-- @return true on success, nil,errmsg on error
function Graph:load(filename)
	local f = QFile.new_local(Q(filename))
	if not f:open(QIODevice.OpenModeFlag.ReadOnly + QIODevice.OpenModeFlag.Text) then
		return nil, "failed to open file"
	end

	local doc = QDomDocument.new_local();
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
                local n = Node()
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

                self._nodes:append(nn)
                nodeMap[name] = n
            elseif name:startsWith(Q"edge") then
                local e = Edge()

                TODO "Determine edge type" --[[
                QDomNode fc = e.firstChild();
                QDomNode sc = fc.firstChild();
                QString type = sc.toText().data();
                ]]

                self._edges:append(ee)
                edgeMap[name] = e
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
                n, e, d = nodeMap[source], nodeMap[target], 'in'
            else
                n, e, d = nodeMap[target], nodeMap[source], 'out'
            end
            self:connect(n, e, name, d)
        end
    end

    self:dump()
    return true
end

--- Saves a graph into a GraphML file
function Graph:save(filename)

end

function Graph:dump()
    log("Graph:")
    self._nodes:foreach(function(n) log(" N %s", tostring(n)) end)
    self._edges:foreach(function(e) log(" E %s", tostring(e)) end)
end
