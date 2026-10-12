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

local Enabled = false
local TweenDuration = 1.5
local CurrentTween = nil
local RunId = 0

local function log(message)
    print("[AutoFarm] " .. message)
end

local function getCharacter()
    local Character = Player.Character
        or Player.CharacterAdded:Wait()

    local Humanoid = Character:WaitForChild("Humanoid", 10)
    local HRP = Character:WaitForChild("HumanoidRootPart", 10)

    if not Humanoid or not HRP then
        log("ERRO: personagem incompleto após 10 segundos.")
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

end

local function runFarm(myRunId)
    while Enabled and RunId == myRunId do
        local Character, Humanoid, HRP = getCharacter()

        if not Character then
            task.wait(1)
            continue
        end

        if not Enabled or RunId ~= myRunId then
            break
        end

        log("Novo ciclo iniciado.")
        log("Posição inicial: " .. tostring(HRP.Position))

        local CompletedCourse = true

        for Index, TargetCFrame in ipairs(Parts) do
            if not Enabled or RunId ~= myRunId then
                CompletedCourse = false
                break
            end

            if not Character.Parent or Humanoid.Health <= 0 then
                log("ERRO: personagem morreu no ponto " .. Index)
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
                log("AVISO: movimento cancelado no ponto " .. Index)
                CompletedCourse = false
                break
            end

            log(
                "Ponto " .. Index .. " alcançado. Posição: "
                    .. tostring(HRP.Position)
            )
        end

        if not Enabled or RunId ~= myRunId then
            break
        end

        if CompletedCourse
            and Character.Parent
            and Humanoid.Health > 0 then

            log("Percurso concluído. Aguardando 1 segundo.")
            task.wait(1)

            if not Enabled or RunId ~= myRunId then
                break
            end

            if Character.Parent and Humanoid.Health > 0 then
                log("Solicitando morte para reiniciar o ciclo.")

                HRP.Anchored = false
                Humanoid.Health = 0

                log("Aguardando o respawn...")

                local NewCharacter

                repeat
                    NewCharacter = Player.CharacterAdded:Wait()
                until not Enabled
                    or RunId ~= myRunId
                    or NewCharacter ~= Character

                if not Enabled or RunId ~= myRunId then
                    break
                end

                log("Novo personagem detectado. Aguardando 1 segundo.")
                task.wait(1)
            end
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
