-- Inventario_Simples.lua
-- GUI simples de inventario - pressione I para abrir

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventarioSimples"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame do inventario (inicia escondido)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.Visible = false
frame.Parent = screenGui

-- Titulo
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
titulo.Text = "MOCHILA"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextSize = 18
 titulo.Font = Enum.Font.GothamBold
 titulo.Parent = frame

-- Texto Paus
local textoPaus = Instance.new("TextLabel")
textoPaus.Size = UDim2.new(1, -20, 0, 25)
textoPaus.Position = UDim2.new(0, 10, 0, 40)
textoPaus.BackgroundTransparency = 1
textoPaus.Text = "Paus: 0"
textoPaus.TextColor3 = Color3.fromRGB(100, 255, 100)
textoPaus.TextSize = 16
textoPaus.Parent = frame

-- Botao fechar
local botaoFechar = Instance.new("TextButton")
botaoFechar.Size = UDim2.new(0, 30, 0, 30)
botaoFechar.Position = UDim2.new(1, -30, 0, 0)
botaoFechar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
botaoFechar.Text = "X"
botaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoFechar.Parent = frame

botaoFechar.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- BOTAO DA MOCHILA (canto inferior direito)
local botaoMochila = Instance.new("TextButton")
botaoMochila.Size = UDim2.new(0, 60, 0, 60)
botaoMochila.Position = UDim2.new(1, -70, 1, -70)
botaoMochila.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
botaoMochila.Text = "MOCHILA"
botaoMochila.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoMochila.TextSize = 10
botaoMochila.Parent = screenGui

botaoMochila.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Tecla I para abrir/fechar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.I then
		frame.Visible = not frame.Visible
	end
end)

print("✅ Inventario carregado! Pressione I ou clique no botao MOCHILA")
