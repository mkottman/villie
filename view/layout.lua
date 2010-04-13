-------------------------------------------------
-- modified Fruchterman-Reingold layouter
-------------------------------------------------

-- some parameters

local K = 200
local MAX_DIST = 800

-- repulsive force

local function rep(dist)
	return - K^2 / dist
end

local function repulsive(v1, v2)
	local force = v2 - v1
	local len = force:len()
	if len < 1 then
		local r = Vector.new(1, 1)
		v2:add(r)
		force = v1 - v2
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
	local force = v2 - v1
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
			local ok, err = xpcall(function() layouter:run() end, debug.traceback)
			if not ok then
				fatal(err)
				layouter:stop()
			end
		end
	end

	self.obj = obj
	self.running = false
end

function Layouter:start(attract, repulse, manual)
	if self.running then return end
	self.attract = attract
	self.repulse = repulse
	
	self.items = {}
	for x in pairs(attract) do self.items[x] = true end
	for x in pairs(repulse) do self.items[x] = true end
	
	if manual then
		self:run()
		self:dump()
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

function Layouter:dump()
	local at = {}
	local re = {}
	for k in pairs(self.attract) do table.insert(at, k) end
	for k in pairs(self.repulse) do table.insert(re, k) end
	warn(repr({attractive = at, repulsive = re}, 'Layouter'))
end

function Layouter:initialize()
	if not self.items then return false end
	local count = 0
	for i in pairs(self.items) do
		if not i.visual then fatal(STR, 'Item is missing visual', i) return false end
		local p = i.visual.item:pos()
		i.pos = Vector.new(p:x(), p:y())
		i.force = Vector.new()
		if i.locked then i.ignored = true end
		count = count + 1
	end
	warn('Moving %d objects', count)
	return true
end

local function restrict(e)
	local vi = e.visual.item
	local br = vi:boundingRect()
	local x = e.pos.x
	local y = e.pos.y
	local width = br:width()
	local height = br:height()
	local r = e.restrictTo
	
	if x < r.x then x = r.x end
	if y < r.y then y = r.y end
	
	if x + width > r.x + r.width then
		x = r.x + r.width - width
	end
	if y + height > r.y + r.height then
		y = r.y + r.height - height
	end
	
	return x, y
end

function Layouter:updatePositions()
	for i in pairs(self.items) do
		if not i.ignored then
			if not i.restrictTo then
				i.visual.item:setPos(i.pos:unpack())
			else
				i.visual.item:setPos(restrict(i))
			end
		else
			warn(STR, 'Ignoring', i)
		end
	end
end

function Layouter:addAttractive()
	for e in pairs(self.attract) do
		for conn in pairs(e.visual.connectors) do
			local other = conn:other(e)
			if self.attract[other] then
				other = other.visual.parent or other
				local force = attractive(e.pos, other.pos)
				e.force:add(force)
				other.force:sub(force)
			else
				warn(STR, 'Ignoring', other)
			end
		end
	end

end

function Layouter:addRepulsive()
	for u in pairs(self.repulse) do
		for v in pairs(self.repulse) do
			if u ~= v then
				u.force:add(repulsive(u.pos, v.pos))
				-- opposite force will be added in other iteration
			end
		end
	end
end

local MAX_FORCE = 10;
local MIN_FORCE = 1;
local ALPHA = 0.05;
local MIN_PORTION = 0.25;

function Layouter:moveElements()
	local moved = 0
	local total = 0
	
	for i in pairs(self.items) do
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
