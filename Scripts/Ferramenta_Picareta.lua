--[[
    FERRAMENTA: PICARETA
    Coloque este script DENTRO do objeto Tool "Picareta" em StarterPack
]]

local tool = script.Parent
local player = nil
local mouse = nil

-- Configurações
local ATAQUE_ALCANCE = 8
local TEMPO_ENTRE_ATAQUES = 0.5
local DANO_PEDRA = 1

local podeAtacar = true

-- Evento quando a ferramenta é equipada
tool.Equipped:Connect(function(mouseConnection)
	player = game.Players.LocalPlayer
	mouse = mouseConnection
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
		
		-- Verificar se é uma pedra/recurso de pedra
		if modelo then
			local tipoRecurso = modelo:GetAttribute("TipoRecurso")
			
			if tipoRecurso == "Pedra" or tipoRecurso == "Stone" then
				-- Enviar evento para o servidor coletar
				local eventoColetar = game.ReplicatedStorage:FindFirstChild("ColetarRecurso")
				if eventoColetar then
					eventoColetar:FireServer(modelo, "Picareta")
				end
				
				-- Efeito visual
				print("⛏️ Picareta atingiu: " .. modelo.Name)
			end
		end
	end
	
	-- Cooldown
	wait(TEMPO_ENTRE_ATAQUES)
	podeAtacar = true
end)
