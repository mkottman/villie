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


--- Returns a new QString
function Q(s)
	return QString.fromUtf8(s, #s)
end
