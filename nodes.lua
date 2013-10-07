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

minetest.register_node("paragenv7:fog", {
	description = "PGV7 Fog",
	drawtype = "glasslike",
	tiles = {"paragenv7_fog.png"},
	alpha = 127,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	post_effect_color = {a=127, r=255, g=255, b=255},
})

minetest.register_node("paragenv7:pleaf", {
	description = "PG Pine Needles",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"paragenv7_pleaf.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
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
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"paragenv7_sleaf.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=4, flammable=2, leaves=1},
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

-- ABMs

-- Pine sapling abm

minetest.register_abm({
    nodenames = {"paragenv7:psapling"},
    interval = PININT,
    chance = PINCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		paragenv7_pine(pos)
		print ("[paragenv7] Pine sapling grows")
    end
})

-- Jungletree sapling abm

minetest.register_abm({
    nodenames = {"paragenv7:jsapling"},
    interval = JUNINT,
    chance = JUNCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		paragenv7_jtree(pos)
		print ("[paragenv7] Jungletree sapling grows")
    end,
})

-- Savanna tree sapling abm

minetest.register_abm({
    nodenames = {"paragenv7:ssapling"},
    interval = SAVINT,
    chance = SAVCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		paragenv7_stree(pos)
		print ("[paragenv7] Savanna tree sapling grows")
    end,
})