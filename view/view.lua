require 'view.layout'


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
function VEdge:_init(edge)
	local item = language.setupEdgeRenderer(edge)

	item:setFlag('ItemIsSelectable', true)
	item:setFlag('ItemIsMovable', true)
	item:setZValue(1)

	self.item = item
	edge.visual = self
end

-------------------------------------------------
-- VNode class
-------------------------------------------------

class.VNode()
function VNode:_init(node)
	local item = language.setupNodeRenderer(node, item)

	item:setFlag('ItemIsSelectable', true)
	item:setFlag('ItemIsMovable', true)
	item:setZValue(2)

	self.item = item
	node.visual = self
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
	
	local txt = QGraphicsTextItem.new_local(Q(inc.name))
	
	function item:paint(...)
		if nv:collidesWithItem(ev) then return end
		local line = QLineF.new_local(nv:pos(), ev:pos())
		item:setLine(line)
		
		local center = (nv:pos() + ev:pos()) / 2
		txt:setPos(center:x() + 15, center:y())
		
		super()
--[[
    QLineF centerLine(myStartItem->pos(), myEndItem->pos());
    setLine(centerLine);

    center = (myStartItem->pos() + myEndItem->pos()) / 2;
    float dx = abs(myEndItem->pos().x() - myStartItem->pos().x());
    float dy = abs(myEndItem->pos().y() - myStartItem->pos().y());

    text->setPos(center.x(), center.y()-20);
    /*
    if (dx > dy) {
        text->setPos(center.x(), center.y() - 15);
    } else {
        text->setPos(center.x() + 15, center.y());
    }
    */

    double angle = ::acos(line().dx() / line().length());
    if (line().dy() >= 0)
        angle = (Pi * 2) - angle;

    const double arrowSize = 10;

    QPointF arrowP1 = center - QPointF(sin(angle + Pi / 3) * arrowSize,
                                            cos(angle + Pi / 3) * arrowSize);
    QPointF arrowP2 = center - QPointF(sin(angle + Pi - Pi / 3) * arrowSize,
                                            cos(angle + Pi - Pi / 3) * arrowSize);

    QPolygonF arrowHead;
    arrowHead << center << arrowP1 << arrowP2;
    painter->drawPolygon(arrowHead);
    painter->drawLine(line());
]]
	end
	
	self.txt = txt
	self.item = item
	inc.visual = self
end

-------------------------------------------------
-- View class
-------------------------------------------------

class.View()

local evChanged = event "itemChanged"

function View:_init(parent)
	self.scene = QGraphicsScene.new(parent)
	self.view = QGraphicsView.new(self.scene, parent)
	self.items = List()
	self.layouter = Layouter(self.items)
	
	local this = self
	function self.view:contextMenuEvent(e)
		this:showPopup(e:globalPos())
	end
	function self.view:wheelEvent(e)
		local scale = e:delta() > 0 and 1.25 or 0.8
		self:scale(scale, scale)
	end
	
--[[
	handle("added", function(g, x)
		self:added(x)
	end)
	handle("removed", function(g, x)
		self:removed(x)
	end)
	handle("connected", function(g, n, e, i)
		self:connected(n, e, i)
	end)
--]]
	handle("itemChanged", function(e)
		local items = List({e})
		for k,v in pairs(e.nodes or e.edges) do
			items:append(v)
		end
		self.layouter:start(items)
	end)
end

function View:added(x)
	log(STR, 'View - added', x)
	if not x:is_a(Node) and not x:is_a(Edge) then
		error("added item is not a Node or Edge: "..STR(x))
	end
	
	local visual
	if x:is_a(Node) then
		visual = VNode(x)
	elseif x:is_a(Edge) then
		visual = VEdge(x)
	end
	local item = visual.item
	item:setPos(math.random(-100,100), math.random(-100, 100))

	local view = self
	function item:mouseMoveEvent(e)
		evChanged(x)
		x.ignored = true
		super()
	end
	
	function item:mouseReleaseEvent(e)
		x.ignored = false
		super()
	end
	
	self.scene:addItem(item)
	self.items:append(x)
end

function View:removed(x)
	local v = x.visual
	assert(v, "removed item does not have visual")
	self.scene:removeItem(v.item)
end

function View:connected(n, e, i)
	local conn = VConnector(n, e, i)
	self.scene:addItem(conn.item)
	self.scene:addItem(conn.txt)
end

function View:clear()
	self.layouter:stop()
	self.scene:clear()
	self.items = List()
end

function View:scramble()
	for i in self.items:iter() do
		i.visual.item:setPos(math.random(-200,200), math.random(-200, 200))
	end
end

function View:fullLayout()
	self.layouter:start(self.items, true)
end

function View:display(start)
	self:clear()
	local done = {}
	local function add(x)
		if done[x] then return end
		done[x] = true
		self:added(x)
		if x:is_a(Node) then
			for inc,edge in pairs(x.edges) do
				add(edge)
				self:connected(x, edge, inc)
			end
		elseif x:is_a(Edge) then
			for inc,node in pairs(x.nodes) do
				add(node)
				self:connected(node, x, inc)
			end		
		else
			fatal(STR, "Unexpected element for display", x)
		end
	end
	add(start)
	self:fullLayout()
end

function View:showPopup(point)
	if not self.graph then return end
	local this = self
	local menu = QMenu.new()
	menu:connect('2aboutToHide()', menu, '1deleteLater()')
	for name, item in pairs(self.graph.elements) do
		local action = QAction.new(Q(name), menu)
		menu:__addmethod(name..'()', function()
			this:display(item)
		end)
		action:connect('2triggered()', menu, '1'..name..'()')
		menu:addAction(action)
	end
	menu:popup(point)
end

function View:reload(graph)
	if graph == self.graph then trace("No need to reload graph") return end
	self.graph = graph
	self:display(graph.elements.Main)
	self:scramble()
	-- self.layouter:start(self.items)
end

return View
