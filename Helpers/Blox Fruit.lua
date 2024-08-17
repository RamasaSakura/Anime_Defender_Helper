shared.Configs = {
	Visual = {
		Enabled = false,
		["Health Bar"] = true,
		["Show Distance"] = true,
		["Box Enabled"] = true,
		["Show Username"] = true,
		["Show Chams"] = true,
		["Show Weapon"] = true,
		["Health Text"] = true
	},
	LocalPlayer = {
		FPS = {
			Enabled = false,
			Limit = 200
		},
		["Disabled Notifications"] = true,
		["White Screen"] = true,
		["Remove Fog"] = false,
		Team = "Pirates",
		Codes = {
			Enabled = false,
			["Redeem Level"] = 1
		},
		["Collect Chest Number"] = 50,
		Raid = {
			Enabled = false,
			["Join Others"] = {
				Enabled = false,
				["Until Fragment"] = 50000
			},
			["Buy Best Raid"] = true,
			["Raid Types"] = "Awaken",
			Awaken = false
		},
		["Close UI"] = false,
		["Last Hop"] = 0
	},
	Combat = {
		["Damage Aura"] = false,
		["Auto Enable Race V4"] = false,
		["Auto Enable Race V3"] = false
	},
	Threading = {
		Teleport_Player = false,
		["Selected Weapons"] = "Equip Best",
		["Fruit Mastery"] = false,
		Zou = {
			["Dark Dagger"] = false,
			["Hallow Scythe"] = false,
			["Buddy Sword"] = false,
			["Spikey Trident"] = false,
			["Shark Anchor"] = false,
			["Rainbow Haki"] = false,
			Yama = false,
			["Mirror Fractal"] = false,
			["Cursed Dual Katana"] = false,
			["Soul Guitar"] = false,
			Tushita = false,
			["Pirate Raid"] = false,
			Canvander = false,
			["Pull Leaver"] = false
		},
		Main = {
			["Player Hunter Quest"] = false,
			["Dressrosa Quest"] = false,
			Saber = false,
			Pole = false
		},
		["Switch Server"] = false,
		Bones = false,
		Dressrosa = {
			Factory = false,
			["Race V3 Quest"] = false,
			["Zou Quest"] = false,
			["Dark Fragment"] = false,
			["Bartilo Quest"] = false,
			["Flower Quest"] = false,
			["Library Key"] = false,
			["Water Key"] = false
		},
		["Auto Collect Chests"] = false,
		["Gun Mastery"] = false,
		["Stop Collect When Got Item"] = false,
		Level = true,
		["Sword Mastery"] = false,
		["Auto Farm Cake Prince"] = false
	},
	Stats = {
		Enabled = true,
		Defense = 2550,
		Melee = 2550,
		Sword = 1275,
		["Blox Fruit"] = 1275
	},
	Aimbot = {
		Enabled = false,
		["Aimbot Types"] = "Players",
		["Max Distance"] = 1000
	},
	["Mystic Island"] = false,
	Character = {
		Modifier = {
			["Auto Activate Ability"] = true,
			["Walk on Water"] = false,
			["Semi Evolve Race"] = false,
			["Semi No Stun"] = false,
			["Infinity Stamina"] = false,
			["Semi Mink Race"] = false
		}
	},
	["Fragments/Beli"] = {
		["Buy Legendary Sword"] = false,
		["Buy Pole V2"] = false,
		["Buy Bones"] = false,
		Kabucha = false,
		["Soul Guitar"] = false,
		["Buy Common"] = false,
		Enchancement = {
			Enabled = false,
			["Buy Color"] = { "Snow White", "Pure Red", "Winter Sky" }
		}
	},
	FightingStyles = {
		["Required 3 Melee Before Zou"] = false,
		["Required V3 Evolved Before Zou"] = false,
		Enabled = false
	},
	Bounty = {
		["Select Weapon"] = { "Melee", "Sword" },
		Collected_Bounty = 0,
		Enabled = false
	},
	Material = {
		Auto_Leather_Scrap_Metal = false,
		Auto_Conjured_Cocoa = false,
		Auto_Angel_Wings = false,
		Auto_Yeti_Fur = false,
		Auto_Gunpowder = false,
		Auto_Fish_Tails = false,
		Auto_Demonic_Wisp = false,
		Auto_Mystic_Droplets = false,
		Auto_Vampire_Fang = false,
		Auto_Meteorite = false,
		Auto_Mini_Tusk = false,
		Auto_Radioactive_Material = false,
		Auto_Magma_Ore = false,
		Auto_Dragon_Scale = false,
		Auto_Ectoplasm = false,
		Auto_Bone = false
	},
	Island = {
		Enabled = false,
		["Selected Island"] = "None"
	},
	DevilFruit = {
		["Random Fruit"] = true,
		["Store Fruit"] = true,
		Sniper = {
			Enabled = true,
			["Buy Fruit"] = { "Dough-Dough", "Light-Light", "Quake-Quake", "Ice-Ice", "Dark-Dark", "Light-Light", "Sound-Sound" }
		}
	},
	
	Debugger = {
		Print_Nearby_Entities_On_Dead = true
	}
}


getgenv().Configuration = {
	['Enabled'] = true,
	['PC Name'] = 'dekonemillionbaht',
	['Delay'] = 0,
};


getgenv().key = '224144088174'
loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))()
loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Extra_Optimization.lua'))()
