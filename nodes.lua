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