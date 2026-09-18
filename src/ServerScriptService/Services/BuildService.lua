local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local BuildService = {}
BuildService.__index = BuildService

function BuildService.new(remotes)
    local self = setmetatable({}, BuildService)
    self.remotes = remotes
    self.folder = Instance.new("Folder")
    self.folder.Name = "PlayerBuilds"
    self.folder.Parent = workspace
    self.counts = {}
    return self
end

function BuildService:Reset()
    self.folder:ClearAllChildren()
    self.counts = {}
end

function BuildService:GetFolder()
    return self.folder
end

function BuildService:SetEnabled(enabled)
    self.enabled = enabled
end

local function snap(n, grid)
    return math.floor((n / grid) + 0.5) * grid
end

function BuildService:HandlePlace(player, targetPosition, normal)
    if not self.enabled then return end
    if typeof(targetPosition) ~= "Vector3" or typeof(normal) ~= "Vector3" then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if (root.Position - targetPosition).Magnitude > Config.BUILD_RANGE then return end

    local limit = player:GetAttribute("BuildLimit") or Config.MAX_BUILD_PARTS
    local count = self.counts[player] or 0
    if count >= limit then
        self.remotes.Toast:FireClient(player, "Лимит построек исчерпан.")
        return
    end

    local grid = Config.BUILD_GRID
    local pos = Vector3.new(snap(targetPosition.X, grid), snap(targetPosition.Y + 2, grid), snap(targetPosition.Z, grid))
    local p = Instance.new("Part")
    p.Name = "Build_" .. player.UserId
    p.Size = Vector3.new(grid, grid, grid)
    p.CFrame = CFrame.new(pos)
    p.Anchored = true
    p.Material = Enum.Material.WoodPlanks
    p.Color = Color3.fromRGB(163, 121, 76)
    p.TopSurface = Enum.SurfaceType.Studs
    p.BottomSurface = Enum.SurfaceType.Inlet
    p:SetAttribute("BuilderUserId", player.UserId)
    p.Parent = self.folder

    self.counts[player] = count + 1
end

function BuildService:HandleDelete(player, target)
    if not self.enabled then return end
    if typeof(target) ~= "Instance" or not target:IsDescendantOf(self.folder) then return end
    if target:GetAttribute("BuilderUserId") ~= player.UserId then return end
    target:Destroy()
    self.counts[player] = math.max(0, (self.counts[player] or 1) - 1)
end

return BuildService
