local GameManager = Class(Prefab, function(self, map)
	self.base._ctor(self, 0, 0)

	--self.map = map

	self.players = {}

	--

	self.turn_num = 0
	self.player_num = 0
end)

function GameManager:NextTurn()
	self.player_num = self.player_num + 1
	if self.player_num > #self.players then
		self.player_num = 1
		self.turn_num = self.turn_num + 1
	end
	--UI_TurnCounter:SetTurn(self.turn_num, self.players[self.player_num])

	--self.map:NextTurn()

	local current_player = self.players[self.player_num]

	--

	--UI_Notifications:RecalcNotifications(current_player.notifications)

	--Center Camera on a unit or city
end

function GameManager:AddPlayer(faction)
	local player = {
		--
	}
	table.insert(self.players, player)

	--self:RecalcUnlocks(player)
end

function GameManager:GetCurrentPlayer()
	return self.players[self.current_player]
end

function GameManager:Update(dt)
	local mx,my = love.mouse:getPosition()
	print(mx..", "..my)
end

--[[function GameManager:PushNotification(player, data)
	table.insert(self.players[player].notifications, data)
	if self.player_num == player then
		UI_Notifications:RecalcNotifications(self.players[player].notifications)
	end
end

function GameManager:DismissNotification(player, num)
	if player == nil then player = self.player_num end
	table.remove(self.players[player].notifications, num)
	if self.player_num == player then
		UI_Notifications:RecalcNotifications(self.players[player].notifications)
	end
end]]

return GameManager