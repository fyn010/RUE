# 🎮 RUE - Recarga Urbana Exploit

<div align="center">

![RUE Banner](https://img.shields.io/badge/RUE-Recarga%20Urbana%20Exploit-blue?style=for-the-badge&logo=roblox)
![Version](https://img.shields.io/badge/Version-1.0.0-green?style=for-the-badge)
![Executor](https://img.shields.io/badge/Executor-Solara-purple?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)

**Um exploit avançado para Recarga Urbana, desenvolvido especificamente para o executor Solara.**

[🚀 Funcionalidades](#-funcionalidades) • [📋 Requisitos](#-requisitos) • [⚙️ Instalação](#️-instalação) • [🎮 Uso](#-uso) • [⚙️ Configuração](#️-configuração) • [⚠️ Avisos](#️-avisos-importantes)

</div>

---

## 📋 Sobre

O **RUE (Recarga Urbana Exploit)** é um script completo de exploit para o jogo **Recarga Urbana** (Place ID: `84448037861644`), desenvolvido exclusivamente para o executor **Solara**. Oferece uma ampla gama de funcionalidades de combate, movimento, visualização, utilidades de jogador e exploits de remotes.

### ✨ Destaques

- 🛡️ **Anti-Cheat Bypass Avançado** - Proteção completa contra AntiTunnel e detecções
- 🎯 **Silent Aim & Aimbot** - Com FOV personalizável, verificação de time/visibilidade
- 📦 **Hitbox Expander** - Expansão inteligente de hitboxes com visualização
- 🔫 **Gun Mods Completos** - No Recoil, No Spread, Rapid Fire, Infinite Ammo
- ✈️ **Movimento Livre** - Fly, Speed, Noclip, Infinite Stamina
- 👁️ **ESP & Tracers** - Caixas, nomes, vida, distância, barras de vida
- 📍 **Teleport & Auto Farm** - Teleporte seguro, farm de cash/XP/kills/itens
- 🎨 **GUI Moderna** - Interface intuitiva com tema personalizável

---

## 🚀 Funcionalidades

### ⚔️ Combate
| Funcionalidade | Descrição |
|---|---|
| **Silent Aim** | Redireciona tiros silenciosamente para o alvo mais próximo no FOV |
| **Aimbot** | Trava a câmera no alvo com suavização configurável |
| **Hitbox Expander** | Expande hitboxes (1x - 10x) com indicador visual |
| **No Recoil** | Remove completamente o recuo das armas |
| **No Spread** | Elimina o spread/bloom dos tiros |
| **Rapid Fire** | Aumenta a taxa de tiro (3x padrão) |
| **Infinite Ammo** | Munição infinita sem recarregar |
| **Instant Reload** | Recarga instantânea (0.01s) |
| **Auto Reload** | Recarrega automaticamente quando vazio |

### 🏃 Movimento
| Funcionalidade | Descrição |
|---|---|
| **Fly** | Voo livre com WASD + Space/Shift, velocidade ajustável |
| **Speed** | WalkSpeed personalizado (1-200) com hook anti-detecção |
| **Noclip** | Atravessa paredes/objetos desativando colisões |
| **Infinite Stamina** | Stamina infinita (hook no ClientState) |

### 👁️ Visuais
| Funcionalidade | Descrição |
|---|---|
| **Player ESP** | Caixas, nomes, vida, distância, barras de vida coloridas por time |
| **Tracers** | Linhas da tela aos jogadores (origem: Bottom/Mouse/Center) |
| **FOV Circle** | Círculo visual do FOV do Silent Aim/Aimbot |
| **Crosshair** | Crosshair personalizável (tamanho, gap, espessura) |

### 👤 Jogador
| Funcionalidade | Descrição |
|---|---|
| **Teleport** | Para jogadores, coordenadas, waypoints, veículos, atrás do alvo |
| **Safe Teleport** | Teleporte com tween suave para evitar detecção |
| **Waypoints** | Salvar/carregar/deletar posições personalizadas |
| **Auto Farm** | Cash, XP, Kills, Items automatizados |
| **God Mode** | Vida infinita, munição infinita, sem dano de queda, anti-ragdoll |

### 🔧 Exploits
| Funcionalidade | Descrição |
|---|---|
| **Remote Logger** | Loga todas as chamadas de RemoteEvent/RemoteFunction |
| **Remote Fire** | Dispara remotes específicos com argumentos personalizados |
| **Admin Commands** | Kill All, Max Cash/XP, Get All Weapons |

---

## 📋 Requisitos

| Requisito | Versão Mínima |
|---|---|
| **Executor** | Solara (última versão) |
| **Roblox** | Cliente atualizado |
| **Jogo** | Recarga Urbana (Place ID: 84448037861644) |

> ⚠️ **Importante**: Este exploit foi desenvolvido **exclusivamente** para o executor **Solara**. Não funcionará corretamente em outros executores (Krnl, Script-Ware, Fluxus, etc.) devido ao uso de APIs específicas do Solara (`solara.protect_function`, `solara.protect_gui`).

---

## ⚙️ Instalação

### Método 1: Loadstring Direto (Recomendado)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fyn010/RUE/main/Main.lua"))()
```

### Método 2: Arquivo Local
1. Baixe o arquivo `Main.lua` deste repositório
2. Cole o conteúdo no seu executor Solara
3. Execute

### Método 3: GitHub (Para Desenvolvedores)
```bash
git clone https://github.com/fyn010/RUE.git
cd RUE
# Execute o Main.lua no Solara
```

---

## 🎮 Uso

### Atalhos Padrão
| Tecla | Ação |
|---|---|
| **RightShift** | Abrir/Fechar GUI |
| **F** | Toggle Fly |
| **V** | Toggle Speed |
| **N** | Toggle Noclip |
| **G** | Toggle Infinite Stamina |

### Primeiros Passos
1. **Entre no jogo** Recarga Urbana
2. **Execute o script** via loadstring no Solara
3. **Pressione RightShift** para abrir a GUI
4. **Navegue pelas abas** e ative as funcionalidades desejadas
5. **Configure** FOV, velocidade, multiplicadores conforme preferência

### Abas da GUI
```
┌─────────────────────────────────────┐
│  Combat  │ Movement │ Visuals │ ... │
├─────────────────────────────────────┤
│  Silent Aim, Aimbot, Hitbox, Guns  │
├─────────────────────────────────────┤
│  Fly, Speed, Noclip, Stamina       │
├─────────────────────────────────────┤
│  ESP, Tracers, FOV, Crosshair      │
├─────────────────────────────────────┤
│  Teleport, Auto Farm, God Mode     │
├─────────────────────────────────────┤
│  Remote Logger, Remote Fire, Admin │
├─────────────────────────────────────┤
│  UI, Config, Anti-Cheat, Debug     │
└─────────────────────────────────────┘
```

---

## ⚙️ Configuração

### Arquivo de Configuração
As configurações são salvas automaticamente em `RUE_Config.json` no workspace do executor.

### Configurações Principais
```lua
-- FOV do Silent Aim/Aimbot (0-500)
State.fovRadius = 120

-- Multiplicador de Hitbox (1-10)
State.hitboxMultiplier = 2

-- Velocidade do Fly (1-500)
State.flySpeed = 50

-- WalkSpeed (1-200)
State.walkSpeed = 16

-- Parte alvo (Head, Torso, HumanoidRootPart, etc.)
State.silentAimTargetPart = "Head"

-- Suavização do Aimbot (0-1)
State.aimbotSmoothness = 0.1

-- Verificações
State.teamCheck = true      -- Não mirar em aliados
State.visibleCheck = true   -- Só alvos visíveis
State.distanceCheck = true  -- Limite de distância
State.maxDistance = 1000    -- Distância máxima
```

### Exportar/Importar Config
- **Settings → Export Config to Clipboard** - Copia config JSON para clipboard
- **Settings → Import Config** - Cola JSON do clipboard (implementar manualmente)

---

## ⚠️ Avisos Importantes

### 🛡️ Anti-Cheat
- O jogo possui **AntiTunnel** e detecção server-side de hits
- O bypass usa `solara.protect_function` para ocultar hooks
- `setthreadidentity(2)` é usado antes de `require()` em módulos do jogo
- **Use por sua conta e risco** - banimentos são possíveis

### 🎯 Detecção de Silent Aim/Aimbot
- Hitmarkers só aparecem após confirmação do servidor (0.35s delay)
- O servidor valida tiros via `ClientState.ConfirmHit`
- Recomenda-se usar **Visible Check** e **Team Check**

### 📝 Boas Práticas
1. **Não abuse** - Use configurações realistas
2. **Teste em conta alternativa** primeiro
3. **Mantenha o executor atualizado**
4. **Não use em servidores com moderadores ativos**
5. **Desative features** quando não estiver usando

### 🔒 Proteção de Hooks
Todos os hooks usam `solara.protect_function(hook, true)` que:
- Oculta o hook do stack trace
- Impede detecção via `debug.info`/`debug.getstack`
- Funciona como `setstackhidden` do Potassium

---

## 📁 Estrutura do Projeto

```
RUE/
├── Main.lua                    # Entry point
├── Core/
│   ├── Services.lua            # Referências de serviços
│   ├── Constants.lua           # Constantes do jogo
│   ├── State.lua               # Estado compartilhado
│   └── Utilities.lua           # Helpers (solara.protect_function, getClosestPlayer, etc.)
├── Features/
│   ├── Combat/
│   │   ├── SilentAim.lua
│   │   ├── Aimbot.lua
│   │   ├── HitboxExpander.lua
│   │   └── GunMods.lua
│   ├── Movement/
│   │   ├── Fly.lua
│   │   ├── Speed.lua
│   │   ├── Noclip.lua
│   │   └── InfiniteStamina.lua
│   ├── Visuals/
│   │   ├── ESP.lua
│   │   └── Tracers.lua
│   ├── Player/
│   │   ├── Teleport.lua
│   │   └── AutoFarm.lua
│   └── Exploits/
│       └── Remotes.lua
├── GUI/
│   ├── Library.lua             # Biblioteca UI customizada
│   ├── Window.lua              # Janela principal
│   └── Tabs/
│       ├── CombatTab.lua
│       ├── MovementTab.lua
│       ├── VisualsTab.lua
│       ├── PlayerTab.lua
│       ├── ExploitsTab.lua
│       └── SettingsTab.lua
├── AntiCheat/
│   ├── Bypass.lua              # Bypass AntiTunnel
│   ├── HookProtection.lua      # Proteção de hooks
│   └── EnvironmentSpoof.lua    # Spoofing de ambiente
└── Utility/
    ├── Maid.lua                # Gerenciamento de limpeza
    ├── Signal.lua              # Sistema de sinais
    ├── Logger.lua              # Sistema de logs
    ├── Profiler.lua            # Profiling de performance
    └── Data2Code.lua           # Serializador (GitHub)
```

---

## 🔧 APIs Solara Utilizadas

| API | Uso |
|---|---|
| `solara.protect_function` | Oculta hooks de detecção |
| `solara.protect_gui` | Protege GUI de detecção |
| `hookmetamethod` | Hook de `__namecall`, `__index`, `__newindex` |
| `hookfunction` | Hook de funções Luau |
| `debug.getupvalue/setupvalue` | Manipulação de upvalues |
| `getgc` | Garbage collection scanning |
| `getrawmetatable/setrawmetatable` | Metatable manipulation |
| `setthreadidentity` | Identity spoofing para require |
| `cloneref` | Referências seguras de serviços |
| `Drawing.new` | Renderização 2D (ESP, FOV, etc.) |
| `getconnections` | Inspeção de sinais |
| `fireproximityprompt` | Auto-interação |
| `isnetworkowner` | Verificação de ownership |

---

## 📝 Changelog

### v1.0.0 (2026-11-01)
- ✨ Lançamento inicial
- 🛡️ AntiTunnel bypass completo
- 🎯 Silent Aim + Aimbot com FOV
- 📦 Hitbox Expander (1-10x)
- 🔫 Gun Mods (No Recoil, No Spread, Rapid Fire, Infinite Ammo, Instant/Auto Reload)
- ✈️ Fly, Speed, Noclip, Infinite Stamina
- 👁️ ESP completo + Tracers
- 📍 Teleport + Waypoints + Auto Farm
- 🔧 Remote Logger + Remote Fire + Admin Commands
- 🎨 GUI moderna com 6 abas
- ⚙️ Sistema de config (save/load/export)
- 📊 Profiler integrado

---

## 🤝 Créditos

- **Desenvolvedor**: [fyn010](https://github.com/fyn010)
- **Executor**: [Solara](https://solara.executor/)
- **Data2Code**: [Awakenchan/GcViewerV2](https://github.com/Awakenchan/GcViewerV2)
- **Inspiração**: Lycoris Rewrite (Blastbrean)

---

## 📄 Licença

Este projeto é fornecido **apenas para fins educacionais e de pesquisa**. O uso em jogos online viola os Termos de Serviço do Roblox e pode resultar em banimento permanente da conta.

```
MIT License - Uso educacional apenas
```

---

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/fyn010/RUE/issues)
- **Discord**: Não disponível
- **Wiki**: Em desenvolvimento

---

<div align="center">

**⭐ Deixe uma estrela se este projeto te ajudou!**

**Desenvolvido com ❤️ para a comunidade Solara**

</div>