-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ArcadeFont = Font.fromEnum(Enum.Font.Arcade)

--------------------------------------------------------------------------------
-- 1. CHAT HELPER
--------------------------------------------------------------------------------
local function gameChat(msg)
    pcall(function()
        local general = TextChatService:FindFirstChild("RBXGeneral", true)
        if general and general:IsA("TextChannel") then
            general:SendAsync(msg)
        else
            local defaultEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if defaultEvents and defaultEvents:FindFirstChild("SayMessageRequest") then
                defaultEvents.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. AUDIO HELPER
--------------------------------------------------------------------------------
local function playSound(soundId, loop)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = 1
    sound.Looped = loop or false
    sound.Parent = Workspace
    sound:Play()
    if not loop then
        sound.Ended:Connect(function() sound:Destroy() end)
    end
    return sound
end

local function stopSound(sound)
    if sound then
        sound:Stop()
        sound:Destroy()
    end
end

--------------------------------------------------------------------------------
-- 3. UI SETUP & BOTTOM SLIDING MENU
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Catware_AnimatedNoob"
ScreenGui.ResetOnSpawn = false

local successParent = pcall(function() ScreenGui.Parent = CoreGui end)
if not successParent or not ScreenGui.Parent then 
    ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") 
end

-- Top Controls Container (Centered so it doesn't block top-left Roblox Chat)
local MainControlFrame = Instance.new("Frame")
MainControlFrame.Size = UDim2.new(0, 480, 0, 200)
MainControlFrame.Position = UDim2.new(0.5, -240, 0.05, 0)
MainControlFrame.BackgroundTransparency = 1
MainControlFrame.Parent = ScreenGui

local TopBanner = Instance.new("TextLabel")
TopBanner.Size = UDim2.new(1, 0, 0, 25)
TopBanner.Position = UDim2.new(0, 0, -0.15, 0)
TopBanner.BackgroundTransparency = 1
TopBanner.Text = 'Use Bottom Menu for Actions'
TopBanner.TextColor3 = Color3.fromRGB(255, 255, 255)
TopBanner.TextScaled = true
TopBanner.FontFace = ArcadeFont
TopBanner.Parent = MainControlFrame

local Keypad = Instance.new("Frame")
Keypad.Size = UDim2.new(0, 150, 0, 150)
Keypad.Position = UDim2.new(0, 40, 0, 0)
Keypad.BackgroundTransparency = 1
Keypad.Parent = MainControlFrame

local function createKeyButton(name, pos, size)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.FontFace = ArcadeFont
    btn.TextSize = 18
    btn.Parent = Keypad
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local btnW = createKeyButton("W", UDim2.new(0, 50, 0, 0), UDim2.new(0, 45, 0, 45))
local btnA = createKeyButton("A", UDim2.new(0, 0, 0, 50), UDim2.new(0, 45, 0, 45))
local btnS = createKeyButton("S", UDim2.new(0, 50, 0, 50), UDim2.new(0, 45, 0, 45))
local btnD = createKeyButton("D", UDim2.new(0, 100, 0, 50), UDim2.new(0, 45, 0, 45))
local btnSpace = createKeyButton("SPACE", UDim2.new(0, 0, 0, 100), UDim2.new(0, 95, 0, 40))
local btnT = createKeyButton("T", UDim2.new(0, 100, 0, 100), UDim2.new(0, 45, 0, 40))

local btnCamLeft = Instance.new("TextButton")
btnCamLeft.Size = UDim2.new(0, 35, 0, 140)
btnCamLeft.Position = UDim2.new(0, 0, 0, 0)
btnCamLeft.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnCamLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCamLeft.Text = "<"
btnCamLeft.FontFace = ArcadeFont
btnCamLeft.TextSize = 22
btnCamLeft.Visible = false
btnCamLeft.Parent = MainControlFrame

local btnCamRight = Instance.new("TextButton")
btnCamRight.Size = UDim2.new(0, 35, 0, 140)
btnCamRight.Position = UDim2.new(0, 195, 0, 0)
btnCamRight.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnCamRight.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCamRight.Text = ">"
btnCamRight.FontFace = ArcadeFont
btnCamRight.TextSize = 22
btnCamRight.Visible = false
btnCamRight.Parent = MainControlFrame

local ToggleKeyboardBtn = Instance.new("TextButton")
ToggleKeyboardBtn.Size = UDim2.new(0, 95, 0, 140)
ToggleKeyboardBtn.Position = UDim2.new(0, 240, 0, 0)
ToggleKeyboardBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleKeyboardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleKeyboardBtn.Text = "Use Controls"
ToggleKeyboardBtn.TextWrapped = true
ToggleKeyboardBtn.FontFace = ArcadeFont
ToggleKeyboardBtn.TextSize = 11
ToggleKeyboardBtn.Parent = MainControlFrame

local FollowCamBtn = Instance.new("TextButton")
FollowCamBtn.Size = UDim2.new(0, 95, 0, 140)
FollowCamBtn.Position = UDim2.new(0, 345, 0, 0)
FollowCamBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FollowCamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FollowCamBtn.Text = "Follow Cam\n[OFF]"
FollowCamBtn.TextWrapped = true
FollowCamBtn.FontFace = ArcadeFont
FollowCamBtn.TextSize = 12
FollowCamBtn.Parent = MainControlFrame

--------------------------------------------------------------------------------
-- VIRTUAL JOYSTICK SETUP
--------------------------------------------------------------------------------
local JoystickFrame = Instance.new("Frame")
JoystickFrame.Name = "CustomJoystick"
JoystickFrame.Size = UDim2.new(0, 120, 0, 120)
JoystickFrame.Position = UDim2.new(0.05, 0, 0.65, 0)
JoystickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
JoystickFrame.BackgroundTransparency = 0.5
JoystickFrame.Visible = false
JoystickFrame.Parent = ScreenGui

local jCorner = Instance.new("UICorner")
jCorner.CornerRadius = UDim.new(1, 0)
jCorner.Parent = JoystickFrame

local JoystickThumb = Instance.new("Frame")
JoystickThumb.Name = "Thumb"
JoystickThumb.Size = UDim2.new(0, 50, 0, 50)
JoystickThumb.Position = UDim2.new(0.5, -25, 0.5, -25)
JoystickThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JoystickThumb.BackgroundTransparency = 0.2
JoystickThumb.Parent = JoystickFrame

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(1, 0)
tCorner.Parent = JoystickThumb

--------------------------------------------------------------------------------
-- BOTTOM SLIDING MENU FRAME
--------------------------------------------------------------------------------
local BottomMenu = Instance.new("Frame")
BottomMenu.Name = "BottomMenu"
BottomMenu.Size = UDim2.new(0.8, 0, 0, 90)
BottomMenu.Position = UDim2.new(0.1, 0, 1, 0)
BottomMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BottomMenu.BorderSizePixel = 0
BottomMenu.Parent = ScreenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = BottomMenu

local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 120, 0, 30)
MenuToggleBtn.Position = UDim2.new(0.5, -60, 0, -30)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleBtn.Text = "▲ Menu"
MenuToggleBtn.FontFace = ArcadeFont
MenuToggleBtn.TextSize = 14
MenuToggleBtn.Parent = BottomMenu

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = MenuToggleBtn

local isMenuOpen = false
MenuToggleBtn.MouseButton1Click:Connect(function()
    isMenuOpen = not isMenuOpen
    local targetPos = isMenuOpen and UDim2.new(0.1, 0, 1, -100) or UDim2.new(0.1, 0, 1, 0)
    MenuToggleBtn.Text = isMenuOpen and "▼ Close" or "▲ Menu"
    
    TweenService:Create(BottomMenu, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = targetPos
    }):Play()
end)

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -15)
ScrollContainer.Position = UDim2.new(0, 10, 0, 10)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.CanvasSize = UDim2.new(0, 500, 0, 0)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.Parent = BottomMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Parent = ScrollContainer

--------------------------------------------------------------------------------
-- 4. HAT LOADER & ACCESSSORY ISOLATION
--------------------------------------------------------------------------------
local noobHatCatalogIds = {
    "13423955204", -- 1: Idle
    "13416449761", -- 2: Walk
    "14442160450", -- 3: Jump
    "13423968413"  -- 4: Sit
}

local noobFrames = {}

local function detachAndIsolate(handle)
    handle.CanCollide = false
    handle.Parent = Workspace
    for _, child in ipairs(handle:GetChildren()) do
        if child:IsA("JointInstance") or child:IsA("WeldConstraint") or (child:IsA("Attachment") and child.Name ~= "EngineAtt0") then
            child:Destroy()
        end
    end
end

local function listenForNoobHats()
    table.clear(noobFrames)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    local conn
    conn = char.ChildAdded:Connect(function(child)
        if child:IsA("Accessory") then
            local handle = child:WaitForChild("Handle", 2)
            if handle and #noobFrames < 4 then
                detachAndIsolate(handle)
                table.insert(noobFrames, handle)
            end
        end
    end)

    gameChat("-gh " .. table.concat(noobHatCatalogIds, " "))
    task.wait(1.5)
    if conn then conn:Disconnect() end
    gameChat("-net")
end

task.spawn(listenForNoobHats)

--------------------------------------------------------------------------------
-- 5. CONTROLS & STATE MANAGER
--------------------------------------------------------------------------------
local isKeyboardEnabled = false
local isSitting = false
local isMoving = false
local isFollowingCam = false
local isNoobHidden = false
local isJumping = false
local jumpOffsetY = 0

local walkSoundTrack = nil
local activeKeys = {W = false, A = false, S = false, D = false}

local currentNoobCFrame = nil
local camYaw = 0
local camPitch = -15
local CAM_SOUND_ID = "95185269700402"

local walkFlipState = false
local walkTimer = 0

local attachedAccessories = {}

local function toggleRobloxTouchGui(visible)
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            local touchGui = playerGui:FindFirstChild("TouchGui")
            if touchGui then
                touchGui.Enabled = visible
            end
        end
    end)
end

local function getCharacterParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    local root = char:FindFirstChild("HumanoidRootPart")
    return char, torso, root
end

local function stepCamera(angleDegrees)
    if not isFollowingCam then return end
    camYaw = camYaw + angleDegrees
    playSound(CAM_SOUND_ID)
end

local function triggerUndergroundSpawn()
    local _, _, root = getCharacterParts()
    if not root then return end
    
    local targetCF = root.CFrame * CFrame.new(0, -1.2, -6)
    local undergroundCF = targetCF * CFrame.new(0, -12, 0)
    
    currentNoobCFrame = undergroundCF
    
    task.spawn(function()
        local elapsed = 0
        local duration = 1.2
        while elapsed < duration do
            elapsed = elapsed + task.wait()
            local alpha = math.min(1, elapsed / duration)
            currentNoobCFrame = undergroundCF:Lerp(targetCF, alpha)
        end
        currentNoobCFrame = targetCF
    end)
end

local function applyWorldAlign(handle, targetCFrame, keyIndex)
    detachAndIsolate(handle)

    local myAtt = handle:FindFirstChild("EngineAtt0") or Instance.new("Attachment", handle)
    myAtt.Name = "EngineAtt0"

    local worldAtt = Workspace.Terrain:FindFirstChild("EngineAttW_Noob_" .. keyIndex) or Instance.new("Attachment", Workspace.Terrain)
    worldAtt.Name = "EngineAttW_Noob_" .. keyIndex
    worldAtt.WorldCFrame = targetCFrame

    local alignPos = handle:FindFirstChild("EnginePos") or Instance.new("AlignPosition", handle)
    alignPos.Name = "EnginePos"
    alignPos.Attachment0 = myAtt
    alignPos.Attachment1 = worldAtt
    alignPos.MaxForce = math.huge
    alignPos.MaxVelocity = math.huge
    alignPos.Responsiveness = 200
    alignPos.ApplyAtCenterOfMass = true

    local alignRot = handle:FindFirstChild("EngineRot") or Instance.new("AlignOrientation", handle)
    alignRot.Name = "EngineRot"
    alignRot.Attachment0 = myAtt
    alignRot.Attachment1 = worldAtt
    alignRot.MaxTorque = math.huge
    alignRot.MaxAngularVelocity = math.huge
    alignRot.Responsiveness = 200
end

local function stopSit()
    if isSitting then isSitting = false end
end

local function processMovement()
    if isNoobHidden then return end
    local hasInput = activeKeys.W or activeKeys.A or activeKeys.S or activeKeys.D
    if hasInput then
        stopSit()
        if not isMoving then
            isMoving = true
            walkSoundTrack = playSound(15103868359, true)
        end
    else
        if isMoving then
            isMoving = false
            stopSound(walkSoundTrack)
            walkSoundTrack = nil
        end
    end
end

local function handleJump()
    if isNoobHidden or not currentNoobCFrame or isJumping then return end
    isJumping = true
    stopSit()
    playSound(129512638771628)

    task.spawn(function()
        local duration = 0.25
        local elapsed = 0
        while elapsed < duration do
            elapsed = elapsed + task.wait()
            local alpha = math.min(1, elapsed / duration)
            jumpOffsetY = math.sin(alpha * (math.pi / 2)) * 4.5
        end

        elapsed = 0
        while elapsed < duration do
            elapsed = elapsed + task.wait()
            local alpha = math.min(1, elapsed / duration)
            jumpOffsetY = (1 - math.sin(alpha * (math.pi / 2))) * 4.5
        end

        jumpOffsetY = 0
        isJumping = false
        processMovement()
    end)
end

local function handleSit()
    if isNoobHidden then return end
    activeKeys.W, activeKeys.A, activeKeys.S, activeKeys.D = false, false, false, false
    processMovement()
    isSitting = true
    playSound(12221944)
end

local function handleRespawnNoobOnly()
    activeKeys.W, activeKeys.A, activeKeys.S, activeKeys.D = false, false, false, false
    processMovement()
    stopSit()
    isNoobHidden = false
    task.spawn(listenForNoobHats)
    triggerUndergroundSpawn()
    playSound(137935424222814)
end

--------------------------------------------------------------------------------
-- JOYSTICK TOUCH INPUT LOGIC
--------------------------------------------------------------------------------
local draggingJoystick = false
local touchInputObj = nil
local maxRadius = 45

local function updateJoystick(inputPos)
    local center = JoystickFrame.AbsolutePosition + (JoystickFrame.AbsoluteSize / 2)
    local delta = Vector2.new(inputPos.X, inputPos.Y) - center
    local distance = math.min(delta.Magnitude, maxRadius)
    local dir = delta.Magnitude > 0 and delta.Unit or Vector2.zero
    
    local newOffset = dir * distance
    JoystickThumb.Position = UDim2.new(0.5, newOffset.X - 25, 0.5, newOffset.Y - 25)

    local normX = dir.X * (distance / maxRadius)
    local normY = dir.Y * (distance / maxRadius)

    activeKeys.W = normY < -0.3
    activeKeys.S = normY > 0.3
    activeKeys.A = normX < -0.3
    activeKeys.D = normX > 0.3
    processMovement()
end

JoystickFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not draggingJoystick then
        draggingJoystick = true
        touchInputObj = input
        updateJoystick(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingJoystick and (input == touchInputObj or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateJoystick(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if draggingJoystick and (input == touchInputObj or input.UserInputType == Enum.UserInputType.MouseButton1) then
        draggingJoystick = false
        touchInputObj = nil
        JoystickThumb.Position = UDim2.new(0.5, -25, 0.5, -25)
        activeKeys.W, activeKeys.A, activeKeys.S, activeKeys.D = false, false, false, false
        processMovement()
    end
end)

--------------------------------------------------------------------------------
-- 6. MENU IMAGE BUTTON CREATION & ACTIONS
--------------------------------------------------------------------------------
local function createMenuIconButton(imageId, textLabel, callback)
    local btnFrame = Instance.new("ImageButton")
    btnFrame.Size = UDim2.new(0, 65, 0, 65)
    btnFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btnFrame.Image = "rbxassetid://" .. tostring(imageId)
    btnFrame.ScaleType = Enum.ScaleType.Fit
    btnFrame.Parent = ScrollContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btnFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 1, -16)
    lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    lbl.BackgroundTransparency = 0.4
    lbl.Text = textLabel
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.FontFace = ArcadeFont
    lbl.Parent = btnFrame

    btnFrame.MouseButton1Click:Connect(function() callback(btnFrame) end)
    return btnFrame
end

local function spawnAccessoryAt(assetId, offsetCFrame, enableCollision, followPlayer)
    gameChat("-gh " .. tostring(assetId))
    
    task.spawn(function()
        local char = LocalPlayer.Character
        if not char then return end

        local targetAccessory = nil
        local connection = nil

        connection = char.ChildAdded:Connect(function(child)
            if child:IsA("Accessory") and not child:FindFirstChild("ProcessedByNoob") then
                local handle = child:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local tag = Instance.new("BoolValue")
                    tag.Name = "ProcessedByNoob"
                    tag.Parent = child

                    targetAccessory = child
                    if connection then connection:Disconnect() end
                end
            end
        end)

        local timeout = 0
        while not targetAccessory and timeout < 30 do
            timeout = timeout + 1
            task.wait(0.1)
        end
        if connection then connection:Disconnect() end

        if targetAccessory and currentNoobCFrame then
            local handle = targetAccessory:FindFirstChild("Handle")
            if handle then
                detachAndIsolate(handle)

                local targetCF = currentNoobCFrame * offsetCFrame
                handle.CFrame = targetCF
                handle.CanCollide = enableCollision or false

                if followPlayer then
                    table.insert(attachedAccessories, {
                        handle = handle,
                        offset = offsetCFrame
                    })
                else
                    local menuAtt0 = Instance.new("Attachment", handle)
                    menuAtt0.Name = "MenuAtt0"

                    local menuAttW = Instance.new("Attachment", Workspace.Terrain)
                    menuAttW.Name = "MenuAttW_" .. tostring(math.random(1000, 9999))
                    menuAttW.WorldCFrame = targetCF

                    local alignPos = Instance.new("AlignPosition", handle)
                    alignPos.Attachment0 = menuAtt0
                    alignPos.Attachment1 = menuAttW
                    alignPos.MaxForce = math.huge
                    alignPos.MaxVelocity = math.huge
                    alignPos.Responsiveness = 200

                    local alignRot = Instance.new("AlignOrientation", handle)
                    alignRot.Attachment0 = menuAtt0
                    alignRot.Attachment1 = menuAttW
                    alignRot.MaxTorque = math.huge
                    alignRot.MaxAngularVelocity = math.huge
                    alignRot.Responsiveness = 200
                end
            end
        end
    end)
end

-- 1. City Spawn
createMenuIconButton("129063595366268", "City", function()
    spawnAccessoryAt("9300074280", CFrame.new(0, 0, -5), true, false)
end)

-- 2. Rubber Duckie
createMenuIconButton("11113512609", "Duck", function()
    spawnAccessoryAt("6964230680", CFrame.new(0, 0, -4), false, false)
end)

-- 3. Respawn Noob
createMenuIconButton("9941579072", "Respawn", function()
    handleRespawnNoobOnly()
end)

-- 4. Retro Skybox
local skyboxOptions = {"12555490712", "12558153498"}
createMenuIconButton("18596085023", "Sky", function()
    local selectedSky = skyboxOptions[math.random(1, #skyboxOptions)]
    spawnAccessoryAt(selectedSky, CFrame.new(0, 0, 0), false, true)
end)

--------------------------------------------------------------------------------
-- 7. HEARTBEAT ENGINE
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    local char, torso, root = getCharacterParts()
    if not char or not torso or not root then return end

    if not currentNoobCFrame then
        triggerUndergroundSpawn()
    end

    if isMoving and not isNoobHidden and currentNoobCFrame then
        walkTimer = walkTimer + dt
        if walkTimer >= 0.3 then
            walkTimer = 0
            walkFlipState = not walkFlipState
        end

        local camCF = Camera.CFrame
        local camLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local camRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

        local moveVector = Vector3.zero
        if activeKeys.W then moveVector = moveVector + camLook end
        if activeKeys.S then moveVector = moveVector - camLook end
        if activeKeys.A then moveVector = moveVector - camRight end
        if activeKeys.D then moveVector = moveVector + camRight end

        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit
            local newPos = currentNoobCFrame.Position + (moveVector * 16 * dt)
            local lookAngle = CFrame.lookAt(newPos, newPos + moveVector)
            currentNoobCFrame = CFrame.new(Vector3.new(newPos.X, root.Position.Y - 1.2, newPos.Z)) * lookAngle.Rotation
        end
    else
        walkTimer = 0
        walkFlipState = false
    end

    local activeIndex = 1
    if isJumping then 
        activeIndex = 3
    elseif isMoving then 
        activeIndex = 2
    elseif isSitting then 
        activeIndex = 4
    end

    local animatedCFrame = currentNoobCFrame and (currentNoobCFrame * CFrame.new(0, jumpOffsetY, 0)) or nil

    if animatedCFrame then
        for _, itemData in ipairs(attachedAccessories) do
            if itemData.handle and itemData.handle.Parent then
                itemData.handle.CFrame = animatedCFrame * itemData.offset
            end
        end
    end

    -- Align tracked Noob accessory frames
    for hatIndex = 1, 4 do
        local handle = noobFrames[hatIndex]
        if handle and handle.Parent then
            local deepVoidCFrame = root.CFrame * CFrame.new(0, -50, 0)

            if isNoobHidden then
                applyWorldAlign(handle, deepVoidCFrame, hatIndex)
            elseif hatIndex == activeIndex and animatedCFrame then
                local finalTargetCFrame = animatedCFrame
                if activeIndex == 2 then
                    local waddleSwing = walkFlipState and math.rad(12) or math.rad(-12)
                    finalTargetCFrame = animatedCFrame * CFrame.Angles(0, waddleSwing, 0)
                end
                applyWorldAlign(handle, finalTargetCFrame, hatIndex)
            else
                applyWorldAlign(handle, deepVoidCFrame, hatIndex)
            end

            handle.AssemblyLinearVelocity = Vector3.new(0, 25.1, 0)
        end
    end

    if isFollowingCam and not isNoobHidden and animatedCFrame then
        Camera.CameraType = Enum.CameraType.Scriptable
        local targetPos = animatedCFrame.Position + Vector3.new(0, 1.5, 0)
        local rotCFrame = CFrame.Angles(0, math.rad(camYaw), 0) * CFrame.Angles(math.rad(camPitch), 0, 0)
        local desiredCamCF = CFrame.new(targetPos) * rotCFrame * CFrame.new(0, 0, 10)
        Camera.CFrame = Camera.CFrame:Lerp(desiredCamCF, 0.1)
    end
end)

--------------------------------------------------------------------------------
-- 8. EVENT BINDINGS
--------------------------------------------------------------------------------
local function setupBtn(btn, key)
    btn.MouseButton1Down:Connect(function()
        activeKeys[key] = true
        processMovement()
    end)
    btn.MouseButton1Up:Connect(function()
        activeKeys[key] = false
        processMovement()
    end)
end

setupBtn(btnW, "W")
setupBtn(btnA, "A")
setupBtn(btnS, "S")
setupBtn(btnD, "D")

btnCamLeft.MouseButton1Click:Connect(function() stepCamera(45) end)
btnCamRight.MouseButton1Click:Connect(function() stepCamera(-45) end)
btnSpace.MouseButton1Click:Connect(handleJump)
btnT.MouseButton1Click:Connect(handleSit)

ToggleKeyboardBtn.MouseButton1Click:Connect(function()
    isKeyboardEnabled = not isKeyboardEnabled
    ToggleKeyboardBtn.BackgroundColor3 = isKeyboardEnabled and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    
    local _, _, root = getCharacterParts()
    if root then root.Anchored = isKeyboardEnabled end

    JoystickFrame.Visible = isKeyboardEnabled
    toggleRobloxTouchGui(not isKeyboardEnabled)
end)

FollowCamBtn.MouseButton1Click:Connect(function()
    isFollowingCam = not isFollowingCam
    if isFollowingCam then
        FollowCamBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        FollowCamBtn.Text = "Follow Cam\n[ON]"
        btnCamLeft.Visible = true
        btnCamRight.Visible = true
    else
        FollowCamBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        FollowCamBtn.Text = "Follow Cam\n[OFF]"
        btnCamLeft.Visible = false
        btnCamRight.Visible = false
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.Left then
        stepCamera(45)
    elseif input.KeyCode == Enum.KeyCode.Right then
        stepCamera(-45)
    end

    if gpe or not isKeyboardEnabled then return end

    if input.KeyCode == Enum.KeyCode.W then activeKeys.W = true; processMovement()
    elseif input.KeyCode == Enum.KeyCode.S then activeKeys.S = true; processMovement()
    elseif input.KeyCode == Enum.KeyCode.A then activeKeys.A = true; processMovement()
    elseif input.KeyCode == Enum.KeyCode.D then activeKeys.D = true; processMovement()
    elseif input.KeyCode == Enum.KeyCode.Space then handleJump()
    elseif input.KeyCode == Enum.KeyCode.T then handleSit()
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if not isKeyboardEnabled then return end

    if input.KeyCode == Enum.KeyCode.W then activeKeys.W = false; processMovement()
    elseif input.KeyCode == Enum.KeyCode.S then activeKeys.S = false; processMovement()
    elseif input.KeyCode == Enum.KeyCode.A then activeKeys.A = false; processMovement()
    elseif input.KeyCode == Enum.KeyCode.D then activeKeys.D = false; processMovement()
    end
end)
