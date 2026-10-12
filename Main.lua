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
    CFrame.new(-53.566, 60.4, 1369.395),
    CFrame.new(-53.566, 60.4, 2139.395),
    CFrame.new(-53.566, 60.4, 2909.395),
    CFrame.new(-53.566, 60.4, 3679.395),
    CFrame.new(-53.566, 60.4, 4449.395),
    CFrame.new(-53.566, 60.4, 5219.395),
    CFrame.new(-53.566, 60.4, 5989.395),
    CFrame.new(-53.566, 60.4, 6759.395),
    CFrame.new(-53.566, 60.4, 7529.395),
    CFrame.new(-53.566, 60.4, 8299.395)
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

    if not Character then
        Character = Player.CharacterAdded:Wait()
    end

    if not Enabled then
        return nil
    end

    local Humanoid = Character:WaitForChild("Humanoid", 10)

    if not Humanoid then
        log("ERRO: Humanoid não apareceu em 10 segundos.")
        return nil
    end

    local HRP = Character:WaitForChild("HumanoidRootPart", 10)

    if not HRP then
        log("ERRO: HumanoidRootPart não apareceu em 10 segundos.")
        return nil
    end

    if not Character.Parent or Player.Character ~= Character then
        log("Personagem substituído durante a inicialização.")
        return nil
    end

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

        if not Character then
            task.wait(0.5)
            continue
        end

        if Humanoid.Health <= 0 then
            task.wait(0.5)
            continue
        end

        log("Novo ciclo iniciado.")

        local CompletedCourse = true

        for Index, TargetCFrame in ipairs(Parts) do
            if not Enabled or RunId ~= myRunId then
                CompletedCourse = false
                break
            end

            if Player.Character ~= Character
                or not Character.Parent
                or Humanoid.Health <= 0 then

                log("Personagem mudou durante o percurso.")
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

            if not Enabled or RunId ~= myRunId then
                CompletedCourse = false
                break
            end

            if State ~= Enum.PlaybackState.Completed then
                log("Movimento cancelado no ponto " .. Index)
                CompletedCourse = false
                break
            end

            log("Ponto " .. Index .. " alcançado.")
        end

        if not Enabled or RunId ~= myRunId then
            break
        end

        if CompletedCourse
            and Player.Character == Character
            and Character.Parent
            and Humanoid.Health > 0 then

            log("Percurso concluído. Solicitando morte.")

            HRP.Anchored = false
            Humanoid.Health = 0

            log("Aguardando o próximo personagem...")

            local NewCharacter = Player.Character

            while Enabled
                and RunId == myRunId
                and NewCharacter == Character do

                NewCharacter = Player.CharacterAdded:Wait()
            end

            if not Enabled or RunId ~= myRunId then
                break
            end

            log("Novo personagem detectado.")
        else
            log("Percurso incompleto. Tentando novamente.")
            task.wait(0.5)
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
