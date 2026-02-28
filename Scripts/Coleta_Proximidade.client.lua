-- Coleta_Proximidade.lua
-- Detecta itens próximos e permite coletar pressionando E
print("🚀 COLETA PROXIMIDADE INICIANDO 2...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

local coletarItemEvento = eventos:FindFirstChild("ColetarItemProximidade")
if not coletarItemEvento then
	coletarItemEvento = Instance.new("RemoteEvent")
	coletarItemEvento.Name = "ColetarItemProximidade"
	coletarItemEvento.Parent = eventos
end

-- Configurações
local DISTANCIA_COLETA = 5
local TEMPO_ENTRE_COLETAS = 0.5

-- GUI - Usar a GUI existente do StarterGui
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ColetaGUI")

-- Criar elementos da GUI se não existirem
local avisoFrame = screenGui:FindFirstChild("AvisoColeta")
if not avisoFrame then
	avisoFrame = Instance.new("Frame")
	avisoFrame.Name = "AvisoColeta"
	avisoFrame.Size = UDim2.new(0, 220, 0, 50)
	avisoFrame.Position = UDim2.new(0.5, -110, 0.7, 0)
	avisoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	avisoFrame.BackgroundTransparency = 0.2
	avisoFrame.BorderSizePixel = 2
	avisoFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	avisoFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = avisoFrame

	local avisoTexto = Instance.new("TextLabel")
	avisoTexto.Name = "AvisoTexto"
	avisoTexto.Size = UDim2.new(1, -40, 1, 0)
	avisoTexto.Position = UDim2.new(0, 40, 0, 0)
	avisoTexto.BackgroundTransparency = 1
	avisoTexto.Text = "Pressione [E] para pegar"
	avisoTexto.TextColor3 = Color3.fromRGB(255, 255, 255)
	avisoTexto.TextSize = 16
	avisoTexto.Font = Enum.Font.GothamBold
	avisoTexto.Parent = avisoFrame

	local icone = Instance.new("TextLabel")
	icone.Name = "Icone"
	icone.Size = UDim2.new(0, 35, 0, 35)
	icone.Position = UDim2.new(0, 5, 0.5, -17)
	icone.BackgroundTransparency = 1
	icone.Text = "🌿"
	icone.TextSize = 28
	icone.Parent = avisoFrame
end

local avisoTexto = avisoFrame:WaitForChild("AvisoTexto")
local icone = avisoFrame:WaitForChild("Icone")

-- Variáveis de controle
local itemProximo = nil
local tempoUltimaColeta = 0

-- Verificar itens próximos
local function verificarItensProximos()
	if not humanoidRootPart then return nil end
	
	local posicaoPlayer = humanoidRootPart.Position
	local itemMaisProximo = nil
	local menorDistancia = DISTANCIA_COLETA
	
	for _, objeto in pairs(workspace:GetDescendants()) do
		if objeto:IsA("Model") or objeto:IsA("Part") or objeto:IsA("MeshPart") then
			local tipoRecurso = objeto:GetAttribute("TipoRecurso")
			if tipoRecurso == "Stick" or tipoRecurso == "Graveto" or tipoRecurso == "Pedra" or tipoRecurso == "Stone" then
				local sucesso, posicao = pcall(function()
					return objeto:GetPivot().Position
				end)
				
				if sucesso and posicao then
					local distancia = (posicaoPlayer - posicao).Magnitude
					if distancia < menorDistancia then
						menorDistancia = distancia
						itemMaisProximo = objeto
					end
				end
			end
		end
	end
	
	return itemMaisProximo
end

-- Atualizar a cada frame
RunService.RenderStepped:Connect(function()
	itemProximo = verificarItensProximos()
	
	if itemProximo then
		avisoFrame.Visible = true
		
		-- Animar
		local tempo = tick()
		local escala = 1 + math.sin(tempo * 5) * 0.03
		avisoFrame.Size = UDim2.new(0, 220 * escala, 0, 50 * escala)
		
		-- Atualizar ícone baseado no tipo
		local tipo = itemProximo:GetAttribute("TipoRecurso")
		if tipo == "Pedra" or tipo == "Stone" then
			icone.Text = "🪨"
		else
			icone.Text = "🌿"
		end
	else
		avisoFrame.Visible = false
	end
end)

-- Coletar ao pressionar E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		local tempoAtual = tick()
		if tempoAtual - tempoUltimaColeta < TEMPO_ENTRE_COLETAS then
			return
		end
		
		if itemProximo then
			tempoUltimaColeta = tempoAtual
			coletarItemEvento:FireServer(itemProximo)
			
			avisoTexto.Text = "Coletando..."
			task.delay(0.3, function()
				avisoTexto.Text = "Pressione [E] para pegar"
			end)
		end
	end
end)

-- Recarregar character quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✅ Sistema de Coleta por Proximidade carregado! Aproxime-se de sticks e pressione E")
