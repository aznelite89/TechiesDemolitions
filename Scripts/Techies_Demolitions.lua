
--<<Techies_Demolitions script by Zanko version 3.1>>
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
    =========== Version 3.1 ===========
     
    Description:
    ------------
        Useful information to plan your Techies strategies (Detailed information can be found in the forum images)
    
    Changelog:
    ----------
	Version 3.1 - 26th December 2014 5:55PM :
        - Clean some code
		- Update spell immunity/invulnerable list
		- Change bomb display, if target cannot be killed then display "MAX" instead of "#INF/#INF"
			
    Version 3.0 - 25th December 2014 12:10AM :
        - Clean code
        - Bomb will not auto detonate if the following modifier occurs 
            - modifier_puck_phase_shift"
            - modifier_storm_spirit_ball_lightning
            - modifier_morphling_waveform
            - modifier_brewmaster_primal_split
            - modifier_ember_spirit_sleight_of_fist_caster
            - modifier_phoenix_supernova_hiding
            - modifier_oracle_false_promise
            - modifier_phoenix_supernova_hiding
            - modifier_faceless_void_time_walk
            - modifier_faceless_void_time_walk_slow
            - modifier_obsidian_destroyer_astral_imprisonment_prison
            - modifier_shadow_demon_disruption
            - modifier_abaddon_borrowed_time
            - modifier_dazzle_shallow_grave
            - modifier_eul_cyclone
            - modifier_brewmaster_storm_cyclone
            
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

------- Draw Helper Function -----------
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
local bombInformationArray = {}
bombInformationArray.Damage = {}
effect.Range = {}
effect.Visible = {}

local F10 = EasyCreateFont("F10", "Arial", 0.0125, 1)
local F11 = EasyCreateFont("F11", "Arial", 0.01274074074074074, 550 * screenResolution.x)
local AllowSelfDetonateText  = EasyCreateText(0.0026041666666666665, 0.041666666666666664, -1, "", F11) 
AllowSelfDetonateText.visible = false


function Tick( tick )

    if not PlayingGame() or client.console or not SleepCheck("stop") then return end
    
    me = entityList:GetMyHero()

    if AllowSelfDetonate == false then
        AllowSelfDetonateText.text = "( ] ) Auto Detonate: OFF"
    else
        AllowSelfDetonateText.text = "( ] ) Auto Detonate: ON"
    end
    
    if not me or me.name ~= "npc_dota_hero_techies"  then
        print("This script is for Techies")
        script:Disable()
    else
		enemies = entityList:GetEntities({type = LuaEntity.TYPE_HERO})
		mines = entityList:GetEntities({classId = CDOTA_NPC_TechiesMines})
		AllowSelfDetonateText.visible = true
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
                MinesInformationDisplay()
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
    
    local xSpacing = 0.034375
    local drawFromTopRatio = 0.070
	local illusionCheck = true
	local meepos = entityList:GetEntities({type = LuaEntity.TYPE_MEEPO})
	
	
    for i = 1, #enemies do
        local heroInfo = enemies[i]
		if meepos ~= nil then
			if heroInfo.name == "npc_dota_hero_meepo" then
				if heroInfo.meepoIllusion then
					illusionCheck = true
				end
				local meepoUlt = heroInfo:GetAbility(4)
				heroInfo.meepoNumber = (meepoUlt:GetProperty("CDOTA_Ability_Meepo_DividedWeStand", "m_nWhichDividedWeStand") + 1)
			else
				heroInfo.meepoNumber = -1
				illusionCheck = heroInfo.illusion
			end
		end
		--print(illusionCheck)
        if illusionCheck == false then
            local uniqueIdentifier = heroInfo.handle
            local playerIconLocation = heroInfo.playerId
            if uniqueIdentifier ~= me.handle then
                if heroInfoPanel[uniqueIdentifier] == nil then 
                    heroInfoPanel[uniqueIdentifier] = {}
                    if playerIconLocation < 5 then
                        xIconOrigin = 0.273958
                        xTextOrigin = 0.2842705
                        playerOffset = 0
                    elseif playerIconLocation > 4 then
                        xIconOrigin = 0.5546875
                        xTextOrigin = 0.565
                        playerOffset = 5
                    end
                    if heroInfo.team ~= me.team and heroInfo.meepoNumber < 2 then
                        heroInfoPanel[uniqueIdentifier].landMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].landMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_land_mine")
                        heroInfoPanel[uniqueIdentifier].landMineIcon.visible = true
                        heroInfoPanel[uniqueIdentifier].landMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio, -1, "", F10)
                        heroInfoPanel[uniqueIdentifier].landMineText.visible = false
                        
                        heroInfoPanel[uniqueIdentifier].remoteMineIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.017, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].remoteMineIcon.textureId = drawMgr:GetTextureId("NyanUI/other/npc_dota_techies_remote_mine")
                        heroInfoPanel[uniqueIdentifier].remoteMineIcon.visible = true
                        heroInfoPanel[uniqueIdentifier].remoteMineText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.017, -1, "", F10)
                        heroInfoPanel[uniqueIdentifier].remoteMineText.visible = false
                        
                        heroInfoPanel[uniqueIdentifier].suicideIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.034, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].suicideIcon.textureId = drawMgr:GetTextureId("NyanUI/spellicons/techies_suicide")
                        heroInfoPanel[uniqueIdentifier].suicideIcon.visible = true
                        heroInfoPanel[uniqueIdentifier].suicideText = EasyCreateText(xTextOrigin + xSpacing * (playerIconLocation - playerOffset), drawFromTopRatio + 0.034, -1, "", F10)
                        heroInfoPanel[uniqueIdentifier].suicideText.visible = false
                        
                        heroInfoPanel[uniqueIdentifier].gemIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), 0.0074, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].gemIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_gem")
                        heroInfoPanel[uniqueIdentifier].gemIcon.visible = false
                        
                        heroInfoPanel[uniqueIdentifier].sentryIcon = EasyCreateRect(xIconOrigin + xSpacing * (playerIconLocation - playerOffset), 0.0074 + 0.015, 0.0078125, 0.01388, 0x00000095)
                        heroInfoPanel[uniqueIdentifier].sentryIcon.textureId = drawMgr:GetTextureId("NyanUI/other/O_sentry")
                        heroInfoPanel[uniqueIdentifier].sentryIcon.visible = false
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
                    heroInfoPanel[uniqueIdentifier].numberOfLandMineRequired = math.ceil(heroInfo.health / landMineDamageDeal) * aliveFlag
                    heroInfoPanel[uniqueIdentifier].maxLandMineRequired = math.ceil(heroInfo.maxHealth / landMineDamageDeal)
                    local landMineString = tostring(heroInfoPanel[uniqueIdentifier].numberOfLandMineRequired).." / "..tostring(heroInfoPanel[uniqueIdentifier].maxLandMineRequired)
                    if heroInfoPanel[uniqueIdentifier].landMineText ~= nil then
                        heroInfoPanel[uniqueIdentifier].landMineText.text = landMineString
                        heroInfoPanel[uniqueIdentifier].landMineText.visible = true
                    end
                end
                
                if upRemoteMine and remoteMineDamage ~= nil then
                    local remoteMineDamageDeal = (1 - heroInfo.magicDmgResist) * remoteMineDamage
					local remoteMineString = ""
                    
					if InvulnerableToRemoteMines(heroInfo) or heroInfo.magicDmgResist == 1 then
						heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired = math.ceil(heroInfo.health / 0) * aliveFlag
						heroInfoPanel[uniqueIdentifier].maxRemoteMineRequired = math.ceil(heroInfo.maxHealth / remoteMineDamageDeal)
						remoteMineString = ("MAX")
					else
						heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired = CalculateBombsRequired(heroInfo, remoteMineDamage, aliveFlag) 
						heroInfoPanel[uniqueIdentifier].maxRemoteMineRequired = math.ceil(heroInfo.maxHealth / remoteMineDamageDeal)
						remoteMineString = tostring(heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired).." / "..tostring(heroInfoPanel[uniqueIdentifier].maxRemoteMineRequired)
					end

                    if heroInfoPanel[uniqueIdentifier].remoteMineText ~= nil then
                        heroInfoPanel[uniqueIdentifier].remoteMineText.text = remoteMineString
                        heroInfoPanel[uniqueIdentifier].remoteMineText.visible = true
                    end
                end
                
                if upSuicide and suicideDamage ~= nil then
                    local suicideDamageDeal = (1 - heroInfo.dmgResist) * suicideDamage
                    if heroInfoPanel[uniqueIdentifier].suicideText ~= nil then
                        if heroInfo.alive then 
                            if suicideDamageDeal > heroInfo.health then
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "Yes"
                            else
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "No"
                            end
                        else 
                            if suicideDamageDeal > heroInfo.maxHealth then
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "Yes"
                            else
                                heroInfoPanel[uniqueIdentifier].suicideText.text = "No"
                            end
                        end
                        heroInfoPanel[uniqueIdentifier].suicideText.visible = true
                    end
                end
                if ShowGem and heroInfoPanel[uniqueIdentifier].gemIcon ~= nil then
                    local gemCheck = heroInfo:FindItem("item_gem")
                    if gemCheck then
                        heroInfoPanel[uniqueIdentifier].gemIcon.visible = true
                    else
                        heroInfoPanel[uniqueIdentifier].gemIcon.visible = false
                    end
                end
                
                if ShowSentry and  heroInfoPanel[uniqueIdentifier].sentryIcon ~= nil then
                    local sentryCheck = heroInfo:FindItem("item_ward_sentry")
                    if sentryCheck then
                        heroInfoPanel[uniqueIdentifier].sentryIcon.visible = true
                    else
                        heroInfoPanel[uniqueIdentifier].sentryIcon.visible = false
                    end
                end
				--print(heroInfo:DoesHaveModifier("modifier_brewmaster_primal_split"))
                if heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired ~= nil then
					bombCountArray = {}
                    if AllowSelfDetonate and numberOfBombsStepped(heroInfo) >= heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired and not InvulnerableToRemoteMines(heroInfo) then
                        SelfDetonate(heroInfoPanel[uniqueIdentifier].numberOfRemoteMineRequired)
                    end
                end
            end
        end
    end

end

function MinesInformationDisplay()
    for i,v in ipairs(mines) do
        if v.team == me.team then
			if bombInformationArray.Damage == nil then
				bombInformationArray.Damage = {}
			end
			
			if v.name == "npc_dota_techies_remote_mine" and bombInformationArray.Damage[v.handle] == nil then
					if me:FindItem("item_ultimate_scepter") then
						bombInformationArray.Damage[v.handle] = 150 * (me:GetAbility(6).level + 1) + 150
					else 
						bombInformationArray.Damage[v.handle] = 150 * (me:GetAbility(6).level + 1)
					end
			end
			
            if effect.Range == nil then
                    effect.Range = {}
            end
			if effect.Visible == nil then
                effect.Visible = {}
            end
            if v.alive then    
                if not effect.Range[v.handle] then
                    effect.Range[v.handle] = Effect(v,"range_display")
                    if v.name == "npc_dota_techies_land_mine" and ShowLandMineRange then
                        effect.Range[v.handle]:SetVector(1, Vector(200,0,0) )
                    elseif v.name == "npc_dota_techies_stasis_trap" and ShowStatisRange then
                        effect.Range[v.handle]:SetVector(1, Vector(450,0,0) )
                    elseif v.name == "npc_dota_techies_remote_mine" and ShowRemoteMineRange then
                        effect.Range[v.handle]:SetVector(1, Vector(425,0,0) )
                    end
                end
            else
                if  effect.Range[v.handle] then
                    effect.Range[v.handle] = nil
                    collectgarbage("collect")
                end
            end
			if v.alive and v.visibleToEnemy then    
                if not effect.Visible[v.handle] and ShowMineVisibility then
                    effect.Visible[v.handle] = Effect(v,"aura_shivas")
                    effect.Visible[v.handle]:SetVector(1, Vector(0,0,0) )
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
					--print(bombInformationArray.Damage[value.handle])
                    check = value.GetDistance2D(value, hero) < 425
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

--[[function isHeroInBombRange(x, y, center_x, center_y)
    if (math.pow((x - center_x),2) + math.pow((y - center_y), 2)) < math.pow(425, 2) then
        return true
    else
        return false
    end
end
]]
function CalculateBombsRequired (hero, bombDamage, alive)
	local remoteMineDamageDeal = (1 - hero.magicDmgResist) * bombDamage
	--[[if hero:DoesHaveModifier("modifier_medusa_mana_shield") then
		local medusaBlockArray = {1.6, 1.9, 2.2, 2.5}
		local damagePerMana = medusaBlockArray[hero:GetAbility(3).level]
		local bombCount = 0
		local haveHP = true
		local haveMP = true
		while haveHP or haveMP do
		remoteMineDamageDealToHP = (1 - hero.magicDmgResist) * bombDamage * 0.4 * bombCount
		remoteMineDamageDealToMP = (bombDamage * 0.6) * bombCount / damagePerMana
		hpLeft = hero.health - remoteMineDamageDealToHP
		mpLeft = hero.health - remoteMineDamageDealToMP
			if hpLeft < 0 then
				haveHP = false
			elseif mpLeft < 0 then
				haveMP = false
			else
				bombCount = bombCount + 1
			end
		end
		
		if haveHP == false and haveMP == true then
			return bombCount
		elseif haveHP == true and haveMP == false then
			return bombCount +  math.ceil(hpLeft / remoteMineDamageDeal)
		else
			return bombCount
		end
	end]]
	
	return math.ceil(hero.health / remoteMineDamageDeal) * alive
end

function InvulnerableToRemoteMines(hero)
    if  
		---- Invulnerability granted by being hidden ----
		hero:DoesHaveModifier("modifier_brewmaster_primal_split") or 
		hero:DoesHaveModifier("modifier_ember_spirit_sleight_of_fist_caster") or
		hero:DoesHaveModifier("modifier_juggernaut_omnislash") or
		hero:DoesHaveModifier("modifier_juggernaut_omnislash_invulnerability") or
		hero:DoesHaveModifier("modifier_life_stealer_infest") or
		hero:DoesHaveModifier("modifier_phoenix_supernova_hiding") or
		hero:DoesHaveModifier("modifier_puck_phase_shift") or
		hero:DoesHaveModifier("modifier_tusk_snowball_movement") or
		---- Invulnerability granted by disables ----
		hero:DoesHaveModifier("modifier_bane_nightmare_invulnerable") or
		hero:DoesHaveModifier("modifier_brewmaster_storm_cyclone") or
		hero:DoesHaveModifier("modifier_eul_cyclone") or
		hero:DoesHaveModifier("modifier_shadow_demon_disruption") or
		hero:DoesHaveModifier("modifier_invoker_tornado") or
		hero:DoesHaveModifier("modifier_obsidian_destroyer_astral_imprisonment_prison") or
		---- Invulnerability granted by blink ----
		hero:DoesHaveModifier("modifier_ember_spirit_fire_remnant") or
		hero:DoesHaveModifier("modifier_faceless_void_time_walk") or
		hero:DoesHaveModifier("modifier_morphling_waveform") or
		hero:DoesHaveModifier("modifier_storm_spirit_ball_lightning") or
		hero:DoesHaveModifier("modifier_rattletrap_hookshot") or -- not invulnerable but too fast to detonate
		---- Invulnerability granted by spell ----
		hero:DoesHaveModifier("modifier_medusa_stone_gaze") or
		hero:DoesHaveModifier("modifier_naga_siren_song_of_the_siren") or
		hero:DoesHaveModifier("modifier_oracle_false_promise") or
		hero:DoesHaveModifier("modifier_dazzle_shallow_grave") or
		hero:DoesHaveModifier("modifier_abaddon_borrowed_time") or
		---- Invulnerability granted by mirror image ----
		hero:DoesHaveModifier("modifier_chaos_knight_phantasm") or
		hero:DoesHaveModifier("modifier_naga_siren_mirror_image") or
		---- Spell Immunity ----
		hero:DoesHaveModifier("modifier_huskar_life_break_charge") or
		--hero:DoesHaveModifier("modifier_item_black_king_bar") or
		hero:DoesHaveModifier("modifier_omniknight_repel") or
		hero:DoesHaveModifier("modifier_life_stealer_rage") or
		hero:DoesHaveModifier("modifier_juggernaut_blade_fury") or
		hero:DoesHaveModifier("modifier_omniknight_repel") then
        return true
    else
        return false
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

