-- # catware
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- Assets & Texture IDs
local SOUND_STARTUP = "rbxassetid://663972699"
local LOGO_ID = "rbxassetid://8696759778"
local MINIMIZE_BALL_ICON = "rbxassetid://8696759778"

local ICON_HOME = "rbxassetid://14219650242"
local ICON_SCRIPTS = "rbxassetid://86591853167234"
local ICON_UNIVERSAL = "rbxassetid://103941960626826"
local ICON_THEMES = "rbxassetid://14189347195"
local ICON_PLAYERS = "rbxassetid://11577689639"

-- Preload Assets
ContentProvider:PreloadAsync({
    SOUND_STARTUP, LOGO_ID, MINIMIZE_BALL_ICON, 
    ICON_HOME, ICON_SCRIPTS, ICON_UNIVERSAL, ICON_THEMES, ICON_PLAYERS
})

-- Chat Function Support (Legacy & TextChatService)
local function sendChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:SendAsync(msg)
            end
        else
            local defaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if defaultChat then
                local sayMessage = defaultChat:FindFirstChild("SayMessageRequest")
                if sayMessage then
                    sayMessage:FireServer(msg, "All")
                end
            end
        end
    end)
end

-- Default Theme & Element Tracking
local ThemeColor = Color3.fromRGB(0, 170, 255)
local AllThemeStrokes = {}
local AllThemeFills = {}
local ActiveHighlights = {}

-- Function to detect current executor name dynamically
local function GetExecutorName()
    local name = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Executor"
    return "@" .. tostring(name):lower()
end

-- Helper to set up autoexec script before teleporting
local function QueueAutoExec()
    local autoExecCode = [[loadstring(game:HttpGet("https://pastefy.app/eXZiKNnz/raw"))()]]
    if queue_on_teleport then
        queue_on_teleport(autoExecCode)
    elseif writefile then
        pcall(function()
            writefile("autoexec/CatwareAutoExec.lua", autoExecCode)
        end)
    end
end

---------------------------------------------------------
-- GAME SCRIPTS & TEMPLATES
---------------------------------------------------------

local GameScripts = {
    [123974602339071] = { -- Just a Baseplate
        Name = "Just a Baseplate",
        Scripts = {
            {
                Name = "Mini Noob [ FE ]", 
                Desc = "some mini noob that took 15 mins", 
                Hidden = false, 
                Code = function() loadstring(game:HttpGet("https://pastefy.app/ukmf5KhX/raw"))() end
            },
            {
                Name = "Particle Ball [ FE ]", 
                Desc = "Makes a ball full of particles u can choose from. fly with R btw. shift to fly faster.", 
                Hidden = false, 
                Code = function() loadstring(game:HttpGet('https://pastefy.app/eXZiKNnz/raw'))() end
            },
            {
                Name = "Text With Hats [ FE ]", 
                Desc = "Make text with hats V1. VERY VERY BUGGY.", 
                Hidden = false, 
                Code = function() loadstring(game:HttpGet('https://pastefy.app/2nqOeRTi/raw'))() end
            },
            {
                Name = "Template Script 1", 
                Desc = "This is hidden and won't show on UI.", 
                Hidden = true, 
                Code = function() print("Executed Hidden Template") end
            }
        }
    },
    [189707] = { -- Natural Disaster Survival
        Name = "Natural Disaster Survival",
        Scripts = {
            {
                Name = "Disaster Announcer", 
                Desc = "Displays next incoming disaster.", 
                Hidden = false, 
                Code = function() print("Executed Announcer") end
            },
            {
                Name = "Island Teleport", 
                Desc = "Teleports to island safety.", 
                Hidden = false, 
                Code = function() print("Executed Teleport") end
            }
        }
    }
}

---------------------------------------------------------
-- SCREEN CONTAINER SETUP
---------------------------------------------------------

local ScreenContainer = Instance.new("ScreenGui")
ScreenContainer.Name = "CatwareContainer"
ScreenContainer.ResetOnSpawn = false

pcall(function()
    ScreenContainer.Parent = CoreGui
end)
if not ScreenContainer.Parent then
    ScreenContainer.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

---------------------------------------------------------
-- STARTUP ANIMATION OVERLAY
---------------------------------------------------------

local StartupContainer = Instance.new("Frame")
StartupContainer.Size = UDim2.new(0, 400, 0, 120)
StartupContainer.Position = UDim2.new(0.5, -200, 0.5, -60)
StartupContainer.BackgroundTransparency = 1
StartupContainer.ClipsDescendants = false
StartupContainer.Parent = ScreenContainer

local IntroLogo = Instance.new("ImageLabel")
IntroLogo.Size = UDim2.new(0, 80, 0, 80)
IntroLogo.Position = UDim2.new(0.5, -40, 0.5, -40)
IntroLogo.BackgroundTransparency = 1
IntroLogo.Image = LOGO_ID
IntroLogo.ImageTransparency = 1
IntroLogo.Parent = StartupContainer

local IntroLogoCorner = Instance.new("UICorner")
IntroLogoCorner.CornerRadius = UDim.new(0, 16)
IntroLogoCorner.Parent = IntroLogo

local IntroText = Instance.new("TextLabel")
IntroText.Text = "Catware"
IntroText.Font = Enum.Font.GothamBold
IntroText.TextSize = 34
IntroText.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroText.BackgroundTransparency = 1
IntroText.Position = UDim2.new(0.5, 10, 0.5, -17)
IntroText.Size = UDim2.new(0, 180, 0, 34)
IntroText.TextTransparency = 1
IntroText.TextXAlignment = Enum.TextXAlignment.Left
IntroText.Parent = StartupContainer

local Audio = Instance.new("Sound")
Audio.SoundId = SOUND_STARTUP
Audio.Volume = 1
Audio.Parent = SoundService
Audio:Play()

---------------------------------------------------------
-- MAIN WINDOW FRAMEWORK (HIDDEN AT START)
---------------------------------------------------------

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 800, 0, 500)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.ClipsDescendants = true
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = ScreenContainer

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ThemeColor
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame
table.insert(AllThemeStrokes, MainStroke)

-- Startup Sequence Handler
task.spawn(function()
    TweenService:Create(IntroLogo, TweenInfo.new(0.6), {ImageTransparency = 0}):Play()
    task.wait(0.8)

    TweenService:Create(IntroLogo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -110, 0.5, -40)}):Play()
    IntroText.Position = UDim2.new(0.5, -20, 0.5, -17)
    task.wait(0.2)
    TweenService:Create(IntroText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    task.wait(3.5)

    TweenService:Create(IntroLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(IntroText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    StartupContainer:Destroy()

    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

    -- Send Chat Announcement
    sendChatMessage("scrıpt from")
    task.wait(2)
    sendChatMessage("z⦿nefn¸us")
end)

---------------------------------------------------------
-- 4-COLUMN SPACED CONTINUOUS RAIN BACKGROUND
---------------------------------------------------------

local BackgroundCanvas = Instance.new("Frame")
BackgroundCanvas.Size = UDim2.new(1, 0, 1, 0)
BackgroundCanvas.BackgroundTransparency = 1
BackgroundCanvas.ClipsDescendants = true
BackgroundCanvas.Parent = MainFrame

local rowHeight = 32
local totalRows = math.ceil(500 / rowHeight) + 3
local rainSpeed = 2.5

local RainRows = {}
local ColumnFormat = "  catware is great.        catware is great.        catware is great.        catware is great."

for row = 1, totalRows do
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, rowHeight)
    Label.Position = UDim2.new(0, 0, 0, (row - 2) * rowHeight)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Code
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextTransparency = 0.93
    Label.Text = ColumnFormat
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = BackgroundCanvas

    table.insert(RainRows, Label)
end

RunService.RenderStepped:Connect(function(dt)
    if MainFrame and MainFrame.Parent and MainFrame.Visible then
        for _, label in ipairs(RainRows) do
            local newY = label.Position.Y.Offset + (rainSpeed * dt * 60)
            if newY >= 500 then
                newY = -rowHeight
            end
            label.Position = UDim2.new(0, 0, 0, newY)
        end
    end
end)

---------------------------------------------------------
-- HEADER SECTION
---------------------------------------------------------

local HeaderLogo = Instance.new("ImageLabel")
HeaderLogo.Size = UDim2.new(0, 38, 0, 38)
HeaderLogo.Position = UDim2.new(0, 18, 0, 14)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Image = LOGO_ID
HeaderLogo.Parent = MainFrame

local HeaderLogoCorner = Instance.new("UICorner")
HeaderLogoCorner.CornerRadius = UDim.new(0, 8)
HeaderLogoCorner.Parent = HeaderLogo

local Title = Instance.new("TextLabel")
Title.Text = "Catware"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Position = UDim2.new(0, 64, 0, 12)
Title.Size = UDim2.new(0, 150, 0, 22)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Text = "free and keyless."
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.Position = UDim2.new(0, 64, 0, 34)
Subtitle.Size = UDim2.new(0, 150, 0, 14)
Subtitle.BackgroundTransparency = 1
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 14)
MinimizeBtn.Text = "-"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.Parent = MainFrame

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinimizeBtn

---------------------------------------------------------
-- MINIMIZE / RESTORE SYSTEM
---------------------------------------------------------

local MiniBall = Instance.new("ImageButton")
MiniBall.Size = UDim2.new(0, 0, 0, 0)
MiniBall.Position = UDim2.new(0.5, -25, 0, 20)
MiniBall.Image = MINIMIZE_BALL_ICON
MiniBall.BackgroundTransparency = 1
MiniBall.Visible = false
MiniBall.Parent = ScreenContainer

local BallCorner = Instance.new("UICorner")
BallCorner.CornerRadius = UDim.new(1, 0)
BallCorner.Parent = MiniBall

local BallStroke = Instance.new("UIStroke")
BallStroke.Color = ThemeColor
BallStroke.Thickness = 2
BallStroke.Parent = MiniBall
table.insert(AllThemeStrokes, BallStroke)

local draggingBall, ballDragStart, ballStartPos
MiniBall.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBall = true
        ballDragStart = input.Position
        ballStartPos = MiniBall.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingBall and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - ballDragStart
        MiniBall.Position = UDim2.new(ballStartPos.X.Scale, ballStartPos.X.Offset + delta.X, ballStartPos.Y.Scale, ballStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingBall = false end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    MainFrame.Visible = false
    MiniBall.Visible = true
    TweenService:Create(MiniBall, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
end)

MiniBall.MouseButton1Click:Connect(function()
    TweenService:Create(MiniBall, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    MiniBall.Visible = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 800, 0, 500), BackgroundTransparency = 0}):Play()
end)

---------------------------------------------------------
-- NAVIGATION SIDEBAR & PAGES
---------------------------------------------------------

local NavFrame = Instance.new("Frame")
NavFrame.Size = UDim2.new(0, 155, 1, -80)
NavFrame.Position = UDim2.new(0, 15, 0, 68)
NavFrame.BackgroundTransparency = 1
NavFrame.Parent = MainFrame

local ActiveTabIndicator = Instance.new("Frame")
ActiveTabIndicator.Size = UDim2.new(0, 3, 0, 38)
ActiveTabIndicator.Position = UDim2.new(0, 0, 0, 0)
ActiveTabIndicator.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
ActiveTabIndicator.BorderSizePixel = 0
ActiveTabIndicator.Parent = NavFrame

local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(1, -190, 1, -80)
ContainerFrame.Position = UDim2.new(0, 180, 0, 68)
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Parent = MainFrame

local Pages = {}

local function CreateTabButton(name, iconId, positionY)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.Position = UDim2.new(0, 10, 0, positionY)
    Btn.Text = ""
    Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Btn.Parent = NavFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Position = UDim2.new(0, 12, 0.5, -9)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconId
    Icon.Parent = Btn

    local BtnText = Instance.new("TextLabel")
    BtnText.Size = UDim2.new(1, -40, 1, 0)
    BtnText.Position = UDim2.new(0, 38, 0, 0)
    BtnText.Text = name
    BtnText.Font = Enum.Font.GothamMedium
    BtnText.TextSize = 13
    BtnText.TextColor3 = Color3.fromRGB(180, 180, 180)
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.BackgroundTransparency = 1
    BtnText.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        for pageName, pageObj in pairs(Pages) do
            pageObj.Visible = (pageName == name)
        end
        for _, child in ipairs(NavFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local txt = child:FindFirstChildOfClass("TextLabel")
                if txt then
                    TweenService:Create(txt, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                end
                TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
            end
        end
        TweenService:Create(BtnText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
        TweenService:Create(ActiveTabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, positionY)}):Play()
    end)

    return Btn
end

Pages["Home"] = Instance.new("Frame", ContainerFrame)
Pages["Scripts"] = Instance.new("Frame", ContainerFrame)
Pages["Universal"] = Instance.new("Frame", ContainerFrame)
Pages["Themes"] = Instance.new("Frame", ContainerFrame)
Pages["Players"] = Instance.new("Frame", ContainerFrame)

for _, p in pairs(Pages) do
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
end
Pages["Home"].Visible = true

local HomeBtn = CreateTabButton("Home", ICON_HOME, 0)
local ScriptsBtn = CreateTabButton("Scripts", ICON_SCRIPTS, 48)
local UniversalBtn = CreateTabButton("Universal", ICON_UNIVERSAL, 96)
local ThemesBtn = CreateTabButton("Themes", ICON_THEMES, 144)
local PlayersBtn = CreateTabButton("Players", ICON_PLAYERS, 192)

HomeBtn:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(255, 255, 255)
HomeBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)

---------------------------------------------------------
-- 1. HOME TAB
---------------------------------------------------------

local UserProfileFrame = Instance.new("Frame")
UserProfileFrame.Size = UDim2.new(1, 0, 0, 70)
UserProfileFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
UserProfileFrame.Parent = Pages["Home"]

local UserCorner = Instance.new("UICorner")
UserCorner.CornerRadius = UDim.new(0, 10)
UserCorner.Parent = UserProfileFrame

local PFP = Instance.new("ImageLabel")
PFP.Size = UDim2.new(0, 50, 0, 50)
PFP.Position = UDim2.new(0, 10, 0.5, -25)
PFP.BackgroundTransparency = 1
PFP.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
PFP.Parent = UserProfileFrame

local PFPCorner = Instance.new("UICorner")
PFPCorner.CornerRadius = UDim.new(1, 0)
PFPCorner.Parent = PFP

local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Text = "Hello @" .. LocalPlayer.Name
WelcomeLabel.Font = Enum.Font.GothamBold
WelcomeLabel.TextSize = 16
WelcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WelcomeLabel.Position = UDim2.new(0, 70, 0, 15)
WelcomeLabel.Size = UDim2.new(0, 300, 0, 20)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
WelcomeLabel.Parent = UserProfileFrame

local ExecLabel = Instance.new("TextLabel")
ExecLabel.Text = GetExecutorName()
ExecLabel.Font = Enum.Font.Gotham
ExecLabel.TextSize = 12
ExecLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ExecLabel.Position = UDim2.new(0, 70, 0, 37)
ExecLabel.Size = UDim2.new(0, 300, 0, 18)
ExecLabel.BackgroundTransparency = 1
ExecLabel.TextXAlignment = Enum.TextXAlignment.Left
ExecLabel.Parent = UserProfileFrame

local HomeScroll = Instance.new("ScrollingFrame")
HomeScroll.Size = UDim2.new(1, 0, 1, -80)
HomeScroll.Position = UDim2.new(0, 0, 0, 80)
HomeScroll.BackgroundTransparency = 1
HomeScroll.ScrollBarThickness = 4
HomeScroll.Parent = Pages["Home"]

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -10, 0, 320)
InfoText.BackgroundTransparency = 1
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 13
InfoText.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Text = [[
-- version
1.0.0

--- ## credits
sage.lua (roblox user: Neko_FHS)

--- ## updates
--- RELEASED <3
--- People have BEGGED me to release these. SO HERE u greedy noobz!1!.. ily all <3
--- Any ideas? Go in discord!
-- ## Game's Supported
-- Just a baseplate
--------------------------------------------------
-- [MORE GAMES COMING SOON]
]]
InfoText.Parent = HomeScroll
HomeScroll.CanvasSize = UDim2.new(0, 0, 0, 330)

---------------------------------------------------------
-- 2. SCRIPTS TAB (DYNAMIC RESIZING BOXES)
---------------------------------------------------------

local CurrentGameData = GameScripts[game.PlaceId]

if CurrentGameData then
    local ScriptScroll = Instance.new("ScrollingFrame")
    ScriptScroll.Size = UDim2.new(1, 0, 1, -55)
    ScriptScroll.BackgroundTransparency = 1
    ScriptScroll.ScrollBarThickness = 4
    ScriptScroll.Parent = Pages["Scripts"]

    local ScriptLayout = Instance.new("UIListLayout")
    ScriptLayout.Padding = UDim.new(0, 10)
    ScriptLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ScriptLayout.Parent = ScriptScroll

    for _, scriptData in ipairs(CurrentGameData.Scripts) do
        if not scriptData.Hidden then
            -- Calculate Description Height Dynamically
            local availableWidth = 570
            local textSize = TextService:GetTextSize(
                scriptData.Desc, 
                10, 
                Enum.Font.Gotham, 
                Vector2.new(availableWidth, 1000)
            )
            local descHeight = math.max(20, textSize.Y)
            local boxHeight = 28 + descHeight + 10 + 26 + 12

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(1, -10, 0, boxHeight)
            Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Box.Parent = ScriptScroll

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 8)
            BoxCorner.Parent = Box

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Color3.fromRGB(55, 55, 55)
            BoxStroke.Thickness = 1
            BoxStroke.Parent = Box
            table.insert(AllThemeStrokes, BoxStroke)

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = scriptData.Name
            NameLbl.Font = Enum.Font.GothamBold
            NameLbl.TextSize = 13
            NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLbl.Position = UDim2.new(0, 12, 0, 8)
            NameLbl.Size = UDim2.new(1, -24, 0, 18)
            NameLbl.BackgroundTransparency = 1
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Parent = Box

            local DescLbl = Instance.new("TextLabel")
            DescLbl.Text = scriptData.Desc
            DescLbl.Font = Enum.Font.Gotham
            DescLbl.TextSize = 10
            DescLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
            DescLbl.Position = UDim2.new(0, 12, 0, 28)
            DescLbl.Size = UDim2.new(1, -24, 0, descHeight)
            DescLbl.BackgroundTransparency = 1
            DescLbl.TextWrapped = true
            DescLbl.TextXAlignment = Enum.TextXAlignment.Left
            DescLbl.TextYAlignment = Enum.TextYAlignment.Top
            DescLbl.Parent = Box

            local ExecBtn = Instance.new("TextButton")
            ExecBtn.Size = UDim2.new(1, -24, 0, 26)
            ExecBtn.Position = UDim2.new(0, 12, 0, 28 + descHeight + 8)
            ExecBtn.Text = "Execute"
            ExecBtn.Font = Enum.Font.GothamBold
            ExecBtn.TextSize = 11
            ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ExecBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            ExecBtn.Parent = Box

            local ExecCorner = Instance.new("UICorner")
            ExecCorner.CornerRadius = UDim.new(0, 6)
            ExecCorner.Parent = ExecBtn

            ExecBtn.MouseButton1Click:Connect(scriptData.Code)
        end
    end

    -- Dynamically calculate canvas scroll height
    ScriptScroll.CanvasSize = UDim2.new(0, 0, 0, ScriptLayout.AbsoluteContentSize.Y + 15)

    -- Footer Under Script Boxes
    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, 0, 0, 48)
    FooterText.Position = UDim2.new(0, 0, 1, -48)
    FooterText.BackgroundTransparency = 1
    FooterText.Font = Enum.Font.GothamBold
    FooterText.TextSize = 11
    FooterText.TextColor3 = Color3.fromRGB(160, 160, 160)
    FooterText.TextXAlignment = Enum.TextXAlignment.Left
    FooterText.Text = "-- these scripts are mainly in my freetime. i comeback to fix them.\n-- all made by catware.\n-- discord.gg/uVvkjC388f"
    FooterText.Parent = Pages["Scripts"]
else
    local UnsupportedFrame = Instance.new("Frame")
    UnsupportedFrame.Size = UDim2.new(1, 0, 1, 0)
    UnsupportedFrame.BackgroundTransparency = 1
    UnsupportedFrame.Parent = Pages["Scripts"]

    local WarnMsg = Instance.new("TextLabel")
    WarnMsg.Text = "Sorry, this game is not supported :(\nyou may leave a suggestion in our discord!"
    WarnMsg.Font = Enum.Font.GothamBold
    WarnMsg.TextSize = 14
    WarnMsg.TextColor3 = Color3.fromRGB(220, 220, 220)
    WarnMsg.Position = UDim2.new(0, 0, 0, 40)
    WarnMsg.Size = UDim2.new(1, 0, 0, 40)
    WarnMsg.BackgroundTransparency = 1
    WarnMsg.TextXAlignment = Enum.TextXAlignment.Center
    WarnMsg.Parent = UnsupportedFrame

    local DiscordBox = Instance.new("TextButton")
    DiscordBox.Size = UDim2.new(0, 260, 0, 36)
    DiscordBox.Position = UDim2.new(0.5, -130, 0, 100)
    DiscordBox.Text = "https://discord.gg/uVvkjC388f"
    DiscordBox.Font = Enum.Font.GothamMedium
    DiscordBox.TextSize = 12
    DiscordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DiscordBox.Parent = UnsupportedFrame

    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 8)
    DCorner.Parent = DiscordBox

    local SubCopy = Instance.new("TextLabel")
    SubCopy.Text = "Click to copy!"
    SubCopy.Font = Enum.Font.Gotham
    SubCopy.TextSize = 11
    SubCopy.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubCopy.Position = UDim2.new(0, 0, 0, 142)
    SubCopy.Size = UDim2.new(1, 0, 0, 20)
    SubCopy.BackgroundTransparency = 1
    SubCopy.TextXAlignment = Enum.TextXAlignment.Center
    SubCopy.Parent = UnsupportedFrame

    DiscordBox.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard("https://discord.gg/uVvkjC388f") end
        DiscordBox.Text = "Copied!"
        task.wait(2)
        DiscordBox.Text = "https://discord.gg/uVvkjC388f"
    end)
end

---------------------------------------------------------
-- 3. UNIVERSAL TAB
---------------------------------------------------------

local UniScroll = Instance.new("ScrollingFrame")
UniScroll.Size = UDim2.new(1, 0, 1, 0)
UniScroll.BackgroundTransparency = 1
UniScroll.ScrollBarThickness = 4
UniScroll.Parent = Pages["Universal"]

local UniLayout = Instance.new("UIListLayout")
UniLayout.Padding = UDim.new(0, 12)
UniLayout.Parent = UniScroll

-- Rejoin & Serverhop Action Buttons
local ActionRow = Instance.new("Frame")
ActionRow.Size = UDim2.new(1, -10, 0, 38)
ActionRow.BackgroundTransparency = 1
ActionRow.Parent = UniScroll

local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(0.5, -5, 1, 0)
RejoinBtn.Position = UDim2.new(0, 0, 0, 0)
RejoinBtn.Text = "Rejoin Server"
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 12
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RejoinBtn.Parent = ActionRow

local RejoinCorner = Instance.new("UICorner")
RejoinCorner.CornerRadius = UDim.new(0, 8)
RejoinCorner.Parent = RejoinBtn

RejoinBtn.MouseButton1Click:Connect(function()
    QueueAutoExec()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

local ServerhopBtn = Instance.new("TextButton")
ServerhopBtn.Size = UDim2.new(0.5, -5, 1, 0)
ServerhopBtn.Position = UDim2.new(0.5, 5, 0, 0)
ServerhopBtn.Text = "Serverhop"
ServerhopBtn.Font = Enum.Font.GothamBold
ServerhopBtn.TextSize = 12
ServerhopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerhopBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ServerhopBtn.Parent = ActionRow

local ServerhopCorner = Instance.new("UICorner")
ServerhopCorner.CornerRadius = UDim.new(0, 8)
ServerhopCorner.Parent = ServerhopBtn

ServerhopBtn.MouseButton1Click:Connect(function()
    QueueAutoExec()
    local servers = {}
    local req = request or http_request or (syn and syn.request)
    if req then
        local res = req({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
        local body = HttpService:JSONDecode(res.Body)
        if body and body.data then
            for _, v in ipairs(body.data) do
                if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

local function CreateSlider(title, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SliderFrame.Parent = UniScroll

    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 8)
    SCorner.Parent = SliderFrame

    local STitle = Instance.new("TextLabel")
    STitle.Text = title .. ": " .. default
    STitle.Font = Enum.Font.GothamBold
    STitle.TextSize = 12
    STitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    STitle.Position = UDim2.new(0, 10, 0, 6)
    STitle.Size = UDim2.new(1, -20, 0, 18)
    STitle.BackgroundTransparency = 1
    STitle.TextXAlignment = Enum.TextXAlignment.Left
    STitle.Parent = SliderFrame

    local BarBack = Instance.new("Frame")
    BarBack.Size = UDim2.new(1, -20, 0, 8)
    BarBack.Position = UDim2.new(0, 10, 0, 30)
    BarBack.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    BarBack.Parent = SliderFrame

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(1, 0)
    BCorner.Parent = BarBack

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    BarFill.BackgroundColor3 = ThemeColor
    BarFill.Parent = BarBack
    table.insert(AllThemeFills, BarFill)

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(1, 0)
    FCorner.Parent = BarFill

    local sliding = false

    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X, 0, 1)
        BarFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        STitle.Text = title .. ": " .. val
        callback(val)
    end

    BarBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

CreateSlider("Speed Changer", 1, 500, 16, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

CreateSlider("Jump Power", 50, 2500, 50, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)

CreateSlider("Gravity", 0, 500, 196, function(v)
    workspace.Gravity = v
end)

local function CreateToggle(title, callback)
    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(1, -10, 0, 38)
    TBtn.Text = "  " .. title
    TBtn.Font = Enum.Font.GothamBold
    TBtn.TextSize = 12
    TBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TBtn.TextXAlignment = Enum.TextXAlignment.Left
    TBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TBtn.Parent = UniScroll

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 8)
    TCorner.Parent = TBtn

    local active = false
    TBtn.MouseButton1Click:Connect(function()
        active = not active
        TBtn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        TBtn.BackgroundColor3 = active and ThemeColor or Color3.fromRGB(35, 35, 35)
        if active then
            table.insert(AllThemeFills, TBtn)
        else
            for i, elem in ipairs(AllThemeFills) do
                if elem == TBtn then table.remove(AllThemeFills, i) break end
            end
        end
        callback(active)
    end)
end

local infJumpConn
CreateToggle("Infinite Jump", function(enabled)
    if enabled then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    elseif infJumpConn then
        infJumpConn:Disconnect()
    end
end)

local noclipConn
CreateToggle("Noclip / Clip Toggle", function(enabled)
    if enabled then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

UniScroll.CanvasSize = UDim2.new(0, 0, 0, UniLayout.AbsoluteContentSize.Y + 20)

---------------------------------------------------------
-- 4. THEMES TAB
---------------------------------------------------------

local ThemeTitle = Instance.new("TextLabel")
ThemeTitle.Text = "Theme Color"
ThemeTitle.Font = Enum.Font.GothamBold
ThemeTitle.TextSize = 16
ThemeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeTitle.Size = UDim2.new(1, 0, 0, 20)
ThemeTitle.BackgroundTransparency = 1
ThemeTitle.TextXAlignment = Enum.TextXAlignment.Left
ThemeTitle.Parent = Pages["Themes"]

local ThemeGrid = Instance.new("Frame")
ThemeGrid.Size = UDim2.new(1, 0, 0, 150)
ThemeGrid.Position = UDim2.new(0, 0, 0, 35)
ThemeGrid.BackgroundTransparency = 1
ThemeGrid.Parent = Pages["Themes"]

local TGrid = Instance.new("UIGridLayout")
TGrid.CellSize = UDim2.new(0, 40, 0, 40)
TGrid.CellPadding = UDim2.new(0, 12, 0, 12)
TGrid.Parent = ThemeGrid

local ColorList = {
    Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 85, 85), Color3.fromRGB(85, 255, 127),
    Color3.fromRGB(255, 170, 0), Color3.fromRGB(170, 85, 255), Color3.fromRGB(255, 105, 180)
}

for _, col in ipairs(ColorList) do
    local ColorBtn = Instance.new("TextButton")
    ColorBtn.Text = ""
    ColorBtn.BackgroundColor3 = col
    ColorBtn.Parent = ThemeGrid
    
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = ColorBtn
    
    ColorBtn.MouseButton1Click:Connect(function()
        ThemeColor = col
        
        for _, stroke in ipairs(AllThemeStrokes) do
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.3), {Color = ThemeColor}):Play()
            end
        end
        
        for _, fillElem in ipairs(AllThemeFills) do
            if fillElem and fillElem.Parent then
                TweenService:Create(fillElem, TweenInfo.new(0.3), {BackgroundColor3 = ThemeColor}):Play()
            end
        end

        for hl, _ in pairs(ActiveHighlights) do
            if hl and hl.Parent then
                hl.FillColor = ThemeColor
                hl.OutlineColor = ThemeColor
            end
        end
    end)
end

---------------------------------------------------------
-- 5. LIVE PLAYERS TAB
---------------------------------------------------------

local LiveCountLabel = Instance.new("TextLabel")
LiveCountLabel.Font = Enum.Font.GothamBold
LiveCountLabel.TextSize = 14
LiveCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LiveCountLabel.Size = UDim2.new(1, 0, 0, 25)
LiveCountLabel.BackgroundTransparency = 1
LiveCountLabel.TextXAlignment = Enum.TextXAlignment.Left
LiveCountLabel.Parent = Pages["Players"]

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 1, -30)
PlayerScroll.Position = UDim2.new(0, 0, 0, 30)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.Parent = Pages["Players"]

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 8)
PlayerListLayout.Parent = PlayerScroll

local function RefreshPlayerList()
    for _, child in ipairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local allPlayers = Players:GetPlayers()
    LiveCountLabel.Text = "Players In Server: " .. #allPlayers .. "/" .. Players.MaxPlayers

    for _, plr in ipairs(allPlayers) do
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -10, 0, 42)
        Row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Row.Parent = PlayerScroll

        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = Row

        local PImg = Instance.new("ImageLabel")
        PImg.Size = UDim2.new(0, 30, 0, 30)
        PImg.Position = UDim2.new(0, 6, 0.5, -15)
        PImg.BackgroundTransparency = 1
        PImg.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        PImg.Parent = Row

        local PImgCorner = Instance.new("UICorner")
        PImgCorner.CornerRadius = UDim.new(1, 0)
        PImgCorner.Parent = PImg

        local PName = Instance.new("TextLabel")
        PName.Text = "@" .. plr.Name
        PName.Font = Enum.Font.GothamMedium
        PName.TextSize = 12
        PName.TextColor3 = Color3.fromRGB(255, 255, 255)
        PName.Position = UDim2.new(0, 42, 0, 0)
        PName.Size = UDim2.new(0, 140, 1, 0)
        PName.BackgroundTransparency = 1
        PName.TextXAlignment = Enum.TextXAlignment.Left
        PName.Parent = Row

        local function CreatePlayerAction(title, posX, callback)
            local ActBtn = Instance.new("TextButton")
            ActBtn.Size = UDim2.new(0, 75, 0, 26)
            ActBtn.Position = UDim2.new(1, posX, 0.5, -13)
            ActBtn.Text = title
            ActBtn.Font = Enum.Font.Gotham
            ActBtn.TextSize = 10
            ActBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            ActBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
            ActBtn.Parent = Row

            local ACorner = Instance.new("UICorner")
            ACorner.CornerRadius = UDim.new(0, 4)
            ACorner.Parent = ActBtn

            ActBtn.MouseButton1Click:Connect(callback)
        end

        CreatePlayerAction("Teleport", -245, function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                LocalPlayer.Character:MoveTo(plr.Character.HumanoidRootPart.Position)
            end
        end)

        CreatePlayerAction("Highlight", -165, function()
            if plr.Character then
                local Highlight = Instance.new("Highlight")
                Highlight.FillColor = ThemeColor
                Highlight.OutlineColor = ThemeColor
                Highlight.Parent = plr.Character
                
                ActiveHighlights[Highlight] = true
                Highlight.Destroying:Connect(function()
                    ActiveHighlights[Highlight] = nil
                end)
            end
        end)

        CreatePlayerAction("Spectate", -85, function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
            end
        end)
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
RefreshPlayerList()

---------------------------------------------------------
-- UI DRAGGING SYSTEM
---------------------------------------------------------

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        if pos.Y - MainFrame.AbsolutePosition.Y > 50 then return end
        
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = false 
    end
end)
