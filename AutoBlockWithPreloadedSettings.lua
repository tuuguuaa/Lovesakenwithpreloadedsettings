--[[
╔══════════════════════════════════════════════════════════════════╗
║            lovesaken v3.5 – Sirius Rayfield Edition             ║
║          Hybrid ESP: old colors + V1PRWARE detection            ║
║          Generators: pink • Medkit: cyan • Bloxy: orange        ║
║        + Elliot Pizza Aimbot (no prediction, character lock)    ║
║        + Killer Ability Aimbot (auto‑aim on Q/E/R/abilities)    ║
║        Movement: NoClip + TP to Item • Spoofer Tab + Auto‑save  ║
║                       + Two Time Loader                         ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- ============================================================
--  SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Stats             = game:GetService("Stats")

local VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager") or nil
local Camera = Workspace.CurrentCamera

-- ============================================================
--  SIRIUS RAYFIELD (with auto‑save)
-- ============================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name            = "lovesaken V3.7",
    LoadingTitle    = "lovesaken V3.7",
    LoadingSubtitle = "loading lovesaken V3.7",
    ConfigurationSaving = true{
        Enabled    = true,
        FolderName = "lovesaken V3.7",
        FileName   = "Config"
    },
    KeySystem = false,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Enter the key to unlock",
        Note = "The key is in the discord server   https://discord.gg/YYcGEYdv",
        FileName = "lovesakenv3.7key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"lovesaken"}
    }
})

-- ============================================================
--  TABS
-- ============================================================
local TabUpdates   = Window:CreateTab("Updates",     "refresh-cw")
local TabAutoBlock = Window:CreateTab("Auto Block",  "shield")
local TabLock      = Window:CreateTab("Lock",        "crosshair")
local TabTechs     = Window:CreateTab("Techs",       "cpu")
local TabAutoPunch = Window:CreateTab("Auto Punch",  "target")
local TabVision    = Window:CreateTab("Vision Cone", "eye")
local TabESP       = Window:CreateTab("ESP",         "eye")
local TabStamina   = Window:CreateTab("Stamina",     "battery")
local TabGenerator = Window:CreateTab("Generator",   "zap")
local TabChance    = Window:CreateTab("Chance",      "sparkle")
local TabLunaTrick = Window:CreateTab("Luna Trick",  "sparkle")
local TabMovement  = Window:CreateTab("Movement",    "move")
local TabSpoofer   = Window:CreateTab("Spoofer",     "smartphone")
local TabAimbot    = Window:CreateTab("Aimbot",      "crosshair")
local TabTwoTime   = Window:CreateTab("Two Time",    "swords")
local TabSettings  = Window:CreateTab("Settings",    "settings")

-- ============================================================
--  REMOTE (pcall-guarded)
-- ============================================================
local testRemote
pcall(function()
    testRemote = ReplicatedStorage
        :WaitForChild("Modules", 10)
        :WaitForChild("Network", 10)
        :WaitForChild("RemoteEvent", 10)
end)

-- ============================================================
--  REMOTE FIRE HELPERS (buffer fallback)
-- ============================================================
local function makeBuffer(str)
    local ok, result = pcall(function() return buffer.fromstring(str) end)
    if ok then return result end
    return str
end

local BLOCK_BUF  = makeBuffer("\3\5\0\0\0Block")
local PUNCH_BUF  = makeBuffer("\3\5\0\0\0Punch")
local CHARGE_BUF = makeBuffer("\3\5\0\0\0Charge")
local CLONE_BUF  = makeBuffer("\3\5\0\0\0Clone")

local function fireRemoteBlock()
    if not testRemote then return end
    pcall(function() testRemote:FireServer("UseActorAbility", { [1] = BLOCK_BUF }) end)
end

local function fireRemotePunch()
    if not testRemote then return end
    pcall(function() testRemote:FireServer("UseActorAbility", { [1] = PUNCH_BUF }) end)
end

local function fireRemoteCharge()
    if not testRemote then return end
    pcall(function() testRemote:FireServer("UseActorAbility", { [1] = CHARGE_BUF }) end)
end

local function fireRemoteClone()
    if not testRemote then return end
    pcall(function() testRemote:FireServer("UseActorAbility", { [1] = CLONE_BUF }) end)
end

-- ============================================================
--  ORIGINAL VARIABLES (cleaned)
-- ============================================================
local autoBlockAudioOn  = true
local detectionRange    = 18
local blockdelay        = 0
local facingCheckEnabled= true
local customFacingDot   = -0.3
local doubleblocktech   = true
local hitboxDraggingTech= true
local Dspeed            = 12
local Ddelay            = 0
local autoPunchOn       = true
local aimPunch          = true
local predictionValue   = 2.2
local autoblocktype     = "Block"

-- Lock variables
local characterLockOn          = true
local cameraLockOn             = false
local lockedTarget             = nil
local cameraLockThread         = nil
local lockCooldown             = 0.05
local aggressiveSmoothing      = 0.7
local cameraAggressiveSmoothing= 0.6
local lockDuration             = 0.4
local lockMaxDistance          = 30
local killerNames = { "c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher","Sixer" }

-- Vision cone
local showVisionRange = false
local visionRange     = 13
local visionAngle     = 70
local centerPart, leftPart, rightPart,
      leftToKillerPart, rightToKillerPart,
      leftToCenterPart, centerToRightPart = nil,nil,nil,nil,nil,nil,nil

-- HDT
local _hitboxDraggingDebounce = false
local cachedAnimator          = nil

-- Sound auto-block
local soundHooks          = {}
local lastLocalBlockTime  = 0
local LOCAL_BLOCK_COOLDOWN= 0.7
local soundBlockedUntil   = {}

-- Aim punch
local lastAimTrigger = {}
local AIM_WINDOW     = 0.5
local AIM_COOLDOWN   = 0.6

-- ============================================================
--  ANIMATION ID TABLES
-- ============================================================
local punchAnimIds = {
    "87259391926321","140703210927645","136007065400978","129843313690921",
    "86709774283672","108807732150251","138040001965654","86096387000557"
}

local blockAnimIds = {
    "72722244508749","96959123077498","95802026624883",
    "100926346851492","120748030255574"
}

local punchAnimSet, blockAnimSet = {}, {}
for _, v in ipairs(punchAnimIds) do punchAnimSet[v] = true end
for _, v in ipairs(blockAnimIds) do blockAnimSet[v] = true end

local autoBlockTriggerSounds = {
    ["102228729296384"] = true, ["140242176732868"] = true, ["112809109188560"] = true, ["136323728355613"] = true,
    ["115026634746636"] = true, ["84116622032112"] = true, ["108907358619313"] = true, ["127793641088496"] = true,
    ["86174610237192"] = true, ["95079963655241"] = true, ["101199185291628"] = true, ["119942598489800"] = true,
    ["84307400688050"] = true, ["113037804008732"] = true, ["105200830849301"] = true, ["75330693422988"] = true,
    ["82221759983649"] = true, ["109348678063422"] = true, ["81702359653578"] = true, ["85853080745515"] = true,
    ["108610718831698"] = true, ["112395455254818"] = true, ["109431876587852"] = true, ["12222216"] = true,
    ["79980897195554"] = true, ["119583605486352"] = true, ["71834552297085"] = true, ["116581754553533"] = true,
    ["86833981571073"] = true, ["110372418055226"] = true, ["105840448036441"] = true, ["86494585504534"] = true,
    ["80516583309685"] = true, ["131406927389838"] = true, ["89004992452376"] = true, ["117231507259853"] = true,
    ["101698569375359"] = true, ["101553872555606"] = true, ["140412278320643"] = true, ["106300477136129"] = true,
    ["117173212095661"] = true, ["104910828105172"] = true, ["140194172008986"] = true, ["85544168523099"] = true,
    ["114506382930939"] = true, ["99829427721752"] = true, ["120059928759346"] = true, ["104625283622511"] = true,
    ["105316545074913"] = true, ["126131675979001"] = true, ["82336352305186"] = true, ["93366464803829"] = true,
    ["84069821282466"] = true, ["128856426573270"] = true, ["121954639447247"] = true, ["128195973631079"] = true,
    ["124903763333174"] = true, ["94317217837143"] = true, ["98111231282218"] = true, ["119089145505438"] = true,
    ["136728245733659"] = true, ["71310583817000"] = true, ["107444859834748"] = true, ["76959687420003"] = true,
    ["72425554233832"] = true, ["96594507550917"] = true, ["139996647355899"] = true, ["107345261604889"] = true,
    ["127557531826290"] = true, ["108651070773439"] = true, ["74842815979546"] = true, ["119583605486352"] = true,
    ["115026634746636"] = true, ["115026634746636"] = true, ["124397369810639"] = true, 
    ["76467993976301"] = true, ["118493324723683"] = true, ["78298577002481"] = true, ["116527305931161"] = true,
    ["5148302439"] = true, ["98675142200448"] = true, ["128367348686124"] = true, ["128367348686124"] = true, 			["71805956520207"] = true, ["125213046326879"] = true,
}

-- ============================================================
--  KILLER AIMBOT VARIABLES (added)
-- ============================================================
local Killer = {
    enabled = false,
    isAiming = false,
    currentTarget = nil,
    deathConnection = nil,
    renderConn = nil,
    originalAutoRotate = nil,
    lastAbilityTime = 0,
    cooldown = 0.3,
    survivors = {},
    lastScan = 0,
    scanInterval = 0.5,
    humanoid = nil,
    hrp = nil
}

-- ============================================================
--  HELPERS
-- ============================================================
local function tableFind(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then return i end
    end
    return nil
end

local function isFacing(localRoot, targetRoot)
    if not facingCheckEnabled then return true end
    local direction = (localRoot.Position - targetRoot.Position).Unit
    local dot = targetRoot.CFrame.LookVector:Dot(direction)
    return dot > customFacingDot
end

local function getNearestKillerModel()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local killersFolder
    pcall(function()
        killersFolder = Workspace.Players.Killers
    end)
    if not killersFolder then return nil end

    local closest, closestDist = nil, math.huge
    for _, killer in pairs(killersFolder:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - myRoot.Position).Magnitude
            if d < closestDist then
                closest, closestDist = killer, d
            end
        end
    end
    return closest
end

local function refreshAnimator()
    local char = LocalPlayer.Character
    if not char then cachedAnimator = nil return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        cachedAnimator = hum:FindFirstChildOfClass("Animator") or nil
    else
        cachedAnimator = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshAnimator()
end)

-- ============================================================
--  LOCK FUNCTIONS (unchanged)
-- ============================================================
local function lockCharacterToTarget(targetHRP, myRoot, duration)
    if not targetHRP or not myRoot then return end
    local humanoid = myRoot.Parent and myRoot.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then pcall(function() humanoid.AutoRotate = false end) end

    local lockStart    = tick()
    local lastValidPos = targetHRP.Position

    while characterLockOn and (tick() - lockStart < duration) do
        pcall(function()
            if targetHRP and targetHRP.Parent and myRoot and myRoot.Parent then
                local tp  = targetHRP.Position
                lastValidPos = tp
                local vel = targetHRP.Velocity or Vector3.zero
                tp = tp + vel * 0.3
                myRoot.CFrame = CFrame.new(myRoot.CFrame.Position, tp)
            elseif myRoot and myRoot.Parent then
                myRoot.CFrame = CFrame.new(myRoot.CFrame.Position, lastValidPos)
            end
        end)
        task.wait(lockCooldown)
    end

    if humanoid and humanoid.Parent then
        pcall(function() humanoid.AutoRotate = true end)
    end
end

local function lockCameraToTarget(targetHRP, duration)
    if not targetHRP then return end
    local camera       = Workspace.CurrentCamera
    local lockStart    = tick()
    local lastValidPos = targetHRP.Position + Vector3.new(0, 1.5, 0)

    while cameraLockOn and (tick() - lockStart < duration) do
        pcall(function()
            if camera then
                local tp
                if targetHRP and targetHRP.Parent then
                    tp = targetHRP.Position + Vector3.new(0,1.5,0)
                    lastValidPos = tp
                    local vel = targetHRP.Velocity or Vector3.zero
                    tp = tp + vel * 0.35
                else
                    tp = lastValidPos
                end
                local camPos  = camera.CFrame.Position
                local newCF   = camera.CFrame:Lerp(CFrame.lookAt(camPos, tp), cameraAggressiveSmoothing)
                camera.CFrame = newCF
            end
        end)
        task.wait(lockCooldown)
    end
end

local function startAggressiveLockOnPunch()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local killersFolder
    pcall(function() killersFolder = Workspace.Players.Killers end)
    if not killersFolder then return end

    local foundTargets = {}
    for _, name in ipairs(killerNames) do
        local killer = killersFolder:FindFirstChild(name)
        if killer then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - myRoot.Position).Magnitude <= lockMaxDistance then
                table.insert(foundTargets, hrp)
            end
        end
    end

    if #foundTargets == 0 then return end
    table.sort(foundTargets, function(a,b)
        return (a.Position - myRoot.Position).Magnitude
             < (b.Position - myRoot.Position).Magnitude
    end)

    local targetHRP = foundTargets[1]
    lockedTarget    = targetHRP

    if characterLockOn then
        task.spawn(lockCharacterToTarget, targetHRP, myRoot, lockDuration)
    end
    if cameraLockOn then
        if cameraLockThread then task.cancel(cameraLockThread) end
        cameraLockThread = task.spawn(lockCameraToTarget, targetHRP, lockDuration)
    end
end

local function stopAllLocks()
    lockedTarget = nil
    if cameraLockThread then task.cancel(cameraLockThread); cameraLockThread = nil end
    local myChar = LocalPlayer.Character
    if myChar then
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.AutoRotate = true end) end
    end
end

-- ============================================================
--  HDT (unchanged)
-- ============================================================
local function beginDragIntoKiller(killerModel)
    if _hitboxDraggingDebounce then return end
    if not killerModel or not killerModel.Parent then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp      = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local targetHRP = killerModel:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    _hitboxDraggingDebounce = true

    local oldWalk = humanoid.WalkSpeed
    local oldJump = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent   = hrp

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not _hitboxDraggingDebounce then
            conn:Disconnect()
            if bv and bv.Parent then bv:Destroy() end
            humanoid.WalkSpeed = oldWalk
            humanoid.JumpPower = oldJump
            return
        end
        if not (char and char.Parent) or not (killerModel and killerModel.Parent) then
            _hitboxDraggingDebounce = false; return
        end
        targetHRP = killerModel:FindFirstChild("HumanoidRootPart")
        if not targetHRP then _hitboxDraggingDebounce = false; return end

        local toTarget = targetHRP.Position - hrp.Position
        local horiz    = Vector3.new(toTarget.X, 0, toTarget.Z)
        if horiz.Magnitude > 0.01 then
            bv.Velocity = horiz.Unit * Dspeed
        else
            bv.Velocity = Vector3.zero
        end
        if toTarget.Magnitude <= 2.0 then
            _hitboxDraggingDebounce = false
        end
    end)

    task.delay(0.4, function()
        _hitboxDraggingDebounce = false
    end)
end

local function startChargeAimUntilChargeEnds(fallbackSec)
    local startWatch = tick()
    local fallback   = fallbackSec or 1.2
    local humanoid   = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local myRoot     = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then humanoid.AutoRotate = false end

    while tick() - startWatch < fallback do
        local nearestKiller = getNearestKillerModel()
        if nearestKiller and myRoot then
            local tHRP = nearestKiller:FindFirstChild("HumanoidRootPart")
            if tHRP then
                myRoot.CFrame = CFrame.lookAt(myRoot.Position, tHRP.Position)
            end
        end
        task.wait()
    end

    if humanoid then humanoid.AutoRotate = true end
end

-- ============================================================
--  VISION CONE (unchanged)
-- ============================================================
local function createVisionPart()
    local p = Instance.new("Part")
    p.Size, p.Shape, p.Anchored    = Vector3.one, Enum.PartType.Ball, true
    p.CanCollide, p.Transparency   = false, 0.5
    p.Color, p.Parent              = Color3.fromRGB(255,0,0), Workspace
    return p
end

local function createConnectionPart()
    local p = Instance.new("Part")
    p.Size, p.Anchored             = Vector3.new(0.2,0.2,1), true
    p.CanCollide, p.Transparency   = false, 0.5
    p.Color, p.Parent              = Color3.fromRGB(255,0,0), Workspace
    return p
end

local function updateConnectionPart(part, startPos, endPos)
    if not part or not startPos or not endPos then return end
    local dist = (endPos - startPos).Magnitude
    part.Size  = Vector3.new(0.2, 0.2, dist)
    part.CFrame= CFrame.new((startPos+endPos)/2, endPos)
end

local function updateVisionCone()
    local hide = Vector3.new(0,-1000,0)
    if not showVisionRange then
        if centerPart then centerPart.Position = hide end
        if leftPart   then leftPart.Position   = hide end
        if rightPart  then rightPart.Position  = hide end
        if leftToKillerPart  then leftToKillerPart.Position  = hide end
        if rightToKillerPart then rightToKillerPart.Position = hide end
        if leftToCenterPart  then leftToCenterPart.Position  = hide end
        if centerToRightPart then centerToRightPart.Position = hide end
        return
    end

    local target = getNearestKillerModel()
    if not target then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local look       = hrp.CFrame.LookVector
    local right      = hrp.CFrame.RightVector
    local centerPos  = hrp.Position + look * visionRange
    local halfAngle  = math.rad(visionAngle / 2)
    local leftDir    = (look * math.cos(halfAngle) - right * math.sin(halfAngle))
    local rightDir   = (look * math.cos(halfAngle) + right * math.sin(halfAngle))
    local leftPos    = hrp.Position + leftDir  * visionRange
    local rightPos   = hrp.Position + rightDir * visionRange

    if not centerPart        then centerPart        = createVisionPart()    end
    if not leftPart          then leftPart          = createVisionPart()    end
    if not rightPart         then rightPart         = createVisionPart()    end
    if not leftToKillerPart  then leftToKillerPart  = createConnectionPart() end
    if not rightToKillerPart then rightToKillerPart = createConnectionPart() end
    if not leftToCenterPart  then leftToCenterPart  = createConnectionPart() end
    if not centerToRightPart then centerToRightPart = createConnectionPart() end

    centerPart.Position = centerPos
    leftPart.Position   = leftPos
    rightPart.Position  = rightPos
    updateConnectionPart(leftToKillerPart,  leftPos,   hrp.Position)
    updateConnectionPart(rightToKillerPart, rightPos,  hrp.Position)
    updateConnectionPart(leftToCenterPart,  leftPos,   centerPos)
    updateConnectionPart(centerToRightPart, centerPos, rightPos)
end

local function cleanupVisionCone()
    for _, p in ipairs({centerPart,leftPart,rightPart,
                        leftToKillerPart,rightToKillerPart,
                        leftToCenterPart,centerToRightPart}) do
        if p then p:Destroy() end
    end
    centerPart,leftPart,rightPart,leftToKillerPart,
    rightToKillerPart,leftToCenterPart,centerToRightPart = nil,nil,nil,nil,nil,nil,nil
end

-- ============================================================
--  SOUND AUTO-BLOCK (audio only)
-- ============================================================
local function extractNumericSoundId(sound)
    if not sound or not sound.SoundId then return nil end
    return tostring(sound.SoundId):match("%d+")
end

local function getCharacterFromDescendant(inst)
    if not inst then return nil end
    local model = inst:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then return model end
    return nil
end

local function attemptBlockForSound(sound)
    if not autoBlockAudioOn then return end
    if not sound or not sound:IsA("Sound") or not sound.IsPlaying then return end

    local now = tick()
    if soundBlockedUntil[sound] and now < soundBlockedUntil[sound] then return end
    if now - lastLocalBlockTime < LOCAL_BLOCK_COOLDOWN then return end

    local id = extractNumericSoundId(sound)
    if not id or not autoBlockTriggerSounds[id] then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local soundPart
    if sound.Parent and sound.Parent:IsA("BasePart") then
        soundPart = sound.Parent
    elseif sound.Parent and sound.Parent:IsA("Attachment") and
           sound.Parent.Parent and sound.Parent.Parent:IsA("BasePart") then
        soundPart = sound.Parent.Parent
    end
    if not soundPart then return end

    local char = getCharacterFromDescendant(soundPart)
    if not char then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if not plr or plr == LocalPlayer then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (hrp.Position - myRoot.Position).Magnitude > detectionRange then return end
    if facingCheckEnabled and not isFacing(myRoot, hrp) then return end

    task.wait(blockdelay)

    if autoblocktype == "Block" then
        fireRemoteBlock()
        if doubleblocktech then fireRemotePunch() end
    elseif autoblocktype == "Charge" then
        fireRemoteCharge()
    elseif autoblocktype == "7n7 Clone" then
        fireRemoteClone()
    end

    lastLocalBlockTime  = now
    soundBlockedUntil[sound] = now + 1.0
end

local function hookSound(sound)
    if not sound or not sound:IsA("Sound") or soundHooks[sound] then return end

    local playedConn = sound.Played:Connect(function()
        attemptBlockForSound(sound)
    end)
    local propConn = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if sound.IsPlaying then attemptBlockForSound(sound) end
    end)
    local destroyConn = sound.Destroying:Connect(function()
        playedConn:Disconnect(); propConn:Disconnect(); destroyConn:Disconnect()
        soundHooks[sound]         = nil
        soundBlockedUntil[sound]  = nil
    end)

    soundHooks[sound] = { playedConn, propConn, destroyConn }
    if sound.IsPlaying then attemptBlockForSound(sound) end
end

local function setupSoundHooks()
    local killersFolder
    pcall(function() killersFolder = Workspace.Players.Killers end)
    if not killersFolder then return end

    for _, desc in pairs(killersFolder:GetDescendants()) do
        if desc:IsA("Sound") then hookSound(desc) end
    end
    killersFolder.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then hookSound(desc) end
    end)
end

-- ============================================================
--  HYBRID ESP (unchanged)
-- ============================================================
local esp = {
    killersEnabled = false,
    survivorsEnabled = false,
    generatorsEnabled = false,
    itemsEnabled = false,
    killersFolder = nil,
    survivorsFolder = nil,
    currentMapFolder = nil,
    playerConnections = {},
    mapConnections = {},
    healthConnections = {},
    progressConnections = {},
}

local function getCurrentMapFolder()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    local ingame = map:FindFirstChild("Ingame")
    if not ingame then return nil end
    return ingame:FindFirstChild("Map")
end

local function getIngameFolder()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    return map:FindFirstChild("Ingame")
end

local function isRealItem(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt") then return true end
    return false
end

local function addESP(obj, espName, color, isPlayer)
    if not obj or obj:FindFirstChild(espName) then return end

    if espName:find("Item") and not isRealItem(obj) then return end

    local root = obj:FindFirstChild("HumanoidRootPart")
        or obj.PrimaryPart
        or obj:FindFirstChildWhichIsA("BasePart")
        or obj:FindFirstChildOfClass("BasePart")
        or obj:FindFirstChild("Base")
        or obj:FindFirstChild("Main")
    if not root then
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then
                root = desc
                break
            end
        end
    end
    if not root then return end

    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = espName
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = obj
        hl.Parent = obj

        local billboard = Instance.new("BillboardGui")
        billboard.Name = espName .. "_Label"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, isPlayer and 150 or 120, 0, isPlayer and 30 or 25)
        billboard.StudsOffset = Vector3.new(0, isPlayer and 2.5 or 1.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = obj

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1,1,1)
        label.Text = obj.Name
        label.Font = Enum.Font.GothamBold
        label.TextSize = isPlayer and 14 or 12
        label.TextStrokeTransparency = 0.3
        label.TextStrokeColor3 = color
        label.Parent = billboard

        if isPlayer then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then
                label.Text = obj.Name .. " (100%)"
                local conn = hum.HealthChanged:Connect(function()
                    if label.Parent then
                        label.Text = obj.Name .. " (" .. math.floor((hum.Health / hum.MaxHealth) * 100) .. "%)"
                    end
                end)
                esp.healthConnections[obj] = conn
            end
        else
            local prog = obj:FindFirstChild("Progress")
            if prog and prog:IsA("NumberValue") then
                label.Text = math.floor(prog.Value) .. "%"
                local conn = prog.Changed:Connect(function()
                    if label.Parent then
                        label.Text = math.floor(prog.Value) .. "%"
                    end
                end)
                esp.progressConnections[obj] = conn
            end
        end
    end)
end

local function removeESP(obj, espName)
    if not obj then return end
    pcall(function()
        if obj:FindFirstChild(espName) then obj[espName]:Destroy() end
        if obj:FindFirstChild(espName .. "_Label") then obj[espName .. "_Label"]:Destroy() end
        if esp.healthConnections[obj] then
            esp.healthConnections[obj]:Disconnect()
            esp.healthConnections[obj] = nil
        end
        if esp.progressConnections[obj] then
            esp.progressConnections[obj]:Disconnect()
            esp.progressConnections[obj] = nil
        end
    end)
end

local function applyKillersESP()
    if not esp.killersFolder then return end
    for _, killer in ipairs(esp.killersFolder:GetChildren()) do
        if killer:IsA("Model") then
            addESP(killer, "HYBRID_ESP_Killer", Color3.fromRGB(255, 0, 0), true)
        end
    end
end

local function applySurvivorsESP()
    if not esp.survivorsFolder then return end
    for _, survivor in ipairs(esp.survivorsFolder:GetChildren()) do
        if survivor:IsA("Model") then
            addESP(survivor, "HYBRID_ESP_Survivor", Color3.fromRGB(0, 255, 0), true)
        end
    end
end

local function applyGeneratorsESP()
    local map = getCurrentMapFolder()
    if not map then return end
    for _, obj in ipairs(map:GetChildren()) do
        if obj.Name == "Generator" then
            addESP(obj, "HYBRID_ESP_Generator", Color3.fromRGB(255, 192, 203), false) -- pink
        end
    end
end

local function applyItemsESP()
    local map = getCurrentMapFolder()
    if not map then return end
    for _, obj in ipairs(map:GetChildren()) do
        if obj.Name == "BloxyCola" or obj.Name == "Medkit" then
            local color = obj.Name == "Medkit" and Color3.fromRGB(0,255,255) or Color3.fromRGB(255,165,0)
            addESP(obj, "HYBRID_ESP_Item", color, false)
        end
    end
end

local function setupPlayerConnections()
    for _, conn in pairs(esp.playerConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    esp.playerConnections = {}

    if esp.killersFolder then
        table.insert(esp.playerConnections, esp.killersFolder.ChildAdded:Connect(function(child)
            task.wait(0.2)
            if esp.killersEnabled then
                addESP(child, "HYBRID_ESP_Killer", Color3.fromRGB(255, 0, 0), true)
            end
        end))
        table.insert(esp.playerConnections, esp.killersFolder.ChildRemoved:Connect(function(child)
            removeESP(child, "HYBRID_ESP_Killer")
        end))
    end

    if esp.survivorsFolder then
        table.insert(esp.playerConnections, esp.survivorsFolder.ChildAdded:Connect(function(child)
            task.wait(0.2)
            if esp.survivorsEnabled then
                addESP(child, "HYBRID_ESP_Survivor", Color3.fromRGB(0, 255, 0), true)
            end
        end))
        table.insert(esp.playerConnections, esp.survivorsFolder.ChildRemoved:Connect(function(child)
            removeESP(child, "HYBRID_ESP_Survivor")
        end))
    end
end

local function setupMapWatcher()
    for _, conn in pairs(esp.mapConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    esp.mapConnections = {}

    local ingame = getIngameFolder()
    if not ingame then return end

    local mapAddedConn = ingame.ChildAdded:Connect(function(child)
        if child.Name == "Map" then
            task.wait(1)
            esp.currentMapFolder = child
            child.ChildAdded:Connect(function(obj)
                task.wait(0.2)
                if esp.generatorsEnabled and obj.Name == "Generator" then
                    addESP(obj, "HYBRID_ESP_Generator", Color3.fromRGB(255, 192, 203), false)
                elseif esp.itemsEnabled and (obj.Name == "BloxyCola" or obj.Name == "Medkit") then
                    local color = obj.Name == "Medkit" and Color3.fromRGB(0,255,255) or Color3.fromRGB(255,165,0)
                    addESP(obj, "HYBRID_ESP_Item", color, false)
                end
            end)
            child.ChildRemoved:Connect(function(obj)
                if obj.Name == "Generator" then
                    removeESP(obj, "HYBRID_ESP_Generator")
                elseif obj.Name == "BloxyCola" or obj.Name == "Medkit" then
                    removeESP(obj, "HYBRID_ESP_Item")
                end
            end)
            if esp.generatorsEnabled then applyGeneratorsESP() end
            if esp.itemsEnabled then applyItemsESP() end
        end
    end)
    local mapRemovedConn = ingame.ChildRemoved:Connect(function(child)
        if child.Name == "Map" then
            for _, obj in ipairs(child:GetChildren()) do
                if obj.Name == "Generator" then
                    removeESP(obj, "HYBRID_ESP_Generator")
                elseif obj.Name == "BloxyCola" or obj.Name == "Medkit" then
                    removeESP(obj, "HYBRID_ESP_Item")
                end
            end
            esp.currentMapFolder = nil
        end
    end)
    table.insert(esp.mapConnections, mapAddedConn)
    table.insert(esp.mapConnections, mapRemovedConn)

    local existingMap = getCurrentMapFolder()
    if existingMap then
        esp.currentMapFolder = existingMap
        task.spawn(function()
            task.wait(2)
            if esp.generatorsEnabled then applyGeneratorsESP() end
            if esp.itemsEnabled then applyItemsESP() end
        end)
    end
end

task.spawn(function()
    task.wait(3)
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        esp.killersFolder = playersFolder:FindFirstChild("Killers")
        esp.survivorsFolder = playersFolder:FindFirstChild("Survivors")
        setupPlayerConnections()
        if esp.killersEnabled then applyKillersESP() end
        if esp.survivorsEnabled then applySurvivorsESP() end
    end
    setupMapWatcher()
end)

-- ============================================================
--  KILLER AIMBOT SETUP (added)
-- ============================================================
local function killerSetupCharacter(char)
    Killer.humanoid = char:WaitForChild("Humanoid")
    Killer.hrp = char:WaitForChild("HumanoidRootPart")
    Killer.isAiming = false
    Killer.currentTarget = nil
    Killer.survivors = {}
end

if LocalPlayer.Character then killerSetupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(killerSetupCharacter)

local function killerIsKiller()
    local char = LocalPlayer.Character
    if not char then return false end
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    local killersFolder = playersFolder:FindFirstChild("Killers")
    if not killersFolder then return false end
    return char:IsDescendantOf(killersFolder)
end

local function killerUpdateSurvivorCache()
    local now = tick()
    if now - Killer.lastScan < Killer.scanInterval then return end
    Killer.lastScan = now

    Killer.survivors = {}
    local survivorsFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors")
    if not survivorsFolder then survivorsFolder = Workspace:FindFirstChild("Survivors") end

    if survivorsFolder then
        for _, surv in ipairs(survivorsFolder:GetChildren()) do
            if surv ~= LocalPlayer.Character and surv:IsA("Model") then
                local hum = surv:FindFirstChildOfClass("Humanoid")
                local root = surv:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(Killer.survivors, root)
                end
            end
        end
    end
end

local function killerFindNearestSurvivor()
    killerUpdateSurvivorCache()
    if not Killer.hrp or #Killer.survivors == 0 then return nil end

    local nearest = nil
    local minDist = math.huge
    local myPos = Killer.hrp.Position

    for _, root in ipairs(Killer.survivors) do
        local dist = (root.Position - myPos).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = root
        end
    end
    return nearest
end

local function killerStopAiming()
    if Killer.isAiming then
        if Killer.deathConnection then
            Killer.deathConnection:Disconnect()
            Killer.deathConnection = nil
        end
        if Killer.originalAutoRotate ~= nil and Killer.humanoid then
            Killer.humanoid.AutoRotate = Killer.originalAutoRotate
        end
        Killer.isAiming = false
        Killer.currentTarget = nil
    end
end

local function killerStartAiming(targetRoot)
    if not targetRoot or not targetRoot.Parent then return end
    if not Killer.humanoid or not Killer.hrp then return end
    if Killer.isAiming and Killer.currentTarget == targetRoot then return end

    killerStopAiming()

    Killer.currentTarget = targetRoot
    Killer.isAiming = true
    Killer.originalAutoRotate = Killer.humanoid.AutoRotate
    Killer.humanoid.AutoRotate = false

    local targetHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    if targetHum then
        Killer.deathConnection = targetHum.Died:Connect(killerStopAiming)
    end
end

-- Ability detection for killer aimbot
if testRemote then
    testRemote.OnClientEvent:Connect(function(...)
        if not Killer.enabled then return end

        local args = {...}
        if typeof(args[1]) == "string" then
            local abilityName = args[1]
            if abilityName:match("Ability") or 
               abilityName:match("[QER]") or 
               abilityName == "UseActorAbility" or
               abilityName == "Slash" or
               abilityName == "Dagger" or
               abilityName == "Charge" then

                if tick() - Killer.lastAbilityTime < Killer.cooldown then return end
                Killer.lastAbilityTime = tick()

                if killerIsKiller() then
                    local target = killerFindNearestSurvivor()
                    if target then
                        killerStartAiming(target)
                    end
                end
            end
        end
    end)
end

-- Render loop for killer aimbot
Killer.renderConn = RunService.RenderStepped:Connect(function()
    if not Killer.enabled or not Killer.isAiming or not Killer.hrp or not Killer.currentTarget then
        return
    end

    local targetRoot = Killer.currentTarget
    if not targetRoot or not targetRoot.Parent then
        killerStopAiming()
        return
    end

    -- Random health check for performance
    if math.random(1, 10) == 1 then
        local targetHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            killerStopAiming()
            return
        end
    end

    -- Smooth rotation
    local dir = (targetRoot.Position - Killer.hrp.Position)
    local flatDir = Vector3.new(dir.X, 0, dir.Z).Unit
    if flatDir.Magnitude > 0 then
        local targetCF = CFrame.new(Killer.hrp.Position, Killer.hrp.Position + flatDir)
        Killer.hrp.CFrame = Killer.hrp.CFrame:Lerp(targetCF, 0.35)
    end
end)

-- ============================================================
--  ELLIOT PIZZA AIMBOT (unchanged)
-- ============================================================
local aimbot = {
    enabled = false,
    requireAnimation = true,
    throwDuration = 0.5,
    isThrowing = false,
    throwTimestamp = 0,
    humanoid = nil,
    hrp = nil,
    autoRotateBackup = nil,
    renderConn = nil
}

local function setupAimbotCharacter(char)
    aimbot.humanoid = char:WaitForChild("Humanoid", 5)
    aimbot.hrp = char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then setupAimbotCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupAimbotCharacter)

task.spawn(function()
    local remote = testRemote
    if not remote then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and self == remote then
            if args[1] == "UseActorAbility" and args[2] and args[2][1] then
                local buf = args[2][1]
                local ok, str = pcall(buffer.tostring, buf)
                if ok and str and string.find(str, "ThrowPizza") then
                    aimbot.isThrowing = true
                    aimbot.throwTimestamp = tick()
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end)

local function findNearestSurvivor()
    local survivors = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors")
    if not survivors then survivors = Workspace:FindFirstChild("Survivors") end
    if not survivors or not aimbot.hrp then return nil end

    local nearest = nil
    local minDist = math.huge
    for _, surv in ipairs(survivors:GetChildren()) do
        if surv ~= LocalPlayer.Character then
            local hum = surv:FindFirstChildOfClass("Humanoid")
            local root = surv:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local dist = (root.Position - aimbot.hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = root
                end
            end
        end
    end
    return nearest
end

local function aimAt(target)
    if not target or not target.Parent then return end
    local targetPos = target.Position

    if aimbot.hrp then
        if aimbot.autoRotateBackup == nil then
            aimbot.autoRotateBackup = aimbot.humanoid.AutoRotate
        end
        aimbot.humanoid.AutoRotate = false
        aimbot.hrp.AssemblyAngularVelocity = Vector3.zero
        local dir = (targetPos - aimbot.hrp.Position)
        local flatDir = Vector3.new(dir.X, 0, dir.Z).Unit
        if flatDir.Magnitude > 0 then
            local targetCF = CFrame.new(aimbot.hrp.Position, aimbot.hrp.Position + flatDir)
            aimbot.hrp.CFrame = aimbot.hrp.CFrame:Lerp(targetCF, 0.35)
        end
    end
end

aimbot.renderConn = RunService.RenderStepped:Connect(function()
    if not aimbot.enabled or not aimbot.humanoid or not aimbot.hrp then
        if aimbot.autoRotateBackup ~= nil and aimbot.humanoid then
            aimbot.humanoid.AutoRotate = aimbot.autoRotateBackup
            aimbot.autoRotateBackup = nil
        end
        return
    end

    if aimbot.isThrowing and (tick() - aimbot.throwTimestamp > aimbot.throwDuration) then
        aimbot.isThrowing = false
    end

    local shouldAim = aimbot.requireAnimation and aimbot.isThrowing or not aimbot.requireAnimation

    if not shouldAim then
        if aimbot.autoRotateBackup ~= nil then
            aimbot.humanoid.AutoRotate = aimbot.autoRotateBackup
            aimbot.autoRotateBackup = nil
        end
        return
    end

    local target = findNearestSurvivor()
    if not target then
        if aimbot.autoRotateBackup ~= nil then
            aimbot.humanoid.AutoRotate = aimbot.autoRotateBackup
            aimbot.autoRotateBackup = nil
        end
        return
    end

    aimAt(target)
end)

-- ============================================================
--  INFINITE STAMINA
-- ============================================================
local infiniteStaminaEnabled = false
local staminaLoop = nil

local function toggleInfiniteStamina(enabled)
    infiniteStaminaEnabled = enabled
    if staminaLoop then staminaLoop:Disconnect(); staminaLoop = nil end
    if enabled then
        staminaLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                local sprintMod = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
                sprintMod.StaminaLossDisabled = true
                sprintMod.CurrentStamina      = sprintMod.MaxStamina
            end)
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local sv = char:FindFirstChild("Stamina") or char:FindFirstChild("StaminaValue")
                if sv and sv:IsA("NumberValue") then
                    sv.Value = sv:GetAttribute("MaxStamina") or 100
                end
            end)
        end)
        Rayfield:Notify({ Title="Stamina", Content="♾️ Infinite Stamina ON", Duration=2 })
    else
        Rayfield:Notify({ Title="Stamina", Content="⏸️ Infinite Stamina OFF", Duration=2 })
    end
end

-- ============================================================
--  MOVEMENT (NoClip + TP to Item)
-- ============================================================
local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip(state)
    noclipEnabled = state
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then return end
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
        Rayfield:Notify({ Title="NoClip", Content="Enabled", Duration=2 })
    else
        Rayfield:Notify({ Title="NoClip", Content="Disabled", Duration=2 })
    end
end

local itemNameMedkit = "Medkit"
local itemNameBloxy = "Bloxy Cola"

local function teleportToNearestItem()
    local success, err = pcall(function()
        local char = LocalPlayer.Character
        if not char then Rayfield:Notify({ Title="Error", Content="Character not found", Duration=2 }); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then Rayfield:Notify({ Title="Error", Content="Root part not found", Duration=2 }); return end

        local targetNames = { itemNameMedkit, itemNameBloxy }
        local nearestItem, nearestDist, nearestPos, nearestName = nil, math.huge, nil, ""

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                for _, targetName in ipairs(targetNames) do
                    if obj.Name == targetName then
                        local pos
                        if obj:IsA("BasePart") then pos = obj.Position
                        elseif obj:IsA("Model") then
                            local primary = obj.PrimaryPart
                            if primary then pos = primary.Position
                            else
                                for _, part in ipairs(obj:GetChildren()) do
                                    if part:IsA("BasePart") then pos = part.Position; break end
                                end
                            end
                        end
                        if pos then
                            local dist = (pos - hrp.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist, nearestItem, nearestPos, nearestName = dist, obj, pos, obj.Name
                            end
                        end
                        break
                    end
                end
            end
        end
        if nearestItem and nearestPos then
            hrp.CFrame = CFrame.new(nearestPos + Vector3.new(0,3,0))
            Rayfield:Notify({ Title="Teleported", Content=string.format("To %s (%.1f studs)", nearestName, nearestDist), Duration=2 })
        else
            Rayfield:Notify({ Title="No Items", Content=string.format("No '%s' or '%s' found", itemNameMedkit, itemNameBloxy), Duration=3 })
        end
    end)
    if not success then
        warn("TP to Item error:", err)
        Rayfield:Notify({ Title="Error", Content="TP failed: " .. tostring(err), Duration=3 })
    end
end

-- ============================================================
--  GENERATOR (full code)
-- ============================================================
local genFlowSolverEnabled = false
local genFlowNodeDelay = 0.04
local genFlowLineDelay = 0.60
local genPuzzleUI = nil

local function genRefreshPuzzleUI()
    genPuzzleUI = LocalPlayer.PlayerGui:FindFirstChild("PuzzleUI")
end

local function genGetDirection(cr,cc,or2,oc)
    if or2 < cr then return "up" elseif or2 > cr then return "down"
    elseif oc < cc then return "left" else return "right" end
end

local function genGetConnections(prev, curr, nxt)
    local conn = {}
    if prev and curr then
        local d = genGetDirection(curr.row,curr.col,prev.row,prev.col)
        if d=="up" then d="down" elseif d=="down" then d="up"
        elseif d=="left" then d="right" else d="left" end
        conn[d] = true
    end
    if nxt and curr then
        local d = genGetDirection(curr.row,curr.col,nxt.row,nxt.col)
        if d then conn[d] = true end
    end
    return conn
end

local function genIsNeighbour(r1,c1,r2,c2)
    if r2==r1-1 and c2==c1 then return "up" end
    if r2==r1+1 and c2==c1 then return "down" end
    if r2==r1 and c2==c1-1 then return "left" end
    if r2==r1 and c2==c1+1 then return "right" end
    return false
end

local function genCoordKey(n) return n.row.."-"..n.col end

local function genOrderPath(path, endpoints)
    if not path or #path == 0 then return path end
    local inPath = {}
    for _, n in ipairs(path) do inPath[genCoordKey(n)] = n end
    local startNode
    for _, ep in ipairs(endpoints or {}) do
        for _, n in ipairs(path) do
            if n.row==ep.row and n.col==ep.col then
                startNode = { row=ep.row, col=ep.col }; break
            end
        end
        if startNode then break end
    end
    if not startNode then
        for _, n in ipairs(path) do
            local neighbors = 0
            for _, d in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
                if inPath[(n.row+d[1]).."-"..(n.col+d[2])] then
                    neighbors = neighbors + 1
                end
            end
            if neighbors == 1 then startNode = {row=n.row,col=n.col}; break end
        end
    end
    if not startNode then startNode = {row=path[1].row,col=path[1].col} end

    local remaining, ordered = {}, {}
    for _, n in ipairs(path) do remaining[genCoordKey(n)] = {row=n.row,col=n.col} end
    local current = startNode
    table.insert(ordered, {row=current.row,col=current.col})
    remaining[genCoordKey(current)] = nil

    while next(remaining) do
        local found = false
        for key, node in pairs(remaining) do
            if genIsNeighbour(current.row,current.col,node.row,node.col) then
                table.insert(ordered, {row=node.row,col=node.col})
                remaining[key] = nil
                current = node; found = true; break
            end
        end
        if not found then break end
    end
    return ordered
end

local function genDrawSolution(puzzle)
    if not puzzle or not puzzle.Solution then return end
    local indices = {}
    for i = 1, #puzzle.Solution do table.insert(indices,i) end
    for i = #indices, 2, -1 do
        local j = math.random(1,i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    for _, colorIndex in ipairs(indices) do
        local path      = puzzle.Solution[colorIndex]
        local endpoints = puzzle.targetPairs[colorIndex]
        local ordered   = genOrderPath(path, endpoints)
        puzzle.paths[colorIndex] = {}
        for i, node in ipairs(ordered) do
            table.insert(puzzle.paths[colorIndex], {row=node.row,col=node.col})
            local prev = ordered[i-1]; local nxt = ordered[i+1]
            local conn = genGetConnections(prev, node, nxt)
            puzzle.gridConnections = puzzle.gridConnections or {}
            puzzle.gridConnections[genCoordKey(node)] = conn
            pcall(function() puzzle:updateGui() end)
            task.wait(genFlowNodeDelay)
        end
        task.wait(genFlowLineDelay)
        pcall(function() puzzle:checkForWin() end)
    end
end

local genFlowModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Misc") and ReplicatedStorage.Modules.Misc:FindFirstChild("FlowGameManager") and ReplicatedStorage.Modules.Misc.FlowGameManager:FindFirstChild("FlowGame")
if genFlowModule then
    local FlowGame = require(genFlowModule)
    local oldNew = FlowGame.new
    FlowGame.new = function(...)
        local puzzle = oldNew(...)
        if genFlowSolverEnabled then
            task.spawn(function()
                task.wait(0.3)
                genDrawSolution(puzzle)
            end)
        end
        return puzzle
    end
end

LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "PuzzleUI" then genRefreshPuzzleUI() end
end)
LocalPlayer.PlayerGui.ChildRemoved:Connect(function() genPuzzleUI = nil end)
genRefreshPuzzleUI()

-- ============================================================
--  CHANCE (full code)
-- ============================================================
local chanceCamLock = false
local chanceCharLock = false
local chanceAbilityActive = false
local chanceAbilityTrack = nil
local chanceAbilityStart = 0
local MAX_ABILITY_TIME = 3
local chanceAnimationIds = { "133491532453922","133607163653602","76649505662612","86371356500204" }
local chanceTargets = { "Slasher","c00lkidd","JohnDoe","1x1x1x1","Noli","Sixer","Nosferatu" }
local chanceHumanoid = nil
local chanceHrp = nil

local function chanceSetupChar(char)
    pcall(function()
        chanceHumanoid = char:WaitForChild("Humanoid",5)
        chanceHrp = char:WaitForChild("HumanoidRootPart",5)
        chanceAbilityActive = false
        if chanceHumanoid then chanceHumanoid.AutoRotate = true end
    end)
end

local function chanceGetTarget()
    local killers
    pcall(function() killers = Workspace.Players.Killers end)
    if not killers then return nil end
    for _, name in ipairs(chanceTargets) do
        local model = killers:FindFirstChild(name)
        if model then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then return root end
        end
    end
end

local function chanceDetectAbility()
    if chanceAbilityActive or not chanceHumanoid then return end
    pcall(function()
        for _, track in ipairs(chanceHumanoid:GetPlayingAnimationTracks()) do
            local id = track.Animation and track.Animation.AnimationId:match("%d+")
            if id and tableFind(chanceAnimationIds, id) then
                chanceAbilityActive = true
                chanceAbilityTrack = track
                chanceAbilityStart = tick()
                chanceHumanoid.AutoRotate = false
                return
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        chanceDetectAbility()
        if chanceAbilityActive and (
            tick() - chanceAbilityStart > MAX_ABILITY_TIME or
            (chanceAbilityTrack and not chanceAbilityTrack.IsPlaying)
        ) then
            chanceAbilityActive = false
            if chanceHumanoid then chanceHumanoid.AutoRotate = true end
            return
        end
        if chanceAbilityActive then
            if chanceCamLock then
                local target = chanceGetTarget()
                if target then
                    local camPos = Camera.CFrame.Position
                    Camera.CFrame = CFrame.new(camPos, target.Position)
                end
            end
            if chanceCharLock and chanceHumanoid and chanceHrp then
                local target = chanceGetTarget()
                if target then
                    local dir = (target.Position - chanceHrp.Position).Unit
                    local yaw = math.atan2(-dir.X, -dir.Z)
                    chanceHrp.CFrame = CFrame.new(chanceHrp.Position) * CFrame.Angles(0, yaw, 0)
                end
            end
        end
    end)
end)

if LocalPlayer.Character then task.spawn(chanceSetupChar, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.5); chanceSetupChar(char) end)

-- ============================================================
--  LUNA-TRICK (full code)
-- ============================================================
local isMobile = UserInputService.TouchEnabled
local device = isMobile and "Mobile" or "PC"
local veerAutoSkateEnabled = false
local veerSkateLoop = nil
local veerSk8ControlEnabled = false
local veerIsSk8Active = false
local veerSk8Loop = nil
local veerSavedHumanoid = {}
local veerCamera = Workspace.CurrentCamera
local veerActiveSk8Track = nil
local veerSk8DashSpeed = 60
local veerSk8AnimationIds = { "117058860640843" }
local autoTrickEnabled = false
local isCurrentlyHighlighted = false
local activeMonitors = {}
local descendantAddedConn = nil

local function veerFireSkateEvent()
    pcall(function()
        local remote = ReplicatedStorage.Modules.Network.RemoteEvent
        remote:FireServer(LocalPlayer.Name.."SkateTrick", {})
    end)
end

local function veerStartSkateFarm()
    if veerSkateLoop then return end
    local last = 0
    veerSkateLoop = RunService.Heartbeat:Connect(function()
        if not veerAutoSkateEnabled then
            veerSkateLoop:Disconnect(); veerSkateLoop = nil; return
        end
        local now = tick()
        if now - last >= 0.2 then
            last = now; veerFireSkateEvent()
        end
    end)
end

local function veerGetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function veerGetRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function veerSaveHumanoidState(humanoid)
    if not humanoid or veerSavedHumanoid[humanoid] then return end
    veerSavedHumanoid[humanoid] = {
        walkSpeed = humanoid.WalkSpeed,
        jumpPower = humanoid.JumpPower,
        platformStand = humanoid.PlatformStand,
        autoRotate = humanoid.AutoRotate
    }
end

local function veerRestoreHumanoidState(humanoid)
    if not humanoid then return end
    local state = veerSavedHumanoid[humanoid]
    if not state then return end
    humanoid.WalkSpeed = state.walkSpeed
    humanoid.JumpPower = state.jumpPower
    humanoid.PlatformStand = state.platformStand
    humanoid.AutoRotate = state.autoRotate
    veerSavedHumanoid[humanoid] = nil
end

local function veerIsSk8AnimationActive()
    local humanoid = veerGetHumanoid()
    if not humanoid then return false end
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local id = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
        if id and tableFind(veerSk8AnimationIds, id) then return track end
    end
    return false
end

local function veerStartSk8Override()
    if veerIsSk8Active then return end
    local humanoid = veerGetHumanoid(); local root = veerGetRootPart()
    if not humanoid or not root then return end

    veerIsSk8Active = true
    veerSaveHumanoidState(humanoid)
    humanoid.WalkSpeed   = veerSk8DashSpeed
    humanoid.AutoRotate  = false

    if veerSk8Loop then veerSk8Loop:Disconnect() end
    veerSk8Loop = RunService.RenderStepped:Connect(function()
        local hum = veerGetHumanoid()
        local rootPart = veerGetRootPart()
        if not hum or not rootPart then return end
        hum.WalkSpeed = veerSk8DashSpeed
        local camLook = veerCamera.CFrame.LookVector
        local moveDir = Vector3.new(camLook.X, 0, camLook.Z)
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            hum:Move(moveDir, false)
        end
        rootPart.CFrame = rootPart.CFrame:Lerp(
            CFrame.new(rootPart.Position, rootPart.Position + moveDir), 0.3)
    end)
end

local function veerStopSk8Override()
    if not veerIsSk8Active then return end
    veerIsSk8Active = false
    if veerSk8Loop then veerSk8Loop:Disconnect(); veerSk8Loop = nil end
    if veerActiveSk8Track then
        pcall(function() veerActiveSk8Track.Stopped:Disconnect() end)
        veerActiveSk8Track = nil
    end
    task.wait(0.05)
    local humanoid = veerGetHumanoid()
    if humanoid and humanoid.Parent then
        veerRestoreHumanoidState(humanoid)
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
        humanoid.WalkSpeed = 16
        humanoid:Move(Vector3.zero, false)
        if isMobile then
            local root = veerGetRootPart()
            if root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
    veerSavedHumanoid = {}
end

RunService.RenderStepped:Connect(function()
    if not veerSk8ControlEnabled then
        if veerIsSk8Active then veerStopSk8Override() end; return
    end
    local humanoid = veerGetHumanoid()
    if not humanoid then if veerIsSk8Active then veerStopSk8Override() end; return end
    local currentTrack = veerIsSk8AnimationActive()
    if currentTrack and not veerIsSk8Active then
        veerActiveSk8Track = currentTrack
        currentTrack.Stopped:Connect(function()
            if veerIsSk8Active then veerStopSk8Override() end
        end)
        veerStartSk8Override()
    elseif not currentTrack and veerIsSk8Active then
        veerStopSk8Override()
    end
end)

local behaviorFolder
pcall(function()
    behaviorFolder = ReplicatedStorage:WaitForChild("Assets",10):WaitForChild("Survivors",10):WaitForChild("Veeronica",10):WaitForChild("Behavior",10)
end)

local function triggerJump()
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.delay(0.1, function()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end)
    end
end

local function monitorHighlight(h)
    if not h or activeMonitors[h] then return end
    local connections = {}
    local prevState = false

    local function cleanup()
        for _, c in ipairs(connections) do
            if c and c.Connected then c:Disconnect() end
        end
        activeMonitors[h] = nil
    end

    local function adorneeIsLocalChar(hl)
        if not hl then return false end
        local adornee = hl.Adornee
        local char = LocalPlayer.Character
        if not adornee or not char then return false end
        return adornee == char or adornee:IsDescendantOf(char)
    end

    local function onChanged()
        if not autoTrickEnabled then return end
        if not h or not h.Parent then cleanup(); return end
        local curr = adorneeIsLocalChar(h)
        if not prevState and curr then
            isCurrentlyHighlighted = true
            triggerJump()
        elseif prevState and not curr then
            isCurrentlyHighlighted = false
        end
        prevState = curr
    end

    local ok, sig = pcall(function() return h:GetPropertyChangedSignal("Adornee") end)
    if ok and sig then table.insert(connections, sig:Connect(onChanged)) end
    table.insert(connections, h.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() else onChanged() end
    end))
    table.insert(connections, LocalPlayer.CharacterAdded:Connect(onChanged))
    table.insert(connections, LocalPlayer.CharacterRemoving:Connect(onChanged))

    activeMonitors[h] = cleanup
    task.spawn(onChanged)
end

local function startAutoTrickManager()
    if descendantAddedConn or not behaviorFolder then return end
    for _, desc in ipairs(behaviorFolder:GetDescendants()) do
        if desc:IsA("Highlight") then monitorHighlight(desc) end
    end
    descendantAddedConn = behaviorFolder.DescendantAdded:Connect(function(child)
        if child:IsA("Highlight") then monitorHighlight(child) end
    end)
end

local function stopAutoTrickManager()
    if descendantAddedConn and descendantAddedConn.Connected then
        descendantAddedConn:Disconnect()
    end
    descendantAddedConn = nil
    local cleans = {}
    for _, fn in pairs(activeMonitors) do if type(fn)=="function" then table.insert(cleans,fn) end end
    for _, fn in ipairs(cleans) do pcall(fn) end
    activeMonitors = {}
end

local function setAutoTrickEnabled(v)
    if autoTrickEnabled == v then return end
    autoTrickEnabled = v
    if v then startAutoTrickManager() else stopAutoTrickManager() end
end

-- ============================================================
--  MAIN HEARTBEAT LOOP (throttled)
-- ============================================================
local _lastPunchScan = 0
local _lastAimScan = 0
local _lastHDTScan = 0
local _lastLockScan = 0
local PUNCH_SCAN_RATE = 0.1
local AIM_SCAN_RATE = 0.1
local HDT_SCAN_RATE = 0.15
local LOCK_SCAN_RATE = 0.1

RunService.Heartbeat:Connect(function()
    local now = tick()
    pcall(updateVisionCone)

    if (characterLockOn or cameraLockOn) and (now - _lastLockScan) >= LOCK_SCAN_RATE then
        _lastLockScan = now
        pcall(function()
            local animator = cachedAnimator
            if not animator then return end
            local isPunching = false
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local animId = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
                if animId and punchAnimSet[animId] then isPunching = true; break end
            end
            if isPunching then startAggressiveLockOnPunch()
            else stopAllLocks() end
        end)
    end

    if autoPunchOn and (now - _lastPunchScan) >= PUNCH_SCAN_RATE then
        _lastPunchScan = now
        pcall(function()
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local killersFolder
            pcall(function() killersFolder = Workspace.Players.Killers end)
            if not killersFolder then return end
            for _, name in ipairs(killerNames) do
                local killer = killersFolder:FindFirstChild(name)
                if killer then
                    local root = killer:FindFirstChild("HumanoidRootPart")
                    if root and (root.Position - myRoot.Position).Magnitude <= 10 then
                        fireRemotePunch()
                        break
                    end
                end
            end
        end)
    end

    if aimPunch and (now - _lastAimScan) >= AIM_SCAN_RATE then
        _lastAimScan = now
        pcall(function()
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local animator = cachedAnimator
            if not myRoot or not animator then return end
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local animId = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
                if animId and punchAnimSet[animId] then
                    local last = lastAimTrigger[track]
                    if not last or tick() - last >= AIM_COOLDOWN then
                        local timePos = track.TimePosition or 0
                        if timePos <= 0.1 then
                            lastAimTrigger[track] = tick()
                            if humanoid then humanoid.AutoRotate = false end
                            task.spawn(function()
                                local start = tick()
                                while tick() - start < AIM_WINDOW do
                                    local nearestKiller = getNearestKillerModel()
                                    if nearestKiller and myRoot then
                                        local kHRP = nearestKiller:FindFirstChild("HumanoidRootPart")
                                        if kHRP and kHRP.Parent then
                                            local predictedPos = kHRP.Position + kHRP.CFrame.LookVector * predictionValue
                                            myRoot.CFrame = CFrame.lookAt(myRoot.Position, predictedPos)
                                        end
                                    end
                                    task.wait()
                                end
                                if humanoid then humanoid.AutoRotate = true end
                            end)
                        end
                    end
                end
            end
        end)
    end

    if hitboxDraggingTech and (now - _lastHDTScan) >= HDT_SCAN_RATE then
        _lastHDTScan = now
        pcall(function()
            if not cachedAnimator then refreshAnimator() end
            local animator = cachedAnimator
            if not animator then return end
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local animId = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
                if animId and blockAnimSet[animId] then
                    local timePos = track.TimePosition or 0
                    if timePos <= 0.12 then
                        local nearest = getNearestKillerModel()
                        if nearest then
                            task.wait(Ddelay)
                            task.spawn(function()
                                beginDragIntoKiller(nearest)
                                startChargeAimUntilChargeEnds(0.4)
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
--  UI – UPDATES TAB
-- ============================================================
do
    TabUpdates:CreateSection("Latest Updates")
    TabUpdates:CreateLabel("✨ lovesaken v3.7 ✨")
    TabUpdates:CreateLabel("🔥 NEW:")
	TabUpdates:CreateLabel("• Added A Key")
    TabUpdates:CreateLabel("• Reworked  ESP")
    TabUpdates:CreateLabel("  – No more false positives on items")
    TabUpdates:CreateLabel("• Added Generators ESP")
    TabUpdates:CreateLabel("• Elliot Pizza Aimbot")
    TabUpdates:CreateLabel("• Killer Ability Aimbot (Q/E/R/abilities)")
end

-- ============================================================
--  UI – AUTO BLOCK TAB (audio only)
-- ============================================================
do
    TabAutoBlock:CreateSection("Audio Auto‑Block")
    TabAutoBlock:CreateToggle({ Name="Auto Block (Audio)", CurrentValue=false, Flag="AutoBlockAudio",
        Callback=function(v) autoBlockAudioOn = v; if v then task.spawn(setupSoundHooks) end end })
    TabAutoBlock:CreateDropdown({ Name="Block Type", Options={"Block","Charge","7n7 Clone"}, CurrentOption="Block", Flag="BlockType",
        Callback=function(v) autoblocktype = v end })
    TabAutoBlock:CreateSlider({ Name="Detection Range", Range={5,50}, Increment=1, CurrentValue=18, Flag="DetectionRange",
        Callback=function(v) detectionRange = v end })
    TabAutoBlock:CreateInput({ Name="Block Delay", PlaceholderText="0", Flag="BlockDelay",
        Callback=function(v) blockdelay = tonumber(v) or 0 end })
    TabAutoBlock:CreateToggle({ Name="Facing Check", CurrentValue=false, Flag="FacingCheck",
        Callback=function(v) facingCheckEnabled = v end })
    TabAutoBlock:CreateInput({ Name="Facing Dot", PlaceholderText="-0.3", Flag="FacingDot",
        Callback=function(v) customFacingDot = tonumber(v) or -0.3 end })
    TabAutoBlock:CreateToggle({ Name="Double Punch Tech", CurrentValue=false, Flag="DoublePunchTech",
        Callback=function(v) doubleblocktech = v end })
end

-- ============================================================
--  UI – LOCK TAB
-- ============================================================
do
    TabLock:CreateSection("Lock Controls")
    TabLock:CreateToggle({ Name="Character Lock", CurrentValue=false, Flag="CharLock",
        Callback=function(v) characterLockOn = v; if not v then stopAllLocks() end end })
    TabLock:CreateToggle({ Name="Camera Lock", CurrentValue=false, Flag="CamLock",
        Callback=function(v) cameraLockOn = v; if not v then stopAllLocks() end end })
    TabLock:CreateSlider({ Name="Lock Duration (s)", Range={0.5,5}, Increment=0.1, CurrentValue=2.0, Flag="LockDuration",
        Callback=function(v) lockDuration = v end })
    TabLock:CreateSlider({ Name="Max Lock Distance", Range={10,50}, Increment=1, CurrentValue=30, Flag="LockMaxDist",
        Callback=function(v) lockMaxDistance = v end })
    TabLock:CreateSlider({ Name="Char Smoothing", Range={0.1,1.0}, Increment=0.05, CurrentValue=0.7, Flag="CharSmooth",
        Callback=function(v) aggressiveSmoothing = v end })
    TabLock:CreateSlider({ Name="Cam Smoothing", Range={0.1,1.0}, Increment=0.05, CurrentValue=0.6, Flag="CamSmooth",
        Callback=function(v) cameraAggressiveSmoothing = v end })
    TabLock:CreateInput({ Name="Lock Cooldown (s)", PlaceholderText="0.05", Flag="LockCooldown",
        Callback=function(v) lockCooldown = tonumber(v) or 0.05 end })
    TabLock:CreateLabel("✅ Locks ONLY activate on YOUR punch")
end

-- ============================================================
--  UI – TECHS TAB
-- ============================================================
do
    TabTechs:CreateSection("Techniques")
    TabTechs:CreateToggle({ Name="Hitbox Dragging Tech", CurrentValue=false, Flag="HDT",
        Callback=function(v) hitboxDraggingTech = v end })
    TabTechs:CreateSlider({ Name="HDT Speed", Range={1,10}, Increment=0.1, CurrentValue=5.6, Flag="HDTSpeed",
        Callback=function(v) Dspeed = v end })
    TabTechs:CreateInput({ Name="HDT Delay", PlaceholderText="0", Flag="HDTDelay",
        Callback=function(v) Ddelay = tonumber(v) or 0 end })
    TabTechs:CreateButton({ Name="Fake Lag Tech", Callback=function()
        pcall(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://136252471123500"
                local track = animator:LoadAnimation(anim)
                track:Play()
            end
        end)
    end })
end

-- ============================================================
--  UI – AUTO PUNCH TAB
-- ============================================================
do
    TabAutoPunch:CreateSection("Punch Settings")
    TabAutoPunch:CreateToggle({ Name="Auto Punch", CurrentValue=false, Flag="AutoPunch",
        Callback=function(v) autoPunchOn = v end })
    TabAutoPunch:CreateToggle({ Name="Punch Aimbot", CurrentValue=false, Flag="PunchAimbot",
        Callback=function(v) aimPunch = v end })
    TabAutoPunch:CreateSlider({ Name="Aim Prediction", Range={0,10}, Increment=0.1, CurrentValue=4, Flag="AimPrediction",
        Callback=function(v) predictionValue = v end })
    TabAutoPunch:CreateLabel("⚡ Fling Punch removed")
end

-- ============================================================
--  UI – VISION TAB
-- ============================================================
do
    TabVision:CreateSection("Vision Cone")
    TabVision:CreateToggle({ Name="Show Vision Cone", CurrentValue=false, Flag="ShowVision",
        Callback=function(v) showVisionRange = v; if not v then cleanupVisionCone() end end })
    TabVision:CreateSlider({ Name="Vision Range", Range={1,50}, Increment=1, CurrentValue=13.5, Flag="VisionRange",
        Callback=function(v) visionRange = v end })
    TabVision:CreateSlider({ Name="Vision Angle", Range={30,180}, Increment=5, CurrentValue=85, Flag="VisionAngle",
        Callback=function(v) visionAngle = v end })
end

-- ============================================================
--  UI – ESP TAB (Hybrid)
-- ============================================================
do
    TabESP:CreateSection("Player ESP")
    TabESP:CreateToggle({ Name="Killers ESP (Red)", CurrentValue=false, Flag="ESPKillers",
        Callback=function(v) esp.killersEnabled = v; if v then applyKillersESP() else
            if esp.killersFolder then
                for _, k in ipairs(esp.killersFolder:GetChildren()) do
                    removeESP(k, "HYBRID_ESP_Killer")
                end
            end
        end end })
    TabESP:CreateToggle({ Name="Survivors ESP (Lime)", CurrentValue=false, Flag="ESPSurvivors",
        Callback=function(v) esp.survivorsEnabled = v; if v then applySurvivorsESP() else
            if esp.survivorsFolder then
                for _, s in ipairs(esp.survivorsFolder:GetChildren()) do
                    removeESP(s, "HYBRID_ESP_Survivor")
                end
            end
        end end })

    TabESP:CreateSection("World ESP")
    TabESP:CreateToggle({ Name="Generators ESP (Pink)", CurrentValue=false, Flag="ESPGenerators",
        Callback=function(v) esp.generatorsEnabled = v; if v then applyGeneratorsESP() else
            local map = getCurrentMapFolder()
            if map then
                for _, gen in ipairs(map:GetChildren()) do
                    if gen.Name == "Generator" then
                        removeESP(gen, "HYBRID_ESP_Generator")
                    end
                end
            end
        end end })
    TabESP:CreateToggle({ Name="Items ESP (Cyan/Orange)", CurrentValue=false, Flag="ESPItems",
        Callback=function(v) esp.itemsEnabled = v; if v then applyItemsESP() else
            local map = getCurrentMapFolder()
            if map then
                for _, item in ipairs(map:GetChildren()) do
                    if item.Name == "BloxyCola" or item.Name == "Medkit" then
                        removeESP(item, "HYBRID_ESP_Item")
                    end
                end
            end
        end end })
end

-- ============================================================
--  UI – STAMINA TAB
-- ============================================================
do
    TabStamina:CreateSection("Stamina Control")
    TabStamina:CreateToggle({ Name="♾️ Infinite Stamina", CurrentValue=false, Flag="InfiniteStamina",
        Callback=function(v) toggleInfiniteStamina(v) end })
    TabStamina:CreateLabel("Never run out of stamina")
end

-- ============================================================
--  UI – GENERATOR TAB
-- ============================================================
do
    TabGenerator:CreateSection("Auto Generator")
    TabGenerator:CreateLabel("⚡ SOLVES gens ⚡")
    TabGenerator:CreateToggle({ Name="Enable Auto Gen", CurrentValue=false, Flag="AutoGen",
        Callback=function(v) genFlowSolverEnabled = v end })
    TabGenerator:CreateSlider({ Name="Node Draw Speed", Range={0.01,0.50}, Increment=0.01, CurrentValue=0.04, Flag="GenNodeSpeed",
        Callback=function(v) genFlowNodeDelay = v end })
    TabGenerator:CreateSlider({ Name="Delay Between Lines", Range={0.00,1.00}, Increment=0.01, CurrentValue=0.60, Flag="GenLineDelay",
        Callback=function(v) genFlowLineDelay = v end })
    TabGenerator:CreateLabel("1. Enable • 2. Start puzzle • 3. Auto-solves!")
end

-- ============================================================
--  UI – CHANCE TAB
-- ============================================================
do
    TabChance:CreateSection("Chance Ability Locks")
    TabChance:CreateLabel("✨ LUNA-CHANCE V2 ✨")
    TabChance:CreateToggle({ Name="Camera Lock", CurrentValue=false, Flag="ChanceCamLock",
        Callback=function(v) chanceCamLock = v end })
    TabChance:CreateToggle({ Name="Character Lock", CurrentValue=false, Flag="ChanceCharLock",
        Callback=function(v) chanceCharLock = v end })
    TabChance:CreateButton({ Name="Force Reset", Callback=function()
        chanceAbilityActive = false
        if chanceHumanoid then chanceHumanoid.AutoRotate = true end
        Rayfield:Notify({ Title="Chance", Content="🔄 Ability state reset", Duration=2 })
    end })
end

-- ============================================================
--  UI – LUNA-TRICK TAB
-- ============================================================
do
    TabLunaTrick:CreateSection("Veeronica")
    TabLunaTrick:CreateLabel("✨ LUNA-TRICK v1.0 ✨")
    TabLunaTrick:CreateLabel("Device: " .. device)

    TabLunaTrick:CreateLabel("🎮 AUTO SKATETRICK FARM")
    TabLunaTrick:CreateToggle({ Name="Auto SkateTrick Farm (No Jump)", CurrentValue=false, Flag="AutoSkateFarm",
        Callback=function(v)
            veerAutoSkateEnabled = v
            if v then veerStartSkateFarm() elseif veerSkateLoop then veerSkateLoop:Disconnect(); veerSkateLoop = nil end
        end })

    TabLunaTrick:CreateLabel("🛹 SK8 CONTROL")
    TabLunaTrick:CreateToggle({ Name="Sk8 Control", CurrentValue=false, Flag="Sk8Control",
        Callback=function(v)
            veerSk8ControlEnabled = v
            if not v and veerIsSk8Active then veerStopSk8Override() end
        end })
    TabLunaTrick:CreateSlider({ Name="Sk8 Speed", Range={30,100}, Increment=5, CurrentValue=60, Flag="Sk8Speed",
        Callback=function(v) veerSk8DashSpeed = v end })

    TabLunaTrick:CreateLabel("🎯 AUTO TRICK (WITH JUMP)")
    TabLunaTrick:CreateToggle({ Name="Auto Trick (With Jump)", CurrentValue=false, Flag="AutoTrick",
        Callback=function(v) setAutoTrickEnabled(v) end })

    TabLunaTrick:CreateButton({ Name="Reset Movement", Callback=function()
        local humanoid = veerGetHumanoid()
        if humanoid then
            veerStopSk8Override()
            humanoid.WalkSpeed = 16
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:Move(Vector3.zero, false)
        end
        Rayfield:Notify({ Title="Luna Trick", Content="✅ Movement reset", Duration=2 })
    end })
end

-- ============================================================
--  UI – MOVEMENT TAB (NoClip + TP to Item)
-- ============================================================
do
    TabMovement:CreateSection("Movement Utilities")
    TabMovement:CreateToggle({ Name="NoClip (Walk through walls)", CurrentValue=false, Flag="NoClip",
        Callback=function(v) toggleNoclip(v) end })
    TabMovement:CreateButton({ Name="📦 TP to Nearest Item", Callback=teleportToNearestItem })
    TabMovement:CreateLabel("Teleports you to the nearest Medkit or Bloxy Cola")
end

-- ============================================================
--  UI – SPOOFER TAB (Universal)
-- ============================================================
do
    local currentDevice = LocalPlayer:GetAttribute("Device")
    if type(currentDevice) == "table" then currentDevice = currentDevice[1] end
    currentDevice = tostring(currentDevice or "PC")
    TabSpoofer:CreateSection("Device Spoofing")
    TabSpoofer:CreateDropdown({ Name="Spoof Device", Options={"PC","Mobile","Console"}, CurrentOption=currentDevice, MultipleOptions=false, Flag="DeviceSpoof",
        Callback=function(selected)
            local device = selected[1]
            local success = false
            local lastError = ""
            local attempts = {
                function() testRemote:FireServer("SetDevice", device) end,
                function() testRemote:FireServer("SetDevice", {device}) end,
                function() testRemote:FireServer({["Device"] = device}) end,
                function() testRemote:FireServer(device) end,
                function() testRemote:FireServer("UpdateDevice", device) end,
                function() testRemote:FireServer("ChangeDevice", device) end,
                function() testRemote:FireServer(LocalPlayer.Name .. "SetDevice", device) end,
                function() testRemote:FireServer("UpdateSettings", "Device", device) end,
                function() testRemote:FireServer({["SetDevice"] = device}) end,
            }
            for i, func in ipairs(attempts) do
                local ok, err = pcall(func)
                if ok then success = true; break else lastError = err end
            end
            if success then
                Rayfield:Notify({ Title="Spoofer", Content="Device set to " .. device, Duration=2 })
                LocalPlayer:SetAttribute("Device", device)
            else
                Rayfield:Notify({ Title="Spoofer Error", Content="All remote attempts failed. Use manual override below.", Duration=4 })
                warn("Spoofer errors:", lastError)
            end
        end })
    TabSpoofer:CreateSection("Manual Override")
    TabSpoofer:CreateButton({ Name="Set Attribute: PC", Callback=function()
        LocalPlayer:SetAttribute("Device", "PC")
        Rayfield:Notify({ Title="Spoofer", Content="Device attribute set to PC", Duration=2 })
    end })
    TabSpoofer:CreateButton({ Name="Set Attribute: Mobile", Callback=function()
        LocalPlayer:SetAttribute("Device", "Mobile")
        Rayfield:Notify({ Title="Spoofer", Content="Device attribute set to Mobile", Duration=2 })
    end })
    TabSpoofer:CreateButton({ Name="Set Attribute: Console", Callback=function()
        LocalPlayer:SetAttribute("Device", "Console")
        Rayfield:Notify({ Title="Spoofer", Content="Device attribute set to Console", Duration=2 })
    end })
    TabSpoofer:CreateButton({ Name="Check Current Device", Callback=function()
        local attr = LocalPlayer:GetAttribute("Device")
        Rayfield:Notify({ Title="Device Attribute", Content=tostring(attr), Duration=3 })
    end })
end

-- ============================================================
--  UI – AIMBOT TAB (Pizza Aimbot + Killer Aimbot)
-- ============================================================
do
    -- Elliot Pizza Aimbot section
    TabAimbot:CreateSection("Elliot Pizza Aimbot")
    TabAimbot:CreateToggle({ Name="Pizza Aimbot Enabled", CurrentValue=false, Flag="PizzaAimbotEnabled",
        Callback=function(v)
            aimbot.enabled = v
            if v then
                Rayfield:Notify({ Title="Pizza Aimbot", Content="Enabled", Duration=2 })
            else
                if aimbot.autoRotateBackup ~= nil and aimbot.humanoid then
                    aimbot.humanoid.AutoRotate = aimbot.autoRotateBackup
                    aimbot.autoRotateBackup = nil
                end
                Rayfield:Notify({ Title="Pizza Aimbot", Content="Disabled", Duration=2 })
            end
        end })
    TabAimbot:CreateToggle({ Name="Require Throw Animation", CurrentValue=true, Flag="AimbotRequireAnim",
        Callback=function(v) aimbot.requireAnimation = v end })
    TabAimbot:CreateSlider({ Name="Aim Duration After Throw", Range={0.1,2}, Increment=0.1, CurrentValue=0.5, Suffix="seconds", Flag="AimbotDuration",
        Callback=function(v) aimbot.throwDuration = v end })
    TabAimbot:CreateLabel("Network Ping: " .. (function()
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        return math.floor(ping) .. " ms"
    end)())
    TabAimbot:CreateLabel("• No prediction – locks onto current position")
    TabAimbot:CreateLabel("• Character lock only – camera unaffected")
    TabAimbot:CreateLabel("• Throw pizza → locks onto nearest survivor")
    TabAimbot:CreateLabel("• Auto‑restores rotation after throw ends")

    -- Killer Ability Aimbot section (added)
    TabAimbot:CreateSection("Killer Ability Aimbot")
    TabAimbot:CreateToggle({
        Name = "Enable Killer Aimbot",
        CurrentValue = false,
        Flag = "KillerAimbotEnabled",
        Callback = function(v)
            Killer.enabled = v
            if not v then killerStopAiming() end
        end
    })
    TabAimbot:CreateSlider({
        Name = "Ability Cooldown (seconds)",
        Range = {0.1, 1},
        Increment = 0.05,
        CurrentValue = 0.3,
        Suffix = "s",
        Flag = "KillerAbilityCooldown",
        Callback = function(v) Killer.cooldown = v end
    })
    TabAimbot:CreateButton({
        Name = "🔍 Force Lock Nearest Survivor",
        Callback = function()
            if not Killer.humanoid or not Killer.hrp then
                Rayfield:Notify({ Title="Error", Content="No character", Duration=2 })
                return
            end
            local target = killerFindNearestSurvivor()
            if target then
                killerStartAiming(target)
                Rayfield:Notify({ Title="Locked", Content="Aiming at "..target.Parent.Name, Duration=2 })
            else
                Rayfield:Notify({ Title="No Target", Content="No survivors found", Duration=2 })
            end
        end
    })
    TabAimbot:CreateButton({
        Name = "🛑 Stop Aiming",
        Callback = killerStopAiming
    })
    TabAimbot:CreateLabel("• Auto‑aims on Q/E/R/abilities when playing as killer")
    TabAimbot:CreateLabel("• Smooth rotation, zero lag")
end

-- ============================================================
--  UI – TWO TIME TAB (LOADER)
-- ============================================================
do
    TabTwoTime:CreateSection("Two Time UI Loader")
    TabTwoTime:CreateButton({
        Name = "▶️ LOAD TWO TIME UI",
        Callback = function()
            Rayfield:Notify({ Title="Two Time", Content="Loading Two Time UI...", Duration=2 })
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://pastebin.com/raw/YgUVVvSK"))()
            end)
            if success then
                Rayfield:Notify({ Title="Two Time", Content="✅ Loaded successfully!", Duration=3 })
            else
                Rayfield:Notify({ Title="Error", Content="Failed to load Two Time UI", Duration=4 })
                warn("Two Time load error:", err)
            end
        end
    })
    TabTwoTime:CreateLabel("Click to load the lightweight Two Time UI")
    TabTwoTime:CreateLabel("(includes its own Back to Main button)")
end

-- ============================================================
--  UI – SETTINGS TAB
-- ============================================================
do
    TabSettings:CreateSection("UI Settings")
    TabSettings:CreateButton({ Name="Close UI", Callback=function()
        Window:Destroy(); Rayfield:Destroy()
    end })
    TabSettings:CreateLabel("Press RightShift to toggle GUI")

    TabSettings:CreateSection("Performance Tuning")
    TabSettings:CreateSlider({ Name="Punch Scan Rate (s)", Range={0.05,0.5}, Increment=0.05, CurrentValue=0.1, Flag="PunchScanRate",
        Callback=function(v) PUNCH_SCAN_RATE = v end })
    TabSettings:CreateSlider({ Name="Aim Scan Rate (s)", Range={0.05,0.5}, Increment=0.05, CurrentValue=0.1, Flag="AimScanRate",
        Callback=function(v) AIM_SCAN_RATE = v end })
    TabSettings:CreateSlider({ Name="HDT Scan Rate (s)", Range={0.05,0.5}, Increment=0.05, CurrentValue=0.15, Flag="HDTScanRate",
        Callback=function(v) HDT_SCAN_RATE = v end })
    TabSettings:CreateSlider({ Name="Lock Scan Rate (s)", Range={0.05,0.5}, Increment=0.05, CurrentValue=0.1, Flag="LockScanRate",
        Callback=function(v) LOCK_SCAN_RATE = v end })
    TabSettings:CreateLabel("⬆ Raise rates to improve FPS on weak devices")
end

-- ============================================================
--  SAFE INITIALIZATION
-- ============================================================
task.spawn(function()
    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    task.wait(1)
    task.spawn(setupSoundHooks)
    refreshAnimator()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    task.spawn(setupSoundHooks)
    refreshAnimator()
    if veerIsSk8Active then veerStopSk8Override() end
    veerSavedHumanoid = {}
    if autoTrickEnabled then stopAutoTrickManager(); startAutoTrickManager() end
end)

-- ============================================================
--  WELCOME NOTIFICATION
-- ============================================================
task.wait(1)
Rayfield:Notify({
    Title   = "lovesaken v3.7",
    Content = "lovesaken V3.7 loaded (Killer Aimbot added)",
    Duration= 5
})
