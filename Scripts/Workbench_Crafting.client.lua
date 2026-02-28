-- Workbench_Crafting.client.lua
-- Interface de crafting na bancada - seleção de ferramentas

print("🔨 WORKBENCH CRAFTING CLIENT INICIANDO...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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

-- Dados das ferramentas disponíveis
local FERRAMENTAS = {
	{
		nome = "Machado",
		descricao = "Usado para cortar madeira",
		icone = "🪓",
		custo = { recurso = "paus", quantidade = 1, nomeExibicao = "Pau" },
		corFundo = Color3.fromRGB(139, 69, 19) -- Marrom para madeira
	},
	{
		nome = "Picareta",
		descricao = "Usada para minerar pedra",
		icone = "⛏️",
		custo = { recurso = "paus", quantidade = 2, nomeExibicao = "Paus" },
		corFundo = Color3.fromRGB(70, 70, 70) -- Cinza escuro para pedra
	}
}

-- GUI Principal
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WorkbenchGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame do aviso de proximidade
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

local cornerAviso = Instance.new("UICorner")
cornerAviso.CornerRadius = UDim.new(0, 10)
cornerAviso.Parent = avisoFrame

local avisoTexto = Instance.new("TextLabel")
avisoTexto.Name = "TextoCrafting"
avisoTexto.Size = UDim2.new(1, 0, 1, 0)
avisoTexto.BackgroundTransparency = 1
avisoTexto.Text = "🔨 Pressione [E] para abrir Workbench"
avisoTexto.TextColor3 = Color3.fromRGB(255, 255, 255)
avisoTexto.TextSize = 14
avisoTexto.Font = Enum.Font.GothamBold
avisoTexto.Parent = avisoFrame

-- Frame principal do menu de crafting
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuCrafting"
menuFrame.Size = UDim2.new(0, 400, 0, 300)
menuFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
menuFrame.BackgroundTransparency = 0.05
menuFrame.BorderSizePixel = 3
menuFrame.BorderColor3 = Color3.fromRGB(200, 150, 80)
menuFrame.Visible = false
menuFrame.Parent = screenGui

local cornerMenu = Instance.new("UICorner")
cornerMenu.CornerRadius = UDim.new(0, 15)
cornerMenu.Parent = menuFrame

-- Título do menu
local titulo = Instance.new("TextLabel")
titulo.Name = "Titulo"
titulo.Size = UDim2.new(1, 0, 0, 50)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "⚒️ WORKBENCH - CRAFTING"
titulo.TextColor3 = Color3.fromRGB(255, 200, 100)
titulo.TextSize = 20
titulo.Font = Enum.Font.GothamBold
titulo.Parent = menuFrame

-- Subtítulo
local subtitulo = Instance.new("TextLabel")
subtitulo.Name = "Subtitulo"
subtitulo.Size = UDim2.new(1, 0, 0, 25)
subtitulo.Position = UDim2.new(0, 0, 0, 40)
subtitulo.BackgroundTransparency = 1
subtitulo.Text = "Selecione uma ferramenta para criar"
subtitulo.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitulo.TextSize = 12
subtitulo.Font = Enum.Font.Gotham
titulo.Parent = menuFrame

-- Container de ferramentas
local container = Instance.new("ScrollingFrame")
container.Name = "ContainerFerramentas"
container.Size = UDim2.new(1, -20, 1, -100)
container.Position = UDim2.new(0, 10, 0, 70)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 6
container.ScrollBarImageColor3 = Color3.fromRGB(200, 150, 80)
container.CanvasSize = UDim2.new(0, 0, 0, #FERRAMENTAS * 90)
container.Parent = menuFrame

-- Botão de fechar
local botaoFechar = Instance.new("TextButton")
botaoFechar.Name = "Fechar"
botaoFechar.Size = UDim2.new(0, 100, 0, 35)
botaoFechar.Position = UDim2.new(0.5, -50, 1, -50)
botaoFechar.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
botaoFechar.Text = "FECHAR [X]"
botaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoFechar.TextSize = 14
botaoFechar.Font = Enum.Font.GothamBold
botaoFechar.Parent = menuFrame

local cornerFechar = Instance.new("UICorner")
cornerFechar.CornerRadius = UDim.new(0, 8)
cornerFechar.Parent = botaoFechar

-- Criar cards das ferramentas
local ferramentaCards = {}

for i, ferramenta in ipairs(FERRAMENTAS) do
	-- Frame do card
	local card = Instance.new("Frame")
	card.Name = "Card_" .. ferramenta.nome
	card.Size = UDim2.new(1, -10, 0, 80)
	card.Position = UDim2.new(0, 5, 0, (i-1) * 85)
	card.BackgroundColor3 = ferramenta.corFundo
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 2
	card.BorderColor3 = Color3.fromRGB(200, 150, 80)
	card.Parent = container
	
	local cornerCard = Instance.new("UICorner")
	cornerCard.CornerRadius = UDim.new(0, 10)
	cornerCard.Parent = card
	
	-- Ícone da ferramenta
	local icone = Instance.new("TextLabel")
	icone.Name = "Icone"
	icone.Size = UDim2.new(0, 50, 0, 50)
	icone.Position = UDim2.new(0, 15, 0, 15)
	icone.BackgroundTransparency = 1
	icone.Text = ferramenta.icone
	icone.TextSize = 40
	icone.Parent = card
	
	-- Nome da ferramenta
	local nome = Instance.new("TextLabel")
	nome.Name = "Nome"
	nome.Size = UDim2.new(1, -80, 0, 25)
	nome.Position = UDim2.new(0, 75, 0, 10)
	nome.BackgroundTransparency = 1
	nome.Text = ferramenta.nome
	nome.TextColor3 = Color3.fromRGB(255, 255, 255)
	nome.TextSize = 18
	nome.Font = Enum.Font.GothamBold
	nome.TextXAlignment = Enum.TextXAlignment.Left
	nome.Parent = card
	
	-- Descrição
	local descricao = Instance.new("TextLabel")
	descricao.Name = "Descricao"
	descricao.Size = UDim2.new(1, -80, 0, 20)
	descricao.Position = UDim2.new(0, 75, 0, 35)
	descricao.BackgroundTransparency = 1
	descricao.Text = ferramenta.descricao
	descricao.TextColor3 = Color3.fromRGB(200, 200, 200)
	descricao.TextSize = 11
	descricao.Font = Enum.Font.Gotham
	descricao.TextXAlignment = Enum.TextXAlignment.Left
	descricao.Parent = card
	
	-- Custo
	local custo = Instance.new("TextLabel")
	custo.Name = "Custo"
	custo.Size = UDim2.new(1, -80, 0, 20)
	custo.Position = UDim2.new(0, 75, 0, 55)
	custo.BackgroundTransparency = 1
	custo.Text = "🌿 Requer: " .. ferramenta.custo.quantidade .. " " .. ferramenta.custo.nomeExibicao
	custo.TextColor3 = Color3.fromRGB(100, 255, 100)
	custo.TextSize = 12
	custo.Font = Enum.Font.GothamBold
	custo.TextXAlignment = Enum.TextXAlignment.Left
	custo.Parent = card
	
	-- Botão de craftar
	local botaoCraft = Instance.new("TextButton")
	botaoCraft.Name = "BotaoCraft"
	botaoCraft.Size = UDim2.new(0, 80, 0, 35)
	botaoCraft.Position = UDim2.new(1, -95, 0.5, -17)
	botaoCraft.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	botaoCraft.Text = "CRIAR"
	botaoCraft.TextColor3 = Color3.fromRGB(255, 255, 255)
	botaoCraft.TextSize = 14
	botaoCraft.Font = Enum.Font.GothamBold
	botaoCraft.Parent = card
	
	local cornerBotao = Instance.new("UICorner")
	cornerBotao.CornerRadius = UDim.new(0, 6)
	cornerBotao.Parent = botaoCraft
	
	-- Guardar referência
	ferramentaCards[ferramenta.nome] = {
		card = card,
		botao = botaoCraft,
		custoLabel = custo
	}
	
	-- Hover effect
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	end)
	
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
	end)
	
	-- Clique para craftar
	botaoCraft.MouseButton1Click:Connect(function()
		craftarFerramenta(ferramenta)
	end)
end

-- Variáveis de controle
local workbenchProxima = nil
local tempoUltimoCraft = 0
local menuAberto = false

-- Função para craftar ferramenta
function craftarFerramenta(ferramenta)
	local tempoAtual = tick()
	if tempoAtual - tempoUltimoCraft < TEMPO_ENTRE_CRAFTS then
		return
	end
	
	tempoUltimoCraft = tempoAtual
	
	-- Atualizar botão
	local cardData = ferramentaCards[ferramenta.nome]
	if cardData then
		cardData.botao.Text = "..."
		cardData.botao.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end
	
	-- Enviar evento ao servidor
	craftarItemEvento:FireServer(ferramenta.nome)
	
	-- Resetar botão após delay
	task.delay(0.5, function()
		if cardData then
			cardData.botao.Text = "CRIAR"
			cardData.botao.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		end
	end)
end

-- Função para abrir/fechar menu
function toggleMenu()
	menuAberto = not menuAberto
	menuFrame.Visible = menuAberto
	avisoFrame.Visible = not menuAberto and workbenchProxima ~= nil
	
	if menuAberto then
		-- Animar entrada
		menuFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.new(0, 400, 0, 300)
		}):Play()
	end
end

function fecharMenu()
	menuAberto = false
	menuFrame.Visible = false
	if workbenchProxima then
		avisoFrame.Visible = true
	end
end

-- Função para encontrar workbench próxima
local function encontrarWorkbenchProxima()
	if not humanoidRootPart then return nil end
	
	local posicaoPlayer = humanoidRootPart.Position
	local workbenchMaisProxima = nil
	local menorDistancia = DISTANCIA_WORKBENCH
	
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") or objeto:IsA("Part") or objeto:IsA("MeshPart") then
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
	local novaWorkbench = encontrarWorkbenchProxima()
	
	-- Se saiu da área da workbench
	if workbenchProxima and not novaWorkbench then
		workbenchProxima = nil
		avisoFrame.Visible = false
		fecharMenu()
	-- Se entrou na área da workbench
	elseif novaWorkbench and not workbenchProxima then
		workbenchProxima = novaWorkbench
		if not menuAberto then
			avisoFrame.Visible = true
		end
	end
	
	workbenchProxima = novaWorkbench
	
	-- Animar aviso
	if avisoFrame.Visible then
		local tempo = tick()
		local escala = 1 + math.sin(tempo * 3) * 0.02
		avisoFrame.Size = UDim2.new(0, 280 * escala, 0, 60 * escala)
	end
end)

-- Input: E para abrir menu, X para fechar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Abrir menu com E
	if input.KeyCode == Enum.KeyCode.E then
		if workbenchProxima and not menuAberto then
			toggleMenu()
		end
	end
	
	-- Fechar menu com X
	if input.KeyCode == Enum.KeyCode.X then
		if menuAberto then
			fecharMenu()
		end
	end
end)

-- Botão de fechar
botaoFechar.MouseButton1Click:Connect(fecharMenu)

-- Recarregar character quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	fecharMenu()
end)

print("✅ Sistema de Crafting na Workbench carregado! Aproxime-se e pressione E")
