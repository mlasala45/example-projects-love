--TMP
local Resources = {}
local UnlockableFeatures = {}
local Wonders = {}

Techs = {}

local ACC_TECHS = 1

local function RegisterTech(name, data)
	Techs[name] = data
	Techs[name].uid = ACC_TECHS

	ACC_TECHS = ACC_TECHS + 1
end

local column

column = {
	Agriculture = {
		column = 0,
		row = 6,
		cost = 0,

		improvements = { Improvements.Farm },
	},
}

for k,v in pairs(column) do RegisterTech(k, v) end

column = {
	Pottery = {
		column = 1,
		row = 2,
		prereq = { Techs.Agriculture },
		cost = 10,

		buildings = { Buildings.Granary },
	},

	AnimalHusbandry = {
		column = 1,
		row = 5,
		prereq = { Techs.Agriculture },
		cost = 10,

		resources = { Resources.Horses },
		improvements = { Improvements.Pasture },
	},

	Archery = {
		column = 1,
		row = 7,
		prereq = { Techs.Agriculture },
		cost = 10,

		units = { Units.Archer },
	},

	Mining = {
		column = 1,
		row = 9,
		prereq = { Techs.Agriculture },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},
}

for k,v in pairs(column) do RegisterTech(k, v) end

column = {
	Sailing = {
		column = 2,
		row = 1,
		prereq = { Techs.Pottery },
		cost = 10,

		units = { Units.WorkBoat, Units.Trireme },
		wonders = { Wonders.GreatLighthouse },
		improvements = { Improvements.FishingBoats },
	},

	Calendar = {
		column = 2,
		row = 2,
		prereq = { Techs.Pottery },
		cost = 10,

		wonders = { Wonders.Stonehenge },
		buildings = { Buildings.Stoneworks },
		improvements = { Improvements.Plantation },

		showcase = Wonders.Stonehenge,
	},

	Writing = {
		column = 2,
		row = 3,
		prereq = { Techs.Pottery },
		cost = 10,

		buildings = { Buildings.Library },
		wonders = { Wonders.GreatLibrary },
		features = { UnlockableFeatures.OpenBorders }
	},

	Trapping = {
		column = 2,
		row = 4,
		prereq = { Techs.AnimalHusbandry },
		cost = 10,

		buildings = { Buildings.Circus },
		improvements = { Improvements.TradingPost, Improvements.Camp },
	},

	TheWheel = {
		column = 2,
		row = 6,
		prereq = { Techs.AnimalHusbandry },
		cost = 10,

		units = { Units.HorseArcher },
		buildings = { Buildings.WaterMill },
		improvements = { Improvements.Road },
	},

	Masonry = {
		column = 2,
		row = 9,
		prereq = { Techs.Mining },
		cost = 10,

		buildings = { Buildings.Walls },
		wonders = { Wonders.Pyramids },
		improvements = { Improvements.Quarry, Improvements.RemoveMarsh },
	},

	BronzeWorking = {
		column = 2,
		row = 10,
		prereq = { Techs.Mining },
		cost = 10,

		units = { Units.Spearman },
		buildings = { Buildings.Barracks },
		wonders = { Wonders.Colossus },
		improvements = { Improvements.RemoveJungle },
	},
}

for k,v in pairs(column) do RegisterTech(k, v) end

column = {
	Optics = {
		column = 3,
		row = 1,
		prereq = { Techs.Sailing },
		cost = 10,

		buildings = { Buildings.Lighthouse },
		features = { UnlockableFeatures.EmbarkUnits },
	},

	Philosophy = {
		column = 3,
		row = 3,
		prereq = { Techs.Writing },
		cost = 10,

		buildings = { Buildings.Temple },
		wonders = { Wonders.NationalCollege, Wonders.NationalEpic, Wonders.Oracle },
		features = {},
	},

	HorsebackRiding = {
		column = 3,
		row = 5,
		prereq = { Techs.TheWheel },
		cost = 10,

		units = { Units.Horseman },
		buildings = { Buildings.Stables },
	},

	Mathematics = {
		column = 3,
		row = 7,
		prereq = { Techs.TheWheel, Techs.Archery },
		cost = 10,

		units = { Units.Catapult },
		buildings = { Buildings.Courthouse },
		wonders = { Wonders.HangingGardens },
	},

	Construction = {
		column = 3,
		row = 9,
		prereq = { Techs.Masonry },
		cost = 10,

		buildings = { Buildings.Colosseum },
		wonders = { Wonders.CircusMaximus, Wonders.GreatWall },
		improvements = { Improvements.LumberMill },
	},

	IronWorking = {
		column = 3,
		row = 10,
		prereq = { Techs.BronzeWorking },
		cost = 10,

		units = { Units.Swordsman },
		wonders = { Wonders.HeroicEpic },
		resources = { Resources.Iron },
	},
}

for k,v in pairs(column) do RegisterTech(k, v) end

--

for k,v in pairs(Techs) do v.name = k end