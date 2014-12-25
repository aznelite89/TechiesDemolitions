
--<<Techies_Demolitions script by Zanko version 2.2>>
--[[

             _.-^^---....,,--
         _--                  --_
        <                        >)
        |                         |
         \._                   _./
            ```--. . , ; .--'''
                  | |   |
               .-=||  | |=-.
               `-=#$%&%$#=-'
                  | ;  :|
         _____.,-#%&$@%#&#~,._____  
    -------------------------------------
    | Techies_Demolitions Script by Zanko |
    -------------------------------------
    =========== Version 2.2 ===========
     
    Description:
    ------------
        Useful information to plan your Techies strategies (Detailed information can be found in the forum images)
    
    Changelog:
    ----------
        Version 2.2b - 24th December 2014 8:00PM :
            - Fixed sentry/gem display bug
            
        Version 2.2 - 24th December 2014 4:58PM :
            - Added Toggle key for auto detonation
            - Fixed bug regarding remote mines and land mines interaction
            - Moved helper function EasyDraw to the top
            
        Version 2.1b - 24th December 2014 10:38AM:
            - Clean duplications of code
            - Fixed bug of not able to initialize script
            
        Version 2.1 - 24th December 2014 01:38AM:
            - Added Self_Detonation Function (BETA)
            - Self Detonation now bomb minimum number of bombs (Efficient)
            
        Version 2.0 - 23rd December 2014 07:12PM:
            - Added bomb visibility
            - Added bomb range
            - Added gem display to the hero panel
            - Added sentry display to the hero panel
            - Fixed reloading script error
            - Added EasyCreateFont(), EasyCreateRect() and EasyCreateText() function for easy drawing
            - Update bomb display info (Bomb will now display both current and Max bomb)
            - Push down the bomb information to avoid blocking the death timer
            - Script will now disabled if Techies is not picked
            - Put on GitHub
            
        Version 1.0 - 6th December 2014 10:28AM:
            - Added simple calculation for Techies land mines, remote mines and suicide.
]]--
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("ShowMineRequired", true)
config:SetParameter("ShowLandMineRange", false)
config:SetParameter("ShowStatisRange", false)
config:SetParameter("ShowRemoteMineRange", true)
config:SetParameter("ShowMineVisibility", true)
config:SetParameter("ShowGem", true)
config:SetParameter("ShowSentry", true)
config:SetParameter("Active", 221, config.TYPE_HOTKEY) -- "]"
config:Load()

------- Helper Function -----------
local screenResolution = client.screenSize

function EasyCreateFont(name, fontname, tallRatio, weight)
    return drawMgr:CreateFont(name, fontname, tallRatio * screenResolution.y, weight)
end

function EasyCreateText(xRatio, yRatio, color, text, font)
    return drawMgr:CreateText(xRatio * screenResolution.x, yRatio * screenResolution.y, color, text, font)
end

function EasyCreateRect(xRatio, yRatio, wRatio, hRatio, color)
    return drawMgr:CreateRect(xRatio * screenResolution.x, yRatio * screenResolution.y, wRatio * screenResolution.x, hRatio * screenResolution.y, color)
end
-------- Initialize Variables --------

local landMineDamage = 0
local remoteMineDamage = 0
local ShowMineRequired = config.ShowMineRequired
local ShowLandMineRange = config.ShowLandMineRange
local ShowStatisRange = config.ShowStatisRange
local ShowRemoteMineRange = config.ShowRemoteMineRange
local ShowMineVisibility = config.ShowMineVisibility
local ShowGem = config.ShowGem
local ShowSentry = config.ShowSentry

local toggleCommand = config.Active
local AllowSelfDetonate = true
local heroInfoPanel = {}
local upLandMine = false
local upRemoteMine = false
local upSuicide = false
local effect = {}
local bombCountArray = {}
effect.Range = {}
effect.Visible = {}

local F10 = EasyCreateFont("F10", "Arial", 0.0125, 1)
local F11 = EasyCreateFont("F11", "Arial", 0.01274074074074074, 550 * screenResolution.x)
local AllowSelfDetonateText  = EasyCreateText(0.0026041666666666665, 0.041666666666666664, -1, "", F11) 
AllowSelfDetonateText.visible = false


function Tick( tick )

    if not PlayingGame() or client.console or not SleepCheck("stop") then return end
    
    me = entityList:GetMyHero()
    enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO})
    mines = entityList:GetEntities({classId = CDOTA_NPC_TechiesMines})
    
    AllowSelfDetonateText.visible = true
    if AllowSelfDetonate == false then
        AllowSelfDetonateText.text = "( ] ) Auto Detonate: OFF"
    else
        AllowSelfDetonateText.text = "( ] ) Auto Detonate: ON"
    end
    
    if not me or me.name ~= "npc_dota_hero_techies"  then
        print("This script is for Techies")
        script:Disable()
    else 
        local scepterCheck = me:FindItem("item_ultimate_scepter")
        
        --Obtain Techies' Land Mines Damage
        if me:GetAbility(1).level ~= 0 then
            local landMineDamageArray = {300, 375, 450, 525}
            landMineDamage = landMineDamageArray[me:GetAbility(1).level]
            upLandMine = true
        end
        
        --Obtain Techies' Remote Mines Damage
        if me:GetAbility(6).level ~= 0 then
            local remoteMineDamageArray = {300, 450, 600}
            if scepterCheck then
                remoteMineDamage = remoteMineDamageArray[me:GetAbility(6).level] + 150
            else 
                remoteMineDamage = remoteMineDamageArray[me:GetAbility(6).level]
            end
            upRemoteMine = true
        end
        
        if me:GetAbility(3).level ~= 0 then
            local suicideDamageArray = {500, 650, 850, 1150}
            upSuicide = true
            suicideDamage = suicideDamageArray[me:GetAbility(3).level]
        end
        
        if ShowMineRequired then
            if mines ~= nil then
                MinesRangeDisplay()
                MinesVisibility()
            end
            CalculateTechiesInformation()
        end
    end
end

function Key(msg,code)
    if client.chat then return end
    if msg == KEY_DOWN then
        if code == toggleCommand then
            AllowSelfDetonate = not AllowSelfDetonate
        end
    end
end

function CalculateTechiesInformation()
    
    local onRadiant = IsRadiant()
    local xSpacing = 0.034375
    local drawFromTopRatio = 0.070
    for i = 1, #enemies do
        local heroInfo = enemies[i]
        if not heroInfo.illusion then
            local uniqueIdentifier = heroInfo.handle
            local playerIconLocation = heroInfo.playerId
            if uniqueIdentifier ~= me.handle then
                if heroInfoPanel[playerIconLocation] == nil then 
                    heroInfoPanel[playerIconLocation] = {}
                    if playerIconLocation < 5 then
                        xIconOrigin = 0.273958
                        xTextOrigin = 0.2842705
                        playerOffset = 0
                    elseif playerIconLocation > 4 then
                        xIconOrigin = 0.5546875
                        xTextOrigin = 0.565
                        playerOffset = 5
                    end
                    if heroInfo.team ~= me.team then
                        heroInfoPanel[playerIconLocation].landMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
                        heroInfoPanel[playerIconLocation].landMineIcon.visible = true
                        heroInfoPanel[playerIconLocation].landMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio, -1, "", F10)
                        heroInfoPanel[playerIconLocation].landMineText.visible = false
                        
                        heroInfoPanel[playerIconLocation].remoteMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.017, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
                        heroInfoPanel[playerIconLocation].remoteMineIcon.visible = true
                        heroInfoPanel[playerIconLocation].remoteMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.017, -1, "", F10)
                        heroInfoPanel[playerIconLocation].remoteMineText.visible = false
                        
                        heroInfoPanel[playerIconLocation].suicideIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.034, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
                        heroInfoPanel[playerIconLocation].suicideIcon.visible = true
                        heroInfoPanel[playerIconLocation].suicideText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.034, -1, "", F10)
                        heroInfoPanel[playerIconLocation].suicideText.visible = false
                        
                        heroInfoPanel[playerIconLocation].gemIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), 0.0074, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].gemIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_gem")
                        heroInfoPanel[playerIconLocation].gemIcon.visible = false
                        
                        heroInfoPanel[playerIconLocation].sentryIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), 0.0074 + 0.015, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].sentryIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_sentry")
                        heroInfoPanel[playerIconLocation].sentryIcon.visible = false
                    end
                end
                ------------------------------------------- CALCULATIONS -------------------------------------------
                
                if heroInfo.alive then
                    aliveFlag = 1
                else
                    aliveFlag = 0
                end

                if upLandMine and landMineDamage ~= nil then
                    local landMineDamageDeal = (1 - heroInfo.dmgResist) * landMineDamage
                    heroInfoPanel[playerIconLocation].numberOfLandMineRequired = math.ceil(heroInfo.health / landMineDamageDeal) * aliveFlag
                    heroInfoPanel[playerIconLocation].maxLandMineRequired = math.ceil(heroInfo.maxHealth / landMineDamageDeal)
                    local landMineString = tostring(heroInfoPanel[playerIconLocation].numberOfLandMineRequired).." / "..tostring(heroInfoPanel[playerIconLocation].maxLandMineRequired)
                    if heroInfoPanel[playerIconLocation].landMineText ~= nil then
                        heroInfoPanel[playerIconLocation].landMineText.text = landMineString
                        heroInfoPanel[playerIconLocation].landMineText.visible = true
                    end
                end
                
                if upRemoteMine and remoteMineDamage ~= nil then
                    local remoteMineDamageDeal = (1 - heroInfo.magicDmgResist) * remoteMineDamage
                    heroInfoPanel[playerIconLocation].numberOfRemoteMineRequired = math.ceil(heroInfo.health / remoteMineDamageDeal) * aliveFlag
                    heroInfoPanel[playerIconLocation].maxRemoteMineRequired = math.ceil(heroInfo.maxHealth / remoteMineDamageDeal)
                    local remoteMineString = tostring(heroInfoPanel[playerIconLocation].numberOfRemoteMineRequired).." / "..tostring(heroInfoPanel[playerIconLocation].maxRemoteMineRequired)
                    if heroInfoPanel[playerIconLocation].remoteMineText ~= nil then
                        heroInfoPanel[playerIconLocation].remoteMineText.text = remoteMineString
                        heroInfoPanel[playerIconLocation].remoteMineText.visible = true
                    end
                end
                
                if upSuicide and suicideDamage ~= nil then
                    local suicideDamageDeal = (1 - heroInfo.dmgResist) * suicideDamage
                    if heroInfoPanel[playerIconLocation].suicideText ~= nil then
                        if heroInfo.alive then 
                            if suicideDamageDeal > heroInfo.health then
                                heroInfoPanel[playerIconLocation].suicideText.text = "Yes"
                            else
                                heroInfoPanel[playerIconLocation].suicideText.text = "No"
                            end
                        else 
                            if suicideDamageDeal > heroInfo.maxHealth then
                                heroInfoPanel[playerIconLocation].suicideText.text = "Yes"
                            else
                                heroInfoPanel[playerIconLocation].suicideText.text = "No"
                            end
                        end
                        heroInfoPanel[playerIconLocation].suicideText.visible = true
                    end
                end
                if ShowGem and heroInfoPanel[playerIconLocation].gemIcon ~= nil then
                    local gemCheck = heroInfo:FindItem("item_gem")
                    if gemCheck then
                        heroInfoPanel[playerIconLocation].gemIcon.visible = true
                    else
                        heroInfoPanel[playerIconLocation].gemIcon.visible = false
                    end
                end
                
                if ShowSentry and  heroInfoPanel[playerIconLocation].sentryIcon ~= nil then
                    local sentryCheck = heroInfo:FindItem("item_ward_sentry")
                    if sentryCheck then
                        heroInfoPanel[playerIconLocation].sentryIcon.visible = true
                    else
                        heroInfoPanel[playerIconLocation].sentryIcon.visible = false
                    end
                end

                if heroInfoPanel[playerIconLocation].numberOfRemoteMineRequired ~= nil then
                    bombCountArray = {}
                    if AllowSelfDetonate and numberOfBombsStepped(heroInfo) >= heroInfoPanel[playerIconLocation].numberOfRemoteMineRequired then
                        SelfDetonate(heroInfoPanel[playerIconLocation].numberOfRemoteMineRequired)
                    end
                end
            end
        end
    end

end

function MinesRangeDisplay()
    for i,v in ipairs(mines) do
        if v.team == me.team then     
            if effect.Range == nil then
                    effect.Range = {}
            end
            if v.alive then    
                if not effect.Range[v.handle] then
                    effect.Range[v.handle] = Effect(v,"range_display")
                    if v.name == "npc_dota_techies_land_mine" and ShowLandMineRange then
                        effect.Range[v.handle]:SetVector( 1, Vector(200,0,0) )
                    elseif v.name == "npc_dota_techies_stasis_trap" and ShowStatisRange then
                        effect.Range[v.handle]:SetVector( 1, Vector(450,0,0) )
                    elseif v.name == "npc_dota_techies_remote_mine" and ShowRemoteMineRange then
                        effect.Range[v.handle]:SetVector( 1, Vector(425,0,0) )
                    end
                end
            else
                if  effect.Range[v.handle] then
                    effect.Range[v.handle] = nil
                    collectgarbage("collect")
                end
            end
                
        end
    end
end

function MinesVisibility()
    for i,v in ipairs(mines) do
        if v.team == me.team then
            if effect.Visible == nil then
                effect.Visible = {}
            end
            if v.alive and v.visibleToEnemy then    
                if not effect.Visible[v.handle] and ShowMineVisibility then
                    effect.Visible[v.handle] = Effect(v,"aura_shivas")
                    effect.Visible[v.handle]:SetVector( 1, Vector(0,0,0) )
                end
            else
                if  effect.Visible[v.handle] then
                    effect.Visible[v.handle] = nil
                    collectgarbage("collect")
                end
            end
                
        end
    end
end


function numberOfBombsStepped(hero)
    local countBomb = 0
    for j,value in ipairs(mines) do
        if value.team == me.team then
            if hero.team ~= me.team and hero.alive then
                if value.alive and value.name == "npc_dota_techies_remote_mine" then    
                    check = isHeroInBombRange(hero.position.x, hero.position.y, value.position.x, value.position.y)
                    if check then
                        bombCountArray[value.handle] = true
                        countBomb = countBomb + 1
                    end
                end
            else
                return -1
            end
        end
    end
    return countBomb
end

function SelfDetonate(bombNeeded)
    local count = 0
    for j,value in ipairs(mines) do
        if bombCountArray[value.handle] == true then
            bombCountArray[value.handle] = false
            if count < bombNeeded then
                count = count + 1
                if value.name == "npc_dota_techies_remote_mine" then
                    value:CastAbility(value:GetAbility(1))
                end
                
            end
        end
    end
end

function isHeroInBombRange(x, y, center_x, center_y)
    if (math.pow((x - center_x),2) + math.pow((y - center_y), 2)) < math.pow(425, 2) then
        return true
    else
        return false
    end
end

function IsRadiant()
    local teamIndicator = me.team
    if teamIndicator == 2 then -- If I'm on Radiant, true    
        return false
    elseif teamIndicator == 3 then -- If I'm not on Radiant, false
        return true
    end
end

function GameClose()
    landMineDamage = 0
    remoteMineDamage = 0
    heroInfoPanel = {}
    upLandMine = false
    upRemoteMine = false
    upSuicide = false
    effect = {}
    collectgarbage("collect")
end




script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_KEY,Key)

