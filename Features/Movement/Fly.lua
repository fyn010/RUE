-- Fly.
---@module Features.Movement.Fly
local Fly = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Utilities = ModuleLoader.load("Core/Utilities")
local Logger = ModuleLoader.load("Utility/Logger")

Fly.enabled = false
Fly.bodyVelocity = nil
Fly.bodyGyro = nil
Fly.flyConnection = nil
Fly.keysPressed = {}

---Initialize Fly
function Fly.initialize()
    Logger.info("Initializing Fly...")
    Fly.enabled = State.flyEnabled
end

---Enable Fly
function Fly.enable()
    if Fly.enabled then return end

    local character = Services.playersService.LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Fly.enabled = true
    State.flyEnabled = true

    -- Create BodyVelocity for movement
    Fly.bodyVelocity = Instance.new("BodyVelocity")
    Fly.bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    Fly.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    Fly.bodyVelocity.Parent = hrp

    -- Create BodyGyro for stability
    Fly.bodyGyro = Instance.new("BodyGyro")
    Fly.bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    Fly.bodyGyro.CFrame = hrp.CFrame
    Fly.bodyGyro.Parent = hrp

    -- Set humanoid state
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end

    -- Handle input
    Fly.setupInput()

    -- Update loop
    Fly.flyConnection = Services.runService.RenderStepped:Connect(function()
        Fly.update()
    end)

    Logger.info("Fly enabled")
end

---Disable Fly
function Fly.disable()
    if not Fly.enabled then return end

    Fly.enabled = false
    State.flyEnabled = false

    if Fly.bodyVelocity then
        Fly.bodyVelocity:Destroy()
        Fly.bodyVelocity = nil
    end

    if Fly.bodyGyro then
        Fly.bodyGyro:Destroy()
        Fly.bodyGyro = nil
    end

    local character = Services.playersService.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    if Fly.flyConnection then
        Fly.flyConnection:Disconnect()
        Fly.flyConnection = nil
    end

    -- Disconnect input
    if Fly.inputBegan then Fly.inputBegan:Disconnect() end
    if Fly.inputEnded then Fly.inputEnded:Disconnect() end

    Fly.keysPressed = {}

    Logger.info("Fly disabled")
end

---Setup input handling
function Fly.setupInput()
    Fly.inputBegan = Services.userInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        Fly.keysPressed[input.KeyCode] = true
    end)

    Fly.inputEnded = Services.userInputService.InputEnded:Connect(function(input, gameProcessed)
        Fly.keysPressed[input.KeyCode] = false
    end)
end

---Update fly movement
function Fly.update()
    if not Fly.enabled then return end

    local character = Services.playersService.LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local camera = Services.camera
    local speed = State.flySpeed or Constants.DEFAULT_FLY_SPEED
    local moveVector = Vector3.new(0, 0, 0)

    -- Forward/Backward
    if Fly.keysPressed[Enum.KeyCode.W] then
        moveVector = moveVector + camera.CFrame.LookVector
    end
    if Fly.keysPressed[Enum.KeyCode.S] then
        moveVector = moveVector - camera.CFrame.LookVector
    end

    -- Left/Right
    if Fly.keysPressed[Enum.KeyCode.A] then
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if Fly.keysPressed[Enum.KeyCode.D] then
        moveVector = moveVector + camera.CFrame.RightVector
    end

    -- Up/Down
    if Fly.keysPressed[Enum.KeyCode.Space] then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if Fly.keysPressed[Enum.KeyCode.LeftShift] or Fly.keysPressed[Enum.KeyCode.LeftControl] then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end

    -- Apply velocity
    if moveVector.Magnitude > 0 then
        Fly.bodyVelocity.Velocity = moveVector.Unit * speed
    else
        Fly.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end

    -- Update gyro to match camera
    Fly.bodyGyro.CFrame = camera.CFrame
end

---Set fly speed
---@param speed number
function Fly.setSpeed(speed)
    State.flySpeed = math.clamp(speed, 1, 500)
end

---Get fly speed
---@return number
function Fly.getSpeed()
    return State.flySpeed or Constants.DEFAULT_FLY_SPEED
end

---Toggle fly
function Fly.toggle()
    if Fly.enabled then
        Fly.disable()
    else
        Fly.enable()
    end
end

---Cleanup
function Fly.cleanup()
    Fly.disable()
end

return Fly