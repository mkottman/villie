local op = {}

function op:run()
	local a = self:node'a':value()
	local b = self:node'b':value()
	print('+Sub', a, b)
	self:node'result':setValue(a - b)
end

function op:config()
	print('Configuring', self)
	return {
		operation = 'string',
		inputs = 'number'
	}, function(...)
		print("Got back: ", ...)
	end
end

op.name = 'sub'
op.color = 'orange'
op.proto = {
	{"a", IN},
	{"b", IN},
	{"result", OUT}
}

return op
