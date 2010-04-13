-- Utility functions

require 'util.repr'
require 'logging'
require 'logging.console'

-- from http://lua-users.org/wiki/ModuleDefinition
function package.clean(module)
  local privenv = {_PACKAGE_CLEAN = true}
  setfenv(3, setmetatable(privenv,
      {__index=_G, __newindex=function(_,k,v) rawset(privenv,k,v); module[k]=v end}
  ))
end


-- from http://lua-users.org/wiki/ModuleDefinition
function package.strict(t)
  local privenv = getfenv(3)
  local top = debug.getinfo(3,'f').func

  local mt = getmetatable(privenv)

  function mt.__index(t,k)
    local v=_G[k]
    if v ~= nil then return v end
    error("variable '" .. k .. "' is not declared", 2)
  end

  if rawget(privenv, '_PACKAGE_CLEAN') then
    local old_newindex = assert(mt.__newindex)
    function mt.__newindex(t,k,v)
      if debug.getinfo(2,'f').func ~= top then
        error("assign to undeclared variable '" .. k .. "'", 2)
      end
      old_newindex(t,k,v)
    end
  else
    function mt.__newindex(t,k,v)
      error("assign to undeclared variable '" .. k .. "'", 2)
      old_newindex(t,k,v)
    end
  end
end


--- Returns a new QString.
-- Uses UTF8.
-- @param s Lua string to be converted to QString
-- @usage Q"Hello World!" -- returns QString containing "Hello World!"
-- @return
function Q(s)
  s = type(s) == "string" and s or tostring(s)
  return QString.fromUtf8(s, #s)
end

--- Returns a Lua string from QString.
-- Uses UTF8.
-- @param q QString to be converted
-- @return Lua string represented by argument q
function S(q)
  return q:toUtf8()
end


function super()
	error(SUPER)
end


local logger = logging.console()
if not DEBUG then logger:setLevel(logging.WARN) end

function setlogger(appender)
	logger = logging.new(appender)
	if not DEBUG then logger:setLevel(logging.WARN) end
end


local function preplog(first, ...)
	if select('#', ...) == 0 then
		return first
	else
		if type(first) == 'function' then
			return first(...)
		else
			return string.format(first, ...)
		end
	end
end

function STR(...)
	local t = {...}
	local n = select('#', ...)
	for i=1,n do
		local x = t[i]
		t[i] = tostring(t[i])
		if type(x) == 'table' or type(x) == 'userdata' then
			local name = x.__type or x._class and x._class._name
			if name then 
				t[i] = name .. '('.. t[i].. ')'
			end
		end
	end
	return table.concat(t, '\t')
end

function trace(...)
	return logger:debug(preplog(...))
end

function info(...)
	return logger:info(preplog(...))
end

function warn(...)
	return logger:warn(preplog(...))
end

function fatal(...)
	return logger:fatal(preplog(...))
end

function log(...)
	return info(...)
end

--- Marks a Todo point
function TODO(s)
  local f = debug.getinfo(2)
  if f then
    log("TODO: '%s' in %s %s:%d", s, f.name or '???', f.source or '???', f.linedefined or 0)
  else
    log("TODO: '%s' (cannot find source)", s)
  end
end




----------------------------------------------------
-- Vector class
----------------------------------------------------

Vector = {}
Vector.__index = Vector

function Vector.new(x,y)
	local nx, ny = 0, 0
	if x then
		local t = type(x)
		if t == "number" then
			nx, ny = x, y
		elseif t == "table" then
			nx, ny = x.x, x.y
		end
	end
	return setmetatable({x=nx,y=ny}, Vector)
end

function Vector:__tostring()
	return '{'..self.x..','..self.y..'}'
end

function Vector.rand(n)
	local x, y = math.random(n)-n/2, math.random(n)-n/2
	return Vector.new(x, y)
end

function Vector.__add(a,b)
	return Vector.new(a.x+b.x, a.y+b.y)
end

function Vector.__sub(a,b)
	return Vector.new(a.x-b.x, a.y-b.y)
end

function Vector.__mul(a,b)
	return Vector.new(a.x*b, a.y*b)
end

function Vector.__div(a,b)
	return Vector.new(a.x/b, a.y/b)
end

function Vector.__unm(a)
	return Vector.new(-a.x, -a.y)
end

function Vector:add(v)
	self.x = self.x + v.x
	self.y = self.y + v.y
end

function Vector:sub(v)
	self.x = self.x - v.x
	self.y = self.y - v.y
end

function Vector:mul(v)
	self.x = self.x * v
	self.y = self.y * v
end

function Vector:div(v)
	self.x = self.x / v
	self.y = self.y / v
end

function Vector:len()
	return math.sqrt(self.x^2 + self.y^2)
end

function Vector:norm()
	local len = self:len()
	return self:div(len)
end

function Vector:unpack()
	return self.x, self.y
end

