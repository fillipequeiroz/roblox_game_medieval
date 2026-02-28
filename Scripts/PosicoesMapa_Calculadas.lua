-- PosicoesMapa_Calculadas.lua
-- Posições predefinidas para o mapa medieval
-- Cole este arquivo como um ModuleScript no ReplicatedStorage

return {
	-- ==================== FLORESTA NORTE (Densidade Alta) ====================
	arvoresNorte = {
		-- Árvores tipo 1 (5 golpes, 1 madeira)
		{tipo = "Tree1", posicao = Vector3.new(-150, 0.8, -280), rotacao = 0},
		{tipo = "Tree1", posicao = Vector3.new(-120, 0.8, -250), rotacao = 45},
		{tipo = "Tree1", posicao = Vector3.new(-180, 0.8, -260), rotacao = 90},
		{tipo = "Tree1", posicao = Vector3.new(-90, 0.8, -290), rotacao = 135},
		{tipo = "Tree1", posicao = Vector3.new(-200, 0.8, -240), rotacao = 180},
		
		-- Árvores tipo 2 (5 golpes, 1 madeira)
		{tipo = "Tree2", posicao = Vector3.new(-130, 0.8, -220), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(-170, 0.8, -230), rotacao = 60},
		{tipo = "Tree2", posicao = Vector3.new(-100, 0.8, -240), rotacao = 120},
		
		-- Árvores tipo 3 (10 golpes, 3 madeiras) - Mais raras
		{tipo = "Tree3", posicao = Vector3.new(-160, 0.8, -200), rotacao = 0},
		{tipo = "Tree3", posicao = Vector3.new(-110, 0.8, -210), rotacao = 90},
		
		-- Árvores tipo 4 (10 golpes, 3 madeiras)
		{tipo = "Tree4", posicao = Vector3.new(-190, 0.8, -220), rotacao = 0},
		
		-- Árvores tipo 5 (8 golpes, 2 madeiras)
		{tipo = "Tree5", posicao = Vector3.new(-140, 0.8, -190), rotacao = 0},
		{tipo = "Tree5", posicao = Vector3.new(-80, 0.8, -200), rotacao = 45},
		
		-- Centro-Norte
		{tipo = "Tree1", posicao = Vector3.new(0, 0.8, -280), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(30, 0.8, -260), rotacao = 30},
		{tipo = "Tree5", posicao = Vector3.new(-30, 0.8, -270), rotacao = 60},
		{tipo = "Tree3", posicao = Vector3.new(60, 0.8, -290), rotacao = 0},
		{tipo = "Tree1", posicao = Vector3.new(-60, 0.8, -250), rotacao = 90},
		
		-- Leste-Norte
		{tipo = "Tree2", posicao = Vector3.new(150, 0.8, -280), rotacao = 0},
		{tipo = "Tree1", posicao = Vector3.new(180, 0.8, -260), rotacao = 45},
		{tipo = "Tree4", posicao = Vector3.new(120, 0.8, -270), rotacao = 0},
		{tipo = "Tree5", posicao = Vector3.new(200, 0.8, -240), rotacao = 90},
		{tipo = "Tree2", posicao = Vector3.new(90, 0.8, -250), rotacao = 180},
		
		-- Oeste-Norte
		{tipo = "Tree1", posicao = Vector3.new(-250, 0.8, -280), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(-280, 0.8, -260), rotacao = 45},
		{tipo = "Tree5", posicao = Vector3.new(-220, 0.8, -270), rotacao = 90},
		
		-- Mais árvores densas
		{tipo = "Tree1", posicao = Vector3.new(-50, 0.8, -230), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(20, 0.8, -240), rotacao = 30},
		{tipo = "Tree1", posicao = Vector3.new(100, 0.8, -230), rotacao = 60},
		{tipo = "Tree5", posicao = Vector3.new(-120, 0.8, -180), rotacao = 0},
		{tipo = "Tree3", posicao = Vector3.new(50, 0.8, -210), rotacao = 90},
		
		-- Agrupamento denso
		{tipo = "Tree1", posicao = Vector3.new(-40, 0.8, -170), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(-10, 0.8, -180), rotacao = 45},
		{tipo = "Tree1", posicao = Vector3.new(20, 0.8, -170), rotacao = 90},
		{tipo = "Tree2", posicao = Vector3.new(-25, 0.8, -150), rotacao = 0},
	},
	
	-- ==================== PLANÍCIE CENTRAL (Densidade Média) ====================
	arvoresCentro = {
		{tipo = "Tree1", posicao = Vector3.new(-200, 0.8, -50), rotacao = 0},
		{tipo = "Tree5", posicao = Vector3.new(-150, 0.8, -30), rotacao = 45},
		{tipo = "Tree2", posicao = Vector3.new(-100, 0.8, -60), rotacao = 90},
		{tipo = "Tree4", posicao = Vector3.new(-50, 0.8, -40), rotacao = 0},
		
		{tipo = "Tree3", posicao = Vector3.new(0, 0.8, -50), rotacao = 0},
		{tipo = "Tree1", posicao = Vector3.new(50, 0.8, -30), rotacao = 60},
		{tipo = "Tree2", posicao = Vector3.new(100, 0.8, -60), rotacao = 120},
		{tipo = "Tree5", posicao = Vector3.new(150, 0.8, -40), rotacao = 180},
		
		{tipo = "Tree1", posicao = Vector3.new(-180, 0.8, 20), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(-80, 0.8, 40), rotacao = 45},
		{tipo = "Tree4", posicao = Vector3.new(80, 0.8, 20), rotacao = 90},
		{tipo = "Tree1", posicao = Vector3.new(180, 0.8, 30), rotacao = 0},
	},
	
	-- ==================== CAMPO SUL (Densidade Baixa) ====================
	arvoresSul = {
		{tipo = "Tree1", posicao = Vector3.new(-100, 0.8, 150), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(0, 0.8, 180), rotacao = 90},
		{tipo = "Tree5", posicao = Vector3.new(100, 0.8, 160), rotacao = 45},
		{tipo = "Tree1", posicao = Vector3.new(-150, 0.8, 200), rotacao = 180},
		{tipo = "Tree3", posicao = Vector3.new(150, 0.8, 190), rotacao = 0},
		{tipo = "Tree2", posicao = Vector3.new(50, 0.8, 220), rotacao = 60},
		{tipo = "Tree4", posicao = Vector3.new(-50, 0.8, 240), rotacao = 120},
		{tipo = "Tree1", posicao = Vector3.new(200, 0.8, 250), rotacao = 0},
		{tipo = "Tree5", posicao = Vector3.new(-200, 0.8, 220), rotacao = 45},
		{tipo = "Tree1", posicao = Vector3.new(0, 0.8, 260), rotacao = 90},
	},
	
	-- ==================== GALHOS ESPALHADOS ====================
	galhos = {
		-- Floresta Norte (mais galhos)
		{posicao = Vector3.new(-140, 0.5, -265), rotacao = 0},
		{posicao = Vector3.new(-100, 0.5, -225), rotacao = 45},
		{posicao = Vector3.new(-180, 0.5, -215), rotacao = 90},
		{posicao = Vector3.new(-60, 0.5, -245), rotacao = 135},
		{posicao = Vector3.new(10, 0.5, -255), rotacao = 0},
		{posicao = Vector3.new(50, 0.5, -235), rotacao = 60},
		{posicao = Vector3.new(-220, 0.5, -250), rotacao = 120},
		{posicao = Vector3.new(120, 0.5, -225), rotacao = 180},
		{posicao = Vector3.new(-30, 0.5, -205), rotacao = 0},
		{posicao = Vector3.new(80, 0.5, -215), rotacao = 45},
		{posicao = Vector3.new(-110, 0.5, -195), rotacao = 90},
		{posicao = Vector3.new(30, 0.5, -185), rotacao = 0},
		{posicao = Vector3.new(-70, 0.5, -175), rotacao = 60},
		{posicao = Vector3.new(140, 0.5, -205), rotacao = 120},
		{posicao = Vector3.new(-250, 0.5, -230), rotacao = 0},
		
		-- Planície Central (médio)
		{posicao = Vector3.new(-120, 0.5, -45), rotacao = 0},
		{posicao = Vector3.new(-40, 0.5, -25), rotacao = 45},
		{posicao = Vector3.new(60, 0.5, -55), rotacao = 90},
		{posicao = Vector3.new(120, 0.5, -35), rotacao = 0},
		{posicao = Vector3.new(-160, 0.5, 25), rotacao = 60},
		{posicao = Vector3.new(40, 0.5, 45), rotacao = 120},
		{posicao = Vector3.new(160, 0.5, 5), rotacao = 0},
		{posicao = Vector3.new(-20, 0.5, -75), rotacao = 45},
		{posicao = Vector3.new(90, 0.5, 35), rotacao = 90},
		{posicao = Vector3.new(-200, 0.5, -15), rotacao = 0},
		
		-- Campo Sul (poucos)
		{posicao = Vector3.new(-80, 0.5, 170), rotacao = 0},
		{posicao = Vector3.new(20, 0.5, 200), rotacao = 45},
		{posicao = Vector3.new(120, 0.5, 180), rotacao = 90},
		{posicao = Vector3.new(-180, 0.5, 210), rotacao = 0},
		{posicao = Vector3.new(80, 0.5, 230), rotacao = 60},
	},
	
	-- ==================== PEDRAS ESPALHADAS ====================
	pedras = {
		-- Floresta Norte (poucas)
		{posicao = Vector3.new(-170, 0.5, -275), escala = 1.0, rotacao = 0},
		{posicao = Vector3.new(-50, 0.5, -265), escala = 1.2, rotacao = 45},
		{posicao = Vector3.new(70, 0.5, -285), escala = 0.8, rotacao = 90},
		{posicao = Vector3.new(180, 0.5, -255), escala = 1.1, rotacao = 0},
		{posicao = Vector3.new(-230, 0.5, -235), escala = 0.9, rotacao = 60},
		{posicao = Vector3.new(-20, 0.5, -245), escala = 1.0, rotacao = 120},
		{posicao = Vector3.new(110, 0.5, -225), escala = 1.3, rotacao = 0},
		{posicao = Vector3.new(-280, 0.5, -275), escala = 0.8, rotacao = 45},
		
		-- Planície Central (mais pedras)
		{posicao = Vector3.new(-180, 0.5, -40), escala = 1.0, rotacao = 0},
		{posicao = Vector3.new(-90, 0.5, -20), escala = 1.1, rotacao = 45},
		{posicao = Vector3.new(0, 0.5, -50), escala = 0.9, rotacao = 90},
		{posicao = Vector3.new(90, 0.5, -30), escala = 1.2, rotacao = 0},
		{posicao = Vector3.new(180, 0.5, -60), escala = 1.0, rotacao = 60},
		{posicao = Vector3.new(-120, 0.5, 50), escala = 0.8, rotacao = 120},
		{posicao = Vector3.new(30, 0.5, 60), escala = 1.1, rotacao = 0},
		{posicao = Vector3.new(150, 0.5, 40), escala = 0.9, rotacao = 45},
		{posicao = Vector3.new(-60, 0.5, 0), escala = 1.0, rotacao = 90},
		{posicao = Vector3.new(60, 0.5, 10), escala = 1.2, rotacao = 0},
		{posicao = Vector3.new(-240, 0.5, 10), escala = 0.8, rotacao = 60},
		{posicao = Vector3.new(240, 0.5, -10), escala = 1.0, rotacao = 0},
		
		-- Campo Sul (poucas)
		{posicao = Vector3.new(-120, 0.5, 190), escala = 1.0, rotacao = 0},
		{posicao = Vector3.new(0, 0.5, 220), escala = 0.9, rotacao = 45},
		{posicao = Vector3.new(130, 0.5, 210), escala = 1.1, rotacao = 90},
		{posicao = Vector3.new(-200, 0.5, 240), escala = 0.8, rotacao = 0},
		{posicao = Vector3.new(200, 0.5, 230), escala = 1.2, rotacao = 60},
	},
}
