-- Cliente_CortarArvore.client.lua
-- Sistema de corte de árvores com machado

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Evento para o servidor (buscar o existente)
local eventos = ReplicatedStorage:WaitForChild("EventosJogo")
local cortarArvoreEvento = eventos:WaitForChild("CortarArvore")
print("🔗 Conectado ao evento CortarArvore")

-- Configurações
local DISTANCIA_CORTE = 8
local TEMPO_ENTRE_GOLPES = 0.8

-- GUI
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CorteArvoreGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local avisoFrame = Instance.new("Frame")
avisoFrame.Name = "AvisoCorte"
avisoFrame.Size = UDim2.new(0, 250, 0, 50)
avisoFrame.Position = UDim2.new(0.5, -125, 0.7, 0)
avisoFrame.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
avisoFrame.BackgroundTransparency = 0.1
avisoFrame.BorderSizePixel = 2
avisoFrame.BorderColor3 = Color3.fromRGB(100, 255, 100)
avisoFrame.Visible = false
avisoFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = avisoFrame

local avisoTexto = Instance.new("TextLabel")
avisoTexto.Size = UDim2.new(1, 0, 1, 0)
avisoTexto.BackgroundTransparency = 1
avisoTexto.Text = "🪓 Pressione [E] para cortar\n🌲 Árvore (0/5)"
avisoTexto.TextColor3 = Color3.fromRGB(255, 255, 255)
avisoTexto.TextSize = 14
avisoTexto.Font = Enum.Font.GothamBold
avisoTexto.Parent = avisoFrame

-- Variáveis
local arvoreProxima = nil
local golpesAtuais = 0
local podeGolpear = true
local temMachado = false

-- Verificar se está segurando machado
local function verificarMachado()
	local char = player.Character
	if not char then return false end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool.Name == "Machado" then
		return true
	end
	return false
end

-- Encontrar árvore próxima
local function encontrarArvoreProxima()
	if not humanoidRootPart then return nil end
	
	local posicaoPlayer = humanoidRootPart.Position
	local arvoreMaisProxima = nil
	local menorDistancia = DISTANCIA_CORTE
	
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") then
			-- Verificar se é uma árvore (Tree ou TreeSpawn)
			local isArvore = objeto.Name:find("Tree") or objeto.Name:find("Arvore") or objeto:GetAttribute("TipoRecurso") == "Madeira"
			
			if isArvore then
				local sucesso, posicao = pcall(function()
					return objeto:GetPivot().Position
				end)
				
				if sucesso and posicao then
					local distancia = (posicaoPlayer - posicao).Magnitude
					if distancia < menorDistancia then
						menorDistancia = distancia
						arvoreMaisProxima = objeto
					end
				end
			end
		end
	end
	
	return arvoreMaisProxima
end

-- Atualizar GUI
RunService.RenderStepped:Connect(function()
	temMachado = verificarMachado()
	
	if not temMachado then
		avisoFrame.Visible = false
		arvoreProxima = nil
		return
	end
	
	local novaArvore = encontrarArvoreProxima()
	
	-- Se mudou de árvore, resetar contador
	if novaArvore ~= arvoreProxima then
		arvoreProxima = novaArvore
		golpesAtuais = 0
	end
	
	if arvoreProxima then
		avisoFrame.Visible = true
		
		-- Animar
		local tempo = tick()
		local escala = 1 + math.sin(tempo * 3) * 0.02
		avisoFrame.Size = UDim2.new(0, 250 * escala, 0, 50 * escala)
		
		avisoTexto.Text = "🪓 Pressione [E] para cortar\n🌲 Árvore (" .. golpesAtuais .. "/1)"
	else
		avisoFrame.Visible = false
	end
end)

-- Golpear árvore
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not temMachado then return end
	if not arvoreProxima then return end
	if not podeGolpear then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		podeGolpear = false
		
		-- Enviar evento ao servidor (nome da árvore)
		cortarArvoreEvento:FireServer(arvoreProxima.Name)
		
		-- Feedback visual
		golpesAtuais = golpesAtuais + 1
		avisoTexto.Text = "🪓 Cortando... (" .. golpesAtuais .. "/1)"
		
		task.wait(TEMPO_ENTRE_GOLPES)
		podeGolpear = true
	end
end)

-- Resetar quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✅ Sistema de corte de árvores carregado!")
