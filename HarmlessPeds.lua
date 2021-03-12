--[[ Meticulously Crafted by JayMontana36 | This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. ]]





--[[ Config Area ]]
local HealthToSet	= 100	--[[ 100 is the lowest possible value; any value lower than 100 will instantly kill the peds whenever this script runs. ]]
local AlwaysActive	= false	--[[ Set this to true if you want this script to always run regardless of the TriggerKey being pressed or not. ]]
local RunWhileHeld	= false --[[ Set this to true if you want this script to loop-run while the TriggerKey is being held down; Set this to false if you want this script to only run once for every one press of the TriggerKey ]]
local MaxNearbyPeds	= 32	--[[ Can be any integer number above 0. 32 is excessive in many cases (as far as I've tested) but works fine; there's no real need to change it. This number is per player; all peds near other players (that your game knows about) will be affected by this, which is ideal for (speedrunning) most missions, however may not work as great in freemode for other players unless you are either near or spectating the other players. ]]
local TriggerKey	= 223	--[[ 223	INPUT_SCRIPT_RDOWN	LEFT MOUSE BUTTON	A | Default TriggerKey; https://docs.fivem.net/docs/game-references/controls/ for alternate keys. ]]





--[[ Script/Code Area ]]
local PAD = CONTROLS--Added/Used due to FiveM differences, for people who are more familiar with FiveM Lua scripting than GTA V Lua Plugin Scripting, same with a lot of the natives below.

local IsControlPressed if RunWhileHeld then IsControlPressed = PAD.IS_CONTROL_PRESSED else IsControlPressed = PAD.IS_CONTROL_JUST_PRESSED end
local NetworkIsPlayerActive			= NETWORK.NETWORK_IS_PLAYER_ACTIVE
local GetPlayerPed					= PLAYER.GET_PLAYER_PED
local GetPedNearbyPeds				= PED.GET_PED_NEARBY_PEDS
local NetworkHasControlOfEntity		= NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY
local NetworkRequestControlOfEntity	= NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY
local IsEntityDead					= ENTITY.IS_ENTITY_DEAD
local SetEntityHealth				= ENTITY.SET_ENTITY_HEALTH
local RemoveAllPedWeapons			= WEAPON.REMOVE_ALL_PED_WEAPONS



local AiPeds, PlayerPeds, PlayerPed
local NearbyPeds, NearbyPedsNum
local ActivePlayers = {}

local HarmlessPeds =
{
	tick	=	function()
					if AlwaysActive or IsControlPressed(0, TriggerKey) then
						AiPeds, PlayerPeds = {}, {}
						
						for i=0,31 do
							ActivePlayers[i] = NetworkIsPlayerActive(i)
							if ActivePlayers[i] then
								PlayerPed = GetPlayerPed(i)
								ActivePlayers[i] = PlayerPed
								PlayerPeds[PlayerPed] = true
							end
						end
						
						for i=0,31 do
							if ActivePlayers[i] then
								NearbyPeds, NearbyPedsNum = GetPedNearbyPeds(ActivePlayers[i], MaxNearbyPeds, -1)
								for j=1,NearbyPedsNum do
									if not PlayerPeds[NearbyPeds[j]] then
										if not AiPeds[NearbyPeds[j]] then
											if NetworkHasControlOfEntity(NearbyPeds[j]) or NetworkRequestControlOfEntity(NearbyPeds[j]) then
												if not IsEntityDead(NearbyPeds[j]) then
													SetEntityHealth(NearbyPeds[j], HealthToSet)
													RemoveAllPedWeapons(NearbyPeds[j], true)
												end
												AiPeds[NearbyPeds[j]] = true
											end
										end
									end
								end
							end
						end
					end
				end
}

return HarmlessPeds