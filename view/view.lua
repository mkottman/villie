require 'view.layout'


local center_point = QPointF.new_local(0,0)

local colors = {
	white = QColor.new_local(Q'white');
	red = QColor.new_local(Q'red'):lighter();
	green = QColor.new_local(Q'green'):lighter();
	blue = QColor.new_local(Q'blue'):lighter();
	black = QColor.new_local(Q'black');
}

-------------------------------------------------
-- VEdge class
-------------------------------------------------

class.VEdge()
function VEdge:_init(view, edge)
	edge.visual = self
	local item = language.setupEdgeRenderer(view, edge)
	self.item = item
end

-------------------------------------------------
-- VNode class
-------------------------------------------------

class.VNode()
function VNode:_init(view, node)
	node.visual = self
	local item = language.setupNodeRenderer(view, node)
	self.item = item
end

-------------------------------------------------
-- VConnector class
-------------------------------------------------

class.VConnector()
do
	local ARROWSIZE = 10
	local blackBrush = QBrush.new_local(colors.black)

function VConnector:_init(from, to)
	local item = QGraphicsLineItem.new_local()
	
	log(STR, "Connecting", from.type.name, to.type.name)
	assert(from.visual, "'from' does not have it's visual representation")
	assert(to.visual, "'to' does not have it's visual representation")
	
	--local txt = QGraphicsTextItem.new_local(Q(inc.name))
	--local pen = QPen.new_local(inc.ignored and colors.red or colors.black)
	--item:setPen(pen)

	item.from = from
	item.to = to

	function item:boundingRect()
		return QRectF.new_local(self.from.visual.item:pos(), self.to.visual.item:pos())
			:normalized()
			:adjusted(-10, -10, 10, 10)
	end

	function item:paint(painter)
		local fromv = self.from.visual.item
		local tov = self.to.visual.item	
	
		if fromv:collidesWithItem(tov) then return end
		
		local startp = fromv:pos() --+ fromv:boundingRect():center()
		local endp = tov:pos() --+ tov:boundingRect():center()
		
		local line = QLineF.new_local(startp, endp)
		self:setLine(line)
		
		local center = (startp + endp) / 2
		--txt:setPos(center:x() + 15, center:y())
		
		local angle = math.atan2(line:dx(), line:dy()) + math.pi/2
		
		local arrowP1 = center + QPointF.new_local(math.sin(angle+math.pi/3) * ARROWSIZE, math.cos(angle + math.pi/ 3) * ARROWSIZE)
		local arrowP2 = center + QPointF.new_local(math.sin(angle+2*math.pi/3) * ARROWSIZE, math.cos(angle + 2*math.pi/ 3) * ARROWSIZE)
		
		local arrowHead = QPolygonF.new_local()
		arrowHead:IN(center):IN(arrowP1):IN(arrowP2)

		painter:setBrush(blackBrush)
		painter:drawPolygon(arrowHead)
		painter:drawLine(line)
	end
	
	self.item = item
end

end -- do

function VConnector:other(x)
	if x == self.item.from then return self.item.to
	else return self.item.from
	end
end

-------------------------------------------------
-- View class
-------------------------------------------------

class.View()

local evChanged = event "itemChanged"

function View:_init(parent)
	self.scene = QGraphicsScene.new(parent)
	self.view = QGraphicsView.new(self.scene, parent)
	
	self.view:setTransformationAnchor('AnchorUnderMouse')
	self.view:setViewportUpdateMode('BoundingRectViewportUpdate')
	self.view:setRenderHint('Antialiasing')
	
	self.history = {}
	self.items = {}
	self.attract = {}
	self.repulse = {}
	self.layouter = Layouter()
	
	local widget = QWidget.new(parent)
	local layout = QHBoxLayout.new(widget)
	
	local elements = QListWidget.new(widget)
	elements:setMaximumWidth(100)

	self.widget = widget
	self.elements = elements
	
	layout:addWidget(self.elements)
	layout:addWidget(self.view)
	

	local deletePixmap = QPixmap.new_local(Q"gui/icons/Delete.png")
	self.normalCursor = QCursor.new_local()
	self.deleteCursor = QCursor.new_local(deletePixmap)

	local this = self
	function self.view:contextMenuEvent(e)
		if this.ignoreClick then
			this.ignoreClick = nil
		else
			this:showPopup(e:globalPos())
		end
	end
	function self.view:wheelEvent(e)
		local scale = e:delta() > 0 and 1.25 or 0.8
		self:scale(scale, scale)
	end
	
	function self.view:keyPressEvent(e)
		local key = e:key()
		if key == Qt.Key.Key_Escape and this.isDeleting then
			this.isDeleting = false
			this.view:setCursor(this.normalCursor)
		elseif key == Qt.Key.Key_Delete and not this.isDeleting then
			this:startDeleting()
		end
	end
	
	
	self.elements:__addmethod('doubleClick(QListWidgetItem*)', function(self, item)
		local name = item.name
		trace("Doubleclick on element %s", name)
		this:display(this.graph.elements[name])
	end)
	self.elements:connect('2itemDoubleClicked(QListWidgetItem*)', self.elements, '1doubleClick(QListWidgetItem*)')

--[[
	handle("itemChanged", function(e)
		local items = {[e]=true}
		local neighbours = {}
		for k,v in pairs(e.nodes or e.edges) do
			v.ignored = false
			items[v] = true
			neighbours[v] = true
		end
		for i in pairs(neighbours) do
			for k,v in pairs(i.nodes or i.edges) do
				v.ignored = true
				items[v] = true
			end
		end
		self.layouter:start(self.attract, self.repulse)
	end)
]]
end

function View:back()
	if #self.history < 2 then return end
	table.remove(self.history)
	local top = table.remove(self.history)
	self:display(top)
end

function View:addItem(x)
	log(STR, 'View - added', x)
	if not x:is_a(Node) and not x:is_a(Edge) then
		error("added item is not a Node or Edge: "..STR(x))
	end
	
	local visual
	if x:is_a(Node) then
		visual = VNode(self, x)
	elseif x:is_a(Edge) then
		visual = VEdge(self, x)
	end
	visual.connectors = {}

	local item = visual.item
	item:setPos(math.random(-100,100), math.random(-100, 100))

	local view = self
	
	function item:mousePressEvent(e)
		if e:button() == "RightButton" and language.edit(view, x) then
			view.ignoreClick = true
		elseif view.isDeleting and language.delete(view.graph, view, x) then
			view.isDeleting = false
			view.view:setCursor(view.normalCursor)
		else
			super()
		end
	end
	
	function item:mouseMoveEvent(e)
		x.ignored = true
		evChanged(x)
		super()
	end
	
	function item:mouseReleaseEvent(e)
		x.ignored = false
		evChanged(x)
		super()
	end
	
	function item:mouseDoubleClickEvent(e)
		language.toggle(view, x)
		super()
	end
	
	self.scene:addItem(item)
	self.items[x] = true
end

function View:removeItem(x)
	if not self.items[x] then warn('Trying to remove item that is not on scene') return end
	
	self.scene:removeItem(x.visual.item)
	for c in pairs(x.visual.connectors) do
		local other = c:other(x)
		other.visual.connectors[c] = nil
		self.scene:removeItem(c.item)
	end
	
	x.visual = nil
	self.items[x] = nil
	self.attract[x] = nil
	self.repulse[x] = nil
end

function View:connect(a, b)
	local conn = VConnector(a, b)
	
	a.visual.connectors[conn] = true
	b.visual.connectors[conn] = true
	
	self.scene:addItem(conn.item)
end

function View:clear()
	self.layouter:stop()
	for i in pairs(self.items) do
		i.visual = nil
	end
	self.scene:clear()
	self.attract = {}
	self.repulse = {}
	self.items = {}
end

function View:scramble()
	for i in pairs(self.items) do
		i.visual.item:setPos(math.random(-200,200), math.random(-200, 200))
	end
end

function View:fullLayout()
	self.layouter:start(self.attract, self.repulse, true)
end

function View:display(start)
	assert(start, "Trying to display nil")
	self:clear()
	self:addItem(start)

	table.insert(self.history, start)

	self.repulse[start] = true
	start.expanded = false
	
	language.toggle(self, start)
	start.visual.item:moveBy(1,1)
end

function View:showPopup(point)
	if not self.graph then return end
	local this = self
	local menu = QMenu.new()
	menu:connect('2aboutToHide()', menu, '1deleteLater()')
	local names = {}
	for name in pairs(self.graph.elements) do
		table.insert(names, name)
	end
	table.sort(names)
	for _,name in ipairs(names) do
		local item = self.graph.elements[name]
		local action = QAction.new(Q(name), menu)
		menu:__addmethod(name..'()', function()
			this:display(item)
		end)
		action:connect('2triggered()', menu, '1'..name..'()')
		menu:addAction(action)
	end
	menu:popup(point)
end

function View:startDeleting()
	self.isDeleting = true
	self.view:setCursor(self.deleteCursor)
end

function View:updateElements()
	local names = List()
	for k in pairs(self.graph.elements) do
		names:append(k)
	end
	-- fill the list with sorted items
	table.sort(names)
	self.elements:clear()
	for n in names:iter() do
		-- add item to the list using parent parameter
		local w = QListWidgetItem.new(Q(n), self.elements)
		w.name = n
	end
end

function View:reload(graph)
	if graph == self.graph then trace("No need to reload graph") return end
	self.graph = graph
	self:updateElements()
	self:display(graph.elements.__Main)
end

return View
