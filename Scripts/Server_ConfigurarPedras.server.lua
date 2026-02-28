-- Server_ConfigurarPedras.server.lua
-- Configura pedras no mapa para serem coletáveis

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

-- Função para configurar uma pedra
local function configurarPedra(pedra)
	-- Definir atributo para identificação
	pedra:SetAttribute("TipoRecurso", "Pedra")
	print("✅ Pedra configurada: " .. pedra.Name)
end

-- Procurar e configurar smallRockStone (template não precisa ser configurado)
-- As pedras spawnadas já são configuradas pelo Server_SpawnRecursos
local pedra = ServerStorage:FindFirstChild("smallRockStone") or Workspace:FindFirstChild("smallRockStone")
if pedra then
	print("✅ Template de pedra encontrado em: " .. pedra.Parent.Name)
else
	print("⚠️ Pedra 'smallRockStone' não encontrada no ServerStorage nem Workspace")
end

print("✅ Sistema de configuração de pedras carregado!")
