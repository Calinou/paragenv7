minetest.register_node("paragenv7:permafrost", {
	description = "PG Permafrost",
	tiles = {"paragenv7_permafrost.png"},
	groups = {crumbly=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("paragenv7:drygrass", {
	description = "PG Dirt With Dry Grass",
	tiles = {"paragenv7_drygrass.png", "default_dirt.png", "paragenv7_drygrass.png"},
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

minetest.register_node("paragenv7:pleaf", {
	description = "PG Pine Needles",
	visual_scale = 1.3,
	tiles = {"paragenv7_pleaf.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"paragenv7:psapling"}, rarity = 20},
			{items = {"paragenv7:pleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("paragenv7:psapling", {
	description = "PG Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"paragenv7_psapling.png"},
	inventory_image = "paragenv7_psapling.png",
	wield_image = "paragenv7_psapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("paragenv7:sleaf", {
	description = "PG Savanna Tree Leaves",
	visual_scale = 1.3,
	tiles = {"paragenv7_sleaf.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"paragenv7:ssapling"}, rarity = 20},
			{items = {"paragenv7:sleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("paragenv7:ssapling", {
	description = "PG Savanna Tree Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"paragenv7_ssapling.png"},
	inventory_image = "paragenv7_ssapling.png",
	wield_image = "paragenv7_ssapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node(":default:snow", {
	description = "Snow",
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	is_ground_content = true,
	paramtype = "light",
	sunlight_propagates = true, -- redefine snow because of this dark nodebox bug
	buildable_to = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
		},
	},
	groups = {crumbly=3,falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	on_construct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "default:dirt_with_grass" then
			minetest.set_node(pos, {name="default:dirt_with_snow"})
		end
	end,
})

-- ABMs

-- Pine sapling abm

minetest.register_abm({
    nodenames = {"paragenv7:psapling"},
    interval = PININT,
    chance = PINCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		paragenv7_pine(pos)
		if DEBUG then
			print ("[paragenv7] Pine sapling grows")
		end
    end
})

-- Jungletree sapling abm

minetest.register_abm({
    nodenames = {"paragenv7:jsapling"},
    interval = JUNINT,
    chance = JUNCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		paragenv7_jtree(pos)
		if DEBUG then
			print ("[paragenv7] Jungletree sapling grows")
		end
    end,
})

-- Savanna tree sapling abm

minetest.register_abm({
    nodenames = {"paragenv7:ssapling"},
    interval = SAVINT,
    chance = SAVCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		paragenv7_stree(pos)
		if DEBUG then
			print ("[paragenv7] Savanna tree sapling grows")
		end
    end,
})