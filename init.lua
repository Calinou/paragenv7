-- paragenv7 0.1.0 by paramat
-- For Minetest 0.4.7 stable
-- Depends default
-- Licenses: Code WTFPL. Textures: CC BY-SA

-- Variables

local ONGEN = true

local SANDY = 3 -- Sandline average y of beach top.
local SANDA = 5 --  -- Sandline amplitude.
local SANDR = 2 --  -- Sandline randomness.
local FMAV = 3 --  -- Surface material average depth at sea level.
local FMAMP = 2 --  -- Surface material depth amplitude.

local HITET = 0.35 --  -- Desert / savanna / rainforest temperature noise threshold.
local LOTET = -0.45 --  -- Tundra / taiga temperature noise threshold.
local HIWET = 0.35 --  -- Wet grassland / rainforest wetness noise threshold.
local LOWET = -0.45 --  -- Tundra / dry grassland / desert wetness noise threshold.

local TGRAD = 160 -- 160 -- Vertical temperature gradient. -- All 3 fall with altitude from y = 0
local HGRAD = 160 -- 160 -- Vertical humidity gradient.
local FMGRAD = 160 -- 160 -- Surface material thinning gradient.

local TUNGRACHA = 121 --  -- Dry shrub 1/x chance per node in tundra.
local TAIPINCHA = 49 --  -- Pine 1/x chance per node in taiga.
local DRYGRACHA = 2 -- 2 -- Dry shrub 1/x chance per node in dry grasslands.
local DECAPPCHA = 64 --  -- Appletree sapling 1/x chance per node in deciduous forest.
local WETGRACHA = 2 -- 2 -- Junglegrass 1/x chance per node in wet grasslands.
local DESCACCHA = 529 --  -- Cactus 1/x chance per node in desert.
local DESGRACHA = 289 --  -- Dry shrub 1/x chance per node in desert.
local SAVGRACHA = 3 -- 3 -- Dry shrub 1/x chance per node in savanna.
local SAVTRECHA = 361 --  -- Savanna tree 1/x chance per node in savanna.
local RAIJUNCHA = 16 --  -- Jungletree 1/x chance per node in rainforest.
local DUNGRACHA = 9 --  -- Dry shrub 1/x chance per node in dunes.
local PAPCHA = 2 -- 2 -- Papyrus 1/x chance per node next to water.

-- 3D Perlin5 fine material depth, sandline
local perl5 = {
	SEED5 = 7028411255342,
	OCTA5 = 2, -- 
	PERS5 = 0.5, -- 
	SCAL5 = 512, -- 
}

-- 2D Perlin6 for temperature
local perl6 = {
	SEED6 = 72,
	OCTA6 = 2, -- 
	PERS6 = 0.5, -- 
	SCAL6 = 512, -- 
}

-- 2D Perlin7 for humidity
local perl7 = {
	SEED7 = 900011676,
	OCTA7 = 2, -- 
	PERS7 = 0.5, -- 
	SCAL7 = 512, -- 
}

-- Stuff

paragenv7 = {}

dofile(minetest.get_modpath("paragenv7").."/nodes.lua")

-- Functions

-- Jungletree function

local function paragenv7_jtree(pos)
	local t = 12 + math.random(5) -- trunk height
	for j = -3, t do
		if j == math.floor(t * 0.7) or j == t then
			for i = -2, 2 do
			for k = -2, 2 do
				local absi = math.abs(i)
				local absk = math.abs(k)
				if math.random() > (absi + absk) / 24 then
					minetest.add_node({x=pos.x+i,y=pos.y+j+math.random(0, 1),z=pos.z+k},{name="default:jungleleaves"})
				end
			end
			end
		end
		minetest.add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:jungletree"})
	end
end

-- Savanna tree function

local function paragenv7_stree(pos)
	local t = 4 + math.random(2) -- trunk height
	for j = -2, t do
		if j == t then
			for i = -3, 3 do
			for k = -3, 3 do
				local absi = math.abs(i)
				local absk = math.abs(k)
				if math.random() > (absi + absk) / 24 then
					minetest.add_node({x=pos.x+i,y=pos.y+j+math.random(0, 1),z=pos.z+k},{name="paragenv7:sleaf"})
				end
			end
			end
		end
		minetest.add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
	end
end

-- Pine tree function

local function paragenv7_pine(pos)
	local t = 10 + math.random(3) -- trunk height
	for i = -2, 2 do
	for k = -2, 2 do
		local absi = math.abs(i)
		local absk = math.abs(k)
		if absi >= absk then
			j = t - absi
		else
			j = t - absk
		end
		if math.random() > (absi + absk) / 24 then
			minetest.add_node({x=pos.x+i,y=pos.y+j+2,z=pos.z+k},{name="default:snow"})
			minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="paragenv7:pleaf"})
			minetest.add_node({x=pos.x+i,y=pos.y+j-1,z=pos.z+k},{name="default:snow"})
			minetest.add_node({x=pos.x+i,y=pos.y+j-2,z=pos.z+k},{name="paragenv7:pleaf"})
			minetest.add_node({x=pos.x+i,y=pos.y+j-4,z=pos.z+k},{name="default:snow"})
			minetest.add_node({x=pos.x+i,y=pos.y+j-5,z=pos.z+k},{name="paragenv7:pleaf"})
		end
	end
	end
	for j = -3, t do
		minetest.add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
	end
end

-- On generated function

if ONGEN then
	minetest.register_on_generated(function(minp, maxp, seed)
		if minp.y >= -100 and minp.y <= 500 then
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
				print ("[paragen] "..(x - x0 + 1).." ("..minp.x.." "..minp.y.." "..minp.z..")")
				for z = z0, z1 do -- for each column do
					local stony = 1000 -- stone y found
					local sol = true -- solid node above
					local des = false -- desert biome
					local sav = false -- savanna biome
					local rai = false -- rainforest biome
					local wet = false -- wet grassland biome
					local dry = false -- dry grassland biome
					local dec = false -- deciduous forest biome
					local tun = false -- tundra biome
					local tai = false -- taiga forest biome
					local noise5c = perlin5:get2d({x=x-777,y=z-777}) -- beach top
					local sandy = SANDY + noise5c * SANDA + math.random(SANDR)
					for y = y1, y0, -1 do -- working downwards through column for each node do
						local noise5b = perlin5:get2d({x=x+777,y=z+777}) -- fine material depth
						local fimadep = math.floor(FMAV + noise5b * FMAMP - y / FMGRAD)
						local nodename = minetest.get_node({x=x,y=y,z=z}).name 
						if nodename == "default:stone" or nodename == "default:stone_with_coal" 
						or nodename == "default:stone_with_iron" then
							if not sol then -- if stone under non-solid node
								stony = y -- most recent surface y recorded
								local noise6 = perlin6:get2d({x=x,y=z}) -- decide / reset biome
								local noise7 = perlin7:get2d({x=x,y=z})
								local temp = noise6 - y / TGRAD
								local hum = noise7 - y / HGRAD
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
							if stony - y <= fimadep then -- if fine material then
								if y <= sandy then -- if beach or dunes
									minetest.add_node({x=x,y=y,z=z},{name="default:sand"})
									if not sol then
										if y > 4 and math.random(DUNGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif y == 1 and (sav or rai or wet) and math.random(PAPCHA) == 2 then -- papyrus
											minetest.add_node({x=x,y=y,z=z},{name="default:water_source"})
											for p = 1, math.random(2,5) do
												minetest.add_node({x=x,y=y+p,z=z},{name="default:papyrus"})
											end
										elseif tai and y > 0 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:snowblock"})
										elseif tun and y > 0 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:snow"})
										end
									end
								elseif des then -- if desert
									minetest.add_node({x=x,y=y,z=z},{name="default:desert_sand"})
									if not sol then
										if y > 16 and math.random(DESGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif y > 16 and math.random(DESCACCHA) == 2 then
											for c = 1, math.random(1,6) do
												minetest.add_node({x=x,y=y+c,z=z},{name="default:cactus"})
											end
										end
									end
								elseif tun then -- if tundra
									minetest.add_node({x=x,y=y,z=z},{name="paragenv7:permafrost"})
									if not sol and y > 0 then
										if math.random(TUNGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										else
											minetest.add_node({x=x,y=y+1,z=z},{name="default:snow"})
										end
									end
								elseif dry or sav then -- dry grassland or savanna
									if not sol then -- if surface node then
										minetest.add_node({x=x,y=y,z=z},{name="paragenv7:drygrass"})
										if dry and y > 0 and math.random(DRYGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif sav and y > 0 and math.random(SAVGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
										elseif sav and math.random(SAVTRECHA) == 2 then
											paragenv7_stree({x=x,y=y+1,z=z})
										end
									else -- underground node
										minetest.add_node({x=x,y=y,z=z},{name="default:dirt"})
									end
								else -- wet grasslands, taiga, deciduous forest, rainforest
									if not sol then
										minetest.add_node({x=x,y=y,z=z},{name="default:dirt_with_grass"})
										if wet and y > 0 and math.random(WETGRACHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:junglegrass"})
										elseif dec and y > sandy and math.random(DECAPPCHA) == 2 then
											minetest.add_node({x=x,y=y+1,z=z},{name="default:sapling"})
										elseif tai then
											if math.random(TAIPINCHA) == 2 then
												paragenv7_pine({x=x,y=y+1,z=z})
											elseif y > 0 then
												minetest.add_node({x=x,y=y+1,z=z},{name="default:snowblock"})
											end
										elseif rai and math.random(RAIJUNCHA) == 2 then
											paragenv7_jtree({x=x,y=y+1,z=z})
										end
									else
										minetest.add_node({x=x,y=y,z=z},{name="default:dirt"})
									end
								end
							elseif y == 1 and (tun or tai) then
								minetest.add_node({x=x,y=y,z=z},{name="default:ice"})
							end
						else
							sol = false
						end
					end
				end	
			end		
		end			
	end)				
end