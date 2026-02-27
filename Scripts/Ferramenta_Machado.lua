--[[
    FERRAMENTA: MACHADO
    Coloque este script DENTRO do objeto Tool "Machado" em StarterPack
]]

local tool = script.Parent
local player = nil
local mouse = nil

-- Configurações
local ATAQUE_ALCANCE = 8
local TEMPO_ENTRE_ATAQUES = 0.5
local DANO_MADEIRA = 1

local podeAtacar = true

-- Animações
local animIdle = nil
local animAtaque = nil

-- Evento quando a ferramenta é equipada
tool.Equipped:Connect(function(mouseConnection)
	player = game.Players.LocalPlayer
	mouse = mouseConnection
	
	-- Carregar animações (opcional - você pode criar suas próprias)
	local char = player.Character
	local humanoid = char:WaitForChild("Humanoid")
end)

-- Evento quando a ferramenta é desequipada
tool.Unequipped:Connect(function()
	mouse = nil
end)

-- Função de ataque
tool.Activated:Connect(function()
	if not podeAtacar or not mouse then return end
	
	podeAtacar = false
	
	-- Raycast para detectar o que foi atingido
	local camera = workspace.CurrentCamera
	local rayOrigin = camera.CFrame.Position
	local rayDirection = (mouse.Hit.Position - rayOrigin).Unit * ATAQUE_ALCANCE
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local resultado = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	if resultado then
		local objetoAtingido = resultado.Instance
		local modelo = objetoAtingido:FindFirstAncestorOfClass("Model")
		
		-- Verificar se é uma árvore/recurso de madeira
		if modelo then
			local tipoRecurso = modelo:GetAttribute("TipoRecurso")
			
			if tipoRecurso == "Madeira" or tipoRecurso == "Arvore" then
				-- Enviar evento para o servidor coletar
				local eventoColetar = game.ReplicatedStorage:FindFirstChild("ColetarRecurso")
				if eventoColetar then
					eventoColetar:FireServer(modelo, "Machado")
				end
				
				-- Efeito visual
				print("🪓 Machado atingiu: " .. modelo.Name)
			end
		end
	end
	
	-- Cooldown
	wait(TEMPO_ENTRE_ATAQUES)
	podeAtacar = true
end)
