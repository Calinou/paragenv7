-- paragenv7 0.1.0 by paramat
-- For latest stable Minetest and back to 0.4.7
-- Depends default
-- Licenses: code WTFPL, textures CC BY-SA
-- TODO Add default:grass for wheat seeds
-- Make thin stone ledges stay as stone no unsupported sand / dirt

-- Variables

local ONGEN = true -- (true/false) Enable biome generation.
local PROG = true -- Print generation progress to terminal.

local SANDY = 2 -- 2 -- Sandline average y of beach top.
local SANDA = 4 -- 4 -- Sandline amplitude.
local SANDR = 2 -- 2 -- Sandline randomness.
local FMAV = 3 -- 3 -- Surface material average depth at sea level.
local FMAMP = 2 -- 2 -- Surface material depth amplitude.

local HITET = 0.25 -- 0.25 -- Desert / savanna / rainforest temperature noise threshold.
local LOTET = -0.55 -- -0.55 -- Tundra / taiga temperature noise threshold.
local HIWET = 0.25 -- 0.25 -- Wet grassland / rainforest wetness noise threshold.
local LOWET = -0.55 -- -0.55 -- Tundra / dry grassland / desert wetness noise threshold.

local TGRAD = 160 -- 160 -- Vertical temperature gradient. -- All 3 fall with altitude from y = 0
local HGRAD = 160 -- 160 -- Vertical humidity gradient.
local FMGRAD = 40 -- 40 -- Surface material thinning gradient.

local TUNGRACHA = 121 -- 121 -- Dry shrub 1/x chance per node in tundra.
local TAIPINCHA = 64 -- 64 -- Pine 1/x chance per node in taiga.
local DRYGRACHA = 2 -- 2 -- Dry shrub 1/x chance per node in dry grasslands.
local DECGRACHA = 9 -- 9 -- Default grasses 1/x chance per node in deciduous forest.
local DECAPPCHA = 64 -- 64 -- Appletree sapling 1/x chance per node in deciduous forest.
local WETGRACHA = 2 -- 2 -- Junglegrass 1/x chance per node in wet grasslands.
local DESCACCHA = 529 -- 529 -- Cactus 1/x chance per node in desert.
local DESGRACHA = 289 -- 289 -- Dry shrub 1/x chance per node in desert.
local SAVGRACHA = 3 -- 3 -- Dry shrub 1/x chance per node in savanna.
local SAVTRECHA = 361 -- 361 -- Savanna tree 1/x chance per node in savanna.
local RAIJUNCHA = 16 -- 16 -- Jungletree 1/x chance per node in rainforest.
local DUNGRACHA = 9 -- 9 -- Dry shrub 1/x chance per node in sand dunes.
local PAPCHA = 2 -- 2 -- Papyrus 1/x chance per node next to water in non-beach areas.

local PININT = 67 -- 67 -- Pine from sapling abm interval in seconds.
local PINCHA = 11 -- 11 -- 1/x chance per node.

local JUNINT = 71 -- 71 -- Jungletree from sapling abm interval in seconds.
local JUNCHA = 11 -- 11 -- 1/x chance per node.

local SAVINT = 73 -- 73 -- Jungletree from sapling abm interval in seconds.
local SAVCHA = 11 -- 11 -- 1/x chance per node.

-- 2D Perlin5 fine material depth and sandline
local perl5 = {
	SEED5 = 7028411255342,
	OCTA5 = 3, -- 
	PERS5 = 0.5, -- 
	SCAL5 = 256, -- 
}

-- 2D Perlin6 for temperature
local perl6 = {
	SEED6 = 72,
	OCTA6 = 3, -- 
	PERS6 = 0.5, -- 
	SCAL6 = 512, -- 
}

-- 2D Perlin7 for humidity
local perl7 = {
	SEED7 = 900011676,
	OCTA7 = 3, -- 
	PERS7 = 0.5, -- 
	SCAL7 = 512, -- 
}

-- Stuff

paragenv7 = {}

dofile(minetest.get_modpath("paragenv7").."/nodes.lua")
dofile(minetest.get_modpath("paragenv7").."/functions.lua")

local sandy
local fimadep2d
local noise
local noise6
local noise7
local temp
local hum

-- On generated function

if ONGEN then
	minetest.register_on_generated(function(minp, maxp, seed)
		if minp.y >= -32 and minp.y <= 208 then -- 4 chunks y = -112 to y = 207
			local perlin5 = minetest.get_perlin(perl5.SEED5, perl5.OCTA5, perl5.PERS5, perl5.SCAL5)
			local perlin6 = minetest.get_perlin(perl6.SEED6, perl6.OCTA6, perl6.PERS6, perl6.SCAL6)
			local perlin7 = minetest.get_perlin(perl7.SEED7, perl7.OCTA7, perl7.PERS7, perl7.SCAL7)
			local x1 = maxp.x
			local y1 = maxp.y
			local z1 = maxp.z
			local x0 = minp.x
			local y0 = minp.y
			local z0 = minp.z
			for x = x0, x1 do -- for each plane do
				if PROG then
					print ("[paragenv7] "..(x - x0 + 1).." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for z = z0, z1 do -- for each column do
					local surfy = 1024 -- stone top surface y (1024 = not yet found)
					local sol = true -- solid node above
					local col = false -- solid nodes in column
					local notre = false -- when solid nodes in column set tre = false at end of block
					local tre = true -- trees enabled for next surface
					local des = false -- desert biome
					local sav = false -- savanna biome
					local rai = false -- rainforest biome
					local wet = false -- wet grassland biome
					local dry = false -- dry grassland biome
					local dec = false -- deciduous forest biome
					local tun = false -- tundra biome
					local tai = false -- taiga forest biome
					for y = y1, y0, -1 do -- working downwards through column for each node do
						local watsur = false
						local stable = true
						local nodename = minetest.get_node({x=x,y=y,z=z}).name 
						local unodename = minetest.get_node({x=x,y=y-1,z=z}).name
						if nodename == "default:water_source" and y == 1 then
							watsur = true
						end
						if unodename == "air" then
							stable = false
						end
						if watsur or stable
						and (nodename == "default:stone"
						or nodename == "default:stone_with_coal"
						or nodename == "default:stone_with_iron"
						or nodename == "default:stone_with_copper") then
							if not col then -- when surface first found calculate sandy, fimadep2d, temp2d, hum2d for column
								local noise5c = perlin5:get2d({x=x-777,y=z-777}) -- beach top
								sandy = SANDY + noise5c * SANDA + math.random(0,SANDR)
								local noise5b = perlin5:get2d({x=x,y=z}) -- fine material depth
								fimadep2d = FMAV + noise5b * FMAMP
								noise6 = perlin6:get2d({x=x,y=z})
								noise7 = perlin7:get2d({x=x,y=z})
								col = true
								notre = true -- flag to set tree = false at end of block
							end
							local fimadep = fimadep2d - y / FMGRAD
							if not sol then -- if solid node under non-solid node then
								surfy = y -- most recent surface y recorded
								temp = noise6 - y / TGRAD -- decide / reset biome
								hum = noise7 - y / HGRAD
								if temp > HITET + math.random() / 10 then
									if hum > HIWET + math.random() / 10 then
										rai = true
									elseif hum < LOWET + math.random() / 10 then
										des = true
									else
										sav = true
									end
								elseif temp < LOTET + math.random() / 10 then
									if hum < LOWET + math.random() / 10 then
										tun = true
									else
										tai = true
									end
								elseif hum > HIWET + math.random() / 10 then
									wet = true
								elseif hum < LOWET + math.random() / 10 then
									dry = true
								else
									dec = true
								end
							end
							if surfy - y < fimadep and not watsur then -- if fine material not water then
								if y < sandy then -- if beach, lakebed or dunes
									minetest.add_node({x=x,y=y,z=z},{name="default:sand"})
									if not sol then
										if y > 3 and tre and math.random(DUNGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif tai and y > 0 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:snowblock"})
										elseif tun and y > 0 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:snow"})
										end
									end
								elseif des then -- if desert
									minetest.add_node({x=x,y=y,z=z},{name="default:desert_sand"})
									if not sol and tre and y > 8 then
										if math.random(DESGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif math.random(DESCACCHA) == 2 then
											for c = 1, math.random(1,6) do
												minetest.add_node({x=x,y=y+c,z=z},{name="default:cactus"})
											end
										end
									end
								elseif tun then -- if tundra
									minetest.add_node({x=x,y=y,z=z},{name="paragenv7:permafrost"})
									if not sol and y > 0 then
										if tre and math.random(TUNGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										else
											minetest.add_node({x=x,y=y+1,z=z},{name="default:snow"})
										end
									end
								elseif dry or sav then -- dry grassland or savanna
									if not sol then -- if surface node then
										minetest.add_node({x=x,y=y,z=z},{name="paragenv7:drygrass"})
										if dry and tre and y > 2 and math.random(DRYGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif sav and tre and y > 2 and math.random(SAVGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif sav and tre and y > -2 and math.random(SAVTRECHA) == 2 then
											paragenv7_stree({x=x,y=y+1,z=z})
										end
									else -- underground node
										minetest.add_node({x=x,y=y,z=z},{name="default:dirt"})
									end
								else -- wet grasslands, taiga, deciduous forest, rainforest
									if not sol then
										minetest.add_node({x=x,y=y,z=z},{name="default:dirt_with_grass"})
										if wet and tre and y > 0 and math.random(WETGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:junglegrass"})
										elseif dec and y > -2 and tre and math.random(DECAPPCHA) == 2 then
											paragenv7_atree({x=x,y=y+1,z=z})
										elseif tai then
											if tre and y > 2 and math.random(TAIPINCHA) == 2 then
												paragenv7_ptree({x=x,y=y+1,z=z})
											elseif y > 0 then
												minetest.add_node({x=x,y=y+1,z=z},{name="default:snowblock"})
											end
										elseif rai and y > -2 and tre and math.random(RAIJUNCHA) == 2 then
											paragenv7_jtree({x=x,y=y+1,z=z})
										end
									else
										minetest.add_node({x=x,y=y,z=z},{name="default:dirt"})
									end
								end
								if not sol and y == 1 and y >= sandy and (des or sav or rai or wet)
								and tre and math.random(PAPCHA) == 2 then -- papyrus
									minetest.add_node({x=x,y=y,z=z},{name="default:water_source"})
									for j = 1, math.random(2,5) do
										if minetest.get_node({x=x,y=y+j,z=z}).name == "air" then
											minetest.add_node({x=x,y=y+j,z=z},{name="default:papyrus"})
										end
									end
								end
							elseif watsur then -- if water surface then
								if temp < LOTET + math.random() / 10 then
									minetest.add_node({x=x,y=y,z=z},{name="default:ice"})
								end
							elseif not sol and y > 0 then -- else if rocky surface above water
								if tai then
									minetest.add_node({x=x,y=y+1,z=z},{name="default:snowblock"})
								elseif tun then
									minetest.add_node({x=x,y=y+1,z=z},{name="default:snow"})
								end
							end
							sol = true -- node above was solid
							if notre then -- if solid nodes found in column then
								tre = false -- disable trees below
							end
						else
							sol = false -- node above was not solid
						end
					end
				end	
			end		
		end			
	end)				
end