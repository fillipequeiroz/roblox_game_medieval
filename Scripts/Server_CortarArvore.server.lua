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

-- Encontrar árvore pelo nome no Workspace
local function encontrarArvorePorNome(nomeArvore)
	for _, objeto in pairs(Workspace:GetDescendants()) do
		if objeto:IsA("Model") and objeto.Name == nomeArvore then
			return objeto
		end
	end
	return nil
end

-- Encontrar modelo Tronco
local function encontrarModeloTronco()
	return Workspace:FindFirstChild("Tronco")
end

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
	
	-- Inicializar contador
	if not golpesArvores[arvoreId] then
		golpesArvores[arvoreId] = 0
	end
	
	-- Incrementar
	golpesArvores[arvoreId] = golpesArvores[arvoreId] + 1
	local golpesAtuais = golpesArvores[arvoreId]
	
	print("🪓 " .. player.Name .. " golpeou '" .. nomeArvore .. "' (" .. golpesAtuais .. "/1)")
	
	-- Se chegou a 1 golpe
	if golpesAtuais >= 1 then
		local posicao = arvore:GetPivot().Position
		
		-- Destruir árvore
		arvore:Destroy()
		golpesArvores[arvoreId] = nil
		
		print("🌲 Árvore '" .. nomeArvore .. "' destruída!")
		
		-- Spawnar tronco
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
			
			novoTronco:PivotTo(CFrame.new(posicao))
			novoTronco.Parent = Workspace
			novoTronco:SetAttribute("TipoRecurso", "Tronco")
			
			print("🪵 Tronco spawnado em: " .. tostring(posicao))
		else
			print("⚠️ Modelo 'Tronco' não encontrado!")
		end
		
		-- Adicionar madeira
		local dados = dadosJogadores[player.UserId]
		if dados then
			dados.inventario.madeira = dados.inventario.madeira + 3
			if atualizarInventario then
				atualizarInventario:FireClient(player, dados.inventario)
			end
			print("🪵 " .. player.Name .. " ganhou 3 madeiras!")
		end
	end
end

-- Conectar evento
print("🔗 Conectando evento CortarArvore...")
cortarArvoreEvento.OnServerEvent:Connect(function(player, nomeArvore)
	print("📨 Evento CortarArvore recebido de " .. player.Name)
	processarGolpe(player, nomeArvore)
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

print("✅ Servidor de corte de árvores inicializado!")
