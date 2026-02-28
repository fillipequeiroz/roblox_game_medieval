-- Server_ConfigurarPedras.server.lua
-- Configura pedras no mapa para serem coletáveis

local Workspace = game:GetService("Workspace")

-- Função para configurar uma pedra
local function configurarPedra(pedra)
	-- Definir atributo para identificação
	pedra:SetAttribute("TipoRecurso", "Pedra")
	print("✅ Pedra configurada: " .. pedra.Name)
end

-- Procurar e configurar smallRockStone
local pedra = Workspace:FindFirstChild("smallRockStone")
if pedra then
	configurarPedra(pedra)
else
	print("⚠️ Pedra 'smallRockStone' não encontrada")
end

print("✅ Sistema de configuração de pedras carregado!")
