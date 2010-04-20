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

-- adapted from penlight: http://penlight.luaforge.net/

local function call_ctor (c,obj,...)
    -- nice alias for the base class ctor
    if c._base then obj.super = c._base._init end
    local res = c._init(obj,...)
    obj.super = nil
    return res
end

local function is_a(self,klass)
    local m = getmetatable(self)
    if not m then return false end --*can't be an object!
    while m do
        if m == klass then return true end
        m = rawget(m,'_base')
    end
    return false
end

local function class_of(klass,obj)
    if type(klass) ~= 'table' or not rawget(klass,'is_a') then return false end
    return klass.is_a(obj,klass)
end

local function _class_tostring (obj)
    local mt = obj._class
    local name = rawget(mt,'_name')
    setmetatable(obj,nil)
    local str = tostring(obj)
    setmetatable(obj,mt)
    if name then str = name ..str:gsub('table','') end
    return str
end

local function _class(base,c_arg,c)
    c = c or {}     -- a new class instance, which is the metatable for all objects of this type
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    local mt = {}   -- a metatable for the class instance

    if type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        tupdate(c,base)
        c._base = base
        -- inherit the 'not found' handler, if present
        if c._handler then mt.__index = c._handler end
    elseif base ~= nil then
        error("must derive from a table type")
    end

    c.__index = c
    setmetatable(c,mt)
    c._init = nil

    if base and base._class_init then
        base._class_init(c,c_arg)
    end

    -- expose a ctor which can be called by <classname>(<args>)
    mt.__call = function(class_tbl,...)
        local obj = {}
        setmetatable(obj,c)

        if c._init then -- explicit constructor
            local res = call_ctor(c,obj,...)
            if res then -- _if_ a ctor returns a value, it becomes the object...
                obj = res
                setmetatable(obj,c)
            end
        elseif base and base._init then -- default constructor
            -- make sure that any stuff from the base class is initialized!
            call_ctor(base,obj,...)
        end

        if base and base._post_init then
            base._post_init(obj)
        end

        if not rawget(c,'__tostring') then
            c.__tostring = _class_tostring
        end
        return obj
    end
    c.is_a = is_a
    c.class_of = class_of
    c._class = c
    return c
end

class = setmetatable({},{
    __index = function(tbl,key)
        local env = getfenv(2)
        return function(...)
            local c = _class(...)
            c._name = key
            env[key] = c
            return c
        end
    end
})

class.List()
function List:append(x)
	table.insert(self, x)
end
function List:iter()
	local s = {i=0, arr = self, cnt=#self}
	return function(s)
		if s.i == s.cnt then return end
		s.i = s.i + 1
		return s.arr[s.i]
	end, s
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

function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
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

