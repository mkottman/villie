local op = {}

function op:run()
	print('+Div', self)
	local a = self:node'a':value()
	local b = self:node'b':value()
	print('Got', a, b)
	self:node'result':setValue(a/b)
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

op.name = 'div'
op.color = 'red'
op.proto = {
	{"a", IN},
	{"b", IN},
	{"result", OUT}
}

return op
