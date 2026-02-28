-- MachadoAtaque.client.lua
-- Sistema de ataque do machado - APENAS animação do personagem, não mexe no machado

local tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configurações
local TEMPO_ATAQUE = 0.6
local PODE_ATACAR = true

-- Animação de ataque (sword slash padrão)
local animacaoAtaque = Instance.new("Animation")
animacaoAtaque.AnimationId = "rbxassetid://522635514"  -- Tool slash

local trackAtaque = nil

-- Quando equipar o machado
tool.Equipped:Connect(function()
	character = player.Character
	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			trackAtaque = humanoid:LoadAnimation(animacaoAtaque)
		end
	end
end)

-- Quando desequipar
tool.Unequipped:Connect(function()
	if trackAtaque and trackAtaque.IsPlaying then
		trackAtaque:Stop()
	end
end)

-- Quando clicar para atacar
tool.Activated:Connect(function()
	if not PODE_ATACAR then return end
	if not trackAtaque then 
		print("⚠️ Animação não carregada")
		return 
	end
	
	PODE_ATACAR = false
	
	-- Tocar animação de ataque (o personagem ataca, o machado acompanha a mão)
	trackAtaque:Play()
	
	print("🪓 Ataque!")
	
	-- Aguardar cooldown
	task.wait(TEMPO_ATAQUE)
	
	PODE_ATACAR = true
end)

print("✅ Machado pronto - Clique para atacar!")
