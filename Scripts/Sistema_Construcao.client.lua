--[[
    SISTEMA DE CONSTRUÇÃO
    Coloque este script em StarterGui (dentro de uma ScreenGui separada)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Eventos
local eventos = ReplicatedStorage:WaitForChild("EventosJogo")
local construirEvento = eventos:FindFirstChild("ConstruirEstrutura")
if not construirEvento then
	construirEvento = Instance.new("RemoteEvent")
	construirEvento.Name = "ConstruirEstrutura"
	construirEvento.Parent = eventos
end

-- Custo das estruturas
local CUSTOS = {
	["ParedePedra"] = { pedra = 3, madeira = 0 },
	["ChaoMadeira"] = { pedra = 0, madeira = 3 },
	["Torre"] = { pedra = 10, madeira = 5 },
	["Portao"] = { pedra = 5, madeira = 8 }
}

-- Modo construção
local modoConstrucao = false
local estruturaSelecionada = nil
local previewEstrutura = nil

-- Usar GUI existente do StarterGui
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ConstrucaoGUI")

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "ConstrucaoFrame"
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
frame.Visible = false
frame.Parent = screenGui

-- Título
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 25)
titulo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titulo.Text = "🏗️ CONSTRUÇÃO"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextSize = 16
titulo.Font = Enum.Font.GothamBold
titulo.Parent = frame

-- Função para criar botão de estrutura
local function criarBotaoEstrutura(nome, posicao, custo)
	local botao = Instance.new("TextButton")
	botao.Name = nome
	botao.Size = UDim2.new(0, 130, 0, 40)
	botao.Position = posicao
	botao.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	botao.Text = nome .. "\n🪨" .. custo.pedra .. " 🪵" .. custo.madeira
	botao.TextColor3 = Color3.fromRGB(255, 255, 255)
	botao.TextSize = 12
	botao.Font = Enum.Font.Gotham
	botao.TextWrapped = true
	botao.Parent = frame
	
	botao.MouseButton1Click:Connect(function()
		selecionarEstrutura(nome)
	end)
	
	return botao
end

-- Criar botões
criarBotaoEstrutura("ParedePedra", UDim2.new(0, 10, 0, 35), CUSTOS["ParedePedra"])
criarBotaoEstrutura("ChaoMadeira", UDim2.new(0, 160, 0, 35), CUSTOS["ChaoMadeira"])
criarBotaoEstrutura("Torre", UDim2.new(0, 10, 0, 85), CUSTOS["Torre"])
criarBotaoEstrutura("Portao", UDim2.new(0, 160, 0, 85), CUSTOS["Portao"])

-- Botão fechar
local botaoFechar = Instance.new("TextButton")
botaoFechar.Size = UDim2.new(0, 25, 0, 25)
botaoFechar.Position = UDim2.new(1, -25, 0, 0)
botaoFechar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
botaoFechar.Text = "X"
botaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoFechar.TextSize = 14
botaoFechar.Font = Enum.Font.GothamBold
botaoFechar.Parent = frame

botaoFechar.MouseButton1Click:Connect(function()
	frame.Visible = false
	modoConstrucao = false
	if previewEstrutura then
		previewEstrutura:Destroy()
		previewEstrutura = nil
	end
end)

-- Função para selecionar estrutura
function selecionarEstrutura(nome)
	modoConstrucao = true
	estruturaSelecionada = nome
	frame.Visible = false
	
	-- Criar preview (representação visual)
	if previewEstrutura then
		previewEstrutura:Destroy()
	end
	
	previewEstrutura = Instance.new("Part")
	previewEstrutura.Anchored = true
	previewEstrutura.CanCollide = false
	previewEstrutura.Transparency = 0.5
	
	-- Configurar tamanho baseado no tipo
	if nome == "ParedePedra" then
		previewEstrutura.Size = Vector3.new(4, 6, 1)
		previewEstrutura.Color = Color3.fromRGB(100, 100, 100)
	elseif nome == "ChaoMadeira" then
		previewEstrutura.Size = Vector3.new(4, 1, 4)
		previewEstrutura.Color = Color3.fromRGB(139, 90, 43)
	elseif nome == "Torre" then
		previewEstrutura.Size = Vector3.new(4, 10, 4)
		previewEstrutura.Color = Color3.fromRGB(80, 80, 80)
	elseif nome == "Portao" then
		previewEstrutura.Size = Vector3.new(6, 5, 1)
		previewEstrutura.Color = Color3.fromRGB(101, 67, 33)
	end
	
	previewEstrutura.Parent = workspace
	
	print("🏗️ Modo construção: " .. nome .. " | Clique para construir | Pressione Q para cancelar")
end

-- Atualizar posição do preview
RunService.RenderStepped:Connect(function()
	if modoConstrucao and previewEstrutura then
		local camera = workspace.CurrentCamera
		local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {player.Character, previewEstrutura}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		
		local resultado = workspace:Raycast(ray.Origin, ray.Direction * 50, raycastParams)
		
		if resultado then
			local posicao = resultado.Position
			-- Alinhar na grade
			posicao = Vector3.new(
				math.floor(posicao.X / 2) * 2,
				posicao.Y + previewEstrutura.Size.Y / 2,
				math.floor(posicao.Z / 2) * 2
			)
			previewEstrutura.Position = posicao
		end
	end
end)

-- Construir ao clicar
mouse.Button1Down:Connect(function()
	if modoConstrucao and previewEstrutura and estruturaSelecionada then
		local posicao = previewEstrutura.Position
		construirEvento:FireServer(estruturaSelecionada, posicao)
	end
end)

-- Cancelar com Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.B then
		frame.Visible = not frame.Visible
		modoConstrucao = false
		if previewEstrutura then
			previewEstrutura:Destroy()
			previewEstrutura = nil
		end
	elseif input.KeyCode == Enum.KeyCode.Q then
		modoConstrucao = false
		estruturaSelecionada = nil
		if previewEstrutura then
			previewEstrutura:Destroy()
			previewEstrutura = nil
		end
		print("❌ Modo construção cancelado")
	end
end)

print("✅ Sistema de Construção carregado! Pressione 'B' para abrir o menu")
