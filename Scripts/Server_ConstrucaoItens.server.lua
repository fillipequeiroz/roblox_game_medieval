-- Server_ConstrucaoItens.server.lua
-- Processa a construção de itens com sistema de hotbar + preview

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

print("🏗️ SERVER CONSTRUÇÃO DE ITENS INICIANDO...")

-- Criar eventos
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

local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")
if not atualizarInventario then
	atualizarInventario = Instance.new("RemoteEvent")
	atualizarInventario.Name = "AtualizarInventario"
	atualizarInventario.Parent = eventos
end

-- Dados dos jogadores
_G.DadosJogadores = _G.DadosJogadores or {}
local dadosJogadores = _G.DadosJogadores

-- Jogadores com construção pendente
local construcoesPendentes = {}

-- Receitas
local RECEITAS = {
	Workbench = {
		custo = { gravetos = 10, pedra = 5 }
	}
}

-- Funções auxiliares
local function temRecursos(player, item)
	local dados = dadosJogadores[player.UserId]
	if not dados then return false end
	
	local receita = RECEITAS[item]
	if not receita then return false end
	
	for recurso, quantidade in pairs(receita.custo) do
		if (dados.inventario[recurso] or 0) < quantidade then
			return false
		end
	end
	return true
end

local function gastarRecursos(player, item)
	if not temRecursos(player, item) then return false end
	
	local dados = dadosJogadores[player.UserId]
	local receita = RECEITAS[item]
	
	for recurso, quantidade in pairs(receita.custo) do
		dados.inventario[recurso] = dados.inventario[recurso] - quantidade
	end
	
	atualizarInventario:FireClient(player, dados.inventario)
	return true
end

local function devolverRecursos(player, item)
	local dados = dadosJogadores[player.UserId]
	if not dados then return end
	
	local receita = RECEITAS[item]
	if not receita then return end
	
	for recurso, quantidade in pairs(receita.custo) do
		dados.inventario[recurso] = (dados.inventario[recurso] or 0) + quantidade
	end
	
	atualizarInventario:FireClient(player, dados.inventario)
end

-- Processar eventos
construirItemEvento.OnServerEvent:Connect(function(player, acao, item, posicao)
	if not player or not acao then 
		print("⚠️ Evento inválido: player=" .. tostring(player) .. " acao=" .. tostring(acao))
		return 
	end
	
	print("📨 Evento recebido: " .. acao .. " de " .. player.Name .. " item=" .. tostring(item))
	
	if acao == "Iniciar" then
		if not item then
			print("❌ Item não especificado")
			return
		end
		
		-- Verificar e gastar recursos
		if not temRecursos(player, item) then
			print("❌ " .. player.Name .. " sem recursos para " .. item)
			return
		end
		
		if not gastarRecursos(player, item) then
			print("❌ Falha ao gastar recursos")
			return
		end
		
		-- Marcar como pendente
		construcoesPendentes[player.UserId] = {
			item = item,
			tempo = tick()
		}
		
		print("🏗️ " .. player.Name .. " iniciou construção: " .. item)
		print("   💰 Recursos gastos")
		print("   ⏳ Aguardando confirmação...")
		
	elseif acao == "Confirmar" then
		if not posicao then
			print("❌ Posição não fornecida")
			return
		end
		
		-- Verificar se estava pendente
		if not construcoesPendentes[player.UserId] then
			print("⚠️ " .. player.Name .. " confirmou sem iniciar (UserId: " .. player.UserId .. ")")
			print("   📋 Pendentes atuais: " .. tostring(#construcoesPendentes))
			for uid, data in pairs(construcoesPendentes) do
				print("      - UserId " .. uid .. ": " .. data.item)
			end
			return
		end
		
		local itemNome = construcoesPendentes[player.UserId].item
		print("✅ Construção confirmada: " .. itemNome)
		print("   📍 Posição: " .. tostring(posicao))
		
		-- Verificar distância
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (posicao - hrp.Position).Magnitude
				if dist > 30 then
					print("⚠️ Distância muito grande: " .. dist)
				end
			end
		end
		
		-- Spawnar workbench (buscar template no ReplicatedStorage)
		local modelo = ReplicatedStorage:FindFirstChild("Workbench") 
			or ReplicatedStorage:FindFirstChild("Bancada")
			or ReplicatedStorage:FindFirstChild("WorkbenchModel")
			or ReplicatedStorage:FindFirstChild("WorkBench4Script")
			or ReplicatedStorage:FindFirstChild("WorkBench")
		
		if not modelo then
			-- Fallback: tentar no ServerStorage depois Workspace
			print("⚠️ Workbench não encontrado no ReplicatedStorage, tentando ServerStorage...")
			modelo = ServerStorage:FindFirstChild("Workbench") 
				or ServerStorage:FindFirstChild("Bancada")
				or ServerStorage:FindFirstChild("WorkbenchModel")
				or ServerStorage:FindFirstChild("WorkBench4Script")
				or ServerStorage:FindFirstChild("WorkBench")
			
			if not modelo then
				print("⚠️ Workbench não encontrado no ServerStorage, tentando Workspace...")
				modelo = Workspace:FindFirstChild("Workbench", true) 
					or Workspace:FindFirstChild("Bancada", true)
					or Workspace:FindFirstChild("WorkbenchModel", true)
					or Workspace:FindFirstChild("WorkBench4Script", true)
			end
		end
		
		if modelo then
			print("   📦 Template encontrado: " .. modelo.Name .. " em " .. modelo.Parent.Name)
			local novo = modelo:Clone()
			novo.Name = "Workbench_" .. player.Name .. "_" .. tostring(math.floor(tick()))
			
			-- Raycast para encontrar o chão na posição recebida
			local rayResult = Workspace:Raycast(
				Vector3.new(posicao.X, posicao.Y + 50, posicao.Z),
				Vector3.new(0, -100, 0)
			)
			
			local alturaChao = rayResult and rayResult.Position.Y or posicao.Y
			
			-- Calcular offset do modelo (centro até base)
			local centroOriginal = modelo:GetPivot().Position.Y
			local baseOriginal = math.huge
			for _, parte in pairs(modelo:GetDescendants()) do
				if parte:IsA("BasePart") then
					local baseParte = parte.Position.Y - (parte.Size.Y / 2)
					if baseParte < baseOriginal then
						baseOriginal = baseParte
					end
				end
			end
			local offsetY = centroOriginal - baseOriginal
			
			-- Posicionar: chão + offset (para base ficar no chão)
			local posicaoFinal = Vector3.new(posicao.X, alturaChao + offsetY, posicao.Z)
			novo:PivotTo(CFrame.new(posicaoFinal))
			novo.Parent = Workspace
			
			print("   📍 Posição recebida: " .. tostring(posicao))
			print("   📍 Altura do chão: " .. alturaChao)
			print("   📐 Offset do modelo: " .. offsetY)
			print("   📍 Posição final: " .. tostring(posicaoFinal))
			
			-- Configurar
			for _, parte in pairs(novo:GetDescendants()) do
				if parte:IsA("BasePart") then
					parte.Anchored = true
					parte.CanCollide = true
					parte.Transparency = 0
					parte.CastShadow = true
				end
			end
			
			novo:SetAttribute("Tipo", "Workbench")
			novo:SetAttribute("Dono", player.Name)
			
			print("✅ " .. player.Name .. " construiu Workbench em " .. tostring(posicao))
		else
			print("⚠️ Modelo Workbench não encontrado!")
			devolverRecursos(player, itemNome)
		end
		
		construcoesPendentes[player.UserId] = nil
		
	elseif acao == "Cancelar" then
		-- Devolver recursos
		if construcoesPendentes[player.UserId] then
			local itemNome = construcoesPendentes[player.UserId].item
			devolverRecursos(player, itemNome)
			print("↩️ " .. player.Name .. " cancelou - recursos devolvidos")
		end
		construcoesPendentes[player.UserId] = nil
	end
end)

-- Limpar ao sair
Players.PlayerRemoving:Connect(function(player)
	if construcoesPendentes[player.UserId] then
		local item = construcoesPendentes[player.UserId].item
		devolverRecursos(player, item)
		construcoesPendentes[player.UserId] = nil
	end
end)

print("✅ Server de Construção inicializado!")
print("   📋 Workbench: 10 Gravetos + 5 Pedras")
print("   🎮 Adicione à hotbar → Equipe → Posicione → E para fixar")
