
local hooks = {}

function emit(event, ...)
	-- trace(STR, 'Emitting signal', event, ...)
	for _,h in ipairs(hooks[event]) do
		h(...)
	end
end

function event(name)
	if hooks[name] then fatal('Event "%s" already defined!', name) return end
	hooks[name] = setmetatable({}, {__call = function(t, ...)
		emit(name, ...)
	end})
	return hooks[name]
end

function handle(event, handler)
	if not hooks[event] then fatal('No event "%s" registered!', event) return end
	table.insert(hooks[event], handler)
end

require 'model.graph'

