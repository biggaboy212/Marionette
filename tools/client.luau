local WS_URL = "ws://localhost:3000/ws"

local lastScript = nil
local ws = nil

local function report(message)
    if ws then
        pcall(function()
            ws:Send(message)
        end)
    end
end

local function connect()
    while true do
        local success, socket = pcall(function()
            return WebSocket.connect(WS_URL)
        end)

        if success and socket then
            ws = socket
            print("Successfully connected to " .. WS_URL)

            ws.OnMessage:Connect(function(message)
                if not message or message == "" or message == lastScript then return end
                lastScript = message

                local func, loadErr = loadstring(message)
                if func then
                    task.spawn(function()
                        local suc, err = pcall(func)
                        if not suc then
                            local stack = debug.traceback(err, 2)
                            report("Execution Error: " .. tostring(err) .. "\nStack:\n" .. stack)
                        end
                    end)
                else
                    report("Syntax Error: " .. tostring(loadErr))
                end
            end)

            ws.OnClose:Connect(function()
                warn("WebSocket connection lost. Reconnecting...")
                ws = nil
                connect()
            end)

            break
        end

        task.wait(3)
    end
end

connect()