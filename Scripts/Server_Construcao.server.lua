--[[
    SERVER - CONSTRUÇÃO
    Coloque este script em ServerScriptService (junto com o Gerenciador de Recursos)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Eventos
local eventos = ReplicatedStorage:WaitForChild("EventosJogo")
local construirEvento = eventos:WaitForChild("ConstruirEstrutura")

-- Referência ao Gerenciador de Recursos (deve estar no mesmo ServerScriptService)
-- Vamos acessar os dados do jogador através do _G ou criar uma tabela compartilhada

-- Custo das estruturas
local CUSTOS = {
	["ParedePedra"] = { pedra = 3, madeira = 0, tamanho = Vector3.new(4, 6, 1) },
	["ChaoMadeira"] = { pedra = 0, madeira = 3, tamanho = Vector3.new(4, 1, 4) },
	["Torre"] = { pedra = 10, madeira = 5, tamanho = Vector3.new(4, 10, 4) },
	["Portao"] = { pedra = 5, madeira = 8, tamanho = Vector3.new(6, 5, 1) }
}

-- Dados dos jogadores (deve ser a mesma tabela do Gerenciador de Recursos)
local dadosJogadores = {}

-- Configurar dados (será sobrescrito quando o outro script rodar)
_G.DadosJogadores = _G.DadosJogadores or {}
dadosJogadores = _G.DadosJogadores

-- Função para verificar se jogador tem recursos suficientes
local function temRecursosSuficientes(player, tipoEstrutura)
	local dados = dadosJogadores[player.UserId]
	if not dados then return false end
	
	local custo = CUSTOS[tipoEstrutura]
	if not custo then return false end
	
	return dados.inventario.pedra >= custo.pedra and 
	       dados.inventario.madeira >= custo.madeira
end

-- Função para gastar recursos
local function gastarRecursos(player, tipoEstrutura)
	local dados = dadosJogadores[player.UserId]
	if not dados then return false end
	
	local custo = CUSTOS[tipoEstrutura]
	if not custo then return false end
	
	dados.inventario.pedra = dados.inventario.pedra - custo.pedra
	dados.inventario.madeira = dados.inventario.madeira - custo.madeira
	
	-- Atualizar GUI
	local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")
	if atualizarInventario then
		atualizarInventario:FireClient(player, dados.inventario)
	end
	
	return true
end

-- Função para criar estrutura
local function criarEstrutura(tipo, posicao, dono)
	local custo = CUSTOS[tipo]
	if not custo then return nil end
	
	local part = Instance.new("Part")
	part.Name = tipo .. "_" .. dono.Name
	part.Size = custo.tamanho
	part.Position = posicao
	part.Anchored = true
	
	-- Configurar aparência baseada no tipo
	if tipo == "ParedePedra" then
		part.Color = Color3.fromRGB(100, 100, 100)
		part.Material = Enum.Material.Slate
	elseif tipo == "ChaoMadeira" then
		part.Color = Color3.fromRGB(139, 90, 43)
		part.Material = Enum.Material.Wood
	elseif tipo == "Torre" then
		part.Color = Color3.fromRGB(80, 80, 80)
		part.Material = Enum.Material.Concrete
	elseif tipo == "Portao" then
		part.Color = Color3.fromRGB(101, 67, 33)
		part.Material = Enum.Material.Wood
	end
	
	-- Adicionar atributos
	part:SetAttribute("Dono", dono.UserId)
	part:SetAttribute("TipoEstrutura", tipo)
	
	-- Criar modelo wrapper
	local modelo = Instance.new("Model")
	modelo.Name = tipo
	part.Parent = modelo
	modelo.Parent = workspace
	
	return modelo
end

-- Processar pedido de construção
construirEvento.OnServerEvent:Connect(function(player, tipoEstrutura, posicao)
	-- Verificações básicas
	if not player or not player.Character then return end
	if not CUSTOS[tipoEstrutura] then return end
	
	-- Verificar distância (anti-exploit)
	local charPos = player.Character:GetPivot().Position
	local distancia = (posicao - charPos).Magnitude
	if distancia > 50 then
		print("⚠️ " .. player.Name .. " tentou construir muito longe!")
		return
	end
	
	-- Verificar recursos
	if not temRecursosSuficientes(player, tipoEstrutura) then
		print("❌ " .. player.Name .. " não tem recursos suficientes para " .. tipoEstrutura)
		return
	end
	
	-- Gastar recursos
	if gastarRecursos(player, tipoEstrutura) then
		-- Criar estrutura
		local estrutura = criarEstrutura(tipoEstrutura, posicao, player)
		if estrutura then
			print("✅ " .. player.Name .. " construiu: " .. tipoEstrutura)
		end
	end
end)

print("✅ Servidor de Construção inicializado!")
