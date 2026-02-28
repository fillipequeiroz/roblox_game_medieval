-- Server_ColetaStick.lua
-- Gerencia coleta de itens e respawn no servidor

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Criar eventos
local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "EventosJogo"
	eventos.Parent = ReplicatedStorage
end

local coletarItemEvento = eventos:FindFirstChild("ColetarItemProximidade")
if not coletarItemEvento then
	coletarItemEvento = Instance.new("RemoteEvent")
	coletarItemEvento.Name = "ColetarItemProximidade"
	coletarItemEvento.Parent = eventos
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

-- Configuração de respawn
local TEMPO_RESPAWN = 5 -- segundos

-- Inicializar jogador
local function inicializarJogador(player)
	-- Só inicializa se não existir (para não sobrescrever dados de outros sistemas)
	if not dadosJogadores[player.UserId] then
		dadosJogadores[player.UserId] = {
			inventario = {
				gravetos = 0,
				madeira = 0,
				pedra = 0
			}
		}
	else
		-- Garante que o campo 'gravetos' exista
		dadosJogadores[player.UserId].inventario.gravetos = dadosJogadores[player.UserId].inventario.gravetos or 0
	end
end

-- Função para respawnar item
local function respawnarItem(template, posicao)
	task.wait(TEMPO_RESPAWN)
	
	if not template then 
		print("⚠️ Template não existe mais")
		return 
	end
	
	-- Verificar se já existe um item na mesma posição
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name:find(template.Name) then
			local dist = (obj:GetPivot().Position - posicao).Magnitude
			if dist < 2 then
				print("⚠️ Já existe item nesta posição, não respawnando")
				return
			end
		end
	end
	
	local novoItem = template:Clone()
	novoItem.Name = template.Name .. "_Respawn"
	novoItem:SetAttribute("TipoRecurso", template:GetAttribute("TipoRecurso"))
	
	novoItem:PivotTo(CFrame.new(posicao))
	novoItem.Parent = workspace
	
	print("🔄 Item respawnado: " .. template.Name .. " em " .. tostring(posicao))
end

-- Processar coleta
local function processarColeta(player, item)
	if not player or not item or not item.Parent then return end
	
	local dados = dadosJogadores[player.UserId]
	if not dados then return end
	
	-- Verificar distância
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local distancia = (humanoidRootPart.Position - item:GetPivot().Position).Magnitude
	if distancia > 10 then
		print("⚠️ Muito longe!")
		return
	end
	
	-- Guardar dados antes de destruir
	local tipoRecurso = item:GetAttribute("TipoRecurso")
	local posicao = item:GetPivot().Position
	local template = item:Clone()
	
	-- Destruir item
	item:Destroy()
	
	-- Processar baseado no tipo
	if tipoRecurso == "Stick" or tipoRecurso == "Pau" then
		dados.inventario.gravetos = dados.inventario.gravetos + 1
		atualizarInventario:FireClient(player, dados.inventario)
		print("🌿 " .. player.Name .. " coletou 1 Pau (Total: " .. dados.inventario.gravetos .. ")")
		
		-- Respawn
		task.spawn(function()
			respawnarItem(template, posicao)
		end)
		
	elseif tipoRecurso == "Pedra" or tipoRecurso == "Stone" then
		dados.inventario.pedra = dados.inventario.pedra + 1
		atualizarInventario:FireClient(player, dados.inventario)
		print("🪨 " .. player.Name .. " coletou 1 Pedra (Total: " .. dados.inventario.pedra .. ")")
		
		-- Respawn
		task.spawn(function()
			respawnarItem(template, posicao)
		end)
	end
end

-- Conectar eventos
coletarItemEvento.OnServerEvent:Connect(processarColeta)
Players.PlayerAdded:Connect(inicializarJogador)
Players.PlayerRemoving:Connect(function(player)
	dadosJogadores[player.UserId] = nil
end)

-- Inicializar jogadores já presentes
for _, player in pairs(Players:GetPlayers()) do
	inicializarJogador(player)
end

print("✅ Server de Coleta com Respawn (" .. TEMPO_RESPAWN .. "s) inicializado!")
