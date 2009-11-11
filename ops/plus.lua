local op = {}

function op:run()
    print('Running', self)
end

function op:config()
    print('Configuring', self)
end

op.name = 'plus'
op.color = 'red'

return op
