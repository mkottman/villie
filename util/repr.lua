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
	local id = 1

	local function p(s) cart[id]=s; id=id+1 end
	local function isemptytable(t)
		local mt = getmetatable(t)
		return next(t) == nil and (not mt or not mt.__index)
	end
	local function basicSerialize (o)
		local so = tostring(o)
		if type(o) == "function" then
		   local info = debug.getinfo(o, "S")
		   -- info.name is nil because o is not a calling level
		   if info.what == "C" then
		      return string.format("%q", so .. ", C function")
		   else
		   		local src = info.source
		   		if src:match('^@') then
		   			local f = assert(io.open(src:sub(2)))
		   			if f then
		   				local line = 1
		   				for l in f:lines() do
		   					if line == info.linedefined then
		   						return "function"..l:match("%b()").." -- "..info.source .. ":" .. info.linedefined
		   					end
		   					line = line + 1
		   				end
		   			end
		   		end
		      -- the information is defined through lines
		      return string.format("%q", so .. ", defined in (" ..
		          info.linedefined .. "-" .. info.lastlinedefined ..
		          ") " .. src)
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
						if not mt then p(ind) end
					end
					if mt then
						addtocart(mt, name .. "_metatable", indent+1, "metatable")
						p(ind)
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
	return dump({
		locals = getlocals(),
		globals = _G,
	}, 'state')
end

function dump(x, name)
	if type(x) ~= "userdata" and type(x) ~= "table" then
		return QMessageBox.information(nil, Q(tostring(x)))
	end

	local items = {}
	local tree = QTreeWidget.new_local()
	tree:setWindowTitle(Q'Dump')
	tree:setColumnCount(3)

	local headers = QStringList.new_local()
	headers:append(Q'name')
	headers:append(Q'type')
	headers:append(Q'value')
	tree:setHeaderLabels(headers)

	local nf = QFont.new_local(Q'Helvetica', 10, 50)
	local bf = QFont.new_local(Q'Helvetica', 10, 75)

	local addChildren
	local function addValue(v, name, parent, expand)
		local item = QTreeWidgetItem.new_local(parent, values) -- adds to parent
		item:setText(0, Q(name))
		item:setText(1, Q(type(v)))
		item:setText(2, Q(tostring(v)))
		item:setFont(0, nf)
		item.name = name
		item.value = v
		items[item] = true
		if expand then
			addChildren(v, item)
		end
	end
	addChildren = function(value, item)
		if item:childCount() > 0 then return end
		if type(value) == "table" then
			for k, c in sortedpairs(value) do
				addValue(c, k, item, false)
			end
		end
		if type(value) == "table" or type(value) == "userdata" then
			local mt = debug.getmetatable(value)
			local env = debug.getfenv(value)
			if mt then
				addValue(mt, "__metatable", item, false)
			end
			if env then
				addValue(env, "__env", item, false)
			end
		end
		if item:childCount() > 0 then
			item:setExpanded(true)
			item:setFont(0, bf)
		end
	end

	tree:__addmethod('expand(QTreeWidgetItem*,int)', function(self, item, col)
		addChildren(item.value, item)
	end)
	tree:connect('2itemClicked(QTreeWidgetItem*,int)', tree, '1expand(QTreeWidgetItem*,int)')

	addValue(x, name or 'root', tree, true)
	tree:show()
end

return repr
