print("Hello Vanilla World!")

frame = CreateFrame("Frame", "MyFrame", UIParent, "BackdropTemplate")

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 1)

frame:SetPoint("TOPLEFT")  -- Placering (centreret på skærmen)
frame:SetSize(UIParent:GetWidth(), 55)

-- widget scripts
frame:SetScript("OnEnter", function()
	GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT")
	GameTooltip:AddLine("HelloWorld!")
	GameTooltip:Show()
end)
frame:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

local hpBar = CreateFrame("StatusBar", nil, frame)
hpBar:SetPoint("LEFT", frame, "LEFT", 10, 0)
hpBar:SetSize(100, 20)
hpBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
hpBar:SetStatusBarColor(0, 1, 0, 1)
hpBar:SetMinMaxValues(0, 100)
hpBar:SetValue(100)

local manaBar = CreateFrame("StatusBar", nil, frame)
manaBar:SetPoint("LEFT", hpBar, "RIGHT", 30, 0)
manaBar:SetSize(100, 20)
manaBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
manaBar:SetStatusBarColor(0, 0.8, 1, 1)
manaBar:SetMinMaxValues(0, 100)
manaBar:SetValue(100)

-- Register events
frame:RegisterEvent("UNIT_HEALTH")
--frame:RegisterEvent("UNIT_POWER")
frame:RegisterEvent("UNIT_MAXHEALTH")
frame:RegisterEvent("UNIT_MAXPOWER")

-- Event handler
frame:SetScript("OnEvent", function(self, event, unit)
  if unit ~= "player" then return end -- Only update for the player

  if event == "UNIT_HEALTH" then
    local cur = UnitHealth("player")
    local max = UnitHealthMax("player")
    hpBar:SetMinMaxValues(0, max)
    hpBar:SetValue(cur)

  end
end)


-- Combat-indikator bar
local combatBar = CreateFrame("Frame", nil, frame)
combatBar:SetSize(50, 20)  -- Juster størrelse efter behov
combatBar:SetPoint("LEFT", manaBar, "RIGHT", 30, 0)
combatBar.texture = combatBar:CreateTexture(nil, "BACKGROUND")
combatBar.texture:SetAllPoints(combatBar)
combatBar.texture:SetColorTexture(1, 1, 1, 1)  -- Hvid som default

-- Registrér combat events
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Håndter combat events
frame:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        combatBar.texture:SetColorTexture(1, 0, 0, 1)  -- Rød i combat
    elseif event == "PLAYER_REGEN_ENABLED" then
        combatBar.texture:SetColorTexture(1, 1, 1, 1)  -- Hvid uden combat
    end
end)

-- Level
local LevelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
LevelText:SetPoint("LEFT", combatBar, "RIGHT", 30, 0)
LevelText:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
LevelText:SetTextColor(1, 1, 0)  -- gul tekst
-- Zone
local ZoneText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZoneText:SetPoint("LEFT", LevelText, "RIGHT", 30, 0)
ZoneText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
ZoneText:SetTextColor(0, 1, 1)
-- Coordinates
local CoordinatesText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
CoordinatesText:SetPoint("LEFT", ZoneText, "RIGHT", 30, 0)
CoordinatesText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
CoordinatesText:SetTextColor(1, 0, 1)
CoordinatesText:SetSize(150,10)

frame:SetScript("OnUpdate", function(self, elapsed)
    local zone = GetZoneText() or "Ukendt"
    local subzone = GetSubZoneText() or "Ukendt"
    local level = UnitLevel("player") or "??"
    local map = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(map, "player")
    local x, y = position:GetXY()
    LevelText:SetText(level)
    ZoneText:SetText(zone.."  /  "..subzone)
    CoordinatesText:SetText(string.format("%.3f %.3f", x*100, y*100))

    local cur = UnitPower("player", 0) -- Get current mana
    local max = UnitPowerMax("player", 0) -- Get max mana
    manaBar:SetMinMaxValues(0, max)
    manaBar:SetValue(cur)
end)

-- Target

-- Target Level
local TargetLevelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
TargetLevelText:SetPoint("LEFT", CoordinatesText, "RIGHT", 30, 0)
TargetLevelText:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
TargetLevelText:SetTextColor(1, 1, 0)  -- gul tekst
TargetLevelText:SetSize(50,30)

local function UpdateTargetLevel()
    local level = UnitLevel("target")
    if level < 0 then level = "??" end
    TargetLevelText:SetText(level)
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateTargetLevel()
    end
end)

local targetText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
targetText:SetPoint("LEFT", TargetLevelText, "RIGHT", 30, 0)
targetText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
targetText:SetTextColor(1, 1, 1)
targetText:SetSize(150,100)
targetText:SetText("No Target")

-- Target indikator (10x10 pixels)
local targetIndicator = CreateFrame("Frame", nil, frame)
targetIndicator:SetSize(30, 30)
targetIndicator:SetPoint("LEFT", targetText, "RIGHT", 5, 0)
targetIndicator.texture = targetIndicator:CreateTexture(nil, "BACKGROUND")
targetIndicator.texture:SetAllPoints(targetIndicator)
targetIndicator.texture:SetColorTexture(1, 1, 1, 1)

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        local tName = UnitName("target")
        if tName then
            targetText:SetText(tName)
            if UnitIsDead("target") then
                targetIndicator.texture:SetColorTexture(1, 0, 1)  -- grå, hvis død
            else
                local reaction = UnitReaction("target", "player")
                if reaction then
                    if reaction >= 5 then
                        targetIndicator.texture:SetColorTexture(0, 1, 0, 1)  -- grøn
                    elseif reaction == 4 then
                        targetIndicator.texture:SetColorTexture(1, 1, 0, 1)  -- gul
                    else
                        targetIndicator.texture:SetColorTexture(1, 0, 0, 1)  -- rød
                    end
                else
                    if UnitIsEnemy("player", "target") then
                        targetIndicator.texture:SetColorTexture(1, 0, 0, 1)
                    else
                        targetIndicator.texture:SetColorTexture(0, 1, 0, 1)
                    end
                end
            end
        else
            targetText:SetText("No Target")
            targetIndicator.texture:SetColorTexture(1, 1, 1, 1)
        end
    end
end)


-- Opret firkant (errorSquare) ved siden af targetIndicator
-- Opret tekstfelt (errorText) ved siden af errorSquare
local errorText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
errorText:SetPoint("LEFT", targetIndicator, "RIGHT", 15, 0)
errorText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
errorText:SetText("Error Msg: ")
errorText:SetSize(100, 30)
local errorSquare = CreateFrame("Frame", nil, frame)
errorSquare:SetSize(30, 30)
errorSquare:SetPoint("LEFT", errorText, "RIGHT", 45, 0)
errorSquare.texture = errorSquare:CreateTexture(nil, "BACKGROUND")
errorSquare.texture:SetAllPoints(errorSquare)
errorSquare.texture:SetColorTexture(1, 1, 1, 1)


-- Definér timer-variabler
local errorDisplayTime = 0.5
local errorTimer = 0
local errorActive = false

-- Sæt OnUpdate på frame (i stedet for errorText)
frame:HookScript("OnUpdate", function(self, elapsed)
    if errorActive then
        errorTimer = errorTimer - elapsed
        if errorTimer <= 0 then
            errorText:SetText("")
            errorSquare.texture:SetColorTexture(0, 1, 0, 1)  -- Skift til grøn
            errorActive = false
        end
    end
end)

hooksecurefunc(UIErrorsFrame, "AddMessage", function(self, text, red, green, blue, holdTime)
    if text and text:find("You are too far away!") then
        errorText:SetText("Too far away!")
        errorText:SetTextColor(1, 0, 0.5, 1)  -- Magenta-rød
        errorSquare.texture:SetColorTexture(1, 0, 0.5, 1)
        errorTimer = errorDisplayTime
        errorActive = true
    elseif text and text:find("You are too far away!") then
        errorText:SetText("Too far away!")
        errorText:SetTextColor(1, 0, 0.5, 1)  -- Magenta-rød
        errorSquare.texture:SetColorTexture(1, 0, 0.5, 1)
        errorTimer = errorDisplayTime
        errorActive = true
    elseif text and text:find("Target needs to be in front of you") then
        errorText:SetText("Target not in front!")
        errorText:SetTextColor(0, 1, 1, 1)  -- Klar cyan
        errorSquare.texture:SetColorTexture(0, 1, 1, 1)
        errorTimer = errorDisplayTime
        errorActive = true
    elseif text and text:find("You are facing the wrong way!") then
        errorText:SetText("Wrong facing!")
        errorText:SetTextColor(1, 0.6, 0.6, 1)  -- Lys rød
        errorSquare.texture:SetColorTexture(1, 0.6, 0.6, 1)
        errorTimer = errorDisplayTime
        errorActive = true
    elseif text and text:find("Spell is not ready yet") then
        errorText:SetText("Spell not ready!")
        errorText:SetTextColor(1, 0.4, 0, 1)  -- Vivid orange-rød
        errorSquare.texture:SetColorTexture(1, 0.4, 0, 1)
        errorTimer = errorDisplayTime
        errorActive = true
    elseif text and text:find("Not enough mana") then
        errorText:SetText("Not enough mana!")
        errorText:SetTextColor(0.7, 0, 1, 1)  -- Lys lilla
        errorSquare.texture:SetColorTexture(0.7, 0, 1, 1)
        errorTimer = errorDisplayTime
        errorActive = true
    end
end)







-- Gør rammen flytbar (valgfrit)
--frame:SetMovable(true)
--frame:EnableMouse(true)
--frame:RegisterForDrag("LeftButton")
--frame:SetScript("OnDragStart", frame.StartMoving)
--frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
