module('vlua.visual', package.seeall)

local color_cache = setmetatable({}, {__mode="v"})
--- Resolves QColor by name.
-- Can use any of these: http://www.w3.org/TR/SVG/types.html#ColorKeywords
local function to_color(c)
	if not color_cache[c] then
		color_cache[c] = QColor.new_local(Q(c))
	end
	return color_cache[c]
end

local icon_cache = setmetatable({}, {__mode="v"})
--- Returns a QPixmap for filename. Caches results.
local function icon(fn)
	if not icon_cache[fn] then
		icon_cache[fn] = QPixmap.new_local(Q(fn))
	end
	return icon_cache[fn]
end


local center_point = QPointF.new_local(0,0)
local center_text = QTextOption.new_local({'AlignHCenter', 'AlignVCenter'})

local SIMPLE_HEIGHT = 30
local WIDTH = 240
	
-- Node renderer not needed
do
	function vlua.setupNodeRenderer(view, node)
		warn(STR, "Trying to display a node", node)
	end
end


-- Edge renderer
do
	local SIDEBAR_SIZE = 10
	local brush = QBrush.new_local(to_color"white")
	local titleBrush = QBrush.new_local(to_color"lightgray")
	local redBrush = QBrush.new_local(to_color"red")
	local triangle = QPolygonF.new_local()
		:IN(QPointF.new_local(2, 0))
		:IN(QPointF.new_local(-SIDEBAR_SIZE, SIDEBAR_SIZE/2 + 2))
		:IN(QPointF.new_local(-SIDEBAR_SIZE, -SIDEBAR_SIZE/2 - 2))
		
	local function createBlockRenderer(view, item, block)
		local height, width
		local size, titleSize, titleSubsize
		
		-- Qt 4.6
		if QGraphicsItem.GraphicsItemFlag.ItemSendsGeometryChanges then
			item:setFlag(QGraphicsItem.GraphicsItemFlag.ItemSendsGeometryChanges, true)
		end
		
		-- sets up child positions and total height
		function block:update()
			height = 24
			width = WIDTH + 10

			-- prepare the values such as count and height
			for inc, node in pairs(block.nodes) do
				if inc.name ~= "do" and inc.name ~= "info" then
					local stat = node.edges["do"]
					height = height + (stat.height or SIMPLE_HEIGHT) + 5
				end
			end

			local pos = item:pos()
			local x, y = pos:x(), pos:y()
			y = item:pos():y() - height/2 + 20

			-- setup the position of all child items
			for i=1,block.count do
				local node = block.nodes[tostring(i)]
				local stat = node.edges["do"]

				local h = stat.height or SIMPLE_HEIGHT
				y = y + h / 2
				if not stat.visual then
					view:addItem(stat)
					-- disable moving for items in block
					stat.visual.item:setFlag('ItemIsMovable', false)
				end
				y = y + h / 2 + 5
				stat.visual.item:setPos(x, y)

				stat.visual.parent = block
				stat.locked = true
			end
			
			item:updateChildPositions(item:pos())
			
			size = QRectF.new_local(-width/2 - SIDEBAR_SIZE, -height/2, width + SIDEBAR_SIZE, height)
			titleSize = QRectF.new_local(-width/2 - SIDEBAR_SIZE, -height/2, width + SIDEBAR_SIZE, 20)
			titleSubsize = QRectF.new_local(-width/2 - SIDEBAR_SIZE, -height/2 + 15, width + SIDEBAR_SIZE, 5)
		end
		
		-- update operation positions after moving of the block
		function item:updateChildPositions(pos)
			local x, y = pos:x(), pos:y()
			local y = y - height/2 + 25
			local zValue = item:zValue() + 2
			
			for i=1,block.count do
				local stat = block.nodes[tostring(i)]
				assert(stat, "cannot find statement "..i.." in block")
				stat = stat.edges["do"]
				local h = stat.height or SIMPLE_HEIGHT
				y = y + h / 2
				stat.visual.item:setPos(x, y)
				stat.visual.item:setZValue(zValue)
				y = y + h / 2 + 5
			end
		end
		function item:itemChange(typ, val)
			if typ == "ItemPositionChange" then self:updateChildPositions(val:toPointF()) end
			super()
		end
		
		-- rendering essentials
		function item:boundingRect()
			return size
		end
		function item:paint(painter)
			painter:setBrush(brush)
			painter:drawRoundedRect(size, 8, 8)
			painter:setBrush(titleBrush)
			local oldpen = painter:pen()
			painter:setPen('NoPen')
			painter:drawRoundedRect(titleSize, 8, 8)
			painter:drawRect(titleSubsize)
			painter:setPen(oldpen)
			if block.title then painter:drawText(titleSize, Q(block.title), center_text) end
			painter:setBrush('NoBrush')
			painter:drawRoundedRect(size, 8, 8)
			
			-- draw red creation position
			if self.createPos then
				painter:setBrush(redBrush)
				local ypos = self.createPos * (SIMPLE_HEIGHT + 5) - height/2 + 23
				painter:translate(-width/2, ypos)
				painter:drawRect(-SIDEBAR_SIZE, -2, width + SIDEBAR_SIZE, 4)
				painter:drawPolygon(triangle)
			end
		end
		
		-- support for creating of operations inside a block
		item:setAcceptHoverEvents(true)
		function item:hoverEnterEvent(e)
			if vlua.isCreating then
				for i=1,block.count do
					local stat = block.nodes[tostring(i)]
					stat = stat.edges["do"]
					stat.visual.item:setEnabled(false)
				end
			end
			super()
		end
		function item:hoverMoveEvent(e)
			if vlua.isCreating then
				local pos = e:pos()
				local x, y = pos:x(), pos:y()
				local y2 = y + height/2
				local createPos = math.floor(y2 / (SIMPLE_HEIGHT + 5))
				self.createPos = createPos
				self:update()
			end
		end
		function item:hoverLeaveEvent(e)
			if vlua.isCreating then
				self.createPos = nil
				for i=1,block.count do
					local stat = block.nodes[tostring(i)]
					stat = stat.edges["do"]
					stat.visual.item:setEnabled(true)
				end
			end
			super()
		end
		function item:mousePressEvent(e)
			if not self.createPos then super() end
			for i=1,block.count do
				local stat = block.nodes[tostring(i)]
				stat = stat.edges["do"]
				stat.visual.item:setEnabled(true)
			end
			local ok, err = xpcall(function() vlua.createItemIn(block, self.createPos) end, debug.traceback)
			if not ok then fatal(err) end
			self.createPos = nil
		end
		item.mousePressOverride = true
		
		block:update()
	end

	local size = QRectF.new_local(-WIDTH/2, -SIMPLE_HEIGHT/2, WIDTH, SIMPLE_HEIGHT)
	local gradient = QRadialGradient.new_local(center_point, WIDTH / 2, center_point)
	gradient:setColorAt(0, to_color"white")
	
	function vlua.setupEdgeRenderer(view, edge)
		local item = QGraphicsItem.new_local()
		
		edge.visual.height = SIMPLE_HEIGHT
		item:setFlag('ItemIsSelectable', true)
		item:setFlag('ItemIsMovable', true)
		item:setZValue(1)
			
		item.str = edge.type and edge.type.name or 'unknown'
		if edge.value then item.str = edge.value end
		item.str = Q(item.str)
	
		if edge.type.name == "Block" then
			createBlockRenderer(view, item, edge)
		else
			if edge.type.icon then item.icon = icon(edge.type.icon) end
			item.poly = edge.type.poly

			function item:boundingRect()
				return size
			end
			function item:paint(painter)
				local col = edge.type.color and to_color(edge.type.color) or to_color"pink"
				gradient:setColorAt(1, col)
				painter:setBrush(QBrush.new_local(gradient))
				if self.poly then
					painter:drawPolygon(self.poly)
				else
					painter:drawRoundedRect(size, 8, 8)
				end
				painter:drawText(size, Q(edge.value), center_text)
				if self.icon then
					local iconX = edge.type.iconRight and (WIDTH/2-21) or (-WIDTH/2+5)
					painter:drawPixmap(QPointF.new_local(iconX, -8), self.icon)
				end
			end
		end
		
		return item
	end
end
