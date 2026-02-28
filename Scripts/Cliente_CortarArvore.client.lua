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
local objetoProximo = nil
local tipoObjeto = nil  -- "arvore" ou "tronco"
local golpesAtuais = 0
local podeGolpear = true
local podeColetar = true
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

-- Verificar se é um tronco
local function checkIsTronco(objeto)
	local nomeTemTronco = objeto.Name:find("Tronco")
	local atributoTronco = objeto:GetAttribute("TipoRecurso") == "Tronco"
	return nomeTemTronco or atributoTronco
end

-- Encontrar a posição mais baixa do objeto (base)
local function getPosicaoBase(objeto)
	-- Se for BasePart diretamente, usa ele mesmo
	if objeto:IsA("BasePart") then
		local baseY = objeto.Position.Y - (objeto.Size.Y / 2)
		return Vector3.new(objeto.Position.X, baseY, objeto.Position.Z)
	end
	
	-- Se for Model, procura a parte mais baixa
	local menorY = math.huge
	local posicaoBase = nil
	
	for _, parte in pairs(objeto:GetDescendants()) do
		if parte:IsA("BasePart") then
			local baseY = parte.Position.Y - (parte.Size.Y / 2)
			if baseY < menorY then
				menorY = baseY
				posicaoBase = Vector3.new(parte.Position.X, baseY, parte.Position.Z)
			end
		end
	end
	
	-- Se não achou parte, usa o pivot
	if not posicaoBase then
		return objeto:GetPivot().Position
	end
	
	return posicaoBase
end

-- Encontrar árvore ou tronco próximo (pela base)
local function encontrarArvoreProxima()
	if not humanoidRootPart then return nil, nil end
	
	local posicaoPlayer = humanoidRootPart.Position
	local objetoMaisProximo = nil
	local menorDistancia = DISTANCIA_CORTE
	local tipoObjeto = nil
	
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") then
			-- Verificar se é árvore ou tronco
			local isArvore = objeto.Name:find("Tree") or objeto.Name:find("Arvore") or objeto:GetAttribute("TipoRecurso") == "Madeira"
			local troncoCheck = checkIsTronco(objeto)
			
			if isArvore or troncoCheck then
				local sucesso, posicaoBase = pcall(function()
					return getPosicaoBase(objeto)
				end)
				
				if sucesso and posicaoBase then
					-- Usar apenas X e Z para distância horizontal, Y do player
					local posicaoHorizontal = Vector3.new(posicaoBase.X, posicaoPlayer.Y, posicaoBase.Z)
					local distancia = (posicaoPlayer - posicaoHorizontal).Magnitude
					
					if distancia < menorDistancia then
						menorDistancia = distancia
						objetoMaisProximo = objeto
						tipoObjeto = troncoCheck and "tronco" or "arvore"
					end
				end
			end
		end
	end
	
	return objetoMaisProximo, tipoObjeto
end

-- Atualizar GUI
RunService.RenderStepped:Connect(function()
	temMachado = verificarMachado()
	
	local novoObjeto, novoTipo = encontrarArvoreProxima()
	
	-- Se mudou de objeto, resetar contador
	if novoObjeto ~= objetoProximo then
		objetoProximo = novoObjeto
		tipoObjeto = novoTipo
		golpesAtuais = 0
	end
	
	if objetoProximo then
		-- Verificar se pode interagir (tronco não precisa de machado, árvore sim)
		local podeInteragir = (tipoObjeto == "tronco") or (tipoObjeto == "arvore" and temMachado)
		
		if podeInteragir then
			avisoFrame.Visible = true
			
			-- Animar
			local tempo = tick()
			local escala = 1 + math.sin(tempo * 3) * 0.02
			avisoFrame.Size = UDim2.new(0, 250 * escala, 0, 50 * escala)
			
			-- Texto diferente para árvore ou tronco
			if tipoObjeto == "tronco" then
				avisoTexto.Text = "🪵 Pressione [E] para coletar\n🌲 Tronco"
			else
				avisoTexto.Text = "🪓 Pressione [E] para cortar\n🌲 Árvore (" .. golpesAtuais .. "/1)"
			end
		else
			-- Tem árvore mas não tem machado
			avisoFrame.Visible = true
			avisoTexto.Text = "⚠️ Necessário Machado\n🌲 Árvore"
			avisoFrame.Size = UDim2.new(0, 250, 0, 50)
		end
	else
		avisoFrame.Visible = false
	end
end)

-- Golpear árvore ou coletar tronco
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not objetoProximo then return end
	
	-- Verificar se pode interagir (tronco não precisa de machado, árvore sim)
	local podeInteragir = (tipoObjeto == "tronco") or (tipoObjeto == "arvore" and temMachado)
	if not podeInteragir then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		if tipoObjeto == "arvore" then
			-- Cortar árvore
			if not podeGolpear then return end
			podeGolpear = false
			
			-- Enviar evento ao servidor (nome da árvore)
			cortarArvoreEvento:FireServer(objetoProximo.Name, "cortar")
			
			-- Feedback visual
			golpesAtuais = golpesAtuais + 1
			avisoTexto.Text = "🪓 Cortando... (" .. golpesAtuais .. "/1)"
			
			task.wait(TEMPO_ENTRE_GOLPES)
			podeGolpear = true
			
		elseif tipoObjeto == "tronco" then
			-- Coletar tronco
			if not podeColetar then return end
			podeColetar = false
			
			-- Enviar evento ao servidor (nome do tronco)
			cortarArvoreEvento:FireServer(objetoProximo.Name, "coletar")
			
			avisoTexto.Text = "🪵 Coletando..."
			
			task.wait(0.5)
			podeColetar = true
		end
	end
end)

-- Resetar quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✅ Sistema de corte de árvores carregado!")
