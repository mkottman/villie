class.VEdge()

function VEdge:_init(edge)
	local size = QRectF.new_local(-25, -10, 50, 20)
	local item = QGraphicsItem.new_local()
	
	item:setFlag('ItemIsSelectable', true);
	item:setFlag('ItemIsMovable', true);
	
	local str = Q(edge)
	function item:boundingRect()
		return size
	end
	function item:paint(painter)
		painter:drawRect(size)
		painter:drawText(size, str)
	end
	self.item = item
	edge.visual = self
end


class.VNode()

function VNode:_init(node)
	local size = QRectF.new_local(-25, -10, 50, 20)
	local item = QGraphicsItem.new_local()
	
	item:setFlag('ItemIsSelectable', true);
	item:setFlag('ItemIsMovable', true);
	
	local str = Q(edge)
	function item:boundingRect()
		return size
	end
	function item:paint(painter)
		painter:drawRect(size)
		painter:drawText(size, str)
	end
	self.item = item
	node.visual = self
end


class.View()

function View:_init(parent)
	self.scene = QGraphicsScene.new(parent)
	self.view = QGraphicsView.new(self.scene, parent)
	self.items = List()
end

function View:clear()
	self.scene:clear()
	self.items = List()
end

function View:scramble()
	for i in self.items:iter() do
		i.item:setPos(math.random(-100,100), math.random(-100, 100))
	end
end

function View:reload(graph)
	for e in graph.edges:iter() do
		local ve = VEdge(e)
		log(repr(ve))
		self.scene:addItem(ve.item)
		self.items:append(ve)
	end
	for n in graph.nodes:iter() do
		local vn = VNode(n)
		self.scene:addItem(vn.item)
		self.items:append(vn)
	end
	
	--local it = self.scene:items()
	--print(it, it.__type, it:size())
	
	self:scramble()
end

return View
