<!-- markdownlint-disable MD024 -->

# Marionette debugger

## What it does

Debugging tools are powerful. Virtually every IDE has one, including roblox studio.
However, roblox cheat development is still behind, in, well every aspect of debugging. There is nothing.

This project aims to fix that, it spins up a small node.js server and connects to your executor, injects debug macros and lets you have at it.

- Hot reloads
- Redirect output to VSCode terminals
- Auto syntax and runtime redirection
- Breakpoints

## Dependencies

- [NodeJS](https://nodejs.org/en) </br> Runs the debug server

## Setting this up

### 1. Executor client

- Put [`tools/client.luau`](./tools/client.luau) into your executor's autoexec. This is the client for connecting your executor to our debugger.

### 2. Debug Server Files

- Move the folder [`tools/debug`](./tools/debug) into your project somewhere (usually in the root)

> [!IMPORTANT]
> You need to edit [`debug/config.json`](./tools/debug/config.json) to adjust the input path.

### 3. VSCode RND launch

- Put [`.vscode/launch.json`](.vscode/launch.json) in your project's `.vscode` folder. (Or make a new .vscode folder if needed)

---

Done!

Press `F5` in VSCode start the debugger (Or start in the "Run & Debug tab" in VSCode)

## Macros

> [!NOTE]
> If you use Luau-LSP, type definitions for macros are available at [`.globals/marionette.d.luau`](./.globals/marionette.d.luau)

### `debugger.halt()`

Acts as a breakpoint.

- Will pause execution once reached
- Go back to your VSCode terminal to interact:
  - Evaluate expressions (global scope):

    ```lua
    return getgenv().variable
    ```

  - Type `continue` to resume

#### Arguments

- `conditional: boolean?` | Pass a inline conditional

```lua
local p = 10

debugger.halt(p == 11) -- pass true/false explicitly
```

Building on your style—clean, documentation-driven, and focused on the developer experience—here is the updated section for your `README`.

### `debugger.watch()`

Register a variable to the watch stack. Lets you see its value and modify it in a eval.

- Takes a get/set closure.
- Automatically shows vars in the watch stack under `Local Variables` during a breakpoint.

#### Arguments

- `name: string` | The vars display name.
- `handler: (set: any?) -> any` | Handles modifying and retrieving the variables value.

```lua
local score = 100

debugger.watch("score", function(val)
    return debugger.check(score, val)
end)
```

```lua
-- In debug terminal
DEBUG> return score
10
DEBUG> score = 20; return score
20
```

### `debugger.watchBatch()`

A convenience macro to register multiple local variables at once. Ideal for use at the start of a function or logic block.

#### Arguments

- `vars: {[string]: (set: any?) -> any}` | A dictionary of names and handler closures.

```lua
local power = 50
local speed = 10

debugger.watchBatch {
    power = function(v) debugger.check(power, v) end,
    speed = function(v) debugger.check(speed, v) end
}
```

### `debugger.check()`

Meant to be used within `debugger.watch()` or `debugger.watchBatch()`. Automatically checks conditions.

#### Arguments

- `current: any` | The current value
- `newValue: any?` | Value passed from eval, if any.

### `debugger.watchStack`

The raw table containing all registered watch handlers.

```lua
table.clear(debugger.watchStack)
```
