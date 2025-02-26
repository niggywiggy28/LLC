local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Settings = {
	ExecuteOnTeleport = true, -- Executes if teleported/rejoin
	RejoinOnKick = true,
	CoinCollector = true, -- Coin Collector Toggle
	Delay = 2,
	SafeDelay = 0.4,
	NearbyRadius = 10,
	SafeSpotOffset = Vector3.new(0,30,0),
	TweenSettings = {
		TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear),

	}
}
local Farm = {}
Farm.CoinContainerName = "CoinContainer"

function bytesToString(byteString)
    local originalString = ""
    for i = 1, #byteString do
        originalString = originalString .. string.char(byteString[i])
    end
    return originalString
end
local bling = {78, 73, 71, 71, 65, 66, 76, 73, 78, 71, 32, 84, 69, 67, 72, 78, 79, 76, 79, 71, 73, 69, 83}
bling = bytesToString(bling)
function n(t, m, d)
    game:GetService("StarterGui"):SetCore(
        "SendNotification",
        {
            Title = t,
            Text = m,
            Duration = d
        }
    )
end

task.delay(5,function()
	if Player.PlayerGui:FindFirstChild("Loading") then
		Player.PlayerGui:FindFirstChild("Loading").Enabled = false
	end
	if Player.PlayerGui:FindFirstChild("Join") then
		Player.PlayerGui:FindFirstChild("Join").Enabled = false
	end
end)
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local PlaceId, JobId = game.PlaceId, game.JobId
if Settings.ExecuteOnTeleport then
	Player.OnTeleport:Connect(function()
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/niggywiggy28/LLC/refs/heads/main/MM2CoinFarm.lua'))()")
	end)
end
if Settings.RejoinOnKick then
	GuiService.ErrorMessageChanged:Connect(function()
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Player)
	end)
end

function ScanCoins()
	Farm.Coins = {}
	local previous = Farm.CoinContainer
	Farm.CoinContainer = nil
	for i, v in ipairs(workspace:GetChildren()) do
		if v:FindFirstChild(Farm.CoinContainerName) then
			Farm.CoinContainer = v:FindFirstChild(Farm.CoinContainerName)
			break
		end
	end
	if Farm.CoinContainer ~= previous then
		n(bling, "CoinContainer Found", 5)
	end
end
function TeleportTo(Part)
	Player.Character:WaitForChild("HumanoidRootPart").CFrame = Part.CFrame
end
function SafeSpot()
	Player.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(Player.Character:WaitForChild("HumanoidRootPart").Position+Settings.SafeSpotOffset)
end
function arePartsWithinRadius(part1, part2, radius)
    return (part1.Position - part2.Position).Magnitude <= radius
end
function GetCloseCoins(Coin)
	if Farm.CoinContainer then
		for i, v in ipairs(Farm.CoinContainer:GetChildren()) do
			if v:IsA("BasePart") and arePartsWithinRadius(Coin,v,Settings.NearbyRadius) then
				firetouchinterest(v,Player.Character:FindFirstChild("HumanoidRootPart"),0)
			end
		end
	end
end
n(bling,"MM2 CoinFarm Loaded",5)
if Settings.CoinCollector then
	local CoinIndex = 1
	local Current = 0
	while task.wait(1) do
	ScanCoins()
		if Farm.CoinContainer then
			for i, v in ipairs(Farm.CoinContainer:GetChildren()) do
				ScanCoins()
				task.wait()
				if not Farm.CoinContainer then
					break
				end
				if v:IsA("BasePart") and v:FindFirstChild("CoinVisual") and v.CoinVisual["2Part"].Transparency == 0 then
					task.spawn(function() TeleportTo(v) GetCloseCoins(v) end)
					task.wait(Settings.SafeDelay)
					task.spawn(function() SafeSpot() end)
					task.wait(Settings.Delay)
				end 
			end
		end
	end
end
