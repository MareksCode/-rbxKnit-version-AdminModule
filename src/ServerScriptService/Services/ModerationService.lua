--[[
	Written by Begi. Modified by EinMarek
	Listens for commands, checks permissions, and executes the appropriate functions from AdminModule.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")

local ModerationService = Knit.CreateService({
	Name = "ModerationService",
	Client = {
		CommandFeedbackEvent = Knit.CreateSignal()
	},
})

local AdminModule, Config

function ModerationService:KnitInit()
	AdminModule = require(ServerStorage.Modules.AdminModule)
	Config = require(ServerStorage.Modules.AdminModuleSettings)
end

function ModerationService:isAdmin(player)
	return table.find(Config.AdminUserIds, player.UserId) ~= nil
end

function ModerationService:processCommand(player, message)
	-- Split the message into command and arguments
	local args = message:split(" ")
	local command = table.remove(args, 1):lower()

	if command == Config.CommandPrefix .. "ban" then
		if ModerationService:isAdmin(player) then
			local targetID = tonumber(args[1])
			local duration = args[2]

			local durationParsed = AdminModule.parseDuration(duration)
			local reason
			if durationParsed then
				reason = table.concat(args, " ", 3)
			else
				duration = "-1"
				reason = table.concat(args, " ", 2)
			end

			if targetID then
				AdminModule.BanPlayer(targetID, duration, reason, player)
			else
				self.Client.CommandFeedbackEvent:FireClient(player, "Player not found.")
			end
		else
			self.Client.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end
	elseif command == Config.CommandPrefix .. "unban" then
		if ModerationService:isAdmin(player) then
			local targetID = tonumber(args[1])

			if targetID then
				AdminModule.UnbanPlayer(targetID, player)
			else
				self.Client.CommandFeedbackEvent:FireClient(player, "Player not found.")
			end
		else
			self.Client.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end
	elseif command == Config.CommandPrefix .. "checkhistory" then
		if ModerationService:isAdmin(player) then
			local targetID = tonumber(args[1])

			if targetID then
				AdminModule.CheckPlayerHistory(targetID, player)
			else
				self.Client.CommandFeedbackEvent:FireClient(player, "Player not found.")
			end
		else
			self.Client.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end
	elseif command == Config.CommandPrefix .. "getid" then
		if ModerationService:isAdmin(player) then
			local targetUsername = args[1]
			AdminModule.GetPlayerID(targetUsername, player)
		else
			self.Client.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end
	else
		self.Client.CommandFeedbackEvent:FireClient(player, "Unknown command.")
	end
end

function ModerationService:KnitStart()
	local function playerAdded(player: Player)
		if ModerationService:isAdmin(player) then
			self.Client.CommandFeedbackEvent:FireClient(
				player,
				"AdminModule is activated for you. Toggle menu: " .. tostring(Config.ToggleKey)
			)
		end

		player.Chatted:Connect(function(message)
			if message:sub(1, #Config.CommandPrefix) == Config.CommandPrefix then
				ModerationService:processCommand(player, message)
			end
		end)
	end

	Players.PlayerAdded:Connect(playerAdded)
end

return ModerationService
