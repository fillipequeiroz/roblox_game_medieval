-- SpawnarMapaPosicoes.server.lua
-- Spawna árvores, galhos e pedras automaticamente no início do jogo
-- Verifica se já foi executado para não duplicar

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

print("🗺️ SISTEMA DE MAPA INICIANDO...")

-- Configuração
local CONFIG = {
	-- Nome do atributo que marca se o mapa já foi gerado
	atributoMapaGerado = "MapaGerado",
	-- Nome da pasta onde os objetos spawnados serão armazenados
	pastaMapa = "MapaGerado",
}

-- Função para verificar se o mapa já foi gerado
local function mapaJaFoiGerado()
	-- Verificar atributo no Workspace
	if Workspace:GetAttribute(CONFIG.atributoMapaGerado) then
		return true
	end
	
	-- Verificar se a pasta do mapa existe e tem objetos
	local pasta = Workspace:FindFirstChild(CONFIG.pastaMapa)
	if pasta and #pasta:GetChildren() > 0 then
		return true
	end
	
	return false
end

-- Função para marcar que o mapa foi gerado
local function marcarMapaGerado()
	Workspace:SetAttribute(CONFIG.atributoMapaGerado, true)
end

-- Função para criar/limpar pasta do mapa
local function prepararPastaMapa()
	local pastaExistente = Workspace:FindFirstChild(CONFIG.pastaMapa)
	if pastaExistente then
		pastaExistente:Destroy()
	end
	
	local novaPasta = Instance.new("Folder")
	novaPasta.Name = CONFIG.pastaMapa
	novaPasta.Parent = Workspace
	return novaPasta
end

-- Função para encontrar altura do terreno
local function getAlturaTerreno(posicaoX, posicaoZ)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local resultado = Workspace:Raycast(
		Vector3.new(posicaoX, 100, posicaoZ),
		Vector3.new(0, -200, 0),
		raycastParams
	)
	
	if resultado then
		return resultado.Position.Y
	end
	return 0.8
end

-- Carregar posições
local sucesso, posicoes = pcall(function()
	return require(ReplicatedStorage:WaitForChild("PosicoesMapa_Calculadas"))
end)

if not sucesso or not posicoes then
	warn("❌ Não foi possível carregar as posições do mapa!")
	return
end

-- ==================== FUNÇÕES DE SPAWN ====================

-- Contadores
local totalArvores = 0
local totalGalhos = 0
local totalPedras = 0
local pastaMapa = nil

-- Spawnar árvore
local function spawnarArvore(tipo, posicao, rotacao, nomeSpawn)
	local modeloOriginal = Workspace:FindFirstChild(tipo)
	if not modeloOriginal then
		return false
	end
	
	local novaArvore = modeloOriginal:Clone()
	novaArvore.Name = nomeSpawn
	
	local alturaY = getAlturaTerreno(posicao.X, posicao.Z)
	novaArvore:PivotTo(CFrame.new(posicao.X, alturaY, posicao.Z) * CFrame.Angles(0, math.rad(rotacao), 0))
	novaArvore.Parent = pastaMapa
	
	for _, parte in pairs(novaArvore:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Anchored = true
			parte.CanCollide = true
			parte:SetAttribute("TipoRecurso", "Madeira")
		end
	end
	
	return true
end

-- Spawnar galho
local function spawnarGalho(posicao, rotacao, nomeSpawn)
	local modeloOriginal = Workspace:FindFirstChild("smallStick")
	if not modeloOriginal then
		return false
	end
	
	local novoGalho = modeloOriginal:Clone()
	novoGalho.Name = nomeSpawn
	
	local alturaY = getAlturaTerreno(posicao.X, posicao.Z)
	novoGalho:PivotTo(CFrame.new(posicao.X, alturaY + 0.1, posicao.Z) * CFrame.Angles(0, math.rad(rotacao), 0))
	novoGalho.Parent = pastaMapa
	
	for _, parte in pairs(novoGalho:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Anchored = true
			parte.CanCollide = true
			parte:SetAttribute("TipoRecurso", "Pau")
		end
	end
	
	return true
end

-- Spawnar pedra
local function spawnarPedra(posicao, escala, rotacao, nomeSpawn)
	local modeloOriginal = Workspace:FindFirstChild("smallRockStone")
	if not modeloOriginal then
		return false
	end
	
	local novaPedra = modeloOriginal:Clone()
	novaPedra.Name = nomeSpawn
	
	local alturaY = getAlturaTerreno(posicao.X, posicao.Z)
	
	for _, parte in pairs(novaPedra:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Size = parte.Size * escala
		end
	end
	
	novaPedra:PivotTo(CFrame.new(posicao.X, alturaY + 0.1, posicao.Z) * CFrame.Angles(0, math.rad(rotacao), 0))
	novaPedra.Parent = pastaMapa
	
	for _, parte in pairs(novaPedra:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Anchored = true
			parte.CanCollide = true
			parte:SetAttribute("TipoRecurso", "Pedra")
		end
	end
	
	return true
end

-- ==================== FUNÇÃO PRINCIPAL DE GERAÇÃO ====================

local function gerarMapa()
	print("\n🌲 INICIANDO GERAÇÃO DO MAPA...")
	
	-- Preparar pasta
	pastaMapa = prepararPastaMapa()
	
	-- Spawnar árvores do Norte
	print("   📍 Floresta Norte...")
	for i, arvore in ipairs(posicoes.arvoresNorte) do
		if spawnarArvore(arvore.tipo, arvore.posicao, arvore.rotacao, "TreeSpawn_N_" .. i) then
			totalArvores = totalArvores + 1
		end
		task.wait(0.01) -- Pequeno delay para não travar
	end
	
	-- Spawnar árvores do Centro
	print("   📍 Planície Central...")
	for i, arvore in ipairs(posicoes.arvoresCentro) do
		if spawnarArvore(arvore.tipo, arvore.posicao, arvore.rotacao, "TreeSpawn_C_" .. i) then
			totalArvores = totalArvores + 1
		end
		task.wait(0.01)
	end
	
	-- Spawnar árvores do Sul
	print("   📍 Campo Sul...")
	for i, arvore in ipairs(posicoes.arvoresSul) do
		if spawnarArvore(arvore.tipo, arvore.posicao, arvore.rotacao, "TreeSpawn_S_" .. i) then
			totalArvores = totalArvores + 1
		end
		task.wait(0.01)
	end
	
	-- Spawnar galhos
	print("   🌿 Distribuindo galhos...")
	for i, galho in ipairs(posicoes.galhos) do
		if spawnarGalho(galho.posicao, galho.rotacao, "StickSpawn_" .. i) then
			totalGalhos = totalGalhos + 1
		end
		task.wait(0.01)
	end
	
	-- Spawnar pedras
	print("   🪨 Distribuindo pedras...")
	for i, pedra in ipairs(posicoes.pedras) do
		if spawnarPedra(pedra.posicao, pedra.escala, pedra.rotacao, "RockSpawn_" .. i) then
			totalPedras = totalPedras + 1
		end
		task.wait(0.01)
	end
	
	-- Marcar como gerado
	marcarMapaGerado()
	
	-- Resumo
	print("\n" .. string.rep("=", 50))
	print("✅ MAPA GERADO COM SUCESSO!")
	print(string.rep("=", 50))
	print("📊 Total de objetos:")
	print("   🌲 Árvores: " .. totalArvores)
	print("   🌿 Galhos: " .. totalGalhos)
	print("   🪨 Pedras: " .. totalPedras)
	print("   📦 Total: " .. (totalArvores + totalGalhos + totalPedras))
	print("\n📁 Todos os objetos estão na pasta: Workspace." .. CONFIG.pastaMapa)
end

-- ==================== COMANDO PARA RESETAR (DESENVOLVIMENTO) ====================

local function resetarMapa()
	print("\n🗑️ RESETANDO MAPA...")
	
	-- Remover atributo
	Workspace:SetAttribute(CONFIG.atributoMapaGerado, nil)
	
	-- Remover pasta
	local pasta = Workspace:FindFirstChild(CONFIG.pastaMapa)
	if pasta then
		pasta:Destroy()
	end
	
	-- Resetar contadores
	totalArvores = 0
	totalGalhos = 0
	totalPedras = 0
	
	print("✅ Mapa resetado! Reinicie o servidor para regenerar.")
end

-- ==================== INICIALIZAÇÃO ====================

-- Verificar se já foi gerado
if mapaJaFoiGerado() then
	print("✅ Mapa já foi gerado anteriormente. Pulando geração.")
	print("   💡 Use o comando /resetmapa no chat para regenerar (apenas desenvolvedores).")
else
	-- Gerar mapa com pequeno delay para garantir que tudo carregou
	task.spawn(function()
		task.wait(2) -- Aguardar 2 segundos
		gerarMapa()
	end)
end

-- Comando para resetar (apenas desenvolvedores)
local function processarComandoChat(player, mensagem)
	if mensagem:lower() == "/resetmapa" then
		-- Verificar se é desenvolvedor (você pode adicionar sua verificação aqui)
		resetarMapa()
	end
end

-- Conectar ao evento de chat (se existir sistema de chat)
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(mensagem)
		processarComandoChat(player, mensagem)
	end)
end)

print("✅ Sistema de Mapa carregado!")
