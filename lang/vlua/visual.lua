module('vlua.visual', package.seeall)

-- can use any of these: http://www.w3.org/TR/SVG/types.html#ColorKeywords
local color_cache = setmetatable({}, {__mode="v"})
local function to_color(c)
	if not color_cache[c] then
		color_cache[c] = QColor.new_local(Q(c))
	end
	return color_cache[c]
end

local icon_cache = setmetatable({}, {__mode="v"})
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
	
-- Node renderer
do
	function vlua.setupNodeRenderer(view, node)
		warn(STR, "Trying to display a node", node)
	end
end


-- Edge renderer
do
	local function createBlockRenderer(view, item, block)
		local height, width
		local size, titleSize, titleSubsize

		item:setZValue(0)
		-- Qt 4.6
		if QGraphicsItem.GraphicsItemFlag.ItemSendsGeometryChanges then
			item:setFlag(QGraphicsItem.GraphicsItemFlag.ItemSendsGeometryChanges, true)
		end
		
		function block:update()
			height = 25
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
					stat.visual.item:setZValue(3)
				end
				y = y + h / 2 + 5
				stat.visual.item:setPos(x, y)

				stat.visual.parent = block
				stat.locked = true
			end

			item:updateChildPositions(item:pos())
			size = QRectF.new_local(-width/2, -height/2, width, height)
			titleSize = QRectF.new_local(-width/2, -height/2, width, 20)
			titleSubsize = QRectF.new_local(-width/2, -height/2 + 15, width, 5)
		end

		local brush = QBrush.new_local(to_color"white")
		local titleBrush = QBrush.new_local(to_color"gray")
		
		function item:updateChildPositions(pos)
			local x, y = pos:x(), pos:y()
			local y = y - height/2 + 25
			for i=1,block.count do
				local stat = block.nodes[tostring(i)]
				assert(stat, "cannot find statement "..i.." in block")
				stat = stat.edges["do"]
				local h = stat.height or SIMPLE_HEIGHT
				y = y + h / 2
				stat.visual.item:setPos(x, y)
				y = y + h / 2 + 5
			end
		end
		function item:itemChange(typ, val)
			if typ == "ItemPositionChange" then self:updateChildPositions(val:toPointF()) end
			super()
		end
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
		end

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
		
		function item:boundingRect()
			return size
		end
		
		if edge.type.name == "Block" then
			createBlockRenderer(view, item, edge)
		else
			if edge.type.icon then item.icon = icon(edge.type.icon) end
			item.poly = edge.type.poly
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
