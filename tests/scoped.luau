loadstring([====[
local foo = 123

print(debugger)
print('hi')

debugger.watch("foo", function(newVal)
    if newVal ~= nil then foo = newVal end
    return foo
end)

debugger.halt()
]====])()
