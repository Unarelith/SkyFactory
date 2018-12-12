--[[

	skyfactory_quests
	================

	Copyright (C) 2018-2019 Quentin Bazin

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

local page = 2

quest_lib.pages[page] = {}
quest_lib.pages[page].quests = {
	{
		name = 'Sieve Gravel, Sand or Dust to get ore pieces',
		hint = 'default:gravel',
		quest = 'pickup_ore_pieces',
		count = 8,
		reward = 'default:gravel 64',
		pickup = {'fs_sieve:iron_ore_piece'},
	},
	{
		name = 'Craft a Bucket',
		hint = 'bucket:bucket_empty',
		quest = 'craft_bucket',
		count = 1,
		reward = 'default:gold_lump',
		craft = {'bucket:bucket_empty'},
	},
	{
		name = 'Craft and place a Wooden Crucible to get Water from Leaves',
		hint = 'fs_crucible:crucible_wood',
		quest = 'craft_wooden_crucible',
		count = 1,
		reward = 'default:leaves 42',
		placenode = {'fs_crucible:crucible_wood'},
	},
	{
		name = 'Make Clay by mixing Water and Dust in a Barrel',
		hint = 'default:clay_lump',
		quest = 'dig_clay',
		count = 4,
		reward = 'default:clay 4',
		dignode = {'default:clay'},
	},
	{
		name = 'Craft and place a Crucible to get Lava from Cobblestone',
		hint = 'fs_crucible:crucible',
		quest = 'craft_crucible',
		count = 1,
		reward = 'default:torch',
		placenode = {'fs_crucible:crucible'},
	},
}

quest_lib.pages[page].get_description = function(player_name)
	return {
		"Hey "..player_name..", Come Up Here!",
		"Wow, look at that view... of... nothing...",
		"You should get to work extending this island.",
		"Perhaps you could start getting some ores too?",
	}
end

