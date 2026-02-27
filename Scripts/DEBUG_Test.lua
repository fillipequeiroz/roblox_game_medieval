-- Script de teste para diagnosticar problemas
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("========================================")
print("🧪 TESTE DE DIAGNOSTICO")
print("========================================")
print("Player: " .. tostring(player and player.Name or "NULO"))
print("PlayerGui: " .. tostring(player and player:FindFirstChild("PlayerGui") and "OK" or "NULO"))

if player then
	local playerGui = player:WaitForChild("PlayerGui", 5)
	if playerGui then
		print("PlayerGui encontrado!")
		
		-- Verificar se as GUIs existem
		local coleta = playerGui:FindFirstChild("ColetaGUI")
		local inventario = playerGui:FindFirstChild("InventarioGUI")
		
		print("ColetaGUI: " .. tostring(coleta and "EXISTE" or "NÃO EXISTE"))
		print("InventarioGUI: " .. tostring(inventario and "EXISTE" or "NÃO EXISTE"))
		
		if coleta then
			print("  - ColetaProximidade: " .. tostring(coleta:FindFirstChild("ColetaProximidade") and "OK" or "FALTA"))
		end
		
		if inventario then
			print("  - GUIInventario: " .. tostring(inventario:FindFirstChild("GUIInventario") and "OK" or "FALTA"))
		end
	else
		print("❌ PlayerGui não encontrado após 5 segundos!")
	end
else
	print("❌ Player é NULO!")
end

print("========================================")
