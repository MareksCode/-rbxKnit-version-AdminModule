local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ModerationController = Knit.CreateController { Name = "ModerationController" }
local ModerationService, NotificationController

function ModerationController:KnitStart()
    local function CommandFeedbackEventFunction(text)
        NotificationController:DisplayNotification(text, "rbxassetid://87731268040856", 30, nil, "Moderation")
       -- print("ModerationController: "..text)
    end

    ModerationService.CommandFeedbackEvent:Connect(CommandFeedbackEventFunction)
end


function ModerationController:KnitInit()
    ModerationService = Knit.GetService("ModerationService")
    NotificationController = Knit.GetController("NotificationController")
end


return ModerationController