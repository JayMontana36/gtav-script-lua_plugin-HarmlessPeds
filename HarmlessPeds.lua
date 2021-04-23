--[[ Meticulously Crafted by JayMontana36 | This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. ]]





--[[ Config Area ]]
-- See HarmlessPeds.ini file





--[[ Script/Code Area ]]
local IsTriggerTrue
local NetworkIsPlayerActive, GetPlayerPed, GetPedNearbyPeds, NetworkHasControlOfEntity, NetworkRequestControlOfEntity, IsEntityDead, SetEntityHealth, RemoveAllPedWeapons
	= NetworkIsPlayerActive, GetPlayerPed, GetPedNearbyPeds, NetworkHasControlOfEntity, NetworkRequestControlOfEntity, IsEntityDead, SetEntityHealth, RemoveAllPedWeapons



local AiPeds, PlayerPeds, PlayerPed
local NearbyPeds, NearbyPedsNum
local ActivePlayers = {}

local HealthToSet, AlwaysActive, RunWhileHeld, MaxNearbyPeds, TriggerKey
return {
	init	=	function()
					local Config = configFileRead("HarmlessPeds.ini")
					local tonumber = tonumber
					HealthToSet = tonumber(Config.HealthToSet)
					AlwaysActive = Config.AlwaysActive == "true"
					RunWhileHeld = Config.RunWhileHeld == "true"
					if RunWhileHeld then IsTriggerTrue = IsControlPressed else IsTriggerTrue = IsControlJustPressed end
					MaxNearbyPeds = tonumber(Config.MaxNearbyPeds)
					TriggerKey = tonumber(Config.TriggerKey)
				end,
	loop	=	function()
					if AlwaysActive or IsTriggerTrue(0, TriggerKey) then
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