-- Server_ConfiguracaoTestes.server.lua
-- Configurações especiais para testes do jogo

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIGURAÇÕES DE TESTE
local CONFIG_TESTES = {
	-- Jogador inicia com machado?
	INICIAR_COM_MACHADO = true,
	
	-- Jogador inicia com recursos?
	PAUS_INICIAIS = 0,
	MADEIRA_INICIAL = 0,
	PEDRA_INICIAL = 0,
}

-- Dados compartilhados
_G.DadosJogadores = _G.DadosJogadores or {}

-- Função para criar machado de teste (mesma lógica do Server_Crafting)
local function criarMachadoTeste()
	local modeloOriginal = Workspace:FindFirstChild("Axe") 
		or Workspace:FindFirstChild("Machado")
		or Workspace:FindFirstChild("AxeModel")
	
	if not modeloOriginal then
		print("⚠️ Modelo Axe não encontrado para teste!")
		return nil
	end
	
	local tool = Instance.new("Tool")
	tool.Name = "Machado"
	tool.ToolTip = "Usado para cortar madeira"
	
	-- Clonar o modelo
	local machado = modeloOriginal:Clone()
	machado.Name = "MachadoModel"
	
	-- Escala de redução (50% do tamanho original)
	local escala = 0.5
	
	-- Coletar todas as partes base
	local partes = {}
	for _, parte in pairs(machado:GetDescendants()) do
		if parte:IsA("BasePart") then
			table.insert(partes, parte)
		end
	end
	
	-- Pegar a posição original do modelo para calcular offsets
	local modeloCFrame = machado:GetPivot()
	
	-- Redimensionar e reposicionar todas as partes
	for _, parte in pairs(partes) do
		-- Redimensionar
		parte.Size = parte.Size * escala
		parte.Anchored = false
		parte.CanCollide = false
		
		-- Calcular posição relativa ao centro do modelo
		local offset = parte.Position - modeloCFrame.Position
		-- Aplicar escala no offset também
		local novoOffset = offset * escala
		-- Nova posição é o centro escalado + offset escalado
		parte.Position = (modeloCFrame.Position * escala) + novoOffset
	end
	
	-- Encontrar a parte que será o Handle (cabo do machado)
	local handlePart = nil
	local maiorComprimentoY = 0
	
	for _, parte in pairs(partes) do
		if parte.Size.Y > maiorComprimentoY then
			maiorComprimentoY = parte.Size.Y
			handlePart = parte
		end
	end
	
	-- Se não achou pelo Y, pega a mais comprida em geral
	if not handlePart then
		local maiorComprimento = 0
		for _, parte in pairs(partes) do
			local comp = math.max(parte.Size.X, parte.Size.Y, parte.Size.Z)
			if comp > maiorComprimento then
				maiorComprimento = comp
				handlePart = parte
			end
		end
	end
	
	-- Se ainda não achou, usa a primeira
	if not handlePart and #partes > 0 then
		handlePart = partes[1]
	end
	
	-- Montar a Tool
	if handlePart then
		-- Guardar CFrame do handle antes de mover
		local handleCF = handlePart.CFrame
		
		-- Mover handle para a tool
		handlePart.Name = "Handle"
		handlePart.Parent = tool
		
		-- Mover as outras partes e criar welds
		for _, parte in pairs(partes) do
			if parte ~= handlePart then
				parte.Parent = tool
				
				-- Criar weld com offset relativo ao handle
				local weld = Instance.new("Weld")
				weld.Part0 = handlePart
				weld.Part1 = parte
				-- Calcular offset: posição da parte em relação ao handle
				weld.C0 = handleCF:Inverse() * parte.CFrame
				weld.Parent = parte
			end
		end
		
		-- Resetar posição do handle para origem (0,0,0) relativo à tool
		-- Sem rotação extra
		handlePart.CFrame = CFrame.new(0, 0, 0)
	end
	
	-- Destruir o modelo vazio
	machado:Destroy()
	
	-- Adicionar script de ataque
	local scriptTemplate = ReplicatedStorage:FindFirstChild("MachadoAtaqueTemplate")
	if scriptTemplate then
		local scriptAtaque = scriptTemplate:Clone()
		scriptAtaque.Name = "MachadoAtaque"
		scriptAtaque.Parent = tool
	end
	
	return tool
end

-- Inicializar jogador com configurações de teste
local function inicializarJogadorTeste(player)
	-- Aguardar character carregar
	local character = player.Character or player.CharacterAdded:Wait()
	local backpack = player:WaitForChild("Backpack")
	
	print("🎮 Configurando jogador " .. player.Name .. " para testes...")
	
	-- Dar machado se configurado
	if CONFIG_TESTES.INICIAR_COM_MACHADO then
		task.wait(1) -- Aguardar tudo carregar
		local machado = criarMachadoTeste()
		if machado then
			machado.Parent = backpack
			print("🪓 Machado de teste dado para " .. player.Name)
			
			-- Equipar automaticamente
			task.wait(0.5)
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:EquipTool(machado)
				print("🪓 Machado equipado automaticamente")
			end
		end
	end
	
	-- Configurar recursos iniciais
	local dados = _G.DadosJogadores[player.UserId]
	if dados then
		dados.inventario.paus = CONFIG_TESTES.PAUS_INICIAIS
		dados.inventario.madeira = CONFIG_TESTES.MADEIRA_INICIAL
		dados.inventario.pedra = CONFIG_TESTES.PEDRA_INICIAL
		
		-- Atualizar GUI
		local eventos = ReplicatedStorage:FindFirstChild("EventosJogo")
		if eventos then
			local atualizarInventario = eventos:FindFirstChild("AtualizarInventario")
			if atualizarInventario then
				atualizarInventario:FireClient(player, dados.inventario)
			end
		end
		
		print("📦 Recursos iniciais configurados para " .. player.Name)
	end
end

-- Conectar aos jogadores
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		inicializarJogadorTeste(player)
	end)
	
	-- Se já tiver character
	if player.Character then
		inicializarJogadorTeste(player)
	end
end)

-- Jogadores já presentes
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(function()
		inicializarJogadorTeste(player)
	end)
end

print("✅ Configurações de teste carregadas!")
print("   🪓 Iniciar com machado: " .. tostring(CONFIG_TESTES.INICIAR_COM_MACHADO))
