# Modelos Importados - Nomenclatura Exata

> Todos os modelos estão em: `ServerStorage`
> 
> ⚠️ IMPORTANTE: Usar os nomes EXATOS abaixo nos scripts!

---

## 🚪 PORTÕES

| Nome Exato | Uso |
|------------|-----|
| `Door` | Portão básico |
| `Gate` | Portão maior/avançado |

---

## 🪚 CARPINTARIAS

| Nome Exato | Uso | Tier |
|------------|-----|------|
| `Table Saw` | Carpintaria Básica | 1 |
| `Advanced Table Saw` | Carpintaria Avançada | 2 |

---

## 🔥 FORJAS

| Nome Exato | Uso | Tier |
|------------|-----|------|
| `Forja` | Forja Primitiva | 1 |
| `Forja_Avancada` | Forja Avançada | 2 |
| `Furnace` | Fornalha (decoração ou processamento) |

---

## ⛏️ MINÉRIOS E COMBUSTÍVEL

| Nome Exato | Uso |
|------------|-----|
| `Iron Ore` | Minério de Ferro (coleta na mina) |
| `Iron bar` | Lingote de Ferro processado |
| `Coal` | Carvão (combustível) |
| `Mine` | Entrada da Mina (estrutura no mapa) |

---

## 🏭 PROCESSAMENTO DE PEDRA

| Nome Exato | Uso |
|------------|-----|
| `Stone cutter` | Pedreira / Cortador de Pedra |
| `Stone block` | Bloco de Pedra processado (item) |

---

## 🧶 TECELAGEM

| Nome Exato | Uso |
|------------|-----|
| `Tecelagem` | Estação de Tecelagem |
| `rope` | Corda/Rolo de corda (item) |

---

## 🪵 MATERIAIS PROCESSADOS

| Nome Exato | Uso |
|------------|-----|
| `Tabua madeira` | Tábua de madeira processada |

---

## 🌿 RECURSOS NATURAIS

| Nome Exato | Uso |
|------------|-----|
| `TallGrass` | Fibra/Planta para coleta |

---

## 🏰 MUROS

| Nome Exato | Uso | Material |
|------------|-----|----------|
| `wood wall` | Muro de Madeira Básico | Madeira |
| `Wooden Defence Wall` | Muro de Madeira Reforçado | Madeira |
| `Stone Wall` | Muro de Pedra | Pedra |

---

## 🕸️ ARMADILHAS

| Nome Exato | Uso | Dano |
|------------|-----|------|
| `Armadilha madeira` | Espinhos de Madeira | Baixo |
| `Armadilha ferro` | Espinhos de Ferro | Alto |

---

## 🧟 ZUMBIS

| Nome Exato | Tipo | Força |
|------------|------|-------|
| `Zumbi Basico` | Zumbi Básico | Fraco |
| `Zumbi Medio` | Zumbi Médio | Médio |
| `Zumbi Avancado` | Zumbi Avançado | Forte |

---

## 📝 NOTAS PARA PROGRAMAÇÃO

### Nomes com acentuação:
- `Forja_Avancada` (sem ç, com _)
- `Armadilha madeira` (sem acento em "madeira")
- `Armadilha ferro`
- `Tabua madeira` (sem acento em "madeira")
- `Zumbi Basico` (sem acento em "basico")
- `Zumbi Medio` (sem acento em "medio")
- `Zumbi Avancado` (sem acento em "avancado")

### Nomes em inglês:
- `Table Saw` (com espaço)
- `Advanced Table Saw` (com espaço)
- `Stone Wall` (com espaço)
- `Iron Ore` (com espaço)
- `TallGrass` (camelCase)
- `Wooden Defence Wall` (com espaço e "Defence" com C)

### Nomes simples:
- `Door`
- `Gate`
- `Coal`
- `Furnace`
- `rope` (minúsculo)
- `Stone block` (com espaço, "block" minúsculo)
- `Stone cutter` (com espaço)
- `wood wall` (tudo minúsculo, com espaço)
- `Tecelagem`

---

## 🎯 MAPEAMENTO PARA SISTEMA

### Estruturas de Processamento:
```lua
Carpintaria_Basica = "Table Saw"
Carpintaria_Avancada = "Advanced Table Saw"
Pedreira = "Stone cutter"
Forja_Primitiva = "Forja"
Forja_Avancada = "Forja_Avancada"
Tecelagem = "Tecelagem"
```

### Recursos:
```lua
Tora = "Tronco" (não listado, usar existente)
Madeira_Processada = "Tabua madeira"
Pedra_Bruta = "smallRockStone" (existente)
Bloco_Pedra = "Stone block"
Minério_Ferro = "Iron Ore"
Ferro_Processado = "Iron bar"
Fibra = "TallGrass"
Cordas = "rope"
Carvao = "Coal"
Entrada_Mina = "Mine"
```

### Defesas:
```lua
Muro_Madeira_Basico = "wood wall"
Muro_Madeira_Reforcado = "Wooden Defence Wall"
Muro_Pedra = "Stone Wall"
Portao = "Door" ou "Gate"
Armadilha_Madeira = "Armadilha madeira"
Armadilha_Ferro = "Armadilha ferro"
```

### Zumbis:
```lua
Zumbi_Basico = "Zumbi Basico"
Zumbi_Medio = "Zumbi Medio"
Zumbi_Avancado = "Zumbi Avancado"
```

---

## ❓ FALTANDO (para implementar depois)

- [ ] **Torres** (não listado)
  - Torre de madeira
  - Torre de flechas
  - Torre de balista

- [ ] **Aço** (lingote)
  - Criar modelo ou reutilizar ferro com cor diferente

- [ ] **Poças/Alcatrão** (armadilha)
  - Usar partes transparentes pretas

- [ ] **Mina Terrestre**
  - Barril ou caixa com pólvora

---

*Atualizado em: 28/02/2026*
