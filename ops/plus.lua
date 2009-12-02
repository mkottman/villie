local op = {}

function op:run()
	print('+Plus', self)
	local a = self:node'in1':value()
	local b = self:node'in2':value()
	print('Got', a, b)
	self:node'out':setValue(a + b)
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

op.name = 'plus'
op.color = 'yellow'
op.proto = {
	{"in1", IN},
	{"in2", IN},
	{"out", OUT}
}

return op
