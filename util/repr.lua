function sortedpairs(t)
  local keys = {}
  for k in pairs(t) do table.insert(keys, k) end
  table.sort(keys, function(a,b)
    if tonumber(a) and tonumber(b) then
      return a < b
    else
      return tostring(a)<tostring(b)
    end
  end)
  local i = 0
  return function()
    if i < #keys then
      i = i + 1
      return keys[i], t[keys[i]]
    end
  end
end

-- Modified version of table serialization from http://lua-users.org/wiki/TableSerialization
-- Original Julio Manuel Fernandez-Diaz, January 12, 2007
function repr(t, name, maxlevel)
	local cart = {}     -- a container

	local function p(s) table.insert(cart, s) end
	local function isemptytable(t)
		local mt = getmetatable(t)
		return next(t) == nil and (not mt or mt.__index)
	end
	local function basicSerialize (o)
		local so = tostring(o)
		if type(o) == "function" then
		   local info = debug.getinfo(o, "S")
		   -- info.name is nil because o is not a calling level
		   if info.what == "C" then
		      return string.format("%q", so .. ", C function")
		   else
		      -- the information is defined through lines
		      return string.format("%q", so .. ", defined in (" ..
		          info.linedefined .. "-" .. info.lastlinedefined ..
		          ") " .. info.source:sub(1, 64))
		   end
		elseif type(o) == "number" then
		   return so
		else
		   return string.format("%q", so)
		end
	end
	local function key(o)
		if type(o)=="string" and o:match("^[%w_]+$") then
			return o
		else
			return "["..basicSerialize(o).."]"
		end
	end

	local saved = {}
	local function addtocart (value, name, indent, field)
		field = field or name
		local ind = ("  "):rep(indent)
		local mt = getmetatable(value)

		p(ind .. field)

		if type(value) ~= "table" then
			p " = "
			p(basicSerialize(value))
			p ";\n"
		else
			if saved[value] then
				p " = {}; -- "
				p(saved[value])
				p(" (self reference)\n")
			else
				saved[value] = name
				if isemptytable(value) then
					p " = {};\n"
				else
					p " = {"
					if maxlevel and indent > maxlevel then
						p " ... "
					else
						p "\n"
						for k, v in sortedpairs(value) do
							k = key(k)
							local fname = string.format("%s.%s", name, k)
							field = k
							addtocart(v, fname, indent+1, field)
						end

						p(ind)
					end
					if mt then
						addtocart(mt, name .. "_metatable", indent+1, "metatable")
					end
					p "};\n"
				end
			end
		end

		if type(value) == "userdata" and mt then
			addtocart(mt, "metatable(" .. field .. ")", indent)
		end
	end

	name = name or "x"
	--[[
	if type(t) ~= "table" then
		return name .. " = " .. basicSerialize(t)
	end
	]]

	local ok, err = xpcall(function() addtocart(t, name, 0) end, debug.traceback)
	if not ok then p(' Error:' .. tostring(err)) end

	return table.concat(cart)
end

local function getlocals()
  local r = {}
  local i = 1
  local l, v = debug.getlocal(2, i)
  while l do
    r[l] = v
    i = i + 1
    l, v = debug.getlocal(2, i)
  end
  return r
end

function dumpstate()
	return print(repr({
		locals = getlocals(),
		globals = _G,
	}, 'state'))
end

function dump(x, name)
	local mt = getmetatable(x)
	return print(repr(x, name), mt and repr(mt, "metatable"))
end

return repr
