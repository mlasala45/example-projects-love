--MeleeAttack

local function onstartfn_meleeattack()
	--
end

local function maindrawfn_meleeattack()
	--
end

local function selectdrawfn_meleeattack()
	--
end

--RangedAttack

local function onstartfn_rangedattack(unit)
	TheTargetingUI.data.borders = renderutil.createbordersegmenttable(unit.map, unit.map:GetTilesInRange(unit.cx, unit.cy, unit.view))
end

local function maindrawfn_rangedattack(unit)
	--Draw Range Border
	renderutil.drawbordersegments()
end

local function selectdrawfn_rangedattack(unit)
	--
end

--
--DEFINITIONS
--

TargetingModes = {
	MeleeAttack = {
		onstartfn = onstartfn_meleeattack,
		maindrawfn = maindrawfn_meleeattack,
		selectdrawfn = selectdrawfn_meleeattack,
	},
	RangedAttack = {
		onstartfn = onstartfn_rangedattack,
		maindrawfn = maindrawfn_rangedattack,
		selectdrawfn = selectdrawfn_rangedattack,
	},
}