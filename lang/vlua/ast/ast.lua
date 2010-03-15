--[[
	Lua <-> AST converter, mostly taken and modified from Metalua, so credit
	goes to Fabien Fleutot and his amazing work. I need the AST for pure Lua,
	so Metalua-specific code was removed and I had to implement the "decompiler"
	myself in pure Lua.
	
	`Label, `Goto and `Stat is not implemented, but that should not be a problem
	because they don't appear in pure Lua.
	
	This file: Copyright (c) 2010 Michal Kottman
	Required files: Copyright (c) 2006-2007 Fabien Fleutot <metalua@gmail.com>
--]]

require 'base'
require 'table2'
require 'string2'
require 'gg'
require 'mlp_lexer'
require 'mlp_misc'
require 'mlp_table'
require 'mlp_expr'
require 'mlp_stat'

module("ast", package.seeall)

local islineinfo = { lineinfo = true, comments = true, source = true}
local function delete_line_info(t)
	for k, v in pairs(t) do
		if islineinfo[k] then
			t[k] = nil
		elseif type(v) == 'table' then
			delete_line_info(v)
		end
	end
	return t
end

--- Produces AST from Lua source.
-- @param src - Either Lua string or a file. In case of file, everything is read and the file is closed
-- @return AST of Lua source.
function compile(src)
	if type(src) == "userdata" and src.read then
		local f = src
		src = src:read('*a')
		f:close()
	end
	local lx = mlp.lexer:newstream(src)
	local ast = mlp.chunk (lx)
	return delete_line_info(ast)
end

--- Produces Lua source from AST
-- @param ast The AST of Lua source
-- @return Lua string containing 'formatted' code from AST.
function decompile(ast)
	local process
	
	local ops = {
		{unm = "-", len = "#", ["not"] = "not"},
		{add = "+", sub = "-", mul = "*", div = "/",
		 mod = "%", pow = "^", concat = "..",
		 eq = "==", lt = "<", le = "<=",
		 ["and"] = "and", ["or"] = "or"
		}
	}
	
	local indent = 0
	
	local function commasep(t, start)
		start = start or 1
		local res = {}
		for i=start,#t do table.insert(res, process(t[i])) end
		return table.concat(res, ', ')
	end
	
	local function iend()
		return ("  "):rep(indent-1) .. 'end\n'
	end
	
	local function block(t)
		local ind = ("  "):rep(indent)
		indent = indent + 1
		local res = ''
		for _,s in ipairs(t) do
			res = res .. ind .. (process(s) or '?').. '\n'
		end
		indent = indent - 1
		return res
	end
	
	local builders = {
	-- expressions
		Number = function(t) return t[1] end,
		String = function(t) return ('%q'):format(t[1]) end,
		Id = function(t) return t[1] end,
		Nil = function() return 'nil' end,
		True = function() return 'true' end,
		False = function() return 'false' end,
		Dots = function() return '...' end,
		
		Table = function(t)
			local res = '{'
			for _,e in ipairs(t) do
				if e.tag == 'Pair' then
					local key = process(e[1])
					local val = process(e[2])
					res = res .. '['..key..'] = '..val
				else
					res = res .. process(e)
				end
				res = res .. '; '
			end
			res = res .. '}'
			return res
		end,
		
		Op = function(t)
			local op = t[1]
			if ops[1][op] then -- unary
				return ops[1][op] .. ' ' .. process(t[2])
			else
				local a = process(t[2])
				local b = process(t[3])
				return a .. ' ' .. ops[2][op] .. ' ' .. b
			end
		end,
		
		Index = function(t)
			local prefix = process(t[1])
			local key = '[' .. process(t[2]) .. ']'
			if t[2].tag == "String" and t[2][1]:match("^[%w_][%w%d_]*$") then
				key = '.' .. t[2][1]
			end
			return prefix .. key
		end,
		
		Call = function(t)
			local f = process(t[1])
			return f .. '(' .. commasep(t, 2) .. ')'
		end,
		Invoke = function(t)
			local obj = process(t[1])
			local fun = t[2][1]
			local args = commasep(t, 3)
			return obj .. ':' .. fun .. '(' .. args .. ')'
		end,
		
		Function = function(t)
			local args = t[1]
			local body = process(t[2])
			return 'function (' .. commasep(args) .. ')\n' .. body .. iend()
		end,
		
		Paren = function(t) return '(' .. process(t[1]) .. ')' end,

	-- statements
		Set = function(t)
			return commasep(t[1]) .. ' = ' .. commasep(t[2])
		end,
		
		Local = function(t)
			local ids = t[1]
			local vals = t[2]
			local res = 'local ' .. commasep(ids)
			if #vals > 0 then
				res = res .. ' = ' .. commasep(vals)
			end
			return res
		end,
		Localrec = function(t)
			-- FIXME: better handling
			local name = process(t[1][1])
			local def = process(t[2][1])
			return 'local '..name..'; '..name..' = '..def
		end,
		
		Do = function(t)
			local body = block(t)
			return 'do\n' .. body .. iend()
		end,
		
		While = function(t)
			local cond = process(t[1])
			local body = process(t[2])
			return 'while ' .. cond .. ' do\n' .. body .. iend()
		end,
		Repeat = function(t)
			local cond = process(t[2])
			local body = process(t[1])
			return 'repeat\n' .. body .. ('  '):rep(indent-1) .. 'until ' .. cond
		end,
		
		Forin = function(t)
			local vars = commasep(t[1])
			local exp = commasep(t[2])
			local body = process(t[3])
			return 'for ' .. vars .. ' in ' .. exp .. ' do\n' .. body .. iend()
		end,
		Fornum = function(t)
			local id = process(t[1])
			local start = process(t[2])
			local to = process(t[3])
			local step = t[4].tag and process(t[4])
			local body = step and process(t[5]) or process(t[4])
			return 'for '..id..' = '..
				start..', '..to..(step and (', '..step) or '')..
				' do\n' .. body .. iend()
		end,
		
		If = function(t)
			local res = ''
			for i=1,#t-1,2 do
				if not t[i] or not t[i+1] then
					print(repr({t=t, i=i}, 'if'))
				end
				local cond = process(t[i])
				local body = process(t[i+1])
				res = res .. (i==1 and 'if' or (('  '):rep(indent-1) .. 'elseif')) .. ' '
				res = res .. cond .. ' then\n' .. body
			end
			if #t%2 == 1 then
				res = res .. ('  '):rep(indent-1) .. 'else\n' .. process(t[#t])
			end
			res = res .. iend()
			return res
		end,
		
		Return = function(t)
			local vals = commasep(t)
			return 'return ' .. vals
		end,
		Break = function(t)
			return 'break'
		end,
		
		Label = function() error('cannot undump `Label') end,
		Goto = function() error('cannot undump `Goto') end,
		Stat = function() error('cannot undump `Stat') end,
	}
	
	function process(t)
		local res
		if not t.tag then
			res = block(t)
		else
			if not builders[t.tag] then
				print(repr(t, 'unknown'))
			else
				res = builders[t.tag](t)
			end
		end
		return res
	end
	
	return process(ast)
end
