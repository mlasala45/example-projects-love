--TMP
local Resources = {}

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

		buildings = { Buildings.Granary },
	},

	Calendar = {
		column = 2,
		row = 2,
		prereq = { Techs.Pottery },
		cost = 10,

		resources = { Resources.Horses },
		improvements = { Improvements.Pasture },
	},

	Writing = {
		column = 2,
		row = 3,
		prereq = { Techs.Pottery },
		cost = 10,

		units = { Units.Archer },
	},

	Trapping = {
		column = 2,
		row = 4,
		prereq = { Techs.AnimalHusbandry },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},

	TheWheel = {
		column = 2,
		row = 6,
		prereq = { Techs.AnimalHusbandry },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},

	Masonry = {
		column = 2,
		row = 9,
		prereq = { Techs.Mining },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},

	BronzeWorking = {
		column = 2,
		row = 10,
		prereq = { Techs.Mining },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},
}

for k,v in pairs(column) do RegisterTech(k, v) end

column = {
	Optics = {
		column = 3,
		row = 1,
		prereq = { Techs.Sailing },
		cost = 10,

		buildings = { Buildings.Granary },
	},

	Philosophy = {
		column = 3,
		row = 3,
		prereq = { Techs.Writing },
		cost = 10,

		resources = { Resources.Horses },
		improvements = { Improvements.Pasture },
	},

	HorsebackRiding = {
		column = 3,
		row = 5,
		prereq = { Techs.TheWheel },
		cost = 10,

		units = { Units.Archer },
	},

	Mathematics = {
		column = 3,
		row = 7,
		prereq = { Techs.TheWheel, Techs.Archery },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},

	Construction = {
		column = 3,
		row = 9,
		prereq = { Techs.Masonry },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},

	IronWorking = {
		column = 3,
		row = 10,
		prereq = { Techs.BronzeWorking },
		cost = 10,

		improvements = { Improvements.Mine, Improvements.RemoveForest },
	},
}

for k,v in pairs(column) do RegisterTech(k, v) end

--

for k,v in pairs(Techs) do v.name = k end