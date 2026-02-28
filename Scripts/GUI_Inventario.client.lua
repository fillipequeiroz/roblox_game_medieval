-- GUI_Inventario.lua
-- Interface do inventário - mostra recursos coletados
-- Tecla I para abrir/fechar + botão flutuante

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar/obter eventos
local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "EventosJogo"
	eventos.Parent = ReplicatedStorage
end

local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")
if not atualizarInventario then
	atualizarInventario = Instance.new("RemoteEvent")
	atualizarInventario.Name = "AtualizarInventario"
	atualizarInventario.Parent = eventos
end

-- Usar GUI existente do StarterGui
local screenGui = playerGui:WaitForChild("InventarioGUI")

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "InventarioFrame"
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0, 10, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
frame.Visible = false
frame.Parent = screenGui

-- Cantos arredondados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Título
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titulo.Text = "📦 INVENTÁRIO"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextSize = 18
titulo.Font = Enum.Font.GothamBold
titulo.Parent = frame

-- Texto Gravetos
local textoGravetos = Instance.new("TextLabel")
textoGravetos.Size = UDim2.new(1, -20, 0, 25)
textoGravetos.Position = UDim2.new(0, 10, 0, 40)
textoGravetos.BackgroundTransparency = 1
textoGravetos.Text = "🌿 Gravetos: 0"
textoGravetos.TextColor3 = Color3.fromRGB(100, 200, 100)
textoGravetos.TextSize = 16
textoGravetos.Font = Enum.Font.Gotham
textoGravetos.TextXAlignment = Enum.TextXAlignment.Left
textoGravetos.Parent = frame

-- Texto Madeira
local textoMadeira = Instance.new("TextLabel")
textoMadeira.Size = UDim2.new(1, -20, 0, 25)
textoMadeira.Position = UDim2.new(0, 10, 0, 70)
textoMadeira.BackgroundTransparency = 1
textoMadeira.Text = "🪵 Madeira: 0"
textoMadeira.TextColor3 = Color3.fromRGB(200, 150, 100)
textoMadeira.TextSize = 16
textoMadeira.Font = Enum.Font.Gotham
textoMadeira.TextXAlignment = Enum.TextXAlignment.Left
textoMadeira.Parent = frame

-- Texto Pedra
local textoPedra = Instance.new("TextLabel")
textoPedra.Size = UDim2.new(1, -20, 0, 25)
textoPedra.Position = UDim2.new(0, 10, 0, 100)
textoPedra.BackgroundTransparency = 1
textoPedra.Text = "🪨 Pedra: 0"
textoPedra.TextColor3 = Color3.fromRGB(150, 150, 150)
textoPedra.TextSize = 16
textoPedra.Font = Enum.Font.Gotham
textoPedra.TextXAlignment = Enum.TextXAlignment.Left
textoPedra.Parent = frame

-- Botão fechar
local botaoFechar = Instance.new("TextButton")
botaoFechar.Size = UDim2.new(0, 30, 0, 30)
botaoFechar.Position = UDim2.new(1, -35, 0, 0)
botaoFechar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
botaoFechar.Text = "X"
botaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoFechar.TextSize = 16
textoPedra.Font = Enum.Font.GothamBold
botaoFechar.Parent = frame

botaoFechar.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- BOTÃO FLUTUANTE 📦
local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Name = "BotaoInventario"
botaoFlutuante.Size = UDim2.new(0, 70, 0, 70)
botaoFlutuante.Position = UDim2.new(1, -80, 1, -80)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
botaoFlutuante.Text = "📦"
botaoFlutuante.TextSize = 35
botaoFlutuante.Parent = screenGui

local botaoCorner = Instance.new("UICorner")
botaoCorner.CornerRadius = UDim.new(1, 0)
botaoCorner.Parent = botaoFlutuante

botaoFlutuante.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Atualizar inventário
atualizarInventario.OnClientEvent:Connect(function(inventario)
	textoGravetos.Text = "🌿 Gravetos: " .. (inventario.gravetos or 0)
	textoMadeira.Text = "🪵 Madeira: " .. (inventario.madeira or 0)
	textoPedra.Text = "🪨 Pedra: " .. (inventario.pedra or 0)
end)

-- Tecla I para abrir/fechar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.I then
		frame.Visible = not frame.Visible
	end
end)

print("✅ GUI de Inventário carregado! Pressione 'I' ou clique no botão 📦")
