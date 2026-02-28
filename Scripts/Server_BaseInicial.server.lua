-- Server_BaseInicial.server.lua
-- Spawna a base inicial (ruína) no centro do mapa

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🏰 SISTEMA DE BASE INICIAL CARREGANDO...")

-- Configuração da base
local CONFIG = {
	posicao = Vector3.new(53.63, 0.8, -48.23), -- Centro da zona segura
	tamanho = 40, -- Tamanho da base (40x40 studs)
	alturaParede = 8,
	corPedra = Color3.fromRGB(120, 120, 120),
	corMadeira = Color3.fromRGB(139, 90, 43),
}

-- Criar pasta para a base
local pastaBase = Instance.new("Folder")
pastaBase.Name = "BaseJogador"
pastaBase.Parent = Workspace

-- Função para criar uma parede quebrada
local function criarParedeQuebrada(posicao, tamanho, rotacao, nome)
	local parede = Instance.new("Part")
	parede.Name = nome
	parede.Size = tamanho
	parede.Position = posicao
	parede.Anchored = true
	parede.Color = CONFIG.corPedra
	parede.Material = Enum.Material.Rock
	parede.Parent = pastaBase
	
	-- Rotacionar
	if rotacao then
		parede.CFrame = CFrame.new(posicao) * CFrame.Angles(0, math.rad(rotacao), 0)
	end
	
	-- Atributos de estrutura quebrada
	parede:SetAttribute("Tipo", "Parede")
	parede:SetAttribute("VidaMax", 100)
	parede:SetAttribute("VidaAtual", 30) -- Quebrada, precisa de reparo
	parede:SetAttribute("Reparavel", true)
	
	-- Visual de quebrada (falhas na parede)
	for i = 1, 3 do
		local buraco = Instance.new("Part")
		buraco.Name = "Buraco_" .. i
		buraco.Size = Vector3.new(
			math.random(2, 4),
			math.random(2, 4),
			1
		)
		buraco.Color = Color3.fromRGB(60, 60, 60) -- Mais escuro
		buraco.Material = Enum.Material.Rock
		buraco.Anchored = true
		buraco.CanCollide = false
		
		-- Posicionar aleatoriamente na parede
		local offsetX = (math.random() - 0.5) * tamanho.X * 0.6
		local offsetY = (math.random() - 0.5) * tamanho.Y * 0.6
		buraco.Position = posicao + Vector3.new(offsetX, offsetY, 0)
		buraco.Parent = parede
	end
	
	return parede
end

-- Função para criar torre destruída
local function criarTorreDestruida(posicao)
	local torre = Instance.new("Model")
	torre.Name = "TorrePrincipal"
	torre.Parent = pastaBase
	
	-- Base da torre (metade destruída)
	local base = Instance.new("Part")
	base.Name = "BaseTorre"
	base.Size = Vector3.new(10, 6, 10)
	base.Position = posicao + Vector3.new(0, 3, 0)
	base.Anchored = true
	base.Color = CONFIG.corPedra
	base.Material = Enum.Material.Rock
	base.Parent = torre
	base:SetAttribute("Tipo", "Torre")
	base:SetAttribute("VidaMax", 200)
	base:SetAttribute("VidaAtual", 50)
	
	-- Topo quebrado (inclinado)
	local topo = Instance.new("Part")
	topo.Name = "TopoQuebrado"
	topo.Size = Vector3.new(6, 4, 6)
	topo.Position = posicao + Vector3.new(2, 8, 1)
	topo.Anchored = true
	topo.Color = CONFIG.corMadeira
	topo.Material = Enum.Material.Wood
	topo.Parent = torre
	
	-- Rotacionar para parecer quebrado
	topo.CFrame = CFrame.new(topo.Position) * CFrame.Angles(
		math.rad(math.random(-15, 15)),
		math.rad(math.random(-30, 30)),
		math.rad(math.random(-10, 10))
	)
	
	return torre
end

-- Função para criar portão destruído
local function criarPortao(posicao)
	local portao = Instance.new("Model")
	portao.Name = "PortaoEntrada"
	portao.Parent = pastaBase
	
	-- Postes do portão
	for _, offset in pairs({-6, 6}) do
		local poste = Instance.new("Part")
		poste.Name = "Poste_" .. (offset < 0 and "Esq" or "Dir")
		poste.Size = Vector3.new(2, 10, 2)
		poste.Position = posicao + Vector3.new(offset, 5, 0)
		poste.Anchored = true
		poste.Color = CONFIG.corMadeira
		poste.Material = Enum.Material.Wood
		poste.Parent = portao
		poste:SetAttribute("Tipo", "Portao")
		poste:SetAttribute("Quebrado", true)
	end
	
	-- Porteira caída no chão
	local porteira = Instance.new("Part")
	porteira.Name = "PorteiraCaida"
	porteira.Size = Vector3.new(10, 1, 6)
	porteira.Position = posicao + Vector3.new(0, 0.5, 3)
	porteira.Anchored = true
	porteira.Color = CONFIG.corMadeira
	porteira.Material = Enum.Material.Wood
	porteira.Parent = portao
	porteira.CFrame = CFrame.new(porteira.Position) * CFrame.Angles(
		math.rad(85), -- Deitada no chão
		math.rad(math.random(-10, 10)),
		0
	)
	
	return portao
end

-- Função para criar fogueira apagada (spawn point)
local function criarFogueira(posicao)
	local fogueira = Instance.new("Model")
	fogueira.Name = "FogueiraBase"
	fogueira.Parent = pastaBase
	
	-- Pedras em círculo
	for i = 1, 8 do
		local angulo = (i / 8) * math.pi * 2
		local pedra = Instance.new("Part")
		pedra.Name = "Pedra_" .. i
		pedra.Size = Vector3.new(1.5, 1, 1.5)
		pedra.Shape = Enum.PartType.Ball
		pedra.Position = posicao + Vector3.new(
			math.cos(angulo) * 3,
			0.5,
			math.sin(angulo) * 3
		)
		pedra.Anchored = true
		pedra.Color = Color3.fromRGB(100, 100, 100)
		pedra.Material = Enum.Material.Rock
		pedra.Parent = fogueira
	end
	
	-- Cinzas no centro (partículas desativadas)
	local cinzas = Instance.new("Part")
	cinzas.Name = "Cinzas"
	cinzas.Size = Vector3.new(4, 0.2, 4)
	cinzas.Position = posicao + Vector3.new(0, 0.1, 0)
	cinzas.Anchored = true
	cinzas.Color = Color3.fromRGB(40, 40, 40)
	cinzas.Material = Enum.Material.Slate
	cinzas.Parent = fogueira
	cinzas:SetAttribute("PontoSpawn", true)
	
	return fogueira
end

-- Função para criar marcadores de perímetro (bandeiras/postes)
local function criarMarcadorPerimetro(posicao)
	local poste = Instance.new("Part")
	poste.Name = "MarcadorPerimetro"
	poste.Size = Vector3.new(0.5, 6, 0.5)
	poste.Position = posicao + Vector3.new(0, 3, 0)
	poste.Anchored = true
	poste.Color = CONFIG.corMadeira
	poste.Material = Enum.Material.Wood
	poste.Parent = pastaBase
	
	-- Bandeira rasgada
	local bandeira = Instance.new("Part")
	bandeira.Name = "Bandeira"
	bandeira.Size = Vector3.new(2, 3, 0.2)
	bandeira.Position = posicao + Vector3.new(1.5, 4.5, 0)
	bandeira.Anchored = true
	bandeira.Color = Color3.fromRGB(150, 50, 50) -- Vermelho escuro
	bandeira.Material = Enum.Material.Fabric
	bandeira.Parent = poste
	
	return poste
end

-- Função principal para spawnar a base
local function spawnarBaseInicial()
	print("🏰 Spawando base inicial...")
	
	local centro = CONFIG.posicao
	local metade = CONFIG.tamanho / 2
	
	-- Paredes dos lados (algumas quebradas, algumas faltando)
	local paredesConfig = {
		{pos = centro + Vector3.new(-metade, CONFIG.alturaParede/2, 0), size = Vector3.new(2, CONFIG.alturaParede, CONFIG.tamanho - 10), rot = 0, nome = "ParedeOeste"},
		{pos = centro + Vector3.new(metade, CONFIG.alturaParede/2, 0), size = Vector3.new(2, CONFIG.alturaParede, CONFIG.tamanho - 10), rot = 0, nome = "ParedeLeste"},
		{pos = centro + Vector3.new(0, CONFIG.alturaParede/2, -metade), size = Vector3.new(CONFIG.tamanho - 10, CONFIG.alturaParede, 2), rot = 0, nome = "ParedeNorte"},
		-- Parede sul tem o portão, então são duas seções
		{pos = centro + Vector3.new(-12, CONFIG.alturaParede/2, metade), size = Vector3.new(16, CONFIG.alturaParede, 2), rot = 0, nome = "ParedeSul_Esq"},
		{pos = centro + Vector3.new(12, CONFIG.alturaParede/2, metade), size = Vector3.new(16, CONFIG.alturaParede, 2), rot = 0, nome = "ParedeSul_Dir"},
	}
	
	for _, config in pairs(paredesConfig) do
		criarParedeQuebrada(config.pos, config.size, config.rot, config.nome)
	end
	
	-- Torre central destruída
	criarTorreDestruida(centro)
	
	-- Portão de entrada (lado sul)
	criarPortao(centro + Vector3.new(0, 0, metade))
	
	-- Fogueira (spawn point)
	criarFogueira(centro + Vector3.new(0, 0, 8))
	
	-- Marcadores de perímetro (cantos)
	local cantos = {
		centro + Vector3.new(-metade, 0, -metade),
		centro + Vector3.new(metade, 0, -metade),
		centro + Vector3.new(-metade, 0, metade),
		centro + Vector3.new(metade, 0, metade),
	}
	for _, pos in pairs(cantos) do
		criarMarcadorPerimetro(pos)
	end
	
	print("✅ Base inicial criada!")
	print("   📍 Posição: " .. tostring(centro))
	print("   📐 Tamanho: " .. CONFIG.tamanho .. "x" .. CONFIG.tamanho)
	print("   🏚️ Paredes quebradas precisam de reparo")
	print("   🔥 Fogueira é o ponto de spawn")
end

-- Spawnar após um delay para garantir que o terreno está carregado
task.spawn(function()
	task.wait(3)
	spawnarBaseInicial()
end)

print("✅ Sistema de Base Inicial carregado!")
