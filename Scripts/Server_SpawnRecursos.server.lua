-- Server_SpawnRecursos.server.lua
-- Spawna árvores, rocks e sticks nas posições fixas do mapa

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

-- Configuração
local CONFIG = {
	atributoMapaGerado = "MapaSpawnGerado",
	pastaMapa = "MapaGerado"
}

-- Modelos base
local modelosArvores = {}
local modeloRock = nil
local modeloStick = nil

-- ==================== COORDENADAS DA GRAMA ====================
-- Posição real da parte "Grama" no Workspace
local GRAMA_POS = Vector3.new(53.63, 0.379, -48.23)
local GRAMA_SIZE = Vector3.new(512.74, 0.759, 512.46)

-- Limites da grama (com margem de segurança de 30 unidades)
local MIN_X = GRAMA_POS.X - GRAMA_SIZE.X/2 + 30  -- -202.74 + 30 = -172.74
local MAX_X = GRAMA_POS.X + GRAMA_SIZE.X/2 - 30  -- 310.00 - 30 = 280.00
local MIN_Z = GRAMA_POS.Z - GRAMA_SIZE.Z/2 + 30  -- -304.46 + 30 = -274.46
local MAX_Z = GRAMA_POS.Z + GRAMA_SIZE.Z/2 - 30  -- 208.00 - 30 = 178.00
local ALTURA_BASE = GRAMA_POS.Y + GRAMA_SIZE.Y/2  -- Topo da grama: ~0.76

-- ==================== POSIÇÕES FIXAS DO MAPA ====================

-- FLORESTA NORTE (Z entre -250 e -100) - Densidade Alta
local ARVORES_NORTE = {
	-- Árvores tipo 1 (5 golpes, 1 madeira)
	{tipo = "Tree1", posicao = Vector3.new(-100, ALTURA_BASE, -250), rotacao = 0},
	{tipo = "Tree1", posicao = Vector3.new(-50, ALTURA_BASE, -230), rotacao = 45},
	{tipo = "Tree1", posicao = Vector3.new(0, ALTURA_BASE, -260), rotacao = 90},
	{tipo = "Tree1", posicao = Vector3.new(50, ALTURA_BASE, -240), rotacao = 135},
	{tipo = "Tree1", posicao = Vector3.new(100, ALTURA_BASE, -270), rotacao = 180},
	
	-- Árvores tipo 2 (5 golpes, 1 madeira)
	{tipo = "Tree2", posicao = Vector3.new(-80, ALTURA_BASE, -200), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(-30, ALTURA_BASE, -220), rotacao = 60},
	{tipo = "Tree2", posicao = Vector3.new(30, ALTURA_BASE, -190), rotacao = 120},
	
	-- Árvores tipo 3 (10 golpes, 3 madeiras) - Mais raras
	{tipo = "Tree3", posicao = Vector3.new(80, ALTURA_BASE, -210), rotacao = 0},
	{tipo = "Tree3", posicao = Vector3.new(120, ALTURA_BASE, -180), rotacao = 90},
	
	-- Árvores tipo 4 (10 golpes, 3 madeiras)
	{tipo = "Tree4", posicao = Vector3.new(150, ALTURA_BASE, -230), rotacao = 0},
	
	-- Árvores tipo 5 (8 golpes, 2 madeiras)
	{tipo = "Tree5", posicao = Vector3.new(180, ALTURA_BASE, -200), rotacao = 45},
	{tipo = "Tree5", posicao = Vector3.new(200, ALTURA_BASE, -250), rotacao = 90},
	
	-- Mais árvores densas (Norte)
	{tipo = "Tree1", posicao = Vector3.new(-120, ALTURA_BASE, -180), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(-150, ALTURA_BASE, -220), rotacao = 30},
	{tipo = "Tree1", posicao = Vector3.new(20, ALTURA_BASE, -150), rotacao = 60},
	{tipo = "Tree3", posicao = Vector3.new(60, ALTURA_BASE, -170), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(100, ALTURA_BASE, -150), rotacao = 90},
	
	-- Centro-Norte
	{tipo = "Tree1", posicao = Vector3.new(-60, ALTURA_BASE, -120), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(-20, ALTURA_BASE, -140), rotacao = 45},
	{tipo = "Tree5", posicao = Vector3.new(20, ALTURA_BASE, -120), rotacao = 0},
	{tipo = "Tree4", posicao = Vector3.new(60, ALTURA_BASE, -140), rotacao = 60},
	{tipo = "Tree1", posicao = Vector3.new(100, ALTURA_BASE, -120), rotacao = 90},
	
	-- Oeste-Norte
	{tipo = "Tree2", posicao = Vector3.new(-140, ALTURA_BASE, -260), rotacao = 0},
	{tipo = "Tree3", posicao = Vector3.new(-170, ALTURA_BASE, -190), rotacao = 45},
	
	-- Leste-Norte
	{tipo = "Tree2", posicao = Vector3.new(220, ALTURA_BASE, -170), rotacao = 0},
	{tipo = "Tree1", posicao = Vector3.new(250, ALTURA_BASE, -220), rotacao = 180},
	
	-- NOVAS ÁRVORES - Preenchendo espaços (Norte)
	{tipo = "Tree1", posicao = Vector3.new(-130, ALTURA_BASE, -135), rotacao = 15},
	{tipo = "Tree3", posicao = Vector3.new(-90, ALTURA_BASE, -155), rotacao = 30},
	{tipo = "Tree2", posicao = Vector3.new(-50, ALTURA_BASE, -175), rotacao = 45},
	{tipo = "Tree4", posicao = Vector3.new(-10, ALTURA_BASE, -195), rotacao = 60},
	{tipo = "Tree5", posicao = Vector3.new(30, ALTURA_BASE, -135), rotacao = 75},
	{tipo = "Tree1", posicao = Vector3.new(70, ALTURA_BASE, -155), rotacao = 90},
	{tipo = "Tree2", posicao = Vector3.new(110, ALTURA_BASE, -175), rotacao = 105},
	{tipo = "Tree3", posicao = Vector3.new(150, ALTURA_BASE, -195), rotacao = 120},
	{tipo = "Tree1", posicao = Vector3.new(190, ALTURA_BASE, -135), rotacao = 135},
	{tipo = "Tree5", posicao = Vector3.new(230, ALTURA_BASE, -155), rotacao = 150},
	
	-- Mais árvores no extremo norte
	{tipo = "Tree2", posicao = Vector3.new(-160, ALTURA_BASE, -270), rotacao = 0},
	{tipo = "Tree1", posicao = Vector3.new(-60, ALTURA_BASE, -285), rotacao = 30},
	{tipo = "Tree4", posicao = Vector3.new(40, ALTURA_BASE, -270), rotacao = 60},
	{tipo = "Tree3", posicao = Vector3.new(140, ALTURA_BASE, -285), rotacao = 90},
	{tipo = "Tree5", posicao = Vector3.new(240, ALTURA_BASE, -270), rotacao = 120},
}

-- PLANÍCIE CENTRAL (Z entre -80 e 50) - Densidade Média
local ARVORES_CENTRO = {
	{tipo = "Tree1", posicao = Vector3.new(-100, ALTURA_BASE, -50), rotacao = 0},
	{tipo = "Tree5", posicao = Vector3.new(-50, ALTURA_BASE, -30), rotacao = 45},
	{tipo = "Tree2", posicao = Vector3.new(0, ALTURA_BASE, -60), rotacao = 90},
	{tipo = "Tree4", posicao = Vector3.new(50, ALTURA_BASE, -40), rotacao = 0},
	
	{tipo = "Tree3", posicao = Vector3.new(100, ALTURA_BASE, -50), rotacao = 0},
	{tipo = "Tree1", posicao = Vector3.new(150, ALTURA_BASE, -30), rotacao = 60},
	{tipo = "Tree2", posicao = Vector3.new(200, ALTURA_BASE, -60), rotacao = 120},
	{tipo = "Tree5", posicao = Vector3.new(-150, ALTURA_BASE, 0), rotacao = 180},
	
	{tipo = "Tree1", posicao = Vector3.new(-100, ALTURA_BASE, 20), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(-50, ALTURA_BASE, 40), rotacao = 45},
	{tipo = "Tree4", posicao = Vector3.new(0, ALTURA_BASE, 20), rotacao = 90},
	{tipo = "Tree1", posicao = Vector3.new(50, ALTURA_BASE, 40), rotacao = 0},
	
	{tipo = "Tree3", posicao = Vector3.new(100, ALTURA_BASE, 0), rotacao = 0},
	{tipo = "Tree5", posicao = Vector3.new(150, ALTURA_BASE, 20), rotacao = 60},
	{tipo = "Tree2", posicao = Vector3.new(200, ALTURA_BASE, 40), rotacao = 0},
	{tipo = "Tree1", posicao = Vector3.new(-120, ALTURA_BASE, -70), rotacao = 90},
	
	-- NOVAS ÁRVORES - Planície Central (mais densidade)
	{tipo = "Tree2", posicao = Vector3.new(-80, ALTURA_BASE, -10), rotacao = 15},
	{tipo = "Tree4", posicao = Vector3.new(-40, ALTURA_BASE, 10), rotacao = 30},
	{tipo = "Tree1", posicao = Vector3.new(0, ALTURA_BASE, -10), rotacao = 45},
	{tipo = "Tree3", posicao = Vector3.new(40, ALTURA_BASE, 10), rotacao = 60},
	{tipo = "Tree5", posicao = Vector3.new(80, ALTURA_BASE, -10), rotacao = 75},
	{tipo = "Tree2", posicao = Vector3.new(120, ALTURA_BASE, 10), rotacao = 90},
	{tipo = "Tree1", posicao = Vector3.new(160, ALTURA_BASE, -10), rotacao = 105},
	{tipo = "Tree4", posicao = Vector3.new(-160, ALTURA_BASE, 50), rotacao = 120},
	{tipo = "Tree3", posicao = Vector3.new(-20, ALTURA_BASE, 60), rotacao = 135},
	{tipo = "Tree5", posicao = Vector3.new(60, ALTURA_BASE, 60), rotacao = 150},
	{tipo = "Tree2", posicao = Vector3.new(180, ALTURA_BASE, 60), rotacao = 165},
}

-- CAMPO SUL (Z entre 70 e 150) - Densidade Baixa
local ARVORES_SUL = {
	{tipo = "Tree1", posicao = Vector3.new(-100, ALTURA_BASE, 80), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(-50, ALTURA_BASE, 100), rotacao = 90},
	{tipo = "Tree5", posicao = Vector3.new(0, ALTURA_BASE, 120), rotacao = 45},
	{tipo = "Tree1", posicao = Vector3.new(50, ALTURA_BASE, 80), rotacao = 180},
	{tipo = "Tree3", posicao = Vector3.new(100, ALTURA_BASE, 100), rotacao = 0},
	{tipo = "Tree2", posicao = Vector3.new(150, ALTURA_BASE, 120), rotacao = 60},
	{tipo = "Tree4", posicao = Vector3.new(200, ALTURA_BASE, 90), rotacao = 120},
	{tipo = "Tree1", posicao = Vector3.new(-120, ALTURA_BASE, 140), rotacao = 0},
	{tipo = "Tree5", posicao = Vector3.new(0, ALTURA_BASE, 150), rotacao = 45},
	{tipo = "Tree1", posicao = Vector3.new(100, ALTURA_BASE, 140), rotacao = 90},
	
	-- NOVAS ÁRVORES - Campo Sul (mais árvores)
	{tipo = "Tree2", posicao = Vector3.new(-70, ALTURA_BASE, 70), rotacao = 15},
	{tipo = "Tree4", posicao = Vector3.new(30, ALTURA_BASE, 70), rotacao = 30},
	{tipo = "Tree3", posicao = Vector3.new(130, ALTURA_BASE, 70), rotacao = 45},
	{tipo = "Tree2", posicao = Vector3.new(-150, ALTURA_BASE, 110), rotacao = 60},
	{tipo = "Tree5", posicao = Vector3.new(-70, ALTURA_BASE, 130), rotacao = 75},
	{tipo = "Tree1", posicao = Vector3.new(50, ALTURA_BASE, 130), rotacao = 90},
	{tipo = "Tree4", posicao = Vector3.new(170, ALTURA_BASE, 130), rotacao = 105},
	{tipo = "Tree3", posicao = Vector3.new(-30, ALTURA_BASE, 160), rotacao = 120},
	{tipo = "Tree2", posicao = Vector3.new(70, ALTURA_BASE, 160), rotacao = 135},
	{tipo = "Tree1", posicao = Vector3.new(200, ALTURA_BASE, 150), rotacao = 150},
}

-- GALHOS ESPALHADOS (posições aleatórias espalhadas pelo mapa)
local GALHOS = {
	-- Floresta Norte
	{posicao = Vector3.new(-80, ALTURA_BASE + 0.1, -240), rotacao = 0},
	{posicao = Vector3.new(-40, ALTURA_BASE + 0.1, -200), rotacao = 45},
	{posicao = Vector3.new(0, ALTURA_BASE + 0.1, -230), rotacao = 90},
	{posicao = Vector3.new(40, ALTURA_BASE + 0.1, -190), rotacao = 135},
	{posicao = Vector3.new(80, ALTURA_BASE + 0.1, -220), rotacao = 0},
	{posicao = Vector3.new(120, ALTURA_BASE + 0.1, -180), rotacao = 60},
	{posicao = Vector3.new(160, ALTURA_BASE + 0.1, -210), rotacao = 120},
	{posicao = Vector3.new(-120, ALTURA_BASE + 0.1, -170), rotacao = 180},
	{posicao = Vector3.new(-40, ALTURA_BASE + 0.1, -160), rotacao = 0},
	{posicao = Vector3.new(40, ALTURA_BASE + 0.1, -140), rotacao = 45},
	
	-- Planície Central (mais galhos)
	{posicao = Vector3.new(-80, ALTURA_BASE + 0.1, -20), rotacao = 0},
	{posicao = Vector3.new(-40, ALTURA_BASE + 0.1, 0), rotacao = 45},
	{posicao = Vector3.new(0, ALTURA_BASE + 0.1, -10), rotacao = 90},
	{posicao = Vector3.new(40, ALTURA_BASE + 0.1, 10), rotacao = 0},
	{posicao = Vector3.new(80, ALTURA_BASE + 0.1, -20), rotacao = 60},
	{posicao = Vector3.new(120, ALTURA_BASE + 0.1, 0), rotacao = 120},
	{posicao = Vector3.new(160, ALTURA_BASE + 0.1, 20), rotacao = 0},
	{posicao = Vector3.new(-120, ALTURA_BASE + 0.1, 10), rotacao = 45},
	{posicao = Vector3.new(-60, ALTURA_BASE + 0.1, 30), rotacao = 90},
	{posicao = Vector3.new(20, ALTURA_BASE + 0.1, 30), rotacao = 0},
	
	-- Campo Sul
	{posicao = Vector3.new(-80, ALTURA_BASE + 0.1, 90), rotacao = 0},
	{posicao = Vector3.new(-40, ALTURA_BASE + 0.1, 110), rotacao = 45},
	{posicao = Vector3.new(0, ALTURA_BASE + 0.1, 130), rotacao = 90},
	{posicao = Vector3.new(40, ALTURA_BASE + 0.1, 90), rotacao = 0},
	{posicao = Vector3.new(80, ALTURA_BASE + 0.1, 110), rotacao = 60},
	
	-- MAIS GALHOS - Espalhados por todo mapa
	{posicao = Vector3.new(-150, ALTURA_BASE + 0.1, -250), rotacao = 30},
	{posicao = Vector3.new(-20, ALTURA_BASE + 0.1, -250), rotacao = 60},
	{posicao = Vector3.new(100, ALTURA_BASE + 0.1, -250), rotacao = 90},
	{posicao = Vector3.new(220, ALTURA_BASE + 0.1, -250), rotacao = 120},
	{posicao = Vector3.new(-100, ALTURA_BASE + 0.1, -100), rotacao = 15},
	{posicao = Vector3.new(50, ALTURA_BASE + 0.1, -100), rotacao = 45},
	{posicao = Vector3.new(200, ALTURA_BASE + 0.1, -100), rotacao = 75},
	{posicao = Vector3.new(-50, ALTURA_BASE + 0.1, 50), rotacao = 0},
	{posicao = Vector3.new(100, ALTURA_BASE + 0.1, 50), rotacao = 30},
	{posicao = Vector3.new(-150, ALTURA_BASE + 0.1, 150), rotacao = 60},
	{posicao = Vector3.new(50, ALTURA_BASE + 0.1, 150), rotacao = 90},
	{posicao = Vector3.new(200, ALTURA_BASE + 0.1, 150), rotacao = 120},
}

-- PEDRAS ESPALHADAS
local PEDRAS = {
	-- Floresta Norte (poucas)
	{posicao = Vector3.new(-100, ALTURA_BASE + 0.1, -220), escala = 1.0, rotacao = 0},
	{posicao = Vector3.new(-20, ALTURA_BASE + 0.1, -210), escala = 1.2, rotacao = 45},
	{posicao = Vector3.new(60, ALTURA_BASE + 0.1, -200), escala = 0.8, rotacao = 90},
	{posicao = Vector3.new(140, ALTURA_BASE + 0.1, -190), escala = 1.1, rotacao = 0},
	
	-- Planície Central (mais pedras)
	{posicao = Vector3.new(-120, ALTURA_BASE + 0.1, -40), escala = 1.0, rotacao = 0},
	{posicao = Vector3.new(-60, ALTURA_BASE + 0.1, -20), escala = 1.1, rotacao = 45},
	{posicao = Vector3.new(0, ALTURA_BASE + 0.1, -40), escala = 0.9, rotacao = 90},
	{posicao = Vector3.new(60, ALTURA_BASE + 0.1, -20), escala = 1.2, rotacao = 0},
	{posicao = Vector3.new(120, ALTURA_BASE + 0.1, -40), escala = 1.0, rotacao = 60},
	{posicao = Vector3.new(180, ALTURA_BASE + 0.1, -20), escala = 0.8, rotacao = 120},
	{posicao = Vector3.new(-80, ALTURA_BASE + 0.1, 20), escala = 1.1, rotacao = 0},
	{posicao = Vector3.new(-20, ALTURA_BASE + 0.1, 40), escala = 0.9, rotacao = 45},
	{posicao = Vector3.new(40, ALTURA_BASE + 0.1, 20), escala = 1.0, rotacao = 90},
	{posicao = Vector3.new(100, ALTURA_BASE + 0.1, 40), escala = 1.2, rotacao = 0},
	
	-- Campo Sul (poucas)
	{posicao = Vector3.new(-60, ALTURA_BASE + 0.1, 100), escala = 1.0, rotacao = 0},
	{posicao = Vector3.new(0, ALTURA_BASE + 0.1, 120), escala = 0.9, rotacao = 45},
	{posicao = Vector3.new(60, ALTURA_BASE + 0.1, 100), escala = 1.1, rotacao = 90},
	{posicao = Vector3.new(120, ALTURA_BASE + 0.1, 130), escala = 0.8, rotacao = 0},
	{posicao = Vector3.new(180, ALTURA_BASE + 0.1, 110), escala = 1.2, rotacao = 60},
	
	-- MAIS PEDRAS - Espalhadas por todo mapa
	{posicao = Vector3.new(-160, ALTURA_BASE + 0.1, -260), escala = 1.0, rotacao = 30},
	{posicao = Vector3.new(-60, ALTURA_BASE + 0.1, -260), escala = 1.1, rotacao = 60},
	{posicao = Vector3.new(40, ALTURA_BASE + 0.1, -260), escala = 0.9, rotacao = 90},
	{posicao = Vector3.new(140, ALTURA_BASE + 0.1, -260), escala = 1.2, rotacao = 120},
	{posicao = Vector3.new(240, ALTURA_BASE + 0.1, -260), escala = 1.0, rotacao = 150},
	{posicao = Vector3.new(-140, ALTURA_BASE + 0.1, -130), escala = 0.8, rotacao = 0},
	{posicao = Vector3.new(-10, ALTURA_BASE + 0.1, -130), escala = 1.1, rotacao = 45},
	{posicao = Vector3.new(130, ALTURA_BASE + 0.1, -130), escala = 1.0, rotacao = 90},
	{posicao = Vector3.new(-100, ALTURA_BASE + 0.1, 70), escala = 1.2, rotacao = 0},
	{posicao = Vector3.new(30, ALTURA_BASE + 0.1, 70), escala = 0.9, rotacao = 60},
	{posicao = Vector3.new(160, ALTURA_BASE + 0.1, 70), escala = 1.1, rotacao = 120},
	{posicao = Vector3.new(-80, ALTURA_BASE + 0.1, 150), escala = 1.0, rotacao = 30},
	{posicao = Vector3.new(80, ALTURA_BASE + 0.1, 150), escala = 0.8, rotacao = 90},
	{posicao = Vector3.new(220, ALTURA_BASE + 0.1, 150), escala = 1.2, rotacao = 150},
}

-- ==================== FUNÇÕES AUXILIARES ====================

-- Verificar se já foi gerado
local function mapaJaFoiGerado()
	if Workspace:GetAttribute(CONFIG.atributoMapaGerado) then
		return true
	end
	local pasta = Workspace:FindFirstChild(CONFIG.pastaMapa)
	if pasta and #pasta:GetChildren() > 0 then
		return true
	end
	return false
end

-- Marcar como gerado
local function marcarMapaGerado()
	Workspace:SetAttribute(CONFIG.atributoMapaGerado, true)
end

-- Preparar pasta do mapa
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
		Vector3.new(posicaoX, 200, posicaoZ), 
		Vector3.new(0, -300, 0), 
		raycastParams
	)
	
	if resultado then
		return resultado.Position.Y
	end
	
	if Terrain then
		local material, altura = Terrain:ReadVoxels(
			Region3.new(Vector3.new(posicaoX, -100, posicaoZ), Vector3.new(posicaoX + 1, 100, posicaoZ + 1)),
			4
		)
		if altura and altura[1] and altura[1][1] and altura[1][1][1] then
			return altura[1][1][1]
		end
	end
	
	return ALTURA_BASE
end

-- ==================== SPAWN ====================

local pastaMapa = nil
local totalArvores = 0
local totalGalhos = 0
local totalPedras = 0

-- Spawnar árvore
local function spawnarArvore(tipo, posicao, rotacao, nomeSpawn)
	-- Buscar no ServerStorage primeiro, depois no Workspace (fallback)
	local modeloOriginal = ServerStorage:FindFirstChild(tipo)
	if not modeloOriginal then
		modeloOriginal = Workspace:FindFirstChild(tipo)
	end
	if not modeloOriginal then
		return false
	end
	
	local novaArvore = modeloOriginal:Clone()
	novaArvore.Name = nomeSpawn
	
	-- Encontrar altura real do terreno
	local alturaY = getAlturaTerreno(posicao.X, posicao.Z)
	
	-- Primeiro posicionar o modelo no chão (sem rotação ainda) para calcular o offset
	novaArvore:PivotTo(CFrame.new(posicao.X, alturaY, posicao.Z))
	
	-- Encontrar o ponto mais baixo do modelo em relação ao seu pivot
	local menorYLocal = math.huge
	
	for _, parte in pairs(novaArvore:GetDescendants()) do
		if parte:IsA("BasePart") then
			-- Posição local em relação ao pivot do modelo
			local posicaoLocal = novaArvore.PrimaryPart and 
				parte.Position - novaArvore.PrimaryPart.Position or
				Vector3.new(0, 0, 0)
			
			-- Se não tem PrimaryPart, calcula em relação ao primeiro BasePart
			if not novaArvore.PrimaryPart then
				local modeloCFrame = novaArvore:GetPivot()
				posicaoLocal = parte.Position - modeloCFrame.Position
			end
			
			local baseYLocal = posicaoLocal.Y - (parte.Size.Y / 2)
			if baseYLocal < menorYLocal then
				menorYLocal = baseYLocal
			end
		end
	end
	
	-- Se não achou nenhuma parte, usar 0
	if menorYLocal == math.huge then
		menorYLocal = 0
	end
	
	-- Ajustar a posição Y para que o ponto mais baixo fique no terreno
	local posicaoFinalY = alturaY - menorYLocal
	
	-- Posicionar finalmente com a rotação
	novaArvore:PivotTo(CFrame.new(posicao.X, posicaoFinalY, posicao.Z) * CFrame.Angles(0, math.rad(rotacao), 0))
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
	-- Buscar no ServerStorage primeiro
	local modeloOriginal = ServerStorage:FindFirstChild("smallStick") or ServerStorage:FindFirstChild("StickRecurso")
	if not modeloOriginal then
		-- Fallback para Workspace
		modeloOriginal = Workspace:FindFirstChild("smallStick") or Workspace:FindFirstChild("StickRecurso")
	end
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
	-- Buscar no ServerStorage primeiro
	local modeloOriginal = ServerStorage:FindFirstChild("smallRockStone")
	if not modeloOriginal then
		-- Fallback para Workspace
		modeloOriginal = Workspace:FindFirstChild("smallRockStone")
	end
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

-- ==================== GERAÇÃO PRINCIPAL ====================

local function gerarMapa()
	print("\n🗺️ GERANDO MAPA COM POSIÇÕES FIXAS...")
	print("   📍 Limites: X[" .. MIN_X .. " a " .. MAX_X .. "], Z[" .. MIN_Z .. " a " .. MAX_Z .. "]")
	
	pastaMapa = prepararPastaMapa()
	
	-- Árvores Norte
	print("   🌲 Floresta Norte (densidade alta)...")
	for i, arvore in ipairs(ARVORES_NORTE) do
		if spawnarArvore(arvore.tipo, arvore.posicao, arvore.rotacao, "TreeSpawn_N_" .. i) then
			totalArvores = totalArvores + 1
		end
	end
	
	-- Árvores Centro
	print("   🌲 Planície Central (densidade média)...")
	for i, arvore in ipairs(ARVORES_CENTRO) do
		if spawnarArvore(arvore.tipo, arvore.posicao, arvore.rotacao, "TreeSpawn_C_" .. i) then
			totalArvores = totalArvores + 1
		end
	end
	
	-- Árvores Sul
	print("   🌲 Campo Sul (densidade baixa)...")
	for i, arvore in ipairs(ARVORES_SUL) do
		if spawnarArvore(arvore.tipo, arvore.posicao, arvore.rotacao, "TreeSpawn_S_" .. i) then
			totalArvores = totalArvores + 1
		end
	end
	
	-- Galhos
	print("   🌿 Distribuindo galhos...")
	for i, galho in ipairs(GALHOS) do
		if spawnarGalho(galho.posicao, galho.rotacao, "StickSpawn_" .. i) then
			totalGalhos = totalGalhos + 1
		end
	end
	
	-- Pedras
	print("   🪨 Distribuindo pedras...")
	for i, pedra in ipairs(PEDRAS) do
		if spawnarPedra(pedra.posicao, pedra.escala, pedra.rotacao, "RockSpawn_" .. i) then
			totalPedras = totalPedras + 1
		end
	end
	
	marcarMapaGerado()
	
	print("\n" .. string.rep("=", 50))
	print("✅ MAPA GERADO COM SUCESSO!")
	print(string.rep("=", 50))
	print("📊 Total de objetos:")
	print("   🌲 Árvores: " .. totalArvores)
	print("   🌿 Galhos: " .. totalGalhos)
	print("   🪨 Pedras: " .. totalPedras)
	print("   📦 Total: " .. (totalArvores + totalGalhos + totalPedras))
	print("\n📁 Todos os objetos estão na pasta: Workspace.MapaGerado")
end

-- ==================== INICIALIZAÇÃO ====================

print("🌍 Iniciando sistema de spawn...")
print("   📍 Grama em: " .. tostring(GRAMA_POS))

if mapaJaFoiGerado() then
	print("✅ Mapa já foi gerado anteriormente. Pulando geração.")
else
	task.spawn(function()
		task.wait(2)
		gerarMapa()
	end)
end
