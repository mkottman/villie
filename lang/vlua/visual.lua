module('vlua.visual', package.seeall)

local color_cache = setmetatable({}, {__mode="v"})
local function to_color(c)
	if not color_cache[c] then
		color_cache[c] = QColor.new_local(Q(c))
	end
	return color_cache[c]
end

local center_point = QPointF.new_local(0,0)

-- Node renderer
do
	local size = QRectF.new_local(-40, -10, 80, 20)
	local small = QRectF.new_local(-5, -5, 10, 10)
	--local gradient = QRadialGradient.new_local(center_point, size:height(), center_point)
	--gradient:setColorAt(0, to_color"white")

	function vlua.setupNodeRenderer(node, item)
		local item
		if node.type.name == "Expression" then
			item = QGraphicsSimpleTextItem.new_local(Q(node.value))
		elseif node.type.name == "Exp" or node.type.name == "Stat" then
			item = QGraphicsRectItem.new_local(small)
		else
			item = QGraphicsItem.new_local()
			item.str = Q(node.type.name .. ": " .. node.id)
			function item:boundingRect()
				return size
			end
			function item:paint(painter)
				gradient:setColorAt(1, to_color(node.type.color))
				painter:setBrush(QBrush.new_local(gradient))
				painter:drawRect(size)
				painter:drawText(center_point, self.str)
			end
		end

		return item
	end
end


-- Edge renderer
do
	local size = QRectF.new_local(-70, -15, 140, 30)
	local gradient = QRadialGradient.new_local(center_point, size:height(), center_point)
	gradient:setColorAt(0, to_color"white");

	function vlua.setupEdgeRenderer(edge)
		local item = QGraphicsItem.new_local()

		local str
		if edge.type.name == "Op" then str = Q(edge.op)
		else str = Q((edge.type and edge.type.name or 'unknown') .. edge.id)
		end

		function item:boundingRect()
			return size
		end
		function item:paint(painter)
			local col = edge.type.color and to_color(edge.type.color) or to_color"pink"
			gradient:setColorAt(1, col)
			painter:setBrush(QBrush.new_local(gradient))
			painter:drawRoundedRect(size, 8, 8)
			painter:drawText(size, str, center_text)
		end

		return item
	end
end