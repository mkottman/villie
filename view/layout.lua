-------------------------------------------------
-- modified Fruchterman-Reingold layouter
-------------------------------------------------

-- some parameters

local K = 60
local MAX_DIST = 300

-- repulsive force

local function rep(dist)
	return - K^2 / dist
end

local function repulsive(v1, v2)
	local force = v2.pos - v1.pos
	local len = force:len()
	if len < 1 then
		local r = Vector.new(1, 1)
		v2.pos:add(r)
		force = v1.pos - v2.pos
		len = force:len()
	elseif len > MAX_DIST then
		return Vector.new()
	end
	force:norm()
	force:mul(rep(len))
	return force
end

-- attractive force

function attr(dist)
	return dist^2 / K
end

function attractive(v1, v2)
	local force = v2.pos - v1.pos
	local len = force:len()
	if len == 0 then return Vector.new() end
	force:norm()
	force:mul(attr(len))
	return force
end

-- the layouter object

class.Layouter()

local TIMER_INTERVAL = 50
local LAYOUT_STEPS = 50

function Layouter:_init()
	local obj = QObject.new_local()
	local progress = QProgressDialog.new_local(Q"Layouting", Q"Cancel", 0, LAYOUT_STEPS)
	progress:setMinimumDuration(1000)
	self.progress = progress

	local layouter = self

	function obj:timerEvent(e)
		if e:timerId() == layouter.timerId then
			layouter:run()
		end
	end

	self.obj = obj
	self.running = false
end

function Layouter:start(items, manual)
	if self.running then return end
	self.items = items
	if manual then
		self:run()
	else
		self.running = true
		local tid = self.obj:startTimer(TIMER_INTERVAL)
		self.timerId = tid
	end
end

function Layouter:run()
	if self:initialize() then
		self.progress:setValue(0)
		for i=1,LAYOUT_STEPS do
			self:layoutStep()
			self.progress:setValue(i)
			if self.progress:wasCanceled() then break end
		end
		self:updatePositions()
	else
		warn('Could not init layouter')
	end
end

function Layouter:stop()
	if not self.running then return end
	self.obj:killTimer(self.timerId)
	self.running = false
end


function Layouter:layoutStep()
	self:addRepulsive()
	self:addAttractive()
	self:moveElements()
end


function Layouter:initialize()
	if not self.items then return false end
	for i in self.items:iter() do
		if not i.visual then fatal(STR, 'Item is missing visual', i) return false end
		local p = i.visual.item:pos()
		i.pos = Vector.new(p:x(), p:y())
		i.force = Vector.new()
	end
	return true
end

function Layouter:updatePositions()
	for i in self.items:iter() do
		if not i.ignored then
			i.visual.item:setPos(i.pos:unpack())
		end
	end
end

function Layouter:addAttractive()
	for e in self.items:iter() do
		if e:is_a(Edge) then
			for i, n in pairs(e.nodes) do
				local force = attractive(e, n)
				e.force:add(force)
				n.force:sub(force)
			end
		end
	end
end

function Layouter:addRepulsive()
	for u in self.items:iter() do
		for v in self.items:iter() do
			if u ~= v then
				u.force:add(repulsive(u, v))
				-- other force will be added in other iteration
			end
		end
	end
end

local MAX_FORCE = 100;
local MIN_FORCE = 1;
local ALPHA = 0.05;
local MIN_PORTION = 0.25;

function Layouter:moveElements()
	local moved = 0
	local total = 0
	
	for i in self.items:iter() do
		total = total + 1
		
		local force = i.force
		force:mul(ALPHA)
		
		local len = force:len()
		if len > MAX_FORCE then
			force:norm()
			force:mul(MAX_FORCE)
		end
		if len > MIN_FORCE then
			i.pos:add(force)
			moved = moved + 1
		end
	end
	
	if total == 0 or moved/total < MIN_PORTION then
		self:stop()
	end
end
