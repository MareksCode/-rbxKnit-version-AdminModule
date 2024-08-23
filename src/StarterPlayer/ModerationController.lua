local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ModerationController = Knit.CreateController { Name = "ModerationController" }
local ModerationService

function ModerationController:KnitStart()
    ModerationService = Knit.GetService("ModerationService")
end


function ModerationController:KnitInit()
    local function CommandFeedbackEvent(text)
        --add your preferred method of notification here

        print("ModerationController: "..text)
    end

    ModerationService.CommandFeedbackEvent:Connect(CommandFeedbackEvent)
end


return ModerationController
