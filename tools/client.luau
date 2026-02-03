local WS = "ws://localhost:3000/ws"

local httpService = game:GetService("HttpService")

if not getgenv().__DSESS then
	getgenv().__DSESS = {
		Threads = {},
		Sockets = {},
		Connections = {},
	}
end

local this = getgenv().__DSESS
local lastScript = nil
local ws = nil

local function lobotomize()
	for _, thread in pairs(this.Threads) do
		if thread then
			task.cancel(thread)
		end
	end
	table.clear(this.Threads)

	for _, sock in pairs(this.Sockets) do
		if sock and sock.Close then
			pcall(function()
				sock:Close()
			end)
		end
	end
	table.clear(this.Sockets)

	for _, conn in pairs(this.Connections) do
		if conn and conn.Disconnect then
			conn:Disconnect()
		end
	end
	table.clear(this.Connections)
end

local function connect()
	while true do
		local success, socket = pcall(function()
			return WebSocket.connect(WS)
		end)

		if success and socket then
			ws = socket

			ws.OnMessage:Connect(function(message)
				if not message or message == "" then
					return
				end

				local success, data = pcall(function()
					return httpService:JSONDecode(message)
				end)

				if success and data.type then
					if data.type == "RESUME" or data.type == "EVAL" then
						if getgenv().debug and getgenv().debugger.handleMessage then
							getgenv().debugger.handleMessage(data)
						end
						return
					end

					if data.type == "SCRIPT" then
						local src = data.payload

						if src == lastScript then
							return
						end

						lastScript = src

						lobotomize()

						local header = [[
                            local _WebSocket = WebSocket
                            local WebSocket = {}
                            WebSocket.connect = function(...)
                                local s = _WebSocket.connect(...)
                                table.insert(getgenv().__DSESS.Sockets, s)
                                return s
                            end
                            setmetatable(WebSocket, {__index = _WebSocket})
                        ]]

						local fullSrc = `{header}\n{src}`

						local func, syn = loadstring(fullSrc)
						if func then
							local t = task.spawn(function()
								local suc, err = pcall(func)
								if not suc then
									local stack = debugger.traceback(err, 2)
									if ws then
										ws:Send(httpService:JSONEncode({
											type = "ERROR",
											msg = tostring(err),
											stack = stack,
										}))
									end
								end
							end)

							table.insert(this.Threads, t)
						else
							ws:Send(httpService:JSONEncode({ type = "ERROR", msg = "Syntax: " .. tostring(syn) }))
						end
					end
				end
			end)

			ws.OnClose:Connect(function()
				warn("WS Lost")

				ws = nil
				lastScript = nil

				task.wait(2)
				connect()
			end)

			ws:Send(httpService:JSONEncode({ type = "READY" }))
			break
		end

		task.wait(1)
	end
end

connect()
