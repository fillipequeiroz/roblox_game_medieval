-- Server_CortarArvore.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "EventosJogo"
	eventos.Parent = ReplicatedStorage
end

local cortarArvoreEvento = eventos:FindFirstChild("CortarArvore")
if not cortarArvoreEvento then
	cortarArvoreEvento = Instance.new("RemoteEvent")
	cortarArvoreEvento.Name = "CortarArvore"
	cortarArvoreEvento.Parent = eventos
end

local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")

_G.DadosJogadores = _G.DadosJogadores or {}
local dadosJogadores = _G.DadosJogadores

local golpesArvores = {}

-- Configuração de tiers de árvores
local CONFIG_ARVORES = {
	Tree1 = { golpesNecessarios = 5, madeira = 1 },
	Tree2 = { golpesNecessarios = 5, madeira = 1 },
	Tree3 = { golpesNecessarios = 10, madeira = 3 },
	Tree4 = { golpesNecessarios = 10, madeira = 3 },
	Tree5 = { golpesNecessarios = 8, madeira = 2 },
}

-- Função para obter configuração da árvore
local function getConfigArvore(nomeArvore)
	-- Verificar se é TreeSpawn_X (árvores spawnadas) - extrair o número
	local spawnNum = nomeArvore:match("TreeSpawn_(%d+)")
	if spawnNum then
		-- Mapear TreeSpawn_X para TreeX
		local treeName = "Tree" .. spawnNum
		if CONFIG_ARVORES[treeName] then
			return CONFIG_ARVORES[treeName]
		end
	end
	
	-- Verificar se o nome começa com Tree1, Tree2, etc (árvores originais)
	for treeName, config in pairs(CONFIG_ARVORES) do
		if nomeArvore:find(treeName) then
			return config
		end
	end
	
	-- Configuração padrão
	return { golpesNecessarios = 5, madeira = 1 }
end

-- Encontrar árvore pelo nome no Workspace
local function encontrarArvorePorNome(nomeArvore)
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") and objeto.Name == nomeArvore then
			return objeto
		end
	end
	return nil
end

-- Template do tronco (cópia armazenada no início do jogo)
local templateTronco = nil

-- Encontrar modelo Tronco e criar template
local function inicializarTemplateTronco()
	local ServerStorage = game:GetService("ServerStorage")
	
	-- Buscar no ServerStorage primeiro
	local tronco = ServerStorage:FindFirstChild("Tronco")
	local origem = "ServerStorage"
	
	-- Se não achou, tenta no Workspace
	if not tronco then
		tronco = Workspace:FindFirstChild("Tronco")
		origem = "Workspace"
	end
	
	if tronco then
		-- Clonar o modelo para usar como template
		templateTronco = tronco:Clone()
		templateTronco.Name = "Tronco_Template"
		templateTronco.Parent = nil -- Não fica no workspace, só na memória
		
		local partes = 0
		for _, p in pairs(templateTronco:GetDescendants()) do
			if p:IsA("BasePart") then partes = partes + 1 end
		end
		print("🪵 Template Tronco criado com " .. partes .. " partes (de " .. origem .. ")")
		return true
	else
		print("⚠️ Modelo Tronco NÃO encontrado no ServerStorage nem Workspace!")
		return false
	end
end

-- Retorna o template para clonar
local function encontrarModeloTronco()
	return templateTronco
end

-- Inicializar template IMEDIATAMENTE (antes que alguém possa coletar o tronco original)
inicializarTemplateTronco()

-- Função para encontrar posição base da árvore
local function getPosicaoBaseArvore(arvore)
	local menorY = math.huge
	local posicaoBase = arvore:GetPivot().Position
	
	for _, parte in pairs(arvore:GetDescendants()) do
		if parte:IsA("BasePart") then
			local baseY = parte.Position.Y - (parte.Size.Y / 2)
			if baseY < menorY then
				menorY = baseY
				posicaoBase = Vector3.new(parte.Position.X, baseY, parte.Position.Z)
			end
		end
	end
	
	return posicaoBase
end

-- Processar golpe
local function processarGolpe(player, nomeArvore)
	print("🪓 Evento recebido: player=" .. tostring(player.Name) .. ", arvore=" .. tostring(nomeArvore))
	
	if not player or not nomeArvore then 
		print("⚠️ Dados inválidos recebidos")
		return 
	end
	
	-- Encontrar a árvore pelo nome
	local arvore = encontrarArvorePorNome(nomeArvore)
	
	if not arvore then
		print("⚠️ Árvore '" .. nomeArvore .. "' não encontrada")
		return
	end
	
	-- Verificar distância (pela base da árvore)
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local posicaoBase = getPosicaoBaseArvore(arvore)
	local posicaoPlayer = humanoidRootPart.Position
	-- Comparar apenas X e Z (distância horizontal)
	local distanciaHorizontal = Vector3.new(posicaoPlayer.X - posicaoBase.X, 0, posicaoPlayer.Z - posicaoBase.Z).Magnitude
	
	if distanciaHorizontal > 12 then
		print("⚠️ " .. player.Name .. " muito longe da árvore! Dist: " .. distanciaHorizontal)
		return
	end
	
	-- Verificar se tem machado
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or tool.Name ~= "Machado" then
		print("⚠️ " .. player.Name .. " não está com machado!")
		return
	end
	
	-- ID único
	local arvoreId = nomeArvore
	
	-- Obter configuração da árvore
	local config = getConfigArvore(nomeArvore)
	local golpesNecessarios = config.golpesNecessarios
	local madeiraReward = config.madeira
	
	-- Inicializar contador
	if not golpesArvores[arvoreId] then
		golpesArvores[arvoreId] = 0
	end
	
	-- Incrementar
	golpesArvores[arvoreId] = golpesArvores[arvoreId] + 1
	local golpesAtuais = golpesArvores[arvoreId]
	
	print("🪓 " .. player.Name .. " golpeou '" .. nomeArvore .. "' (" .. golpesAtuais .. "/" .. golpesNecessarios .. ")")
	
	-- Se chegou aos golpes necessários
	if golpesAtuais >= golpesNecessarios then
		local posicao = arvore:GetPivot().Position
		
		-- Destruir árvore
		arvore:Destroy()
		golpesArvores[arvoreId] = nil
		
		print("🌲 Árvore '" .. nomeArvore .. "' destruída!")
		
		-- Spawnar tronco (estrutura Model "Tronco" com MeshPart "Base" dentro)
		local modeloTronco = encontrarModeloTronco()
		if modeloTronco then
			local novoTronco = modeloTronco:Clone()
			novoTronco.Name = "Tronco_Spawn"
			
			-- Raycast para altura do terreno
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			
			local resultado = Workspace:Raycast(Vector3.new(posicao.X, 100, posicao.Z), Vector3.new(0, -200, 0), raycastParams)
			if resultado then
				posicao = Vector3.new(posicao.X, resultado.Position.Y, posicao.Z)
			end
			
			-- Ajustar altura para o tronco ficar deitado no chão
			posicao = posicao + Vector3.new(0, 0.5, 0)
			
			novoTronco:PivotTo(CFrame.new(posicao))
			novoTronco.Parent = Workspace
			novoTronco:SetAttribute("TipoRecurso", "Tronco")
			novoTronco:SetAttribute("Madeira", madeiraReward)  -- Guardar quantidade de madeira no tronco
			
			-- Configurar TODAS as partes do modelo
			for _, parte in pairs(novoTronco:GetDescendants()) do
				if parte:IsA("BasePart") then
					parte.Anchored = true
					parte.CanCollide = true
				end
			end
			
			print("🪵 Tronco spawnado em: " .. tostring(posicao))
		else
			print("⚠️ Modelo 'Tronco' não encontrado!")
		end
		
		-- Madeira só será dada quando coletar o tronco!
		print("🪵 Tronco spawnado! Colete-o para ganhar madeiras.")
	end
end

-- Processar coleta de tronco (DEFINIR ANTES de usar no OnServerEvent)
local function processarColetaTronco(player, nomeTronco)
	print("🪵 Coletando tronco: " .. tostring(nomeTronco))
	
	if not player or not nomeTronco then 
		print("⚠️ Dados inválidos para coleta")
		return 
	end
	
	-- Verificar distância do player
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	local posicaoPlayer = humanoidRootPart.Position
	
	-- Buscar o tronco mais próximo do jogador (independente do nome)
	local troncoMaisProximo = nil
	local menorDistancia = 12 -- Distância máxima permitida
	
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") and objeto:GetAttribute("TipoRecurso") == "Tronco" then
			local posicaoBase = getPosicaoBaseArvore(objeto)
			local distancia = Vector3.new(posicaoPlayer.X - posicaoBase.X, 0, posicaoPlayer.Z - posicaoBase.Z).Magnitude
			
			if distancia < menorDistancia then
				menorDistancia = distancia
				troncoMaisProximo = objeto
			end
		end
	end
	
	-- Se não achou pelo atributo, tenta pelo nome (fallback para compatibilidade)
	local tronco = troncoMaisProximo
	if not tronco then
		for _, objeto in pairs(Workspace:GetDescendants()) do
			if objeto:IsA("Model") and objeto.Name == nomeTronco then
				tronco = objeto
				print("🪵 Tronco encontrado pelo nome (fallback): " .. objeto.Name)
				break
			end
		end
	else
		print("🪵 Tronco mais próximo encontrado: " .. tronco.Name .. " | Dist: " .. menorDistancia)
	end
	
	if not tronco then
		print("⚠️ Nenhum tronco encontrado perto de " .. player.Name)
		return
	end
	
	-- Obter quantidade de madeira do tronco (ou usar 1 como padrão)
	local madeira = tronco:GetAttribute("Madeira") or 1
	
	-- Destruir tronco
	tronco:Destroy()
	print("🪵 Tronco coletado!")
	
	-- Adicionar madeira ao inventário
	local dados = dadosJogadores[player.UserId]
	if dados then
		dados.inventario.madeira = dados.inventario.madeira + madeira
		if atualizarInventario then
			atualizarInventario:FireClient(player, dados.inventario)
		end
		print("🪵 " .. player.Name .. " ganhou " .. madeira .. " madeira(s)!")
	end
end

-- Conectar evento (DEPOIS de definir todas as funções)
print("🔗 Conectando evento CortarArvore...")
cortarArvoreEvento.OnServerEvent:Connect(function(player, nomeObjeto, acao)
	print("📨 Evento recebido de " .. player.Name .. " - Objeto: " .. tostring(nomeObjeto) .. " - Ação: " .. tostring(acao))
	
	if acao == "coletar" then
		processarColetaTronco(player, nomeObjeto)
	else
		processarGolpe(player, nomeObjeto)
	end
end)

-- Limpar tabela periodicamente
task.spawn(function()
	while true do
		task.wait(30)
		for id, _ in pairs(golpesArvores) do
			local arvore = encontrarArvorePorNome(id)
			if not arvore then
				golpesArvores[id] = nil
			end
		end
	end
end)

print("✅ Servidor de corte de árvores e coleta de troncos inicializado!")
