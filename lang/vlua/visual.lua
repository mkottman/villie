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

-- Node renderer
do
	local size = QRectF.new_local(-40, -10, 80, 20)
	local small = QRectF.new_local(-5, -5, 10, 10)
	--local gradient = QRadialGradient.new_local(center_point, size:height(), center_point)
	--gradient:setColorAt(0, to_color"white")
	local whiteBrush = QBrush.new_local(to_color"white")

	function vlua.setupNodeRenderer(view, node)
		local item
		if node.type.name == "Expression" then
			item = QGraphicsSimpleTextItem.new_local(Q(node.value))
		elseif node.type.name == "Exp" or node.type.name == "Stat" then
			item = QGraphicsRectItem.new_local(small)
			item:setBrush(QBrush.new_local(to_color"black"))
		else
			item = QGraphicsItem.new_local()
			item.str = Q(node.value)
			function item:boundingRect()
				return size
			end
			function item:paint(painter)
				painter:drawRect(size)
				painter:drawText(size, self.str)
			end
		end
		
		item:setFlag('ItemIsSelectable', true)
		item:setFlag('ItemIsMovable', true)
		item:setZValue(2)
		
		return item
	end
end


-- Edge renderer
do
	local SIMPLE_HEIGHT = 30

	local function addExpressions(view, stat)
		for inc, node in pairs(stat.nodes) do
			if node.type.name == "Expression" then
				view:addItem(node)
				view:connect(node, stat)
				local pos = stat.visual.item:pos()
				local x, y = pos:x(), pos:y()
				node.visual.item:setPos(x + 200, y)
			end
		end
	end
	
	local function createBlockRenderer(view, item, block)
		local height = 20
		local width = 150
		local count = 0

		-- prepare the values such as count and height
		for inc, node in pairs(block.nodes) do
			if inc.name ~= "do" then
				local stat = node.edges["do"]
				height = height + (stat.height or SIMPLE_HEIGHT) + 5
				count = count + 1
			end
		end
		
		item:setZValue(0)
		
		local pos = item:pos()
		local x, y = pos:x(), pos:y()
		y = item:pos():y() - height/2 + SIMPLE_HEIGHT + 5
		
		for inc, node in pairs(block.nodes) do
			if inc.name ~= "do" then
				local stat = node.edges["do"]
				
				view:addItem(stat)
				stat.visual.item:setPos(x, y)
				y = y + (stat.height or SIMPLE_HEIGHT) + 5				
				
				addExpressions(view, stat)
				
				-- disable moving for items in block
				stat.visual.item:setFlag('ItemIsMovable', false)
				stat.visual.item:setZValue(3)
				
				stat.visual.parent = block
				stat.locked = true
			end
		end
		
		view.repulse[block] = true
		
		local size = QRectF.new_local(-width/2, -height/2, width, height)
		local titleSize = QRectF.new_local(-width/2, -height/2, width, 15)
		local titleSubsize = QRectF.new_local(-width/2, -height/2 + 10, width, 5)
		local brush = QBrush.new_local(to_color"white")
		local titleBrush = QBrush.new_local(to_color"gray")
		
		function item:updateChildPositions(pos)
			local x, y = pos:x(), pos:y()
			local y = y - height/2 + SIMPLE_HEIGHT + 5
			for i=1,count do
				local stat = block.nodes[tostring(i)]
				assert(stat, "cannot find statement "..i.." in block")
				stat = stat.edges["do"]
				stat.visual.item:setPos(x, y)
				y = y + (stat.height or SIMPLE_HEIGHT) + 5
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
			local x, y = self:x(), self:y()
			painter:setBrush(brush)
			painter:drawRoundedRect(size, 8, 8)
			painter:setBrush(titleBrush)
			painter:setPen('NoPen')
			painter:drawRoundedRect(titleSize, 8, 8)
			painter:drawRect(titleSubsize)
		end
	end
	
	local center_text = QTextOption.new_local({'AlignHCenter', 'AlignVCenter'})
	local size = QRectF.new_local(-70, -SIMPLE_HEIGHT/2, 140, SIMPLE_HEIGHT)
	local gradient = QRadialGradient.new_local(center_point, size:height(), center_point)
	gradient:setColorAt(0, to_color"white")
	
	local custom_polys = {
		If = QPolygonF.new_local()
			:IN(QPointF.new_local(-70, 0))
			:IN(QPointF.new_local(0, -SIMPLE_HEIGHT/2))
			:IN(QPointF.new_local(70, 0))
			:IN(QPointF.new_local(0, SIMPLE_HEIGHT/2));
	
		Call = QPolygonF.new_local()
			:IN(QPointF.new_local(-50, -SIMPLE_HEIGHT/2))
			:IN(QPointF.new_local(70, -SIMPLE_HEIGHT/2))
			:IN(QPointF.new_local(50, SIMPLE_HEIGHT/2))
			:IN(QPointF.new_local(-70, SIMPLE_HEIGHT/2))
	}
	custom_polys.Invoke = custom_polys.Call

	function vlua.setupEdgeRenderer(view, edge)
		local item = QGraphicsItem.new_local()
		
		edge.visual.height = SIMPLE_HEIGHT
		item:setFlag('ItemIsSelectable', true)
		item:setFlag('ItemIsMovable', true)
		item:setZValue(1)
			
		local str
		if edge.type.name == "Op" then str = Q(edge.op)
		else str = Q((edge.type and edge.type.name or 'unknown') .. ':' .. edge.id)
		end
		
		function item:boundingRect()
			return size
		end
		
		if edge.type.name == "Block" then
			createBlockRenderer(view, item, edge)
		else
			if edge.type.icon then
				item.icon = icon(edge.type.icon)
			end
			item.poly = custom_polys[edge.type.name]
			function item:paint(painter)
				local col = edge.type.color and to_color(edge.type.color) or to_color"pink"
				gradient:setColorAt(1, col)
				painter:setBrush(QBrush.new_local(gradient))
				if self.poly then
					painter:drawPolygon(self.poly)
				else
					painter:drawRoundedRect(size, 8, 8)
				end
				painter:drawText(size, str, center_text)
				if self.icon then
					painter:drawPixmap(QPointF.new_local(-60, -8), self.icon)
				end
			end
		end
		
		return item
	end
end
