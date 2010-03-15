module("vlua", package.seeall)

package.path = './lang/vlua/ast/?.lua;' .. package.path

require 'ast'

function initialize(graph)
	
end

function import(graph)
	local name = QFileDialog.getOpenFileName(nil, Q"Select Lua source", 
		Q".", Q"Lua source (*.lua)")
	if not name:isEmpty() then
		local ast = ast.compile(io.open(S(name)))
		print(repr(ast))
	else
		return graph
	end
end

function export(graph)
	
end

log('VLua active')

return _M