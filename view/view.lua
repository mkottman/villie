local center_text = QTextOption.new_local({'AlignHCenter', 'AlignVCenter'})
local center_point = QPointF.new_local(0,0)

local colors = {
	white = QColor.new_local(Q'white');
	red = QColor.new_local(Q'red'):lighter();
	green = QColor.new_local(Q'green'):lighter();
	blue = QColor.new_local(Q'blue'):lighter();
}

-------------------------------------------------
-- VEdge class
-------------------------------------------------

class.VEdge()
do
	local size = QRectF.new_local(-70, -15, 140, 30)
	local gradient = QRadialGradient.new_local(center_point, size:height(), center_point)
	gradient:setColorAt(0, colors.white);
	gradient:setColorAt(1, colors.blue);
	gradient = QBrush.new_local(gradient)
	
	function VEdge:_init(edge)
		local item = QGraphicsItem.new_local()
		
		item:setFlag('ItemIsSelectable', true)
		item:setFlag('ItemIsMovable', true)
		item:setZValue(1)
		
		local str = Q(edge)
		function item:boundingRect()
			return size
		end
		function item:paint(painter)
			painter:setBrush(gradient)
			painter:drawRoundedRect(size, 8, 8)
			painter:drawText(size, str, center_text)
		end
		self.item = item
		edge.visual = self
	end
end

-------------------------------------------------
-- VNode class
-------------------------------------------------

class.VNode()
do
	local size = QRectF.new_local(-25, -10, 50, 20)
	local gradient = QRadialGradient.new_local(center_point, size:height(), center_point)
	gradient:setColorAt(0, colors.white);
	gradient:setColorAt(1, colors.red);
	gradient = QBrush.new_local(gradient)
	
	function VNode:_init(node)
		local item = QGraphicsItem.new_local()
		
		item:setFlag('ItemIsSelectable', true)
		item:setFlag('ItemIsMovable', true)
		item:setZValue(2)
		
		local str = Q(edge)
		function item:boundingRect()
			return size
		end
		function item:paint(painter)
			painter:setBrush(gradient)
			painter:drawRect(size)
			painter:drawText(size, str)
		end
		self.item = item
		node.visual = self
	end
end

-------------------------------------------------
-- VConnector class
-------------------------------------------------

class.VConnector()

function VConnector:_init(node, edge, inc)
	local item = QGraphicsLineItem.new_local()
	
	assert(node.visual, "node does not have it's visual representation")
	assert(edge.visual, "edge does not have it's visual representation")
	local nv = node.visual.item
	local ev = edge.visual.item
	
	function item:paint()
		self:setLine(nv:pos(), ev:pos())
	end
	
	self.item = item
	inc.visual = self
end

-------------------------------------------------
-- View class
-------------------------------------------------

class.View()

function View:_init(parent)
	self.scene = QGraphicsScene.new(parent)
	self.view = QGraphicsView.new(self.scene, parent)
	self.items = List()
	
	handle("added", function(g, x)
		self:added(x)
	end)
	handle("removed", function(g, x)
		self:removed(x)
	end)
	handle("connected", function(g, n, e, i)
		self:connected(n, e, i)
	end)
end

function View:added(x)
	warn(STR, 'Added', x)
	if x:is_a(Node) then
		local vn = VNode(x)
		self.scene:addItem(vn.item)
		self.items:append(vn)
	elseif x:is_a(Edge) then
		local ve = VEdge(x)
		self.scene:addItem(ve.item)
		self.items:append(ve)
	else
		error("added item is not a Node or Edge")
	end
end

function View:removed(x)
	local v = x.visual
	assert(v, "removed item does not have visual")
	self.scene:removeItem(v.item)
end

function View:connected(n, e, i)
	local conn = VConnector(n, e, i)
	self.scene:addItem(conn.item)
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
	if graph == self.graph then trace("No need to reload graph") return end
	self.graph = graph
	self:scramble()
end




return View
