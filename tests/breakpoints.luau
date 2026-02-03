local num = 10

debugger.watch("num", function(set: any?) -- add the var "num" to watch stack as "num"
	if set ~= nil then
		num = set
	end

	return num
end)

--[[ debugger.watchBatch{ -- add a set of vars to the watch stack
	num = function(set: any?)
		num = set or num

		return num
	end,
} ]]

debugger.halt() -- breakpoint
--debugger.halt(num < 20) -- You can also add inline conditionals

if num < 20 then
	print("Not enough")
else
	print("Passed")
end
