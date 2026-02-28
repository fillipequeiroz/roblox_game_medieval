# Planejamento - Medieval War (Defesa Contra Zumbis)

> Documento de planejamento do sistema de recursos, processamento e construção
> Atualizado em: 27/02/2026

---

## 🎮 CONCEITO GERAL

Jogador coleta recursos brutos no mapa, processa em estruturas especializadas e constrói defesas para sobreviver a hordas de zumbis que atacam à noite.

---

## 📋 RESPOSTAS DAS DECISÕES

1. **Recursos Iniciais:** Jogador começa **ZERADO** (sem nada)
2. **Minério de Ferro:** Localizado dentro de uma **mina distante** no mapa
3. **Dano de Zumbis:** Sim, zumbis dão dano e **destroem estruturas** (jogador precisa reconstruir)
4. **Limite de Construção:** Definido pela **área do terreno** (zona delimitada), pode repetir estruturas
5. **Carpintarias:** Jogador pode construir **quantas quiser** (otimização é responsabilidade do jogador)

---

## 🌲 FLUXO DE RECURSOS

### Recursos BRUTOS (Coleta no Mapa)

| Recurso | Fonte | Uso Direto | Precisa Processar |
|---------|-------|------------|-------------------|
| **Gravetos** | Chão, arbustos | Crafting básico | ❌ Não |
| **Tora** | Árvores grandes | Construção simples | ✅ Sim → Madeira |
| **Pedra Bruta** | Rochas | Fundação | ✅ Sim → Blocos de Pedra |
| **Minério de Ferro** | Mina (distante) | - | ✅ Sim → Ferro |
| **Fibra** | Plantas | Cordas | ✅ Sim → Tecido |
| **Carvão** | Mina / Florestas queimadas | Combustível | ❌ Não |

### Materiais PROCESSADOS

| Material | Processado em | Recursos Necessários | Tempo |
|----------|---------------|---------------------|-------|
| **Madeira** | Carpintaria | 1 Tora | 2s |
| **Bloco de Pedra** | Pedreira | 2 Pedras Brutas | 3s |
| **Tábuas** | Carpintaria (upgrade) | 2 Madeiras | 4s |
| **Ferro** | Forja | 1 Minério + 2 Madeiras | 5s |
| **Aço** | Forja Avançada | 2 Ferros + 1 Carvão | 8s |
| **Cordas** | Estação de Tecelagem | 3 Fibras | 2s |
| **Pólvora** | Alquimia | Enxofre + Carvão | 10s |

---

## 🏗️ ESTRUTURAS DE PROCESSAMENTO

### Tier 1 - Básico

#### 1. Carpintaria Básica
```
Custo para construir:
- 8 Toras
- 4 Gravetos

Processa:
- Tora → Madeira (1:1)
- Madeira → Tábuas (2:1) [requer upgrade]

Desbloqueia:
- Muralhas de Madeira
- Torres de Madeira
- Pontes
- Arcos Simples
```

#### 2. Pedreira Manual
```
Custo para construir:
- 10 Pedras Brutas
- 4 Madeiras

Processa:
- Pedra Bruta → Bloco de Pedra (2:1)

Desbloqueia:
- Muralhas de Pedra
- Fundações de Pedra
- Torres de Pedra
```

---

### Tier 2 - Intermediário

#### 3. Carpintaria Avançada (Upgrade)
```
Custo para upgrade:
- 6 Madeiras
- 4 Tábuas
- 2 Cordas

Novos processamentos:
- Madeira → Tábuas (2:1)
- Tábuas → Vigas Reforçadas (2:1)

Desbloqueia:
- Muralhas Reforçadas
- Portões de Madeira
- Torres de Flechas de Madeira
- Arcos Reforçados
```

#### 4. Forja Primitiva
```
Custo para construir:
- 15 Blocos de Pedra
- 8 Madeiras
- 6 Toras

Processa:
- Minério de Ferro + Madeiras → Ferro (1:1:1)

Desbloqueia:
- Armas de Ferro
- Armaduras Básicas
- Torres com Pontas de Ferro
- Espinhos de Ferro
```

---

### Tier 3 - Avançado

#### 5. Forja Avançada (Upgrade)
```
Custo para upgrade:
- 20 Ferros
- 10 Blocos de Pedra
- 8 Tábuas

Novos processamentos:
- Ferro → Aço (2:1 + Carvão)

Desbloqueia:
- Armas de Aço
- Torres de Balistas
- Armaduras Pesadas
- Portões de Ferro/Aço
```

#### 6. Estação de Cerco
```
Custo para construir:
- 30 Blocos de Pedra
- 15 Madeiras
- 10 Cordas
- 5 Ferros

Desbloqueia:
- Catapultas
- Torres de Cerco
- Armadilhas Avançadas
- Mina Terrestre
```

#### 7. Alquimia (Futuro)
```
Custo para construir:
- 20 Blocos de Pedra
- 10 Tábuas
- 5 Ferros
- 5 Vidros (novo recurso)

Processa:
- Recursos → Poções
- Carvão + Enxofre → Pólvora

Desbloqueia:
- Poções de Cura
- Poções de Força
- Explosivos
```

---

## 🏰 ESTRUTURAS DE DEFESA

### Muralhas

| Tipo | Custo | Vida | Dano Zumbi | Reparação | Desbloqueado |
|------|-------|------|------------|-----------|--------------|
| Muralha de Madeira | 3 Madeiras | 150 | - | 1 Madeira | Carpintaria Básica |
| Muralha de Pedra | 4 Blocos | 300 | - | 2 Blocos | Pedreira |
| Muralha Reforçada | 2 Tábuas + 2 Blocos | 500 | - | 1 Tábua + 1 Bloco | Carpintaria Avançada |
| Muralha c/ Espinhos | + 3 Ferros | 400 | 10/s | 2 Ferros | Forja Primitiva |
| Muralha de Ferro | 6 Ferros | 800 | - | 3 Ferros | Forja Avançada |

### Portões

| Tipo | Custo | Vida | Abertura | Desbloqueado |
|------|-------|------|----------|--------------|
| Portão Madeira | 8 Madeiras | 200 | Manual | Carpintaria Básica |
| Portão Reforçado | 6 Tábuas | 400 | Manual | Carpintaria Avançada |
| Portão de Ferro | 10 Ferros + 4 Blocos | 800 | Alavanca | Forja Primitiva |
| Portão de Aço | 6 Aço + 6 Blocos | 1500 | Automática | Forja Avançada |

### Torres

| Tipo | Custo | Dano | Alcance | Velocidade | Desbloqueado |
|------|-------|------|---------|------------|--------------|
| Torre de Madeira | 10 Madeiras | - | - | - | Carpintaria Básica |
| Torre de Flechas | + 4 Madeiras + 2 Cordas | 15 | 30 studs | 1.5s | Carpintaria Básica |
| Torre Flechas Reforçada | + 6 Tábuas + 4 Cordas | 25 | 40 studs | 1.2s | Carpintaria Avançada |
| Torre de Balista | + 8 Ferros + 4 Cordas | 60 | 60 studs | 3.0s | Forja Primitiva |
| Torre de Cerco | + 15 Ferros + 10 Pedras | 100 (área) | 50 studs | 5.0s | Estação de Cerco |

### Armadilhas

| Tipo | Custo | Efeito | Duração |
|------|-------|--------|---------|
| Fossa | Solo (grátis) | Lentidão 50% | Permanente |
| Espinhos Madeira | 4 Gravetos + 2 Madeiras | 20 dano | 10 ataques |
| Espinhos Ferro | 6 Ferros | 40 dano + sangramento | 20 ataques |
| Alcatrão | 8 Madeiras (queimadas) | Lentidão 80% | 30s |
| Mina Terrestre | 5 Ferros + 3 Pólvora | 150 dano (área) | 1 uso |

---

## ⚔️ ARMAS E EQUIPAMENTOS

### Ferramentas de Coleta

| Item | Custo | Eficiência | Desbloqueado |
|------|-------|------------|--------------|
| Machado de Pedra | 3 Pedras + 2 Gravetos | 100% | Início |
| Machado de Ferro | 4 Ferros + 2 Madeiras | 200% | Forja Primitiva |
| Machado de Aço | 3 Aço + 2 Madeiras | 300% | Forja Avançada |
| Picareta de Pedra | 3 Pedras + 2 Gravetos | 100% | Início |
| Picareta de Ferro | 4 Ferros + 2 Madeiras | 200% | Forja Primitiva |

### Armas de Combate

| Item | Custo | Dano | Velocidade | Desbloqueado |
|------|-------|------|------------|--------------|
| Espada de Madeira | 4 Madeiras | 20 | 1.0s | Carpintaria Básica |
| Espada de Ferro | 6 Ferros + 2 Madeiras | 45 | 0.8s | Forja Primitiva |
| Espada de Aço | 4 Aço + 2 Madeiras | 80 | 0.7s | Forja Avançada |
| Arco Simples | 3 Madeiras + 2 Cordas | 15 | 1.0s | Carpintaria Básica |
| Arco Reforçado | 4 Tábuas + 3 Cordas | 30 | 0.8s | Carpintaria Avançada |
| Besta | 6 Ferros + 4 Madeiras + 2 Cordas | 50 | 1.5s | Forja Primitiva |
| Balista Portátil | 10 Ferros + 6 Cordas | 100 | 3.0s | Forja Avançada |

---

## 📈 PROGRESSÃO SUGERIDA

### FASE 1 - Sobrevivência (0-10 min)
- Coleta: Gravetos, Toras, Pedras
- Craft: Machado/Picareta de Pedra
- Constrói: Carpintaria Básica + Pedreira
- Primeira muralha de madeira

### FASE 2 - Fortificação (10-20 min)
- Processa: Madeiras e Blocos de Pedra
- Expande muralhas
- Constrói Torres de Flechas
- Prepara para primeira noite de ataque

### FASE 3 - Exploração (20-30 min)
- Explora mina distante
- Coleta Minério de Ferro
- Constrói Forja Primitiva
- Craft armas de ferro

### FASE 4 - Guerra (30+ min)
- Processa Aço
- Constrói balistas
- Cria armadilhas avançadas
- Sobrevive a hordas grandes

---

## 🎯 INTERFACE DA SEGUNDA BANCADA (CARPINTARIA)

```
┌─────────────────────────────────────┐
│      🪚 CARPINTARIA               │
├─────────────────────────────────────┤
│  [ Processar ]  [ Construir ]      │
├─────────────────────────────────────┤
│                                     │
│  PROCESSAMENTO:                    │
│  ┌─────┐  ┌─────┐  ┌─────┐        │
│  │Tora │→ │Madei│→ │Tábua│        │
│  │ 1x  │  │ra 1x│  │  1x │        │
│  └─────┘  └─────┘  └─────┘        │
│                                     │
│  [Upgrade para Avançada] - Requer: │
│  6 Madeiras, 4 Tábuas, 2 Cordas    │
│                                     │
├─────────────────────────────────────┤
│  CONSTRUÇÕES DESBLOQUEADAS:         │
│                                     │
│  Muralha de Madeira    [3 Madeira] │
│  Torre de Madeira      [10 Madeira]│
│  Portão de Madeira     [8 Madeira] │
│  Arco Simples          [3M+2Corda] │
│                                     │
│  [Craft] → Adiciona à hotbar       │
└─────────────────────────────────────┘
```

---

## 🔧 SISTEMA DE DANO E REPARO

### Dano de Zumbis em Estruturas
- Zumbis básicos: 5 dano/ataque
- Zumbis fortes: 15 dano/ataque
- Zumbis gigantes: 40 dano/ataque

### Reparo
- Jogador gasta 50% dos materiais originais
- Reparo restaura 50% da vida máxima
- Estrutura destruída dropa 30% dos materiais

### Destruição Completa
- Estrutura some do mapa
- Dropa fragmentos no chão
- Jogador precisa reconstruir do zero

---

## 🗺️ ÁREA DE CONSTRUÇÃO

- Limite definido por terreno (marcação visual no chão)
- Fora da área: não permite construir
- Dentro da área: construção livre, sem limite de quantidade
- Jogador pode construir quantas carpintarias quiser dentro da área

---

## 📝 NOTAS PARA IMPLEMENTAÇÃO

1. Sistema de "Processamento" precisa de timer/barra de progresso
2. Torres de defesa precisam de IA para detectar e atacar zumbis
3. Portões precisam de sistema de abrir/fechar (colisão on/off)
4. Zumbis precisam priorizar atacar estruturas vs jogador
5. Sistema de ondas: contador de tempo + spawn de zumbis
6. Mina distante: ponto fixo no mapa com minérios respawnáveis

---

*Documento criado para planejamento - sujeito a alterações durante desenvolvimento*
