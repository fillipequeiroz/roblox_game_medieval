--[[
    SERVER - GERENCIADOR DE RECURSOS
    Coloque este script em ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Criar pasta de eventos remotos se não existir
local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "EventosJogo"
	eventos.Parent = ReplicatedStorage
end

-- Criar RemoteEvent para coleta
local coletarEvento = eventos:FindFirstChild("ColetarRecurso")
if not coletarEvento then
	coletarEvento = Instance.new("RemoteEvent")
	coletarEvento.Name = "ColetarRecurso"
	coletarEvento.Parent = eventos
end

-- Criar RemoteEvent para atualizar inventário
local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")
if not atualizarInventario then
	atualizarInventario = Instance.new("RemoteEvent")
	atualizarInventario.Name = "AtualizarInventario"
	atualizarInventario.Parent = eventos
end

-- Dados dos jogadores (inventário)
local dadosJogadores = {}

-- Configurações de recursos
local CONFIG_RECURSOS = {
	["Madeira"] = {
		tipoFerramenta = "Machado",
		quantidadePorHit = 1,
		vidaMaxima = 3,
		respawnTime = 30
	},
	["Pedra"] = {
		tipoFerramenta = "Picareta",
		quantidadePorHit = 1,
		vidaMaxima = 5,
		respawnTime = 45
	}
}

-- Função para inicializar jogador
local function inicializarJogador(player)
	dadosJogadores[player.UserId] = {
		inventario = {
			madeira = 0,
			pedra = 0,
			paus = 0
		},
		ferramentaEquipada = nil
	}
	
	print("✅ Jogador inicializado: " .. player.Name)
end

-- Função para processar coleta
local function processarColeta(player, recursoModelo, ferramentaUsada)
	if not recursoModelo or not recursoModelo.Parent then return end
	if not dadosJogadores[player.UserId] then return end
	
	local tipoRecurso = recursoModelo:GetAttribute("TipoRecurso")
	if not tipoRecurso then return end
	
	-- Verificar se a ferramenta correta foi usada
	local config = CONFIG_RECURSOS[tipoRecurso]
	if not config then return end
	
	if config.tipoFerramenta ~= ferramentaUsada then
		print("❌ Ferramenta incorreta! Use: " .. config.tipoFerramenta)
		return
	end
	
	-- Processar coleta
	local vidaAtual = recursoModelo:GetAttribute("Vida") or config.vidaMaxima
	vidaAtual = vidaAtual - 1
	recursoModelo:SetAttribute("Vida", vidaAtual)
	
	-- Adicionar ao inventário
	local dados = dadosJogadores[player.UserId]
	if tipoRecurso == "Madeira" then
		dados.inventario.madeira = dados.inventario.madeira + config.quantidadePorHit
		print("🪵 +" .. config.quantidadePorHit .. " Madeira para " .. player.Name)
	elseif tipoRecurso == "Pedra" then
		dados.inventario.pedra = dados.inventario.pedra + config.quantidadePorHit
		print("🪨 +" .. config.quantidadePorHit .. " Pedra para " .. player.Name)
	end
	
	-- Atualizar GUI do jogador
	atualizarInventario:FireClient(player, dados.inventario)
	
	-- Se recurso foi destruído
	if vidaAtual <= 0 then
		destruirRecurso(recursoModelo, config)
	end
end

-- Função para destruir recurso e fazer respawn
function destruirRecurso(modelo, config)
	local posicao = modelo:GetPivot().Position
	local tipo = modelo:GetAttribute("TipoRecurso")
	local template = modelo:Clone()
	
	-- Destruir modelo atual
	modelo:Destroy()
	
	-- Respawn após tempo
	task.delay(config.respawnTime, function()
		if template then
			local novoModelo = template:Clone()
			novoModelo:SetAttribute("Vida", config.vidaMaxima)
			novoModelo:PivotTo(CFrame.new(posicao))
			novoModelo.Parent = workspace
			print("🔄 Recurso respawned: " .. tipo)
		end
	end)
end

-- Conectar evento de coleta
coletarEvento.OnServerEvent:Connect(processarColeta)

-- Conectar jogadores
Players.PlayerAdded:Connect(inicializarJogador)
Players.PlayerRemoving:Connect(function(player)
	dadosJogadores[player.UserId] = nil
end)

-- Inicializar jogadores já presentes
for _, player in pairs(Players:GetPlayers()) do
	inicializarJogador(player)
end

print("✅ Gerenciador de Recursos inicializado!")
