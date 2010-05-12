function fib(n)
	if n < 3 then return 1
	else return fib(n-2) + fib(n-1) end
end

function fib2(n)
	local a = 1
	local b = 1
	for i=3,n do
		local c = b
		b = a
		a = a + c
	end
	return a
end

N = 10
F = fib(N)
F2 = fib2(N)
print(F, F2)
