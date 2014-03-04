minetest.register_node("paragenv7:dirt", {
	description = "PG7 Dirt",
	tiles = {"default_dirt.png"},
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("paragenv7:grass", {
	description = "PG7 Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

minetest.register_node("paragenv7:drygrass", {
	description = "Dry Grass",
	tiles = {"paragenv7_drygrass.png"},
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

minetest.register_node("paragenv7:permafrost", {
	description = "Permafrost",
	tiles = {"paragenv7_permafrost.png"},
	groups = {crumbly=2},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("paragenv7:goldengrass", {
	description = "Golden Grass",
	drawtype = "plantlike",
	tiles = {"paragenv7_goldengrass.png"},
	inventory_image = "paragenv7_goldengrass.png",
	wield_image = "paragenv7_goldengrass.png",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {snappy=3,flammable=3,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("paragenv7:cactus", {
	description = "PG7 Cactus",
	tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_side.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {snappy=1,choppy=3,flammable=2},
	drop = "default:cactus",
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("paragenv7:jungleleaf", {
	description = "PG7 Jungletree Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_jungleleaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=4, flammable=2, leaves=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("paragenv7:acacialeaf", {
	description = "PG7 Acacia Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=4, flammable=2, leaves=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("paragenv7:needles", {
	description = "PG7 Pine Needles",
	tiles = {"paragenv7_needles.png"},
	is_ground_content = false,
	groups = {snappy=3, leafdecay=3},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("paragenv7:fog", {
	description = "PG7 Fog",
	drawtype = "glasslike",
	tiles = {"paragenv7_fog.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	post_effect_color = {a=128, r=241, g=248, b=255},
	groups = {not_in_creative_inventory=1},
})