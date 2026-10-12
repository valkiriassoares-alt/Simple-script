local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local TextButton = Instance.new("TextButton")
TextButton.Parent = ScreenGui
TextButton.Position = UDim2.new(0, 0, 0.9106, 0)
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.Text = "Auto Farm"

local Parts = {
    CFrame.new(-53.566, 70, 1369.395),
    CFrame.new(-53.566, 70, 2139.395),
    CFrame.new(-53.566, 70, 2909.395),
    CFrame.new(-53.566, 70, 3679.395),
    CFrame.new(-53.566, 70, 4449.395),
    CFrame.new(-53.566, 70, 5219.395),
    CFrame.new(-53.566, 70, 5989.395),
    CFrame.new(-53.566, 70, 6759.395),
    CFrame.new(-53.566, 70, 7529.395),
    CFrame.new(-53.566, 70, 8299.395)
}

local Enabled = false
local TweenDuration = 1.25
local CurrentTween = nil
local RunId = 0

local function log(message)
    print("[AutoFarm] " .. message)
end

local function getCharacter()
    local Character = Player.Character
        or Player.CharacterAdded:Wait()

    local Humanoid = Character:WaitForChild("Humanoid")
    local HRP = Character:WaitForChild("HumanoidRootPart")

    return Character, Humanoid, HRP
end

local function stopTween()
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end

    local Character = Player.Character
    local HRP = Character
        and Character:FindFirstChild("HumanoidRootPart")

    if HRP then
        HRP.Anchored = false
    end
end

local function runFarm(myRunId)
    while Enabled and RunId == myRunId do
        local Character, Humanoid, HRP = getCharacter()

        if not Enabled or RunId ~= myRunId then
            break
        end

        log("Novo ciclo iniciado.")

        local CompletedCourse = true

        for Index, TargetCFrame in ipairs(Parts) do
            if not Enabled or RunId ~= myRunId then
                CompletedCourse = false
                break
            end

            if not Character.Parent or Humanoid.Health <= 0 then
                CompletedCourse = false
                break
            end

            log("Indo para o ponto " .. Index .. "/" .. #Parts)

            local Tween = TweenService:Create(
                HRP,
                TweenInfo.new(
                    TweenDuration,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.InOut
                ),
                { CFrame = TargetCFrame }
            )

            CurrentTween = Tween
            Tween:Play()

            local State = Tween.Completed:Wait()

            if CurrentTween == Tween then
                CurrentTween = nil
            end

            if State ~= Enum.PlaybackState.Completed then
                CompletedCourse = false
                break
            end

            log("Ponto " .. Index .. " alcançado.")
        end

        if not Enabled or RunId ~= myRunId then
            break
        end

        if CompletedCourse
            and Character.Parent
            and Humanoid.Health > 0 then

            log("Percurso concluído. Solicitando morte.")

            HRP.Anchored = false
            Humanoid.Health = 0

            log("Aguardando o próximo personagem...")
            local NewCharacter = Player.CharacterAdded:Wait()

            if not Enabled or RunId ~= myRunId then
                break
            end

            log("Novo personagem detectado: " .. NewCharacter.Name)
        else
            log("Percurso incompleto. Tentando novamente.")
            task.wait(1)
        end
    end

    stopTween()
    log("Auto Farm desligado.")
end

TextButton.Activated:Connect(function()
    Enabled = not Enabled
    RunId += 1

    if Enabled then
        TextButton.Text = "Parar Auto Farm"
        log("Auto Farm ativado.")
        task.spawn(runFarm, RunId)
    else
        TextButton.Text = "Auto Farm"
        log("Solicitação para parar recebida.")
        stopTween()
    end
end)
