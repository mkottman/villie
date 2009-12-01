local op = {}

function op:run()
	print('Running', self)
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

op.name = 'minus'
op.color = 'red'
op.proto = {
	{"a", IN},
	{"b", IN},
	{"result", OUT}
}

return op
