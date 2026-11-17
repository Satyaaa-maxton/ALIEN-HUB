
--[[
    👽 ALIEN HUB V4.0
    UNIVERSAL GUI EDITION
    Android + PC
    GUI / HISTORY / NOTIFICATION DEMO
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CLEAN OLD GUI
local old = playerGui:FindFirstChild("AlienHubV4")
if old then old:Destroy() end

-- COLORS
local PURPLE = Color3.fromRGB(145, 75, 255)
local GREEN = Color3.fromRGB(80, 255, 160)
local DARK = Color3.fromRGB(17, 14, 27)
local PANEL = Color3.fromRGB(30, 24, 44)
local WHITE = Color3.fromRGB(255, 255, 255)

-- MAIN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AlienHubV4"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(340, 420)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.BackgroundColor3 = DARK
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 14)

local border = Instance.new("UIStroke")
border.Color = PURPLE
border.Thickness = 2
border.Parent = main

-- RESPONSIVE
local scale = Instance.new("UIScale")
scale.Parent = main

local function resize()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize

    scale.Scale = math.min(
        1,
        viewport.X / 370,
        viewport.Y / 450
    )
end

resize()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(
    function()
        resize()
        local camera = workspace.CurrentCamera
        if camera then
            camera:GetPropertyChangedSignal(
                "ViewportSize"
            ):Connect(resize)
        end
    end
)

-- LABEL
local function label(parent, text, y, height, color)
    local obj = Instance.new("TextLabel")
    obj.Size = UDim2.new(1, -20, 0, height)
    obj.Position = UDim2.fromOffset(10, y)
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = color or WHITE
    obj.TextSize = 14
    obj.Font = Enum.Font.GothamBold
    obj.Parent = parent
    return obj
end

-- BUTTON
local function button(parent, text, y, color)
    local obj = Instance.new("TextButton")
    obj.Size = UDim2.new(1, -30, 0, 40)
    obj.Position = UDim2.fromOffset(15, y)
    obj.BackgroundColor3 = color
    obj.Text = text
    obj.TextColor3 = WHITE
    obj.TextSize = 13
    obj.Font = Enum.Font.GothamBold
    obj.Parent = parent

    Instance.new("UICorner", obj).CornerRadius =
        UDim.new(0, 8)

    return obj
end

-- HEADER
label(main, "👽 ALIEN HUB", 8, 35, GREEN).TextSize = 24
label(main, "UNIVERSAL EDITION V4.0", 40, 20,
    Color3.fromRGB(190, 160, 255))

local status = label(main, "STATUS: READY", 65, 25, GREEN)

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -130)
content.Position = UDim2.fromOffset(10, 115)
content.BackgroundColor3 = PANEL
content.Parent = main

Instance.new("UICorner", content).CornerRadius =
    UDim.new(0, 10)

local pages = {}

for _, name in ipairs({"HOME", "HISTORY", "SETTINGS"}) do
    local page = Instance.new("Frame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content
    pages[name] = page
end

-- NAVIGATION
local nav = Instance.new("Frame")
nav.Size = UDim2.new(1, -20, 0, 32)
nav.Position = UDim2.fromOffset(10, 82)
nav.BackgroundTransparency = 1
nav.Parent = main

local function navButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1/3, -3, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = PANEL
    b.Text = text
    b.TextColor3 = WHITE
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.Parent = nav
    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 6)
    return b
end

local homeTab = navButton("HOME", 0)
local historyTab = navButton("HISTORY", 1/3)
local settingsTab = navButton("SETTINGS", 2/3)

local function showPage(name)
    for key, page in pairs(pages) do
        page.Visible = key == name
    end

    homeTab.TextColor3 = name == "HOME" and GREEN or WHITE
    historyTab.TextColor3 = name == "HISTORY" and GREEN or WHITE
    settingsTab.TextColor3 = name == "SETTINGS" and GREEN or WHITE
end

homeTab.MouseButton1Click:Connect(function()
    showPage("HOME")
end)

historyTab.MouseButton1Click:Connect(function()
    showPage("HISTORY")
end)

settingsTab.MouseButton1Click:Connect(function()
    showPage("SETTINGS")
end)

-- VARIABLES
local running = false
local total = 0
local history = {}
local notificationCount = 4
local queue = {}
local busy = false

-- NOTIFICATION
local function notify(message)
    table.insert(queue, message)

    if busy then return end
    busy = true

    task.spawn(function()
        while #queue > 0 do
            local msg = table.remove(queue, 1)

            local popup = Instance.new("TextLabel")
            popup.Size = UDim2.fromOffset(250, 45)
            popup.Position = UDim2.new(1, 260, 0, 20)
            popup.BackgroundColor3 = DARK
            popup.TextColor3 = GREEN
            popup.Text = msg
            popup.TextSize = 13
            popup.Font = Enum.Font.GothamBold
            popup.Parent = gui

            Instance.new("UICorner", popup).CornerRadius =
                UDim.new(0, 9)

            local outline = Instance.new("UIStroke")
            outline.Color = PURPLE
            outline.Parent = popup

            popup:TweenPosition(
                UDim2.new(1, -260, 0, 20),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )

            task.wait(2)

            if popup.Parent then
                popup:Destroy()
            end
        end

        busy = false
    end)
end

-- HISTORY
label(pages.HISTORY, "CATCH HISTORY", 10, 30, GREEN)

local historyText = label(
    pages.HISTORY,
    "No catch history yet.",
    45,
    300,
    WHITE
)

historyText.TextYAlignment = Enum.TextYAlignment.Top
historyText.TextWrapped = true

local function addHistory(name)
    table.insert(history, 1, name)

    if #history > 30 then
        table.remove(history)
    end

    local result = {}

    for i, item in ipairs(history) do
        table.insert(result, i .. ". " .. item)
    end

    historyText.Text = table.concat(result, "\n")
end

-- HOME
label(pages.HOME, "FISHING CONTROL", 10, 30, GREEN)

local startBtn = button(
    pages.HOME, "▶ START DEMO", 50,
    Color3.fromRGB(35, 145, 85)
)

local stopBtn = button(
    pages.HOME, "■ STOP", 100,
    Color3.fromRGB(170, 55, 65)
)

local testBtn = button(
    pages.HOME, "🔔 TEST NOTIFICATIONS", 150,
    PURPLE
)

local totalLabel = label(
    pages.HOME, "TOTAL DEMO CATCH: 0", 205, 30, GREEN
)

local function demoCatch()
    total += 1
    totalLabel.Text = "TOTAL DEMO CATCH: " .. total

    addHistory("Demo Catch #" .. total)
end

startBtn.MouseButton1Click:Connect(function()
    running = true
    status.Text = "STATUS: DEMO RUNNING"
    status.TextColor3 = GREEN
    notify("ALIEN HUB STARTED")
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
    status.Text = "STATUS: STOPPED"
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    notify("ALIEN HUB STOPPED")
end)

testBtn.MouseButton1Click:Connect(function()
    for i = 1, notificationCount do
        demoCatch()
        notify("👽 CATCH #" .. i .. " - DEMO")
    end
end)

-- SETTINGS
label(pages.SETTINGS, "DEVICE SETTINGS", 10, 30, GREEN)

local device = UIS.TouchEnabled and "MOBILE" or "PC"

label(
    pages.SETTINGS,
    "DEVICE: " .. device,
    50, 30, WHITE
)

local countBtn = button(
    pages.SETTINGS,
    "CHANGE NOTIFICATION COUNT",
    100,
    PURPLE
)

local countText = label(
    pages.SETTINGS,
    "NOTIFICATIONS: 4",
    150, 30, GREEN
)

countBtn.MouseButton1Click:Connect(function()
    notificationCount = notificationCount == 4 and 2 or 4
    countText.Text = "NOTIFICATIONS: " .. notificationCount
end)

-- MINIMIZE
local mini = Instance.new("TextButton")
mini.Size = UDim2.fromOffset(35, 30)
mini.Position = UDim2.new(1, -42, 0, 8)
mini.BackgroundColor3 = PURPLE
mini.Text = "_"
mini.TextColor3 = WHITE
mini.Parent = main

Instance.new("UICorner", mini).CornerRadius =
    UDim.new(0, 6)

mini.MouseButton1Click:Connect(function()
    content.Visible = not content.Visible
    nav.Visible = not nav.Visible
    main.Size = content.Visible
        and UDim2.fromOffset(340, 420)
        or UDim2.fromOffset(340, 55)
end)

-- CLOSE
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(25, 30)
close.Position = UDim2.new(1, -75, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(180, 50, 65)
close.Text = "X"
close.TextColor3 = WHITE
close.Parent = main

close.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

-- DRAG SUPPORT
local dragging = false
local dragInput
local dragStart
local startPosition

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        if input.Position.Y > main.AbsolutePosition.Y + 55 then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

showPage("HOME")

print("👽 ALIEN HUB V4.0 LOADED")
