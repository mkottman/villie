A = 1

local f = io.open('test.lua')

print(f)

f:read("*a")

if math.sin(A) > 0 then A = 2 else return 3 end

while A > 4 do print(A) end

repeat
until A < 5

for i=1,6 do
	break
end

for a in keys(_G) do
	A = A + 1
end

function func(x)
	local y = x * 5
	return math.sqrt(y) + 2
end
