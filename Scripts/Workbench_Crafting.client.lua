-- Workbench_Crafting.client.lua
-- Sistema de crafting na bancada - pressione E para criar machado

print("🔨 WORKBENCH CRAFTING CLIENT INICIANDO...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Criar/obter eventos
local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "EventosJogo"
	eventos.Parent = ReplicatedStorage
end

local craftarItemEvento = eventos:FindFirstChild("CraftarItem")
if not craftarItemEvento then
	craftarItemEvento = Instance.new("RemoteEvent")
	craftarItemEvento.Name = "CraftarItem"
	craftarItemEvento.Parent = eventos
end

-- Configurações
local DISTANCIA_WORKBENCH = 8
local TEMPO_ENTRE_CRAFTS = 1

-- GUI - Aviso de crafting
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WorkbenchGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local avisoFrame = Instance.new("Frame")
avisoFrame.Name = "AvisoCrafting"
avisoFrame.Size = UDim2.new(0, 280, 0, 60)
avisoFrame.Position = UDim2.new(0.5, -140, 0.7, 0)
avisoFrame.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
avisoFrame.BackgroundTransparency = 0.1
avisoFrame.BorderSizePixel = 2
avisoFrame.BorderColor3 = Color3.fromRGB(200, 150, 80)
avisoFrame.Visible = false
avisoFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = avisoFrame

local avisoTexto = Instance.new("TextLabel")
avisoTexto.Name = "TextoCrafting"
avisoTexto.Size = UDim2.new(1, 0, 1, 0)
avisoTexto.BackgroundTransparency = 1
avisoTexto.Text = "🔨 Pressione [E] para criar Machado\n🌿 Requer: 1 Pau"
avisoTexto.TextColor3 = Color3.fromRGB(255, 255, 255)
avisoTexto.TextSize = 14
avisoTexto.Font = Enum.Font.GothamBold
avisoTexto.Parent = avisoFrame

-- Variáveis de controle
local workbenchProxima = nil
local tempoUltimoCraft = 0

-- Função para encontrar workbench próxima
local function encontrarWorkbenchProxima()
	if not humanoidRootPart then return nil end
	
	local posicaoPlayer = humanoidRootPart.Position
	local workbenchMaisProxima = nil
	local menorDistancia = DISTANCIA_WORKBENCH
	
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") or objeto:IsA("Part") or objeto:IsA("MeshPart") then
			-- Procura por atributo ou nome
			local isWorkbench = objeto:GetAttribute("Tipo") == "Workbench" 
				or objeto.Name:lower():find("workbench") 
				or objeto.Name:lower():find("bancada")
			
			if isWorkbench then
				local sucesso, posicao = pcall(function()
					return objeto:GetPivot().Position
				end)
				
				if sucesso and posicao then
					local distancia = (posicaoPlayer - posicao).Magnitude
					if distancia < menorDistancia then
						menorDistancia = distancia
						workbenchMaisProxima = objeto
					end
				end
			end
		end
	end
	
	return workbenchMaisProxima
end

-- Atualizar a cada frame
RunService.RenderStepped:Connect(function()
	workbenchProxima = encontrarWorkbenchProxima()
	
	if workbenchProxima then
		avisoFrame.Visible = true
		
		-- Animar
		local tempo = tick()
		local escala = 1 + math.sin(tempo * 3) * 0.02
		avisoFrame.Size = UDim2.new(0, 280 * escala, 0, 60 * escala)
	else
		avisoFrame.Visible = false
	end
end)

-- Craftar ao pressionar E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		if not workbenchProxima then return end
		
		local tempoAtual = tick()
		if tempoAtual - tempoUltimoCraft < TEMPO_ENTRE_CRAFTS then
			return
		end
		
		tempoUltimoCraft = tempoAtual
		
		-- Enviar evento ao servidor
		craftarItemEvento:FireServer("Machado")
		
		-- Feedback visual
		avisoTexto.Text = "🔨 Craftando..."
		task.delay(0.5, function()
			avisoTexto.Text = "🔨 Pressione [E] para criar Machado\n🌿 Requer: 1 Pau"
		end)
	end
end)

-- Recarregar character quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✅ Sistema de Crafting na Workbench carregado! Aproxime-se e pressione E")
