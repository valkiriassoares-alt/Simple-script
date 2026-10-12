```lua
local ScreenGui = Instance.new("ScreenGui")
local TextButton = Instance.new("TextButton")

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

TextButton.Parent = ScreenGui
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0, 0, 0.910622418, 0)
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.Font = Enum.Font.Unknown
TextButton.Text = "Auto Farm"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 14
TextButton.TextWrapped = true

local Parts = {
    CFrame.new(-53.566, 50.4, 1369.395),
    CFrame.new(-53.566, 50.4, 2139.395),
    CFrame.new(-53.566, 50.4, 2909.395),
    CFrame.new(-53.566, 50.4, 3679.395),
    CFrame.new(-53.566, 50.4, 4449.395),
    CFrame.new(-53.566, 50.4, 5219.395),
    CFrame.new(-53.566, 50.4, 5989.395),
    CFrame.new(-53.566, 50.4, 6759.395),
    CFrame.new(-53.566, 50.4, 7529.395),
    CFrame.new(-53.566, 50.4, 8299.395)
}

local Teleporting = false
local TweenDuration = 2
local CurrentTween = nil

TextButton.Activated:Connect(function()
    Teleporting = not Teleporting

    if not Teleporting then
        if CurrentTween then
            CurrentTween:Cancel()
            CurrentTween = nil
        end

        TextButton.Text = "Auto Farm"
        return
    end

    TextButton.Text = "Parar Auto Farm"

    task.spawn(function()
        while Teleporting do
            local Character = Player.Character
                or Player.CharacterAdded:Wait()

            if not Teleporting then
                break
            end

            local Humanoid = Character:WaitForChild("Humanoid")
            local HRP = Character:WaitForChild("HumanoidRootPart")

            HRP.Anchored = true

            for _, TargetCFrame in ipairs(Parts) do
                if not Teleporting then
                    break
                end
                if not Character.Parent or Humanoid.Health <= 0 then
                    break
                end

                CurrentTween = TweenService:Create(
                    HRP,
                    TweenInfo.new(
                        TweenDuration,
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.InOut
                    ),
                    {CFrame = TargetCFrame}
                )

                CurrentTween:Play()

                local State = CurrentTween.Completed:Wait()
                CurrentTween = nil

                if State ~= Enum.PlaybackState.Completed then
                    break
                end
            end

            if not Teleporting then
                break
            end

            if Character.Parent
                and Humanoid.Health > 0
                and HRP.Position:FuzzyEq(Parts[#Parts].Position, 0.1) then

                HRP.Anchored = false
                Humanoid.Health = 0

                local NewCharacter = Player.Character

                repeat
                    NewCharacter = Player.CharacterAdded:Wait()
                until not Teleporting or NewCharacter ~= Character

                if not Teleporting then
                    break
                end
						
                task.wait(0.5)
            end
        end

        if CurrentTween then
            CurrentTween:Cancel()
            CurrentTween = nil
        end

        TextButton.Text = "Auto Farm"
    end)
end)
```
