-- Utility functions

require 'util.repr'

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
  return QString.fromUtf8(s, #s)
end

--- Returns a Lua string from QString.
-- Uses UTF8.
-- @param q QString to be converted
-- @return Lua string represented by argument q
function S(q)
  return q:toUtf8()
end

--- Marks a Todo point
function TODO(s)
  local f = debug.getinfo(2)
  if f then
    log("TODO: '%s' in %s %s:%d", s, f.name, f.source, f.linedefined)
  else
    log("TODO: '%s' (cannot find source)", s)
  end
end
