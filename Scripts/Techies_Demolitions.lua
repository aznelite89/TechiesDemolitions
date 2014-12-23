
--<<Techies_Demolitions script by Zanko version 2.0>>
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
    =========== Version 2.0 ===========
     
    Description:
    ------------
        Useful information to plan your Techies strategies (Detailed information can be found in the forum images)
    Changelog:
    ----------
        Version 2.0 - 23rd December 2014:
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
        Version 1.0 - 6th December 2014:
            Added simple calculation for Techies land mines, remote mines and suicide.
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
config:Load()



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

local heroInfoPanel = {}
local upLandMine = false
local upRemoteMine = false
local upSuicide = false
local effect = {}
effect.Range = {}
effect.Visible = {}
local screenResolution = client.screenSize
local F10 = drawMgr:CreateFont("F10", "Arial", 0.0125 * screenResolution.y, 1)


function Tick( tick )

    if not PlayingGame() or client.console or not SleepCheck("stop") then return end
    

    local me = entityList:GetMyHero()
    enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO})
    
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
            MinesRangeDisplay()
            MinesVisibility()
            CalculateTechiesInformation()
        end
    end
end

function CalculateTechiesInformation()
    local me = entityList:GetMyHero()
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
                    if onRadiant and playerIconLocation < 5 then
                        local xIconOrigin = 0.273958
                        local xTextOrigin = 0.2842705
                        heroInfoPanel[playerIconLocation].landMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation), drawFromTopRatio, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
                        heroInfoPanel[playerIconLocation].landMineIcon.visible = true
                        heroInfoPanel[playerIconLocation].landMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation), drawFromTopRatio, -1, "", F10)
                        heroInfoPanel[playerIconLocation].landMineText.visible = false
                        
                        heroInfoPanel[playerIconLocation].remoteMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation), drawFromTopRatio + 0.017, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
                        heroInfoPanel[playerIconLocation].remoteMineIcon.visible = true
                        heroInfoPanel[playerIconLocation].remoteMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation), drawFromTopRatio + 0.017, -1, "", F10)
                        heroInfoPanel[playerIconLocation].remoteMineText.visible = false
                        
                        heroInfoPanel[playerIconLocation].suicideIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation), drawFromTopRatio + 0.034, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
                        heroInfoPanel[playerIconLocation].suicideIcon.visible = true
                        heroInfoPanel[playerIconLocation].suicideText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation), drawFromTopRatio + 0.034, -1, "", F10)
                        heroInfoPanel[playerIconLocation].suicideText.visible = false
                        
                        heroInfoPanel[playerIconLocation].gemIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation), 0.0074, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].gemIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_gem")
                        heroInfoPanel[playerIconLocation].gemIcon.visible = false
                        
                        heroInfoPanel[playerIconLocation].sentryIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation), 0.0074 + 0.015, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].sentryIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_sentry")
                        heroInfoPanel[playerIconLocation].sentryIcon.visible = false
                        
                    elseif not onRadiant and playerIconLocation > 4 then
                        local xIconOrigin = 0.5546875
                        local xTextOrigin = 0.565
                        heroInfoPanel[playerIconLocation].landMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - 5), drawFromTopRatio, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
                        heroInfoPanel[playerIconLocation].landMineIcon.visible = true
                        heroInfoPanel[playerIconLocation].landMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - 5), drawFromTopRatio, -1, "", F10)
                        heroInfoPanel[playerIconLocation].landMineText.visible = false
                        
                        heroInfoPanel[playerIconLocation].remoteMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - 5), drawFromTopRatio + 0.017, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
                        heroInfoPanel[playerIconLocation].remoteMineIcon.visible = true
                        heroInfoPanel[playerIconLocation].remoteMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - 5), drawFromTopRatio + 0.017, -1, "", F10)
                        heroInfoPanel[playerIconLocation].remoteMineText.visible = false
                        
                        heroInfoPanel[playerIconLocation].suicideIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - 5), drawFromTopRatio + 0.034, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
                        heroInfoPanel[playerIconLocation].suicideIcon.visible = true
                        heroInfoPanel[playerIconLocation].suicideText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - 5), drawFromTopRatio + 0.034, -1, "", F10)
                        heroInfoPanel[playerIconLocation].suicideText.visible = false
                        
                        heroInfoPanel[playerIconLocation].gemIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - 5), 0.0074, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[playerIconLocation].gemIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_gem")
                        heroInfoPanel[playerIconLocation].gemIcon.visible = false
                        
                        heroInfoPanel[playerIconLocation].sentryIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - 5), 0.0074 + 0.015, 0.0078125, 0.01388, 0x00000095)
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
                    end
                end
                
                if ShowSentry and  heroInfoPanel[playerIconLocation].sentryIcon ~= nil then
                    local sentryCheck = heroInfo:FindItem("item_ward_sentry")
                    if sentryCheck then
                        heroInfoPanel[playerIconLocation].sentryIcon.visible = true
                    end
                end
            end
        end
    end

end

function MinesRangeDisplay()
    local mines = entityList:GetEntities({classId = CDOTA_NPC_TechiesMines})
    local me = entityList:GetMyHero()
    for i,v in ipairs(mines) do
        if v.team == me.team then            
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
    local mines = entityList:GetEntities({classId = CDOTA_NPC_TechiesMines})
    local me = entityList:GetMyHero()
    for i,v in ipairs(mines) do
        if v.team == me.team then            
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

function IsRadiant()
    local me = entityList:GetMyHero()
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

function EasyCreateFont(name, fontname, tallRatio, weight)
    return drawMgr:CreateFont(name, fontname, tallRatio * screenResolution.y, weight)
end

function EasyCreateText(xRatio, yRatio, color, text, font)
    return drawMgr:CreateText(xRatio * screenResolution.x, yRatio * screenResolution.y, color, text, font)
end

function EasyCreateRect(xRatio, yRatio, wRatio, hRatio, color)
    return drawMgr:CreateRect(xRatio * screenResolution.x, yRatio * screenResolution.y, wRatio * screenResolution.x, hRatio * screenResolution.y, color)
end


script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_CLOSE,GameClose)
