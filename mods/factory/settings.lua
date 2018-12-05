-- LemonLake's Factories: Config

-- NB: miners require fans in the crafting recipe. recommended to enable fans if miners are enabled.
-- 	   alternatively change the crafting recipe manually in crafting.lua

factory.enableMiner = true
factory.enableFan = true
factory.enableVacuum = true

factory.fertilizerGeneration = true

factory.minerDigLimit = 512

--TODO: turn into registrations
-- Sapling IO for the Sapling Treatment Plant
factory.stpIO = {	{input = "default:sapling", output = "default:tree",				min = 4, 	max = 7},
					{input = "default:junglesapling", output="default:jungletree",		min = 8, 	max = 12},
					-- these moretrees values are incorrect, please change them to your liking
					{input = "moretrees:beech_sapling", output="moretrees:beech_trunk", min = 4,	max = 8},
					{input = "moretrees:apple_tree_sapling", output="moretrees:apple_tree_trunk",	min = 4, max = 8},
					{input = "moretrees:oak_sapling", output="moretrees:oak_trunk",		min = 4, max = 8},
					{input = "moretrees:sequoia_sapling", output="moretrees:sequoia_trunk", min = 4, max = 8},
					{input = "moretrees:birch_sapling", output="moretrees:birch_trunk", min = 4, max = 8},
					{input = "moretrees:palm_sapling", output="moretrees:palm_trunk", 	min = 4, max = 8},
					{input = "moretrees:spruce_sapling", output="moretrees:spruce_trunk", min = 4, max = 8},
					{input = "moretrees:pine_sapling", output="moretrees:pine_trunk", 	min = 4, max = 8},
					{input = "moretrees:willow_sapling", output="moretrees:willow_trunk", min = 4, max = 8},
					{input = "moretrees:acacia_sapling", output="moretrees:acacia_trunk", min = 4, max = 8},
					{input = "moretrees:rubber_tree_sapling", output="moretrees:rubber_tree_trunk", min = 4, max = 8},
					{input = "moretrees:fir_sapling", output="moretrees:fir_trunk", 	min = 4, max = 8},
					-- your trees here
		 }