function paragenv7_appletree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_apple = minetest.get_content_id("default:apple")
	local c_leaves = minetest.get_content_id("default:leaves")
	for j = -2, 4 do
		if j >= 1 then
			for i = -2, 2 do
			for k = -2, 2 do
				local vil = area:index(x + i, y + j + 1, z + k)
				if math.random(48) == 2 then
					data[vil] = c_apple
				elseif math.random(3) ~= 2 then
					data[vil] = c_leaves
				end
			end
			end
		end
		local vit = area:index(x, y + j, z)
		data[vit] = c_tree
	end
end

function paragenv7_pinetree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_pg7needles = minetest.get_content_id("paragenv7:needles")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	for j = -4, 13 do
		if j == 3 or j == 6 or j == 9 or j == 12 then
			for i = -2, 2 do
			for k = -2, 2 do
				if math.abs(i) == 2 or math.abs(k) == 2 then
					if math.random(5) ~= 2 then
						local vil = area:index(x + i, y + j, z + k)
						data[vil] = c_pg7needles
						local vila = area:index(x + i, y + j + 1, z + k)
						data[vila] = c_snowblock
					end
				end
			end
			end
		elseif j == 4 or j == 7 or j == 10 or j == 13 then
			for i = -1, 1 do
			for k = -1, 1 do
				if not (i == 0 and j == 0) then
					if math.random(7) ~= 2 then
						local vil = area:index(x + i, y + j, z + k)
						data[vil] = c_pg7needles
						local vila = area:index(x + i, y + j + 1, z + k)
						data[vila] = c_snowblock
					end
				end
			end
			end
		end
		local vit = area:index(x, y + j, z)
		data[vit] = c_tree
	end
	local vil = area:index(x, y + 14, z)
	local vila = area:index(x, y + 15, z)
	local vilaa = area:index(x, y + 16, z)
	data[vil] = c_pg7needles
	data[vila] = c_pg7needles
	data[vilaa] = c_snowblock
end

function paragenv7_jungletree(x, y, z, area, data)
	local c_juntree = minetest.get_content_id("default:jungletree")
	local c_pg7junleaf = minetest.get_content_id("paragenv7:jungleleaf")
	for j = -5, 17 do
		if j == 11 or j == 17 then
			for i = -2, 2 do
			for k = -2, 2 do
				local vil = area:index(x + i, y + j + math.random(0, 1), z + k)
				if math.random(5) ~= 2 then
					data[vil] = c_pg7junleaf
				end
			end
			end
		elseif j <= 0 then
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 2 then
					local vit = area:index(x + i, y + j, z + k)
					data[vit] = c_juntree
				end
			end
			end
		end
		local vit = area:index(x, y + j, z)
		data[vit] = c_juntree
	end
end

function paragenv7_acaciatree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_acacialeaf = minetest.get_content_id("paragenv7:acacialeaf")
	for j = -3, 7 do
		if j == 7 then
			for i = -4, 4 do
			for k = -4, 4 do
				if not (i == 0 or k == 0) then
					if math.random(5) ~= 2 then
						local vil = area:index(x + i, y + j, z + k)
						data[vil] = c_acacialeaf
					end
				end
			end
			end
		elseif j == 6 then
			for i = -2, 2, 4 do
			for k = -2, 2, 4 do
				local vit = area:index(x + i, y + j, z + k)
				data[vit] = c_tree
			end
			end
		elseif j == 5 then
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 2 then
					local vit = area:index(x + i, y + j, z + k)
					data[vit] = c_tree
				end
			end
			end
		else
			local vit = area:index(x, y + j, z)
			data[vit] = c_tree
		end
	end
end

function paragenv7_grass(data, vi)
	local c_grass1 = minetest.get_content_id("default:grass_1")
	local c_grass2 = minetest.get_content_id("default:grass_2")
	local c_grass3 = minetest.get_content_id("default:grass_3")
	local c_grass4 = minetest.get_content_id("default:grass_4")
	local c_grass5 = minetest.get_content_id("default:grass_5")
	local rand = math.random(5)
	if rand == 1 then
		data[vi] = c_grass1
	elseif rand == 2 then
		data[vi] = c_grass2
	elseif rand == 3 then
		data[vi] = c_grass3
	elseif rand == 4 then
		data[vi] = c_grass4
	else
		data[vi] = c_grass5
	end
end

function paragenv7_flower(data, vi)
	local c_danwhi = minetest.get_content_id("flowers:dandelion_white")
	local c_danyel = minetest.get_content_id("flowers:dandelion_yellow")
	local c_rose = minetest.get_content_id("flowers:rose")
	local c_tulip = minetest.get_content_id("flowers:tulip")
	local c_geranium = minetest.get_content_id("flowers:geranium")
	local c_viola = minetest.get_content_id("flowers:viola")
	local rand = math.random(6)
	if rand == 1 then
		data[vi] = c_danwhi
	elseif rand == 2 then
		data[vi] = c_rose
	elseif rand == 3 then
		data[vi] = c_tulip
	elseif rand == 4 then
		data[vi] = c_danyel
	elseif rand == 5 then
		data[vi] = c_geranium
	else
		data[vi] = c_viola
	end
end

function paragenv7_cactus(x, y, z, area, data)
	local c_pg7cactus = minetest.get_content_id("paragenv7:cactus")
	for j = -2, 4 do
	for i = -2, 2 do
		if i == 0 or j == 2 or (j == 3 and math.abs(i) == 2) then
			local vic = area:index(x + i, y + j, z)
			data[vic] = c_pg7cactus
		end
	end
	end
end

function paragenv7_papyrus(x, y, z, area, data)
	local c_papyrus = minetest.get_content_id("default:papyrus")
	local ph = math.random(0, 3)
	for j = 0, ph do
		local vip = area:index(x, y + j, z)
		data[vip] = c_papyrus
	end
end