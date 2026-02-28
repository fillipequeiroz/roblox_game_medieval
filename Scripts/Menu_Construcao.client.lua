-- Menu_Construcao.client.lua
-- Menu de construção - adiciona itens à hotbar nativa do Roblox
-- Ao equipar o item, entra no modo preview de posicionamento

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterPack = game:GetService("StarterPack")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Criar/obter eventos
local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "EventosJogo"
	eventos.Parent = ReplicatedStorage
end

local construirItemEvento = eventos:FindFirstChild("ConstruirItem")
if not construirItemEvento then
	construirItemEvento = Instance.new("RemoteEvent")
	construirItemEvento.Name = "ConstruirItem"
	construirItemEvento.Parent = eventos
end

local atualizarInventario = eventos:WaitForChild("AtualizarInventario")

-- Dados do inventário local
local inventarioAtual = { gravetos = 0, madeira = 0, pedra = 0 }

-- Estado
local modoConstrucao = false
local itemPreview = nil
local itemTool = nil
local distanciaPreview = 5

-- Receber atualizações do inventário
atualizarInventario.OnClientEvent:Connect(function(inventario)
	inventarioAtual = inventario
end)

-- Atualizar character quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	-- Se tinha modo ativo, cancelar
	if modoConstrucao then
		cancelarModoConstrucao()
	end
end)

-- Usar GUI existente
local screenGui = playerGui:WaitForChild("InventarioGUI")

-- ==================== BOTÃO DE CONSTRUÇÃO ====================

local botaoConstrucao = Instance.new("TextButton")
botaoConstrucao.Name = "BotaoConstrucao"
botaoConstrucao.Size = UDim2.new(0, 70, 0, 70)
botaoConstrucao.Position = UDim2.new(1, -160, 1, -80)
botaoConstrucao.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
botaoConstrucao.Text = "🔨"
botaoConstrucao.TextSize = 35
botaoConstrucao.Parent = screenGui

local botaoCorner = Instance.new("UICorner")
botaoCorner.CornerRadius = UDim.new(1, 0)
botaoCorner.Parent = botaoConstrucao

-- ==================== MENU DE CONSTRUÇÃO ====================

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuConstrucao"
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

-- Título
local titulo = Instance.new("TextLabel")
titulo.Name = "Titulo"
titulo.Size = UDim2.new(1, 0, 0, 50)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "🔨 CONSTRUÇÃO"
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
subtitulo.Text = "Adicione itens à sua hotbar"
subtitulo.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitulo.TextSize = 12
subtitulo.Font = Enum.Font.Gotham
subtitulo.Parent = menuFrame

-- Container de itens
local container = Instance.new("ScrollingFrame")
container.Name = "ContainerItens"
container.Size = UDim2.new(1, -20, 1, -90)
container.Position = UDim2.new(0, 10, 0, 70)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 6
container.ScrollBarImageColor3 = Color3.fromRGB(200, 150, 80)
container.CanvasSize = UDim2.new(0, 0, 0, 100)
container.Parent = menuFrame

-- Botão de fechar
local botaoFechar = Instance.new("TextButton")
botaoFechar.Name = "Fechar"
botaoFechar.Size = UDim2.new(0, 100, 0, 35)
botaoFechar.Position = UDim2.new(0.5, -50, 1, -45)
botaoFechar.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
botaoFechar.Text = "FECHAR"
botaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoFechar.TextSize = 14
botaoFechar.Font = Enum.Font.GothamBold
botaoFechar.Parent = menuFrame

local cornerFechar = Instance.new("UICorner")
cornerFechar.CornerRadius = UDim.new(0, 8)
cornerFechar.Parent = botaoFechar

-- ==================== GUI DE POSICIONAMENTO ====================

local guiPosicionamento = Instance.new("ScreenGui")
guiPosicionamento.Name = "GUI_Posicionamento"
guiPosicionamento.ResetOnSpawn = false

local avisoPosicionar = Instance.new("Frame")
avisoPosicionar.Name = "AvisoPosicionar"
avisoPosicionar.Size = UDim2.new(0, 350, 0, 60)
avisoPosicionar.Position = UDim2.new(0.5, -175, 0.8, 0)
avisoPosicionar.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
avisoPosicionar.BackgroundTransparency = 0.1
avisoPosicionar.BorderSizePixel = 2
avisoPosicionar.BorderColor3 = Color3.fromRGB(100, 255, 100)

local cornerAviso = Instance.new("UICorner")
cornerAviso.CornerRadius = UDim.new(0, 10)
cornerAviso.Parent = avisoPosicionar

local textoAviso = Instance.new("TextLabel")
textoAviso.Size = UDim2.new(1, 0, 1, 0)
textoAviso.BackgroundTransparency = 1
textoAviso.Text = "📍 Posicione o item\nPressione [E] para fixar ou [ESC] para cancelar"
textoAviso.TextColor3 = Color3.fromRGB(255, 255, 255)
textoAviso.TextSize = 14
textoAviso.Font = Enum.Font.GothamBold
textoAviso.Parent = avisoPosicionar

avisoPosicionar.Parent = guiPosicionamento
guiPosicionamento.Parent = playerGui

-- ==================== CONFIGURAÇÃO DOS ITENS ====================

local ITENS_CONSTRUCAO = {
	{
		nome = "Workbench",
		nomeExibicao = "Bancada de Trabalho",
		descricao = "Equipe para posicionar",
		icone = "🔨",
		hotbarIcone = "rbxassetid://0", -- Usar ícone padrão ou customizar
		custo = {
			{ recurso = "gravetos", quantidade = 10, icone = "🌿", nome = "Gravetos" },
			{ recurso = "pedra", quantidade = 5, icone = "🪨", nome = "Pedras" },
		},
		corFundo = Color3.fromRGB(139, 69, 19)
	}
}

-- Criar cards dos itens
for i, item in ipairs(ITENS_CONSTRUCAO) do
	local card = Instance.new("Frame")
	card.Name = "Card_" .. item.nome
	card.Size = UDim2.new(1, -10, 0, 100)
	card.Position = UDim2.new(0, 5, 0, (i-1) * 105)
	card.BackgroundColor3 = item.corFundo
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 2
	card.BorderColor3 = Color3.fromRGB(200, 150, 80)
	card.Parent = container
	
	local cornerCard = Instance.new("UICorner")
	cornerCard.CornerRadius = UDim.new(0, 10)
	cornerCard.Parent = card
	
	local icone = Instance.new("TextLabel")
	icone.Name = "Icone"
	icone.Size = UDim2.new(0, 50, 0, 50)
	icone.Position = UDim2.new(0, 15, 0, 25)
	icone.BackgroundTransparency = 1
	icone.Text = item.icone
	icone.TextSize = 40
	icone.Parent = card
	
	local nome = Instance.new("TextLabel")
	nome.Name = "Nome"
	nome.Size = UDim2.new(1, -80, 0, 25)
	nome.Position = UDim2.new(0, 75, 0, 10)
	nome.BackgroundTransparency = 1
	nome.Text = item.nomeExibicao
	nome.TextColor3 = Color3.fromRGB(255, 255, 255)
	nome.TextSize = 18
	nome.Font = Enum.Font.GothamBold
	nome.TextXAlignment = Enum.TextXAlignment.Left
	nome.Parent = card
	
	local descricao = Instance.new("TextLabel")
	descricao.Name = "Descricao"
	descricao.Size = UDim2.new(1, -80, 0, 20)
	descricao.Position = UDim2.new(0, 75, 0, 35)
	descricao.BackgroundTransparency = 1
	descricao.Text = item.descricao
	descricao.TextColor3 = Color3.fromRGB(200, 200, 200)
	descricao.TextSize = 11
	descricao.Font = Enum.Font.Gotham
	descricao.TextXAlignment = Enum.TextXAlignment.Left
	descricao.Parent = card
	
	local textoCusto = ""
	for _, custo in ipairs(item.custo) do
		textoCusto = textoCusto .. custo.icone .. " " .. custo.quantidade .. " " .. custo.nome .. "  "
	end
	
	local custo = Instance.new("TextLabel")
	custo.Name = "Custo"
	custo.Size = UDim2.new(1, -80, 0, 20)
	custo.Position = UDim2.new(0, 75, 0, 55)
	custo.BackgroundTransparency = 1
	custo.Text = textoCusto
	custo.TextColor3 = Color3.fromRGB(100, 255, 100)
	custo.TextSize = 11
	custo.Font = Enum.Font.GothamBold
	custo.TextXAlignment = Enum.TextXAlignment.Left
	custo.Parent = card
	
	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Size = UDim2.new(1, -80, 0, 20)
	status.Position = UDim2.new(0, 75, 0, 75)
	status.BackgroundTransparency = 1
	status.Text = "✅ Disponível"
	status.TextColor3 = Color3.fromRGB(100, 255, 100)
	status.TextSize = 11
	status.Font = Enum.Font.Gotham
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = card
	
	local botaoAdicionar = Instance.new("TextButton")
	botaoAdicionar.Name = "BotaoAdicionar"
	botaoAdicionar.Size = UDim2.new(0, 80, 0, 35)
	botaoAdicionar.Position = UDim2.new(1, -95, 0.5, -17)
	botaoAdicionar.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	botaoAdicionar.Text = "ADICIONAR"
	botaoAdicionar.TextColor3 = Color3.fromRGB(255, 255, 255)
	botaoAdicionar.TextSize = 12
	botaoAdicionar.Font = Enum.Font.GothamBold
	botaoAdicionar.Parent = card
	
	local cornerBotao = Instance.new("UICorner")
	cornerBotao.CornerRadius = UDim.new(0, 6)
	cornerBotao.Parent = botaoAdicionar
	
	-- Hover effect
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	end)
	
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
	end)
	
	-- Função para verificar recursos
	local function verificarRecursos()
		local temRecursos = true
		for _, custo in ipairs(item.custo) do
			if (inventarioAtual[custo.recurso] or 0) < custo.quantidade then
				temRecursos = false
				break
			end
		end
		
		if temRecursos then
			botaoAdicionar.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
			botaoAdicionar.Text = "ADICIONAR"
			status.Text = "✅ Disponível"
			status.TextColor3 = Color3.fromRGB(100, 255, 100)
			return true
		else
			botaoAdicionar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			botaoAdicionar.Text = "FALTA"
			status.Text = "❌ Sem recursos"
			status.TextColor3 = Color3.fromRGB(255, 100, 100)
			return false
		end
	end
	
	-- Atualizar status quando inventário mudar
	atualizarInventario.OnClientEvent:Connect(function(inventario)
		inventarioAtual = inventario
		verificarRecursos()
	end)
	
	-- Clique para adicionar à hotbar
	botaoAdicionar.MouseButton1Click:Connect(function()
		if not verificarRecursos() then
			return
		end
		
		-- Notificar servidor para gastar recursos
		print("📤 Enviando Iniciar para servidor...")
		construirItemEvento:FireServer("Iniciar", item.nome)
		
		-- Criar Tool e adicionar à hotbar
		criarToolConstrucao(item)
		
		-- Fechar menu
		menuFrame.Visible = false
	end)
	
	verificarRecursos()
end

-- ==================== SISTEMA DE TOOL/HOTBAR ====================

function criarToolConstrucao(item)
	print("🔧 Criando Tool para: " .. item.nomeExibicao)
	
	-- Criar Tool para a hotbar
	local tool = Instance.new("Tool")
	tool.Name = item.nomeExibicao
	tool.ToolTip = "Equipe para posicionar " .. item.nomeExibicao
	tool.CanBeDropped = false
	
	-- Criar parte de visualização da Tool (icone na hotbar)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1, 1)
	handle.Anchored = false
	handle.CanCollide = false
	handle.Transparency = 1 -- Invisível quando segurando
	handle.Parent = tool
	
	-- Adicionar atributos
	tool:SetAttribute("TipoConstrucao", item.nome)
	tool:SetAttribute("CustoGravetos", 10)
	tool:SetAttribute("CustoPedra", 5)
	tool:SetAttribute("ProntoParaUsar", false) -- Só ativa após delay
	
	-- CONECTAR EVENTO EQUIPPED
	tool.Equipped:Connect(function()
		print("🖱️ Tool equipada: " .. tool.Name)
		-- Só criar preview se estiver pronto (evita ativação automática)
		if tool:GetAttribute("ProntoParaUsar") then
			criarPreviewLocal(tool)
		else
			print("   ⏳ Tool ainda não está pronta, aguardando...")
		end
	end)
	
	tool.Unequipped:Connect(function()
		print("🖱️ Tool desequipada: " .. tool.Name)
		-- Se desequipar sem confirmar, cancela (com delay para evitar cancelamento acidental)
		if modoConstrucao and itemTool == tool then
			task.delay(0.1, function()
				-- Verificar novamente se ainda está desequipada e em modo construção
				if modoConstrucao and itemTool == tool and tool.Parent == backpack then
					print("   ❌ Cancelando por desequipamento")
					cancelarModoConstrucao()
				end
			end)
		end
	end)
	
	-- Adicionar à backpack (hotbar)
	tool.Parent = backpack
	
	-- Marcar como pronto após um pequeno delay (evita ativação automática)
	task.delay(0.5, function()
		if tool and tool.Parent then
			tool:SetAttribute("ProntoParaUsar", true)
			print("   ✅ Tool pronta para uso!")
		end
	end)
	
	print("🔨 " .. item.nomeExibicao .. " adicionada à hotbar!")
	print("   💡 Equipe (clique ou pressione 1-9) para posicionar")
end

-- ==================== SISTEMA DE PREVIEW ====================

-- Criar preview local (não gasta recursos, já gastou ao adicionar)
function criarPreviewLocal(tool)
	if modoConstrucao then
		cancelarModoConstrucao()
	end
	
	local tipoItem = tool:GetAttribute("TipoConstrucao")
	if not tipoItem then return end
	
	-- Criar preview
	itemPreview = criarPreview(tipoItem)
	if not itemPreview then
		-- Se não achou modelo, devolver tool para backpack
		tool.Parent = backpack
		return
	end
	
	itemTool = tool
	modoConstrucao = true
	
	-- Esconder a tool visualmente (não remover para manter equipada)
	local handle = tool:FindFirstChild("Handle")
	if handle then
		handle.Transparency = 1
	end
	
	-- Mostrar GUI
	avisoPosicionar.Visible = true
	
	-- Conectar loop de atualização (só se não estiver já conectado)
	pcall(function()
		RunService:UnbindFromRenderStep("AtualizarPreview")
	end)
	RunService:BindToRenderStep("AtualizarPreview", 200, atualizarPosicaoPreview)
	
	print("🏗️ Modo construção: Posicione o item e pressione E")
end

function criarPreview(tipoItem)
	print("🔍 Buscando modelo para preview de: " .. tostring(tipoItem))
	
	-- Buscar modelo no ReplicatedStorage (cliente pode acessar)
	local modeloOriginal = nil
	local possiveisNomes = {"Workbench", "Bancada", "WorkbenchModel", "CraftingTable", "WorkBench4Script", tipoItem, "Model"}
	
	-- Primeiro tenta busca no ReplicatedStorage
	for _, nome in ipairs(possiveisNomes) do
		modeloOriginal = ReplicatedStorage:FindFirstChild(nome)
		if modeloOriginal then
			print("✅ Modelo encontrado no ReplicatedStorage: " .. modeloOriginal.Name)
			break
		end
	end
	
	-- Se não achou no ReplicatedStorage, tenta no Workspace (fallback)
	if not modeloOriginal then
		print("⚠️ Modelo não encontrado no ReplicatedStorage, tentando Workspace...")
		for _, nome in ipairs(possiveisNomes) do
			modeloOriginal = Workspace:FindFirstChild(nome, true)
			if modeloOriginal then
				print("✅ Modelo encontrado no Workspace: " .. modeloOriginal.Name)
				break
			end
		end
	end
	
	if not modeloOriginal then
		warn("❌ Modelo Workbench não encontrado no Workspace!")
		warn("   Procurando por: Workbench, Bancada, WorkBench4Script, etc.")
		return nil
	end
	
	print("✅ Usando modelo: " .. modeloOriginal.Name)
	print("   📊 Tipo: " .. modeloOriginal.ClassName)
	print("   📊 Filhos: " .. #modeloOriginal:GetChildren())
	
	-- Pegar o CFrame atual do modelo (posição no mundo)
	local cfOriginal = modeloOriginal:GetPivot()
	print("   📍 Posição original do modelo: " .. tostring(cfOriginal.Position))
	
	local preview = modeloOriginal:Clone()
	preview.Name = tipoItem .. "_Preview"
	
	-- Garantir que tem PrimaryPart
	if not preview.PrimaryPart then
		for _, parte in pairs(preview:GetDescendants()) do
			if parte:IsA("BasePart") then
				preview.PrimaryPart = parte
				print("   🔧 PrimaryPart definida: " .. parte.Name)
				break
			end
		end
	end
	
	-- Calcular offset Y do modelo original (do centro até a base)
	local centroOriginal = cfOriginal.Position.Y
	local baseOriginal = math.huge
	for _, parte in pairs(modeloOriginal:GetDescendants()) do
		if parte:IsA("BasePart") then
			local baseParte = parte.Position.Y - (parte.Size.Y / 2)
			if baseParte < baseOriginal then
				baseOriginal = baseParte
			end
		end
	end
	local offsetY = centroOriginal - baseOriginal
	preview:SetAttribute("OffsetY", offsetY)
	print("   📐 Offset Y calculado: " .. offsetY .. " (centro: " .. centroOriginal .. ", base: " .. baseOriginal .. ")")
	
	-- CORREÇÃO CRÍTICA: Resetar posições das partes para serem relativas ao centro do modelo
	-- Primeiro, calcular o centro do modelo baseado na PrimaryPart
	local partCount = 0
	local partes = {}
	for _, parte in pairs(preview:GetDescendants()) do
		if parte:IsA("BasePart") then
			table.insert(partes, parte)
			partCount = partCount + 1
		end
	end
	
	print("   📊 Partes encontradas: " .. partCount)
	
	if partCount == 0 then
		warn("❌ Modelo não tem partes! Criando placeholder...")
		local placeholder = Instance.new("Part")
		placeholder.Name = "PlaceholderWorkbench"
		placeholder.Size = Vector3.new(4, 4, 4)
		placeholder.Anchored = true
		placeholder.CanCollide = false
		placeholder.Transparency = 0.3
		placeholder.Color = Color3.fromRGB(100, 255, 100)
		placeholder.Material = Enum.Material.Neon
		placeholder.Parent = preview
		preview.PrimaryPart = placeholder
		partCount = 1
	end
	
	-- Parentar ao Workspace ANTES de reposicionar partes
	preview.Parent = Workspace
	
	-- Agora reposicionar o modelo inteiro para a frente do jogador
	if humanoidRootPart then
		local posicao = humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * distanciaPreview)
		
		-- Raycast para encontrar chão
		local rayResult = Workspace:Raycast(
			Vector3.new(posicao.X, posicao.Y + 50, posicao.Z),
			Vector3.new(0, -100, 0)
		)
		local alturaY = rayResult and rayResult.Position.Y or posicao.Y
		
		-- Posicionar o centro do preview na altura do chão + offset
		-- Assim a base do preview tocará o chão
		local offsetY = preview:GetAttribute("OffsetY") or 0
		local posFinal = Vector3.new(posicao.X, alturaY + offsetY, posicao.Z)
		
		-- Usar PivotTo (mais confiável que SetPrimaryPartCFrame)
		preview:PivotTo(CFrame.new(posFinal))
		print("   📍 Preview reposicionado para: " .. tostring(posFinal))
		print("   📐 Com offset Y: " .. offsetY)
	end
	
	-- Agora aplicar as cores e materiais (DEPOIS de parentar)
	local primeira = true
	for _, parte in pairs(partes) do
		parte.Anchored = true
		parte.CanCollide = false
		parte.Transparency = 0.3
		parte.CastShadow = false
		parte.Color = Color3.fromRGB(100, 255, 100) -- Verde
		parte.Material = Enum.Material.Neon
		
		if primeira then
			print("   📏 Tamanho primeira parte: " .. tostring(parte.Size))
			print("   📍 Posição primeira parte: " .. tostring(parte.Position))
			primeira = false
		end
	end
	
	print("   ✅ Preview finalizado com " .. partCount .. " partes em " .. tostring(preview:GetPivot().Position))
	
	return preview
end

function atualizarPosicaoPreview()
	if not itemPreview or not humanoidRootPart then return end
	
	-- Calcular posição na frente do jogador
	local posicaoBase = humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * distanciaPreview)
	
	-- Raycast para altura do terreno
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {itemPreview, character}
	
	local resultado = Workspace:Raycast(
		Vector3.new(posicaoBase.X, posicaoBase.Y + 50, posicaoBase.Z),
		Vector3.new(0, -100, 0),
		raycastParams
	)
	
	local alturaY
	if resultado then
		alturaY = resultado.Position.Y
	else
		-- Se não achou terreno, usa altura do jogador
		alturaY = humanoidRootPart.Position.Y
	end
	
	-- Aplicar posição usando PivotTo (mais confiável)
	local novaPosicao = Vector3.new(posicaoBase.X, alturaY + 0.5, posicaoBase.Z)
	itemPreview:PivotTo(CFrame.new(novaPosicao))
end

function confirmarPosicionamento()
	if not modoConstrucao or not itemPreview then return end
	
	-- Pegar posição atual do preview
	local posicaoPreview = itemPreview:GetPivot().Position
	local tipoItem = itemTool:GetAttribute("TipoConstrucao")
	
	-- O preview já está posicionado corretamente com o offset aplicado
	-- Então usamos a posição atual do preview diretamente
	local posicaoFinal = posicaoPreview
	
	print("📍 Posição do preview: " .. tostring(posicaoPreview))
	
	-- Notificar servidor com posição ajustada
	construirItemEvento:FireServer("Confirmar", tipoItem, posicaoFinal)
	
	-- Destruir tool (já foi usada)
	if itemTool then
		itemTool:Destroy()
		itemTool = nil
	end
	
	-- Limpar
	cancelarModoConstrucao()
end

function cancelarModoConstrucao()
	-- Se cancelou antes de confirmar, notificar servidor para reembolso
	if itemTool and itemTool.Parent then
		local tipoItem = itemTool:GetAttribute("TipoConstrucao")
		construirItemEvento:FireServer("Cancelar", tipoItem)
		
		-- Devolver tool para backpack
		itemTool.Parent = backpack
		
		-- Restaurar visibilidade do handle
		local handle = itemTool:FindFirstChild("Handle")
		if handle then
			handle.Transparency = 1
		end
	end
	
	modoConstrucao = false
	itemTool = nil
	
	if itemPreview then
		itemPreview:Destroy()
		itemPreview = nil
	end
	
	RunService:UnbindFromRenderStep("AtualizarPreview")
	avisoPosicionar.Visible = false
end

-- ==================== CONTROLES ====================

local function abrirMenu()
	menuFrame.Visible = true
	menuFrame.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 400, 0, 300)
	}):Play()
end

local function fecharMenu()
	menuFrame.Visible = false
end

-- Botão de construção
botaoConstrucao.MouseButton1Click:Connect(function()
	if menuFrame.Visible then
		fecharMenu()
	else
		abrirMenu()
	end
end)

botaoFechar.MouseButton1Click:Connect(fecharMenu)

-- Input E para confirmar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		if modoConstrucao then
			confirmarPosicionamento()
		end
	end
	
	if input.KeyCode == Enum.KeyCode.Escape and modoConstrucao then
		cancelarModoConstrucao()
	end
end)

print("✅ Menu de Construção carregado!")
print("   🔨 Clique no botão para adicionar itens à hotbar")
print("   📍 Equipe o item da hotbar para posicionar")
