-- Server_SpawnRecursos.server.lua
-- Spawna árvores, rocks e sticks no mapa

local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

-- Modelos base
local modelosArvores = {}
local modeloRock = nil
local modeloStick = nil

-- Configurações de spawn
local SPAWN_ARVORES_FIXAS = {
	Vector3.new(20, 0, -50),
	Vector3.new(40, 0, -30),
	Vector3.new(-20, 0, -60),
	Vector3.new(60, 0, -80),
	Vector3.new(-40, 0, -20),
	Vector3.new(80, 0, -40),
	Vector3.new(10, 0, -100),
	Vector3.new(-60, 0, 10),
	Vector3.new(100, 0, -20),
	Vector3.new(-80, 0, -70),
}

local QUANTIDADE_ROCKS = 15
local QUANTIDADE_STICKS = 20

-- Área de spawn aleatório
local AREA_SPAWN = {
	minX = -100, maxX = 100,
	minZ = -100, maxZ = 100,
	Y = 3
}

-- Função para encontrar altura do terreno
local function getAlturaTerreno(posicaoX, posicaoZ)
	-- Raycast para baixo a partir de altura alta
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
	
	-- Fallback: usar altura do terreno se disponível
	if Terrain then
		local material, altura = Terrain:ReadVoxels(
			Region3.new(Vector3.new(posicaoX, -100, posicaoZ), Vector3.new(posicaoX + 1, 100, posicaoZ + 1)),
			4
		)
		if altura and altura[1] and altura[1][1] and altura[1][1][1] then
			return altura[1][1][1]
		end
	end
	
	return AREA_SPAWN.Y
end

-- Função para carregar modelos base
local function carregarModelos()
	for i = 1, 5 do
		local arvore = Workspace:FindFirstChild("Tree" .. i)
		if arvore then
			modelosArvores[i] = arvore
			-- Configurar árvore original para ser cortável
			arvore:SetAttribute("TipoRecurso", "Madeira")
			arvore:SetAttribute("Vida", 3)
			print("🌲 Árvore " .. i .. " carregada e configurada")
		end
	end
	
	modeloRock = Workspace:FindFirstChild("smallRockStone")
	modeloStick = Workspace:FindFirstChild("StickRecurso")
end

-- Função para spawnar árvores em locais fixos
local function spawnarArvoresFixas()
	if #modelosArvores == 0 then
		print("⚠️ Nenhuma árvore disponível")
		return
	end
	
	for i, posicaoBase in ipairs(SPAWN_ARVORES_FIXAS) do
		local indiceAleatorio = math.random(1, #modelosArvores)
		local modeloBase = modelosArvores[indiceAleatorio]
		
		if modeloBase then
			local novaArvore = modeloBase:Clone()
			novaArvore.Name = "TreeSpawn_" .. i
			
			-- Encontrar a parte mais baixa da árvore (base do tronco)
			local parteMaisBaixa = nil
			local menorY = math.huge
			
			for _, parte in pairs(novaArvore:GetDescendants()) do
				if parte:IsA("BasePart") then
					local baseY = parte.Position.Y - (parte.Size.Y / 2)
					if baseY < menorY then
						menorY = baseY
						parteMaisBaixa = parte
					end
				end
			end
			
			-- Encontrar altura do terreno
			local alturaTerreno = getAlturaTerreno(posicaoBase.X, posicaoBase.Z)
			
			-- Calcular offset para ajustar a base da árvore ao solo
			local offset = 0
			if parteMaisBaixa then
				offset = parteMaisBaixa.Position.Y - menorY
			end
			
			-- Posicionar árvore com a base no solo
			local posicaoFinal = Vector3.new(posicaoBase.X, alturaTerreno + offset, posicaoBase.Z)
			novaArvore:PivotTo(CFrame.new(posicaoFinal))
			novaArvore.Parent = Workspace
			
			-- Configurar atributos
			novaArvore:SetAttribute("TipoRecurso", "Madeira")
			novaArvore:SetAttribute("Vida", 3)
			
			print("🌲 Árvore " .. indiceAleatorio .. " spawnada em: " .. tostring(posicaoFinal))
		end
	end
end

-- Função para gerar posição aleatória
local function posicaoAleatoria()
	local x = math.random(AREA_SPAWN.minX, AREA_SPAWN.maxX)
	local z = math.random(AREA_SPAWN.minZ, AREA_SPAWN.maxZ)
	local y = getAlturaTerreno(x, z)
	
	return Vector3.new(x, y, z)
end

-- Função para spawnar rocks
local function spawnarRocks()
	if not modeloRock then return end
	
	for i = 1, QUANTIDADE_ROCKS do
		local novaRock = modeloRock:Clone()
		novaRock.Name = "RockSpawn_" .. i
		
		local posicao = posicaoAleatoria()
		novaRock:PivotTo(CFrame.new(posicao))
		novaRock.Parent = Workspace
		
		novaRock:SetAttribute("TipoRecurso", "Pedra")
		
		print("🪨 Rock " .. i .. " spawnado")
	end
end

-- Função para spawnar sticks
local function spawnarSticks()
	if not modeloStick then return end
	
	for i = 1, QUANTIDADE_STICKS do
		local novoStick = modeloStick:Clone()
		novoStick.Name = "StickSpawn_" .. i
		
		local posicao = posicaoAleatoria()
		novoStick:PivotTo(CFrame.new(posicao))
		novoStick.Parent = Workspace
		
		novoStick:SetAttribute("TipoRecurso", "Stick")
		
		print("🌿 Stick " .. i .. " spawnado")
	end
end

-- Inicializar
print("🌍 Iniciando sistema de spawn...")

carregarModelos()
task.wait(2)

spawnarArvoresFixas()
spawnarRocks()
spawnarSticks()

print("✅ Spawn finalizado!")
