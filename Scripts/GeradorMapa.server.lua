-- GeradorMapa.server.lua
-- Gera posições fixas de árvores, galhos e pedras no mapa
-- Execute este script uma vez no Studio para posicionar os objetos

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🗺️ GERADOR DE MAPA INICIANDO...")

-- Configurações do mapa (baseado na grama)
local GRAMA_POS = Vector3.new(53.63, 0.379, -48.23)
local GRAMA_SIZE = Vector3.new(512.74, 0.759, 512.46)

-- Limites do mapa
local MIN_X = GRAMA_POS.X - GRAMA_SIZE.X/2 + 20  -- Margem de 20
local MAX_X = GRAMA_POS.X + GRAMA_SIZE.X/2 - 20
local MIN_Z = GRAMA_POS.Z - GRAMA_SIZE.Z/2 + 20
local MAX_Z = GRAMA_POS.Z + GRAMA_SIZE.Z/2 - 20
local ALTURA_BASE = GRAMA_POS.Y + GRAMA_SIZE.Y/2  -- Topo da grama

-- Tipos de árvores disponíveis
local TIPOS_ARVORES = {"Tree1", "Tree2", "Tree3", "Tree4", "Tree5"}

-- Configuração de densidade por região
local REGIOES = {
	-- Região Norte (densidade alta - floresta)
	{
		nome = "Floresta Norte",
		minX = MIN_X, maxX = MAX_X,
		minZ = MIN_Z, maxZ = MIN_Z + (MAX_Z - MIN_Z) * 0.3,
		densidade = "alta",
		quantidadeArvores = 40,
		quantidadeGalhos = 15,
		quantidadePedras = 8
	},
	-- Região Centro (densidade média)
	{
		nome = "Planície Central",
		minX = MIN_X, maxX = MAX_X,
		minZ = MIN_Z + (MAX_Z - MIN_Z) * 0.3, maxZ = MIN_Z + (MAX_Z - MIN_Z) * 0.7,
		densidade = "media",
		quantidadeArvores = 20,
		quantidadeGalhos = 25,
		quantidadePedras = 12
	},
	-- Região Sul (densidade baixa - campo aberto)
	{
		nome = "Campo Sul",
		minX = MIN_X, maxX = MAX_X,
		minZ = MIN_Z + (MAX_Z - MIN_Z) * 0.7, maxZ = MAX_Z,
		densidade = "baixa",
		quantidadeArvores = 10,
		quantidadeGalhos = 10,
		quantidadePedras = 5
	}
}

-- Função para gerar posição aleatória dentro de uma região
local function gerarPosicaoRegiao(regiao)
	local x = math.random(regiao.minX * 100, regiao.maxX * 100) / 100
	local z = math.random(regiao.minZ * 100, regiao.maxZ * 100) / 100
	return Vector3.new(x, ALTURA_BASE, z)
end

-- Função para verificar distância mínima entre objetos
local function distanciaValida(posicao, objetosExistentes, distanciaMinima)
	for _, obj in pairs(objetosExistentes) do
		local dist = (posicao - obj.posicao).Magnitude
		if dist < distanciaMinima then
			return false
		end
	end
	return true
end

-- Função para fazer raycast e encontrar altura do terreno
local function getAlturaTerreno(posicao)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local resultado = Workspace:Raycast(
		Vector3.new(posicao.X, ALTURA_BASE + 100, posicao.Z),
		Vector3.new(0, -200, 0),
		raycastParams
	)
	
	if resultado then
		return resultado.Position.Y
	end
	return ALTURA_BASE
end

-- Coletar posições existentes (para não sobrepor)
local objetosExistentes = {}

-- Função para posicionar árvore
local function posicionarArvore(tipoArvore, posicao, nomeSpawn)
	local modeloOriginal = Workspace:FindFirstChild(tipoArvore)
	if not modeloOriginal then
		print("⚠️ Modelo " .. tipoArvore .. " não encontrado!")
		return nil
	end
	
	local novaArvore = modeloOriginal:Clone()
	novaArvore.Name = nomeSpawn
	
	-- Encontrar altura do terreno
	local alturaY = getAlturaTerreno(posicao)
	
	-- Posicionar
	novaArvore:PivotTo(CFrame.new(posicao.X, alturaY, posicao.Z))
	novaArvore.Parent = Workspace
	
	-- Configurar partes
	for _, parte in pairs(novaArvore:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Anchored = true
			parte.CanCollide = true
			parte:SetAttribute("TipoRecurso", "Madeira")
		end
	end
	
	return {
		tipo = "arvore",
		nome = nomeSpawn,
		posicao = Vector3.new(posicao.X, alturaY, posicao.Z)
	}
end

-- Função para posicionar galho
local function posicionarGalho(posicao, nomeSpawn)
	local modeloOriginal = Workspace:FindFirstChild("smallStick")
	if not modeloOriginal then
		return nil
	end
	
	local novoGalho = modeloOriginal:Clone()
	novoGalho.Name = nomeSpawn
	
	local alturaY = getAlturaTerreno(posicao)
	
	-- Rotação aleatória para variedade
	local rotacao = math.random(0, 360)
	novoGalho:PivotTo(CFrame.new(posicao.X, alturaY + 0.1, posicao.Z) * CFrame.Angles(0, math.rad(rotacao), 0))
	novoGalho.Parent = Workspace
	
	for _, parte in pairs(novoGalho:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Anchored = true
			parte.CanCollide = true
			parte:SetAttribute("TipoRecurso", "Graveto")
		end
	end
	
	return {
		tipo = "galho",
		nome = nomeSpawn,
		posicao = Vector3.new(posicao.X, alturaY, posicao.Z)
	}
end

-- Função para posicionar pedra
local function posicionarPedra(posicao, nomeSpawn)
	local modeloOriginal = Workspace:FindFirstChild("smallRockStone")
	if not modeloOriginal then
		return nil
	end
	
	local novaPedra = modeloOriginal:Clone()
	novaPedra.Name = nomeSpawn
	
	local alturaY = getAlturaTerreno(posicao)
	
	-- Rotação aleatória
	local rotacao = math.random(0, 360)
	local escala = 0.8 + math.random() * 0.4  -- Escala entre 0.8 e 1.2
	
	novaPedra:PivotTo(CFrame.new(posicao.X, alturaY + 0.1, posicao.Z) * CFrame.Angles(0, math.rad(rotacao), 0))
	
	-- Aplicar escala
	for _, parte in pairs(novaPedra:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Size = parte.Size * escala
		end
	end
	
	novaPedra.Parent = Workspace
	
	for _, parte in pairs(novaPedra:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Anchored = true
			parte.CanCollide = true
			parte:SetAttribute("TipoRecurso", "Pedra")
		end
	end
	
	return {
		tipo = "pedra",
		nome = nomeSpawn,
		posicao = Vector3.new(posicao.X, alturaY, posicao.Z)
	}
end

-- ==================== GERAÇÃO DO MAPA ====================

print("\n🌲 INICIANDO GERAÇÃO DE ÁRVORES...")

for _, regiao in ipairs(REGIOES) do
	print("\n📍 Região: " .. regiao.nome .. " (densidade: " .. regiao.densidade .. ")")
	
	-- Definir distâncias mínimas baseadas na densidade
	local distanciaMinimaArvores = 15
	if regiao.densidade == "alta" then
		distanciaMinimaArvores = 10
	elseif regiao.densidade == "baixa" then
		distanciaMinimaArvores = 25
	end
	
	-- Gerar árvores
	local arvoresGeradas = 0
	local tentativas = 0
	local maxTentativas = regiao.quantidadeArvores * 5
	
	while arvoresGeradas < regiao.quantidadeArvores and tentativas < maxTentativas do
		tentativas = tentativas + 1
		
		local posicao = gerarPosicaoRegiao(regiao)
		
		-- Verificar se não está muito perto de outras árvores
		if distanciaValida(posicao, objetosExistentes, distanciaMinimaArvores) then
			-- Escolher tipo de árvore aleatório
			local tipoArvore = TIPOS_ARVORES[math.random(1, #TIPOS_ARVORES)]
			local nomeSpawn = "TreeSpawn_" .. tipoArvore .. "_" .. tostring(arvoresGeradas + 1)
			
			local arvore = posicionarArvore(tipoArvore, posicao, nomeSpawn)
			if arvore then
				table.insert(objetosExistentes, arvore)
				arvoresGeradas = arvoresGeradas + 1
			end
		end
	end
	
	print("   🌲 Árvores geradas: " .. arvoresGeradas .. "/" .. regiao.quantidadeArvores)
	
	-- Gerar galhos
	local galhosGerados = 0
	tentativas = 0
	maxTentativas = regiao.quantidadeGalhos * 5
	
	while galhosGerados < regiao.quantidadeGalhos and tentativas < maxTentativas do
		tentativas = tentativas + 1
		
		local posicao = gerarPosicaoRegiao(regiao)
		
		-- Distância menor para galhos
		if distanciaValida(posicao, objetosExistentes, 5) then
			local nomeSpawn = "StickSpawn_" .. tostring(galhosGerados + 1)
			local galho = posicionarGalho(posicao, nomeSpawn)
			if galho then
				table.insert(objetosExistentes, galho)
				galhosGerados = galhosGerados + 1
			end
		end
	end
	
	print("   🌿 Galhos gerados: " .. galhosGerados .. "/" .. regiao.quantidadeGalhos)
	
	-- Gerar pedras
	local pedrasGeradas = 0
	tentativas = 0
	maxTentativas = regiao.quantidadePedras * 5
	
	while pedrasGeradas < regiao.quantidadePedras and tentativas < maxTentativas do
		tentativas = tentativas + 1
		
		local posicao = gerarPosicaoRegiao(regiao)
		
		-- Distância média para pedras
		if distanciaValida(posicao, objetosExistentes, 8) then
			local nomeSpawn = "RockSpawn_" .. tostring(pedrasGeradas + 1)
			local pedra = posicionarPedra(posicao, nomeSpawn)
			if pedra then
				table.insert(objetosExistentes, pedra)
				pedrasGeradas = pedrasGeradas + 1
			end
		end
	end
	
	print("   🪨 Pedras geradas: " .. pedrasGeradas .. "/" .. regiao.quantidadePedras)
end

-- ==================== RESUMO ====================

print("\n" .. string.rep("=", 50))
print("✅ GERAÇÃO DO MAPA CONCLUÍDA!")
print(string.rep("=", 50))

local totalArvores = 0
local totalGalhos = 0
local totalPedras = 0

for _, obj in pairs(objetosExistentes) do
	if obj.tipo == "arvore" then
		totalArvores = totalArvores + 1
	elseif obj.tipo == "galho" then
		totalGalhos = totalGalhos + 1
	elseif obj.tipo == "pedra" then
		totalPedras = totalPedras + 1
	end
end

print("📊 TOTAL DE OBJETOS GERADOS:")
print("   🌲 Árvores: " .. totalArvores)
print("   🌿 Galhos: " .. totalGalhos)
print("   🪨 Pedras: " .. totalPedras)
print("   📦 Total: " .. #objetosExistentes)
print("\n💡 Para salvar as posições, copie o output acima ou")
print("   use o plugin de exportação do Roblox Studio.")

-- Opcional: Exportar posições para um módulo
local posicoesExport = {}
for _, obj in pairs(objetosExistentes) do
	table.insert(posicoesExport, {
		tipo = obj.tipo,
		nome = obj.nome,
		posicao = {obj.posicao.X, obj.posicao.Y, obj.posicao.Z}
	})
end

-- Salvar em ReplicatedStorage para referência
local moduloPosicoes = Instance.new("ModuleScript")
moduloPosicoes.Name = "PosicoesMapaGerado"
moduloPosicoes.Source = "return " .. "{[=[" .. game:GetService("HttpService"):JSONEncode(posicoesExport) .. "]=]}"
moduloPosicoes.Parent = ReplicatedStorage

print("\n📁 Posições salvas em ReplicatedStorage.PosicoesMapaGerado")

print("\n🗺️ GERADOR DE MAPA FINALIZADO!")
