-- Main Window.
---@module GUI.Window
local Window = {}

local Library = ModuleLoader.load("GUI/Library")
local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")

Window.mainWindow = nil

---Create the main RUE window
---@return table
function Window.create()
    Window.mainWindow = Library.createWindow("RUE - Recarga Urbana Exploit", Vector2.new(650, 550))
    return Window.mainWindow
end

---Get the main window
---@return table?
function Window.get()
    return Window.mainWindow
end

---Destroy the main window
function Window.destroy()
    if Window.mainWindow then
        Library.destroyWindow(Window.mainWindow)
        Window.mainWindow = nil
    end
end

---Toggle window visibility
function Window.toggle()
    if Window.mainWindow and Window.mainWindow.screenGui then
        Window.mainWindow.screenGui.Enabled = not Window.mainWindow.screenGui.Enabled
    end
end

---Set window visibility
---@param visible boolean
function Window.setVisible(visible)
    if Window.mainWindow and Window.mainWindow.screenGui then
        Window.mainWindow.screenGui.Enabled = visible
    end
end

return Window