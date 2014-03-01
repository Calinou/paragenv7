-- paragenv7 0.2.0 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- Licenses: code WTFPL, textures CC BY-SA

-- Parameters

local DEPTH = 5 -- 

local HITET = 0.5 --
local LOTET = -0.5 -- 
local ICETET = -0.8 -- 
local HIHUT = 0.5 -- 
local MIDHUT = 0 -- 
local LOHUT = -0.5 --

local PINCHA = 47 -- Pine tree 1/x chance per surface node
local APTCHA = 47 -- Appletree
local FLOCHA = 47 -- Flower
local FOGCHA = 9 -- Forest grass
local GRACHA = 3 -- Grassland grasses
local JUTCHA = 16 -- Jungletree
local JUGCHA = 9 -- Junglegrass
local CACCHA = 841 -- Cactus
local DRYCHA = 169 -- Dry shrub
local PAPCHA = 2 -- Papyrus
local ACACHA = 841 -- Acacia tree
local GOGCHA = 3 -- Golden grass

-- 2D noise for temperature

local np_temp = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

-- 2D noise for humidity

local np_humid = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = -5500,
	octaves = 3,
	persist = 0.5
}

-- 2D noise for dirt / sand depth, sandline

local np_depth = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = 886611390,
	octaves = 3,
	persist = 0.6
}

-- Stuff

paragenv7 = {}

dofile(minetest.get_modpath("paragenv7").."/nodes.lua")
dofile(minetest.get_modpath("paragenv7").."/functions.lua")

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y < -32 or minp.y > 208 then
		return
	end
	
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[paragenv7] chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_air = minetest.get_content_id("air")
	local c_sand = minetest.get_content_id("default:sand")
	local c_desertsand = minetest.get_content_id("default:desert_sand")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_ice = minetest.get_content_id("default:ice")
	local c_dirtsnow = minetest.get_content_id("default:dirt_with_snow")
	local c_jungrass = minetest.get_content_id("default:junglegrass")
	local c_dryshrub = minetest.get_content_id("default:dry_shrub")
	local c_clay = minetest.get_content_id("default:clay")
	local c_stone = minetest.get_content_id("default:stone")
	local c_stonecopper = minetest.get_content_id("default:stone_with_copper")
	local c_stoneiron = minetest.get_content_id("default:stone_with_iron")
	local c_stonecoal = minetest.get_content_id("default:stone_with_coal")
	local c_water = minetest.get_content_id("default:water_source")
	
	local c_pg7dirt = minetest.get_content_id("paragenv7:dirt")
	local c_pg7grass = minetest.get_content_id("paragenv7:grass")
	local c_pg7drygrass = minetest.get_content_id("paragenv7:drygrass")
	local c_pg7permafrost = minetest.get_content_id("paragenv7:permafrost")
	local c_pg7goldengrass = minetest.get_content_id("paragenv7:goldengrass")
	
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local minposxz = {x=x0, y=z0}
	
	local nvals_temp = minetest.get_perlin_map(np_temp, chulens):get2dMap_flat(minposxz)
	local nvals_humid = minetest.get_perlin_map(np_humid, chulens):get2dMap_flat(minposxz)
	local nvals_depth = minetest.get_perlin_map(np_depth, chulens):get2dMap_flat(minposxz)
	
	local nixz = 1
	for z = z0, z1 do
	for x = x0, x1 do -- for each column do
		local n_temp = nvals_temp[nixz]
		local n_humid = nvals_humid[nixz]
		local biome = false -- select biome for column
		if n_temp < LOTET then
			if n_humid < MIDHUT then
				biome = 1 -- tundra
			else
				biome = 2 -- taiga
			end
		elseif n_temp > HITET then
			if n_humid < LOHUT then
				biome = 6 -- desert
			elseif n_humid > HIHUT then
				biome = 8 -- rainforest
			else
				biome = 7 -- savanna
			end
		else
			if n_humid < LOHUT then
				biome = 3 -- dry grassland
			elseif n_humid > HIHUT then
				biome = 5 -- deciduous forest
			else
				biome = 4 -- grassland
			end
		end
		
		local stodep = 0 -- number of consecutive stone nodes
		local lasurfy = 0 -- last surface y
		local open = true -- open to sky?
		local primed = false -- surface addition primed by non-solid node?
		for y = y1, y0, -1 do -- working down each column for each node do
			local vi = area:index(x, y, z)
			local nodid = data[vi]
			if y ~= y0
			and (nodid == c_stone
			or nodid == c_stonecopper
			or nodid == c_stoneiron
			or nodid == c_stonecoal) then
				if stodep == 0 and y ~= y1 then -- if stone below air or water
					lasurfy = y
				end
				stodep = stodep + 1
			elseif nodid == c_air or nodid == c_water or y == y0 then
				if nodid == c_water and y == 1 and n_temp < ICETET then -- ice
					data[vi] = c_ice
				end
				
				if primed and lasurfy >= 5 and stodep >= 3 then
					local acdirtdep = math.min(stodep - 2, 5)
					for y = lasurfy, lasurfy - acdirtdep + 1, -1 do -- fine materials
						local vi = area:index(x, y, z)
						if y == lasurfy then -- surface nodes
							if biome == 1 or biome == 3 or biome == 7 then
								data[vi] = c_pg7drygrass
							elseif biome == 2 then
								data[vi] = c_dirtsnow
							elseif biome == 6 then
								data[vi] = c_desertsand
							else
								data[vi] = c_pg7grass
							end
						else -- under surface
							if biome == 6 then
								data[vi] = c_desertsand
							elseif biome == 1 then
								data[vi] = c_pg7permafrost
							else
								data[vi] = c_pg7dirt
							end
						end
					end
					if open then -- add flora / snow
						local y = lasurfy + 1
						local vi = area:index(x, y, z)
						if biome == 1 then
							if math.random(DRYCHA) == 2 then
								data[vi] = c_dryshrub
							end
						elseif biome == 2 then
							if math.random(PINCHA) == 2 then
								paragenv7_pinetree(x, y, z, area, data)
							else
								data[vi] = c_snowblock
							end
						elseif biome == 3 then
							if math.random(GRACHA) == 2 then
								if math.random(5) == 2 then
									data[vi] = c_pg7goldengrass
								else
									data[vi] = c_dryshrub
								end
							end
						elseif biome == 4 then
							if math.random(FLOCHA) == 2 then
								paragenv7_flower(data, vi)
							elseif math.random(GRACHA) == 2 then
								if math.random(11) == 2 then
									data[vi] = c_pg7goldengrass
								else
									paragenv7_grass(data, vi)
								end
							end
						elseif biome == 5 then
							if math.random(APTCHA) == 2 then
								paragenv7_appletree(x, y, z, area, data)
							elseif math.random(FLOCHA) == 2 then
								paragenv7_flower(data, vi)
							elseif math.random(FOGCHA) == 2 then
								paragenv7_grass(data, vi)
							end
						elseif biome == 6 then
							if math.random(CACCHA) == 2 then
								paragenv7_cactus(x, y, z, area, data)
							elseif math.random(DRYCHA) == 2 then
								data[vi] = c_dryshrub
							end
						elseif biome == 7 then
							if math.random(ACACHA) == 2 then
								paragenv7_acaciatree(x, y, z, area, data)
							elseif math.random(GOGCHA) == 2 then
								data[vi] = c_pg7goldengrass
							end
						elseif biome == 8 then
							if math.random(JUTCHA) == 2 then
								paragenv7_jungletree(x, y, z, area, data)
							elseif math.random(JUGCHA) == 2 then
								data[vi] = c_jungrass
							end
						end
					end
					open = false
					primed = false
				elseif primed and lasurfy < 5 and stodep >= 3 then -- sand
					local acsanddep = math.min(stodep - 2, 5)
					for y = lasurfy, lasurfy - acsanddep + 1, -1 do
						local vi = area:index(x, y, z)
						data[vi] = c_sand
					end
					open = false
					primed = false
				elseif nodid == c_air or nodid == c_water then
					primed = true
				end
				stodep = 0
			end
		end
		nixz = nixz + 1
	end	
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[paragenv7] "..chugent.." ms")			
end)	