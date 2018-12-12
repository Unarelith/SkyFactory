--[[

	skyfactory_quests
	================

	Copyright (C) 2018-2019 Quentin Bazin

	LGPLv2.1+
	See LICENSE.txt for more information

]]--

local page = 1

quest_lib.pages[page] = {}
quest_lib.pages[page].quests = {
	{
		name = 'Place a Sapling and grow a Tree with Bonemeal',
		hint = 'default:sapling',
		quest = 'place_sapling',
		count = 1,
		reward = 'default:axe_stone',
		placenode = {'default:sapling'},
	},
	{
		name = 'Dig 10 Tree',
		hint = 'default:tree',
		quest = 'dig_tree',
		count = 10,
		reward = 'default:torch',
		dignode = {'default:tree'},
	},
	{
		name = 'Craft a Wooden Crook to get Silkworms from Leaves',
		hint = 'fs_tools:crook_wood',
		quest = 'craft_crook',
		count = 1,
		reward = 'default:leaves 48',
		craft = {'fs_tools:crook_wood'},
	},
	{
		name = 'Infest Leaves with a Silkworm to get String',
		hint = 'farming:string',
		quest = 'pickup_string',
		count = 10,
		reward = 'fs_tools:crook_wood',
		pickup = {'farming:string'},
	},
	{
		name = 'Craft a Wooden Barrel',
		hint = 'fs_barrel:barrel_wood',
		quest = 'craft_barrel',
		count = 1,
		reward = 'default:sapling 4',
		craft = {'fs_barrel:barrel_wood'},
	},
	{
		name = 'Compost sapling and leaves into Dirt with a Barrel',
		hint = 'default:dirt',
		quest = 'place_barrel',
		count = 1,
		reward = 'fs_barrel:barrel_wood 2',
		placenode = {'fs_barrel:barrel_wood'},
	},
	{
		name = 'Craft a Sieve to get Stone Pebbles from Dirt',
		hint = 'fs_sieve:sieve',
		quest = 'craft_sieve',
		count = 1,
		reward = 'fs_core:stone_pebble 4',
		craft = {'fs_sieve:sieve'},
	},
	{
		name = 'Craft and place a Furnace',
		hint = 'default:furnace',
		quest = 'place_furnace',
		count = 1,
		reward = 'default:coal_lump',
		placenode = {'default:furnace'},
	},
	{
		name = 'Craft a Wooden Hammer',
		hint = 'fs_tools:hammer_wood',
		quest = 'craft_hammer',
		count = 1,
		reward = 'default:tree 8',
		craft = {'fs_tools:hammer_wood'},
	},
	{
		name = 'Crush Cobble with the Hammer to get Gravel, Sand and Dust',
		hint = 'default:gravel',
		quest = 'pickup_gravel',
		count = 8,
		reward = 'default:gravel 10',
		pickup = {'default:gravel'},
	},
}

quest_lib.pages[page].get_description = function(player_name)
	return {
		"Welcome "..player_name..", of the Sky People",
		"We can no longer live on the surface.",
		"Can you help us rebuild in the sky?",
		"Complete the quests to receive great rewards!",
	}
end

