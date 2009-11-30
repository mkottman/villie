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

op.name = 'plus'
op.color = 'red'
op.proto = {
	{"in1", IN},
	{"in2", IN},
	{"out", OUT}
}

return op
