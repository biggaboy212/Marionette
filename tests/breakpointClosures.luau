local function run()
    print("start")
    debugger.halt()
    print("next")

    local function nested()
        debugger.halt()
        print("done")
    end

    nested()
end

run()