-- Parameters

local YSAV = 4 -- Average sandline y, dune grasses above this
local SAMP = 3 -- Sandline amplitude
local BERGDEP = 16 -- Maximum iceberg depth

local HITET = 0.35 -- High temperature threshold
local LOTET = -0.35 -- Low ..
local ICETET = -0.7 -- Ice ..
local HIHUT = 0.35 -- High humidity threshold
local LOHUT = -0.35 -- Low ..
local BLEND = 0.02 -- Biome blend randomness

local PINCHA = 1 / 49 -- Pine tree 1/x chance per surface node
local APTCHA = 1 / 49 -- Appletree max chance
local FLOCHA = 1 / 529 -- Flower
local GRACHA = 1 / 25 -- Grasses
local JUTCHA = 1 / 16 -- Jungletree
local JUGCHA = 1 / 9 -- Junglegrass
local CACCHA = 1 / 841 -- Cactus
local DRYCHA = 1 / 121 -- Dry shrub
local ACACHA = 1 / 841 -- Acacia tree
local GOGCHA = 1 / 4 -- Golden savanna grass
local PAPCHA = 1 / 4 -- Papyrus
local DUGCHA = 1 / 9 -- Dune grass

-- 2D noise for temperature

local np_temp = {
	offset = 0,
	scale = 1,
	spread = {x=2048, y=2048, z=2048},
	seed = 9130,
	octaves = 3,
	persist = 0.33
}

-- 2D noise for humidity

local np_humid = {
	offset = 0,
	scale = 1,
	spread = {x=2048, y=2048, z=2048},
	seed = -5500,
	octaves = 3,
	persist = 0.33
}

-- 2D noise for flora / sandline / icesheet depth

local np_flora = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=384, z=384},
	seed = 777001,
	octaves = 3,
	persist = 0.6
}

-- Do files

dofile(minetest.get_modpath("paragenv7").."/nodes.lua")
dofile(minetest.get_modpath("paragenv7").."/functions.lua")

-- Clear mgv5/mgv7 biomes and decorations

minetest.clear_registered_biomes()
minetest.clear_registered_decorations()

-- Set "nolight", calculate light after chunk generation only

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({flags = "nolight"})
end)

-- Initialize noise objects to nil

local nobj_temp = nil
local nobj_humid = nil
local nobj_flora = nil

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y < -32 or minp.y > 448 then
		return
	end
	
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_air = minetest.get_content_id("air")
	local c_water = minetest.get_content_id("default:water_source")
	local c_stone = minetest.get_content_id("default:stone")
	local c_desertstone = minetest.get_content_id("default:desert_stone")
	local c_stonecopper = minetest.get_content_id("default:stone_with_copper")
	local c_stoneiron = minetest.get_content_id("default:stone_with_iron")
	local c_stonecoal = minetest.get_content_id("default:stone_with_coal")
	local c_dirt = minetest.get_content_id("default:dirt")
	local c_sand = minetest.get_content_id("default:sand")
	local c_desertsand = minetest.get_content_id("default:desert_sand")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_ice = minetest.get_content_id("default:ice")
	local c_dirtsnow = minetest.get_content_id("default:dirt_with_snow")
	local c_clay = minetest.get_content_id("default:clay")
	local c_gravel = minetest.get_content_id("default:gravel")
	local c_jungrass = minetest.get_content_id("default:junglegrass")
	local c_dryshrub = minetest.get_content_id("default:dry_shrub")
	
	local c_pg7dirt = minetest.get_content_id("paragenv7:dirt")
	local c_pg7grass = minetest.get_content_id("paragenv7:grass")
	local c_pg7drygrass = minetest.get_content_id("paragenv7:drygrass")
	local c_pg7permafrost = minetest.get_content_id("paragenv7:permafrost")
	local c_pg7goldengrass = minetest.get_content_id("paragenv7:goldengrass")
	
	local chunksize = x1 - x0 + 1
	local pmapsize = {x = chunksize, y = chunksize, z = 1}
	local pmapminpxz = {x = x0, y = z0}
	
	nobj_temp = nobj_temp or minetest.get_perlin_map(np_temp, pmapsize)
	nobj_humid = nobj_humid or minetest.get_perlin_map(np_humid, pmapsize)
	nobj_flora = nobj_flora or minetest.get_perlin_map(np_flora, pmapsize)
	
	local nvals_temp = nobj_temp:get2dMap_flat(pmapminpxz)
	local nvals_humid = nobj_humid:get2dMap_flat(pmapminpxz)
	local nvals_flora = nobj_flora:get2dMap_flat(pmapminpxz)
	
	local nixz = 1
	for z = z0, z1 do
	for x = x0, x1 do -- for each column do
		local n_temp = nvals_temp[nixz] -- select biome
		local n_humid = nvals_humid[nixz]
		local biome = false
		if n_temp < LOTET - math.random() * BLEND then
			if n_humid < LOHUT - math.random() * BLEND then
				biome = 1 -- tundra
			elseif n_humid > HIHUT + math.random() * BLEND then
				biome = 3 -- taiga
			else
				biome = 2 -- snowplains
			end
		elseif n_temp > HITET + math.random() * BLEND then
			if n_humid < LOHUT - math.random() * BLEND then
				biome = 7 -- desert
			elseif n_humid > HIHUT + math.random() * BLEND then
				biome = 9 -- rainforest
			else
				biome = 8 -- savanna
			end
		else
			if n_humid < LOHUT - math.random() * BLEND then
				biome = 4 -- dry grassland
			elseif n_humid > HIHUT + math.random() * BLEND then
				biome = 6 -- deciduous forest
			else
				biome = 5 -- grassland
			end
		end
		
		local n_flora = nvals_flora[nixz]
		local n_absflora = math.abs(n_flora)
		local sandy = YSAV + n_flora * SAMP + math.random(0, 1) -- sandline
		local bergdep = n_absflora * BERGDEP -- iceberg depth
		local open = true -- open to sky?
		local solid = true -- solid node above?
		local water = false -- water node above?
		local surfy = y1 + 80 -- y of last surface detected
		for y = y1, y0, -1 do -- working down each column for each node do
			local fimadep = math.floor(6 - y / 16) + math.random(0, 1)
			local vi = area:index(x, y, z)
			local nodid = data[vi]
			local viuu = area:index(x, y - 2, z)
			local nodiduu = data[viuu]
			if nodid == c_stone
			or nodid == c_stonecopper
			or nodid == c_stoneiron
			or nodid == c_stonecoal
			or nodid == c_gravel
			or nodid == c_dirt
			or nodid == c_sand then
				if biome == 7 then
					data[vi] = c_desertstone
				end
				if not solid then -- if surface
					surfy = y
					if nodiduu ~= c_air
					and nodiduu ~= c_water
					and fimadep >= 1 then
						if y <= sandy then -- sand
							if math.abs(n_temp) < 0.05 and y == -1 then -- clay
								data[vi] = c_clay
							else
								data[vi] = c_sand
							end
							if open and water and y == 0 and biome >= 7
							and math.random() < n_absflora * PAPCHA then -- papyrus
								paragenv7_papyrus(x, 2, z, area, data)
							elseif open and biome >= 4
							and y >= 4 + math.random() 
							and math.random() < n_absflora * DUGCHA then -- dune grass
								local vi = area:index(x, y + 1, z)
								data[vi] = c_pg7goldengrass
							elseif open and y >= 1
							and (biome == 2 or biome == 3) then
								local vi = area:index(x, y + 1, z) -- snowy beach
								data[vi] = c_snowblock
							end
						else -- above sandline
							if biome == 1 then
								if math.random(121) == 2 then
									data[vi] = c_ice
								elseif math.random(25) == 2 then
									data[vi] = c_dirtsnow
								else
									data[vi] = c_pg7drygrass
								end
							elseif biome == 4 or biome == 8 then
								data[vi] = c_pg7drygrass
							elseif biome == 2 or biome == 3 then
								data[vi] = c_dirtsnow
							elseif biome == 7 then
								data[vi] = c_desertsand
							else
								data[vi] = c_pg7grass
							end
							if open then -- if open to sky then flora
								local y = surfy + 1
								local vi = area:index(x, y, z)
								if biome == 1 then
									if math.random() < DRYCHA then
										data[vi] = c_dryshrub
									end
								elseif biome == 2 then
									data[vi] = c_snowblock
								elseif biome == 3 then
									if math.random() < PINCHA
									and n_absflora > 0.1 then
										paragenv7_pinetree(x, y, z, area, data)
									else
										data[vi] = c_snowblock
									end
								elseif biome == 4 then
									if math.random() < DRYCHA then
										data[vi] = c_dryshrub
									end
								elseif biome == 5 then
									if math.random() < FLOCHA then
										paragenv7_flower(data, vi)
									elseif math.random() < GRACHA then
										paragenv7_grass(data, vi)
									end
								elseif biome == 6 then
									if math.random() < APTCHA
									and n_absflora > 0.1 then
										paragenv7_appletree(x, y, z, area, data)
									elseif math.random() < GRACHA then
										paragenv7_grass(data, vi)
									end
								elseif biome == 7 then
									if math.random() < CACCHA then
										paragenv7_cactus(x, y, z, area, data)
									elseif math.random() < DRYCHA then
										data[vi] = c_dryshrub
									end
								elseif biome == 8 then
									if math.random() < ACACHA then
										paragenv7_acaciatree(x, y, z, area, data)
									elseif math.random() < GOGCHA then
										data[vi] = c_pg7goldengrass
									end
								elseif biome == 9 then
									if math.random() < JUTCHA then
										paragenv7_jungletree(x, y, z, area, data)
									elseif math.random() < JUGCHA then
										data[vi] = c_jungrass
									end
								end
							end
						end
					end
				else -- underground
					if nodiduu ~= c_air
					and nodiduu ~= c_water
					and surfy - y + 1 <= fimadep then
						if y <= sandy then
							data[vi] = c_sand
						elseif biome == 1 then
							if math.random(121) == 2 then
								data[vi] = c_ice
							else
								data[vi] = c_pg7permafrost
							end
						elseif biome == 7 then
							data[vi] = c_desertsand
						else
							data[vi] = c_pg7dirt
						end
					end
				end
				open = false
				solid = true
			elseif nodid == c_air or nodid == c_water then
				solid = false
				if nodid == c_water then
					water = true
					if y >= 1 - bergdep and y <= 1 + bergdep / 8
					and n_temp < ICETET then-- icesheet
						data[vi] = c_ice
					end
				end
			end
		end
		nixz = nixz + 1
	end	
	end
	
	vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[paragenv7] "..chugent.." ms  minp ("..x0.." "..y0.." "..z0..")")			
end)	
