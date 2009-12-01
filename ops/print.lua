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

op.name = 'print'
op.color = 'green'
op.proto = {
	{"input", IN},
}

return op
