
class.Graph()

function Graph:_init(fn)

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
	assert(node:is_a(Node) and edge:is_a(Edge))
end

function Graph:disconnect(node, edge)

end
