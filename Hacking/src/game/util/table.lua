function table.len(t)
	t = t or {}
	local i = 0
	for k,v in pairs(t) do
		i = i + 1
	end
	return i
end

function table.random(t)
	local i = math.random(1, table.len(t))
	for k,v in pairs(t) do
		i = i - 1
		if i == 0 then
			return v
		end
	end
end

function table.contains(t, v)
	for k,vv in pairs(t) do
		if vv==v then return true end
	end
	return false
end

function table.find(t, v)
	for k,vv in pairs(t) do
		if vv==v then return k end
	end
	return nil
end

function table.reverse(t)
	local ret = {}
	local i = #t
	for i,v in ipairs(t) do
		ret[i] = t[#t-(i-1)]
		i = i - 1
	end
	return ret
end

function table.numbers(n)
	local ret = {}
	for i=1,n do table.insert(ret, i) end
	return ret
end

function table.shuffle(t)
	local ret = {}
	t = table.copy(t) --Prevents modification of original input
	while #t > 0 do
		local i = math.random(1,#t)
		table.insert(ret, t[i])
		table.remove(t, i)
	end
	return ret
end

--Checks if a table misses elements when parsed with ipairs, due to a nil element
function table.broken(t)
	if (not t) or type(t)~="table" then assert(false, "Passed a non-table value to table.broken: "..tostring(t)) end

	local max_pairs = 0
	local max_ipairs = 0
	for k,v in pairs(t) do
		if type(k)=="number" and k>max_pairs then max_pairs = k end
	end
	for i,v in ipairs(t) do
		if i>max_ipairs then max_ipairs = i end
	end
	if max_pairs > max_ipairs then
		return true, max_ipairs + 1
	else
		return false
	end
end

--Adds the corresponding elements of a list together
--Modifies the existing t1 table
--Throws errors if you try to add non-numbers
function table.add(t1, t2)
	for k,v in pairs(t2) do
		if t1[k] then
			t1[k] = t1[k] + v
		else
			t1[k] = v
		end
	end
end

function table.tostring(t)
	if table.len(t) == 0 then return "<Empty Table>" end
	local ret = ""
	for k,v in pairs(t) do
		ret = ret..tostring(k).."   "..tostring(v).."\n"
	end
	return ret
end

--Only first level
function table.copy(t)
	local ret = {}
	for k,v in pairs(t) do
		ret[k] = v
	end
	return ret
end