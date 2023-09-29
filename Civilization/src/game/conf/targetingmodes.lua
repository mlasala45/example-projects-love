--MotionRange

local function onstartfn_motionrange(unit)
	TheTargetingUI.data.borders = renderutil.createbordersegmenttable(unit.map, TheTargetingUI.data.cells)
end

local function maindrawfn_motionrange(unit)
	renderutil.drawbordersegments(unit.map, TheTargetingUI.data.borders, COLORS.CYAN)

	love.graphics.setLineWidth(2)
	love.graphics.setColor(COLORS.RED)
	for cell,_ in pairs(TheTargetingUI.valid_cells) do
		if cell.unit and cell.unit:IsAttackable(unit) then
			local x, y = unit.map:GetHexCenter(cell.unit.cx, cell.unit.cy)
			love.graphics.circle("line", x, y, HEX_RADIUS_SHORT * TheCamera.sx)
		end
	end

	love.graphics.setLineWidth(1)
end

local function selectdrawfn_motionrange(unit, cell)
	ThePathfinder.target = cell
	ThePathfinder.path = hex.path(unit, cell)
end

--MeleeAttack

local function onstartfn_meleeattack(unit)
	--
end

local function maindrawfn_meleeattack(unit)
	love.graphics.setLineWidth(4)
	love.graphics.setColor(COLORS.RED)
	for cell,_ in pairs(TheTargetingUI.valid_cells) do
		local wx, wy = unit.map:GetHexCenter(cell.unit.cx, cell.unit.cy)
		local verts = HexVerts(wx, wy, TheCamera.sx*0.8, TheCamera.sy*0.8)
		love.graphics.polygon("line", verts)
	end

	love.graphics.setLineWidth(1)
end

local function selectdrawfn_meleeattack(unit, cell)
	--
end

--RangedAttack

local function onstartfn_rangedattack(unit)
	TheTargetingUI.data.borders = renderutil.createbordersegmenttable(unit.map, unit.map:GetTilesInViewRange(unit.cx, unit.cy, unit.view, false, false))
end

local function maindrawfn_rangedattack(unit)
	--Draw Range Border
	renderutil.drawbordersegments(unit.map, TheTargetingUI.data.borders, COLORS.RED)

	love.graphics.setLineWidth(2)
	love.graphics.setColor(COLORS.RED)
	for cell,_ in pairs(TheTargetingUI.valid_cells) do
		local x, y = unit.map:GetHexCenter(cell.unit.cx, cell.unit.cy)
		love.graphics.circle("line", x, y, HEX_RADIUS_SHORT * TheCamera.sx)
	end

	love.graphics.setLineWidth(1)
end

local function selectdrawfn_rangedattack(unit, cell)
	--
end

--
--DEFINITIONS
--

TargetingModes = {
	MotionRange = {
		onstartfn = onstartfn_motionrange,
		maindrawfn = maindrawfn_motionrange,
		selectdrawfn = selectdrawfn_motionrange,
	},
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
for k,v in pairs(TargetingModes) do v.name = k end