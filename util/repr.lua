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

function repr(t, name, opts)
	local cart = {}     -- a container
	local id = 1
	local autoref = {} -- for self references
	opts = setmetatable(opts or {}, {__index={
		indent = "  ",
		ignore = {"parent"},
		nometa = false,
		maxlevel = 2
	}})
	
	local function p(s) cart[id]=s; id=id+1 end
	local function ar(s) table.insert(autoref, s) end
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
			return o, '.'
		else
			return "["..basicSerialize(o).."]"
		end
	end

	local function addtocart (value, name, ind, saved, field)
		local indent = opts.indent:rep(ind)
		saved = saved or {}
		field = field or name
	 
		p(indent .. field)

		if type(value) ~= "table" then
			p " = "
			p(basicSerialize(value))
			p ";\n"
			if not opts.nometa and type(value) == "userdata" then
				if getmetatable(value) then addtocart(getmetatable(value), "metatable", ind) end
				if debug.getfenv(value) then addtocart(debug.getfenv(value), "env", ind) end
			end
		else
			if saved[value] then
				p " = {}; -- "
				p(saved[value])
				p(" (self reference)\n")
				ar(name .. " = " .. saved[value] .. ";\n")
			else
				saved[value] = name
				if isemptytable(value) then
					p " = {};\n"
				else
					p " = {"
					if ind > opts.maxlevel then
						p " ... "
					else
						p "\n"
						for k, v in sortedpairs(value) do
							k, kk = key(k)
							local fname = string.format("%s%s%s", name, kk or '', k)
							field = k
							if not opts.ignore[k] then
								addtocart(v, fname, ind+1, saved, field)
							end
						end
						p(indent)
					end
					p "};\n"
				end
			end
		end
	end

	name = name or "x"
	local ok, err = xpcall(function() addtocart(t, name, 0) end, debug.traceback)
	if not ok then p(' Error:' .. tostring(err)) end
	return table.concat(cart) .. table.concat(autoref)
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
