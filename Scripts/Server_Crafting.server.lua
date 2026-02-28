-- Server_Crafting.server.lua
-- Gerencia o sistema de crafting no servidor

print("🔨 SERVER CRAFTING INICIANDO...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Criar eventos
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

local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")
if not atualizarInventario then
	atualizarInventario = Instance.new("RemoteEvent")
	atualizarInventario.Name = "AtualizarInventario"
	atualizarInventario.Parent = eventos
end

-- Dados dos jogadores (compartilhado entre todos os scripts)
_G.DadosJogadores = _G.DadosJogadores or {}
local dadosJogadores = _G.DadosJogadores

-- Criar ferramenta genérica a partir de um modelo
local function criarFerramenta(nome, modeloNome, toolTip, escala)
	-- Buscar o modelo no Workspace
	local modeloOriginal = Workspace:FindFirstChild(modeloNome)
		or Workspace:FindFirstChild(nome)
		or Workspace:FindFirstChild(modeloNome .. "Model")
	
	if not modeloOriginal then
		print("⚠️ Modelo " .. modeloNome .. " não encontrado no Workspace!")
		return nil
	end
	
	-- Criar uma Tool wrapper
	local tool = Instance.new("Tool")
	tool.Name = nome
	tool.ToolTip = toolTip
	
	-- Clonar o modelo
	local modelo = modeloOriginal:Clone()
	modelo.Name = nome .. "Model"
	
	-- Escala padrão 50% se não especificado
	local escala = escala or 0.5
	
	-- Coletar todas as partes base
	local partes = {}
	for _, parte in pairs(modelo:GetDescendants()) do
		if parte:IsA("BasePart") then
			table.insert(partes, parte)
		end
	end
	
	-- Pegar a posição original do modelo para calcular offsets
	local modeloCFrame = modelo:GetPivot()
	
	-- Redimensionar e reposicionar todas as partes
	for _, parte in pairs(partes) do
		-- Redimensionar
		parte.Size = parte.Size * escala
		parte.Anchored = false
		parte.CanCollide = false
		
		-- Calcular posição relativa ao centro do modelo
		local offset = parte.Position - modeloCFrame.Position
		-- Aplicar escala no offset também
		local novoOffset = offset * escala
		-- Nova posição é o centro escalado + offset escalado
		parte.Position = (modeloCFrame.Position * escala) + novoOffset
	end
	
	-- Encontrar a parte que será o Handle (cabo do machado)
	local handlePart = nil
	local maiorComprimentoY = 0
	
	for _, parte in pairs(partes) do
		if parte.Size.Y > maiorComprimentoY then
			maiorComprimentoY = parte.Size.Y
			handlePart = parte
		end
	end
	
	-- Se não achou pelo Y, pega a mais comprida em geral
	if not handlePart then
		local maiorComprimento = 0
		for _, parte in pairs(partes) do
			local comp = math.max(parte.Size.X, parte.Size.Y, parte.Size.Z)
			if comp > maiorComprimento then
				maiorComprimento = comp
				handlePart = parte
			end
		end
	end
	
	-- Se ainda não achou, usa a primeira
	if not handlePart and #partes > 0 then
		handlePart = partes[1]
	end
	
	-- Montar a Tool
	if handlePart then
		-- Guardar CFrame do handle antes de mover
		local handleCF = handlePart.CFrame
		
		-- Mover handle para a tool
		handlePart.Name = "Handle"
		handlePart.Parent = tool
		
		-- Mover as outras partes e criar welds
		for _, parte in pairs(partes) do
			if parte ~= handlePart then
				parte.Parent = tool
				
				-- Criar weld com offset relativo ao handle
				local weld = Instance.new("Weld")
				weld.Part0 = handlePart
				weld.Part1 = parte
				-- Calcular offset: posição da parte em relação ao handle
				weld.C0 = handleCF:Inverse() * parte.CFrame
				weld.Parent = parte
			end
		end
		
		-- Resetar posição do handle para origem (0,0,0) relativo à tool
		-- Sem rotação extra
		handlePart.CFrame = CFrame.new(0, 0, 0)
	end
	
	-- Destruir o modelo vazio
	modelo:Destroy()
	
	-- Adicionar script de ataque
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local scriptTemplate = nil
	
	if nome == "Machado" then
		scriptTemplate = ReplicatedStorage:FindFirstChild("MachadoAtaqueTemplate")
	elseif nome == "Picareta" then
		scriptTemplate = ReplicatedStorage:FindFirstChild("PicaretaAtaqueTemplate")
	end
	
	if scriptTemplate then
		local scriptAtaque = scriptTemplate:Clone()
		scriptAtaque.Name = nome .. "Ataque"
		scriptAtaque.Parent = tool
		print("📝 Script de ataque adicionado ao " .. nome)
	else
		print("⚠️ Template de ataque não encontrado para " .. nome)
	end
	
	return tool
end

-- Função wrapper para criar Machado
local function criarMachado()
	return criarFerramenta("Machado", "Axe", "Usado para cortar madeira", 0.5)
end

-- Função wrapper para criar Picareta
local function criarPicareta()
	return criarFerramenta("Picareta", "Pickaxe", "Usada para minerar pedra", 0.5)
end

-- Configuração de receitas
local RECEITAS = {
	Machado = {
		custo = { recurso = "gravetos", quantidade = 1 },
		criar = criarMachado
	},
	Picareta = {
		custo = { recurso = "gravetos", quantidade = 2 },
		criar = criarPicareta
	}
}

-- Função para verificar se jogador tem recursos
local function temRecursos(player, item)
	local dados = dadosJogadores[player.UserId]
	if not dados then return false end
	
	local receita = RECEITAS[item]
	if not receita then return false end
	
	local recurso = receita.custo.recurso
	local quantidade = receita.custo.quantidade
	
	return dados.inventario[recurso] >= quantidade
end

-- Função para gastar recursos
local function gastarRecursos(player, item)
	local dados = dadosJogadores[player.UserId]
	if not dados then return false end
	
	local receita = RECEITAS[item]
	if not receita then return false end
	
	local recurso = receita.custo.recurso
	local quantidade = receita.custo.quantidade
	
	if dados.inventario[recurso] >= quantidade then
		dados.inventario[recurso] = dados.inventario[recurso] - quantidade
		
		-- Atualizar GUI do cliente
		if atualizarInventario then
			atualizarInventario:FireClient(player, dados.inventario)
		end
		
		return true
	end
	
	return false
end

-- Processar crafting
local function processarCraft(player, item)
	if not player or not item then return end
	
	-- Verificar se tem recursos
	if not temRecursos(player, item) then
		print("❌ " .. player.Name .. " não tem recursos para craftar " .. item)
		return
	end
	
	-- Gastar recursos
	if not gastarRecursos(player, item) then
		return
	end
	
	-- Criar e dar o item ao jogador
	local receita = RECEITAS[item]
	if receita then
		local ferramenta = receita.criar()
		if ferramenta then
			ferramenta.Parent = player.Backpack
			print("✅ " .. player.Name .. " craftou um " .. item .. "! (-" .. receita.custo.quantidade .. " " .. receita.custo.recurso .. ")")
		end
	end
end

-- Conectar evento de crafting
craftarItemEvento.OnServerEvent:Connect(function(player, item)
	processarCraft(player, item)
end)

print("✅ Servidor de Crafting inicializado!")
print("   📋 Receitas disponíveis:")
print("      🪓 Machado = 1 Pau")
print("      ⛏️ Picareta = 2 Paus")
