# QuantomLib — Documentação

## 📦 Carregar no Script

```lua
local QuantomLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dimess1/ui/refs/heads/main/library.lua'))()
```

---

## 🎨 Criar Janela Principal

```lua
local Window = QuantomLib:CreateWindow({
    Name       = "MEU HUB",
    Version    = "v1.0.0",
    MinimizeKey = Enum.KeyCode.RightShift -- opcional
})
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do hub exibido no header |
| `Version` | string | Versão exibida no header |
| `MinimizeKey` | Enum.KeyCode | Tecla padrão para minimizar/abrir (padrão: `RightShift`) |

> A tab **⚙ Config** é criada automaticamente no final da sidebar e permite ao utilizador alterar a keybind de minimizar em runtime.

---

## 📑 Criar Tabs/Categorias

```lua
local Tab = Window:CreateTab({
    Name = "Principal",
    Icon = "🏠"
})
```

**Parâmetros:**
- `Name` (string) — Nome da tab
- `Icon` (string) — Ícone emoji

**Exemplo com múltiplas tabs:**
```lua
local MainTab   = Window:CreateTab({Name = "Main",    Icon = "🏠"})
local CombatTab = Window:CreateTab({Name = "Combat",  Icon = "⚔️"})
local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "👁"})
local MiscTab   = Window:CreateTab({Name = "Misc",    Icon = "🔧"})
```

---

## 🔧 Elementos da UI

### 1️⃣ AddSection (Separador)

```lua
Tab:AddSection("CONFIGURAÇÕES GERAIS")
```

**Parâmetros:**
- `title` (string) — Texto do separador em maiúsculas

---

### 2️⃣ AddToggle (Botão On/Off)

```lua
Tab:AddToggle({
    Name    = "Auto Farm",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
    end
})
```

**Parâmetros:**
- `Name` (string) — Nome do toggle
- `Default` (boolean) — Valor inicial
- `Callback` (function) — Chamada ao mudar estado, recebe `value` (boolean)

**Métodos:**
```lua
local MyToggle = Tab:AddToggle({...})
MyToggle:SetValue(true)
```

---

### 3️⃣ AddToggleKeybind (Toggle + Tecla de Atalho) 🆕

Elemento combinado numa única linha: toggle à esquerda e keybind à direita. Clicar no toggle **ou** pressionar a tecla atribuída dispara o mesmo callback com o novo estado.

```lua
Tab:AddToggleKeybind({
    Name    = "Aimbot",
    Default = false,
    Key     = Enum.KeyCode.X,
    Callback = function(state)
        _G.AimbotEnabled = state
        print("Aimbot:", state)
    end,
    KeyChanged = function(newKey)        -- opcional
        print("Nova tecla:", newKey.Name)
    end
})
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do elemento |
| `Default` | boolean | Estado inicial do toggle |
| `Key` | Enum.KeyCode | Tecla de atalho padrão |
| `Callback` | function | Chamada ao mudar estado (toggle ou tecla), recebe `state` (boolean) |
| `KeyChanged` | function | Chamada quando a tecla é alterada pelo utilizador, recebe `newKey` |

**Métodos:**
```lua
local MyTK = Tab:AddToggleKeybind({...})
MyTK:SetToggle(true)
MyTK:SetKey(Enum.KeyCode.F)
MyTK:GetState()  -- retorna boolean
MyTK:GetKey()    -- retorna Enum.KeyCode
```

> **Teclas bloqueadas:** W, A, S, D, Space, LeftShift e LeftControl não podem ser atribuídas como keybind.

---

### 4️⃣ AddButton (Botão)

```lua
Tab:AddButton({
    Name = "Teleport Spawn",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
})
```

**Parâmetros:**
- `Name` (string) — Nome do botão
- `Callback` (function) — Chamada ao clicar

---

### 5️⃣ AddSlider (Controle Deslizante)

```lua
Tab:AddSlider({
    Name    = "WalkSpeed",
    Min     = 16,
    Max     = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

**Parâmetros:**
- `Name` (string) — Nome do slider
- `Min` (number) — Valor mínimo
- `Max` (number) — Valor máximo
- `Default` (number) — Valor inicial
- `Callback` (function) — Chamada ao mudar, recebe `value` (number)

**Métodos:**
```lua
local MySlider = Tab:AddSlider({...})
MySlider:SetValue(100)
```

---

### 6️⃣ AddTextbox (Campo de Texto)

```lua
Tab:AddTextbox({
    Name        = "Player Name",
    Default     = "",
    Placeholder = "Digite o nome...",
    Callback = function(value)
        print("Texto:", value)
    end
})
```

**Parâmetros:**
- `Name` (string) — Nome do textbox
- `Default` (string) — Texto inicial
- `Placeholder` (string) — Texto exibido quando vazio
- `Callback` (function) — Chamada ao pressionar Enter, recebe `value` (string)

**Métodos:**
```lua
local MyTextbox = Tab:AddTextbox({...})
MyTextbox:SetValue("NovoTexto")
```

---

### 7️⃣ AddDropdown (Menu Suspenso — Seleção Simples)

```lua
Tab:AddDropdown({
    Name    = "Weapon",
    Options = {"Sword", "Gun", "Knife", "Bomb"},
    Default = "Sword",
    Callback = function(value)
        _G.SelectedWeapon = value
        print("Arma:", value)
    end
})
```

**Parâmetros:**
- `Name` (string) — Nome do dropdown
- `Options` (table) — Lista de opções
- `Default` (string) — Opção inicial
- `Callback` (function) — Chamada ao selecionar, recebe `value` (string)

**Métodos:**
```lua
local MyDropdown = Tab:AddDropdown({...})
MyDropdown:SetValue("Gun")
```

---

### 8️⃣ AddMultiDropdown (Menu Suspenso — Seleção Múltipla) 🆕

Igual ao dropdown normal mas permite selecionar **várias opções simultaneamente**. Cada item mostra `✓` quando ativo.

```lua
Tab:AddMultiDropdown({
    Name        = "Gamemodes",
    Options     = {"Sword", "Gun", "Knife", "Bomb"},
    Default     = {"Sword", "Gun"},     -- pré-selecionados (opcional)
    Placeholder = "Selecionar...",      -- texto quando nada selecionado (opcional)
    Callback = function(selected)
        -- selected = tabela com todos os itens ativos
        print(table.concat(selected, ", "))
    end
})
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do elemento |
| `Options` | table | Lista de opções disponíveis |
| `Default` | table | Opções pré-selecionadas |
| `Placeholder` | string | Texto quando nenhum item está selecionado |
| `Callback` | function | Chamada ao mudar seleção, recebe `selected` (table) |

**Métodos:**
```lua
local MyMulti = Tab:AddMultiDropdown({...})
MyMulti:SetValues({"Gun", "Knife"}) -- substitui seleção atual
MyMulti:GetValues()                 -- retorna tabela com selecionados
MyMulti:AddOption("Grenade")        -- adiciona nova opção dinamicamente
```

---

### 9️⃣ AddColorPicker (Seletor de Cor)

```lua
Tab:AddColorPicker({
    Name    = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        _G.ESPColor = color
    end
})
```

**Parâmetros:**
- `Name` (string) — Nome do color picker
- `Default` (Color3) — Cor inicial
- `Callback` (function) — Chamada ao mudar cor, recebe `color` (Color3)

**Métodos:**
```lua
local MyCP = Tab:AddColorPicker({...})
MyCP:SetValue(Color3.fromRGB(0, 255, 0))
```

---

### 🔟 AddKeybind (Tecla de Atalho)

```lua
Tab:AddKeybind({
    Name    = "Ativar ESP",
    Default = Enum.KeyCode.Z,
    KeyChanged = function(newKey)    -- opcional
        print("Tecla alterada para:", newKey.Name)
    end,
    Callback = function()
        -- executado ao pressionar a tecla
        print("ESP ativado!")
    end
})
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do keybind |
| `Default` | Enum.KeyCode | Tecla padrão |
| `Callback` | function | Chamada ao pressionar a tecla |
| `KeyChanged` | function | Chamada quando o utilizador reatribui a tecla, recebe `newKey` |

> Para um toggle com keybind integrado, usa `AddToggleKeybind` em vez deste.

---

## 💧 Watermark (Marca d'água)

A Watermark é exibida automaticamente no **canto superior esquerdo** da tela e mostra em tempo real:

```
Quantom.gg  |  NickName  |  60 FPS  |  32 ms
```

- **Ativada por padrão** ao carregar a library
- Pode ser ativada/desativada na tab **⚙ Config → Watermark**
- Atualiza FPS e Ping a cada 0.5 segundos
- Adapta o tamanho automaticamente ao conteúdo
- Design elegante com barra de gradiente no topo

> Não é necessário configurar nada — a watermark funciona automaticamente.

---

## 🔔 Sistema de Notificações

```lua
Window:Notify({
    Title    = "Título",
    Message  = "Mensagem aqui",
    Type     = "Success",
    Duration = 5
})
```

**Parâmetros:**
- `Title` (string) — Título
- `Message` (string) — Mensagem
- `Type` (string) — `"Success"` | `"Error"` | `"Warning"` | `"Info"`
- `Duration` (number) — Duração em segundos (padrão: 5)

```lua
Window:Notify({Title = "Sucesso!",  Message = "Operação concluída",    Type = "Success"})
Window:Notify({Title = "Erro!",     Message = "Algo deu errado",       Type = "Error"})
Window:Notify({Title = "Atenção!",  Message = "Cuidado com isso",      Type = "Warning"})
Window:Notify({Title = "Info",      Message = "Informação importante", Type = "Info"})
```

---

## 🎮 Controles da Janela

```lua
Window:Show()    -- Mostrar UI
Window:Hide()    -- Esconder UI
Window:Toggle()  -- Alternar visibilidade
```

**Atalho de teclado:** Configurável — padrão `RightShift`.
Pode ser alterado via parâmetro `MinimizeKey` na criação da janela **ou** em runtime pela tab **⚙ Config** que é gerada automaticamente no final da sidebar.

### Tab ⚙ Config (automática)

A tab Config é criada automaticamente e inclui:
- **Watermark** — Toggle para ativar/desativar a marca d'água (Quantom.gg | Nick | FPS | Ping)
- **Minimizar / Abrir** — Keybind configurável para mostrar/esconder a UI

---

## 📱 Suporte Mobile

A biblioteca deteta automaticamente dispositivos mobile e ajusta:
- Tamanho de todos os elementos (touch-friendly)
- Botão flutuante arrastável para abrir/fechar
- Layout e fontes otimizados para ecrãs pequenos

---

## 💡 Exemplo Completo

```lua
local QuantomLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dimess1/ui/refs/heads/main/library.lua'))()

local Window = QuantomLib:CreateWindow({
    Name        = "BLOX FRUITS HUB",
    Version     = "v2.0.0",
    MinimizeKey = Enum.KeyCode.RightShift
})

Window:Notify({Title = "Bem-vindo!", Message = "Hub carregado com sucesso", Type = "Success", Duration = 3})

local MainTab   = Window:CreateTab({Name = "Main",   Icon = "🏠"})
local CombatTab = Window:CreateTab({Name = "Combat", Icon = "⚔️"})

-- ── MAIN ────────────────────────────────────────────
MainTab:AddSection("AUTO FARM")

MainTab:AddToggleKeybind({
    Name    = "Auto Farm",
    Default = false,
    Key     = Enum.KeyCode.F,
    Callback = function(state)
        _G.AutoFarm = state
    end
})

MainTab:AddSlider({
    Name    = "Farm Speed",
    Min     = 1,
    Max     = 100,
    Default = 50,
    Callback = function(value)
        _G.FarmSpeed = value
    end
})

MainTab:AddSection("TELEPORTS")

MainTab:AddDropdown({
    Name    = "Teleport Location",
    Options = {"Spawn", "Shop", "Boss", "Quest"},
    Default = "Spawn",
    Callback = function(value)
        if value == "Spawn" then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end
})

MainTab:AddMultiDropdown({
    Name    = "Farm Targets",
    Options = {"Mobs", "Bosses", "Players", "Chests"},
    Default = {"Mobs"},
    Callback = function(selected)
        _G.FarmTargets = selected
    end
})

-- ── COMBAT ──────────────────────────────────────────
CombatTab:AddSection("AIMBOT")

CombatTab:AddToggleKeybind({
    Name    = "Aimbot",
    Default = false,
    Key     = Enum.KeyCode.X,
    Callback = function(state)
        _G.Aimbot = state
    end
})

CombatTab:AddSlider({
    Name    = "FOV Size",
    Min     = 50,
    Max     = 500,
    Default = 150,
    Callback = function(value)
        _G.FOVSize = value
    end
})

CombatTab:AddColorPicker({
    Name    = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        _G.FOVColor = color
    end
})

CombatTab:AddButton({
    Name = "Kill All",
    Callback = function()
        Window:Notify({Title = "Kill All", Message = "Executando...", Type = "Info"})
    end
})

Window:Show()
```

---

## 🎨 Personalização de Cores

As cores são definidas no `Theme` (linha ~20 do código):

```lua
local Theme = {
    Background  = Color3.fromRGB(12, 12, 14),
    Surface     = Color3.fromRGB(18, 18, 22),
    Primary     = Color3.fromRGB(66, 135, 245),
    Success     = Color3.fromRGB(80, 200, 120),
    Warning     = Color3.fromRGB(255, 200, 80),
    Error       = Color3.fromRGB(255, 80, 80),
    -- ... outras cores
}
```

---

## ⚙️ Recursos Avançados

### Loops com Toggle
```lua
local farmToggle = Tab:AddToggle({
    Name    = "Auto Farm",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})

task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFarm then
            -- código do farm
        end
    end
end)
```

### Toggle com Keybind + Loop
```lua
Tab:AddToggleKeybind({
    Name    = "Speed Hack",
    Default = false,
    Key     = Enum.KeyCode.G,
    Callback = function(state)
        _G.SpeedHack = state
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = state and 100 or 16
    end
})
```

### Multi-seleção Dinâmica
```lua
local multiDrop = Tab:AddMultiDropdown({
    Name    = "Layers",
    Options = {"ESP", "Chams", "Tracers"},
    Callback = function(selected)
        for _, v in ipairs(selected) do print(v) end
    end
})

-- Adicionar opção depois de criado
multiDrop:AddOption("Names")

-- Ler selecionados
local current = multiDrop:GetValues()
```

### Atualizar Valores em Runtime
```lua
local speedSlider = Tab:AddSlider({...})
speedSlider:SetValue(200)

local toggle = Tab:AddToggle({...})
toggle:SetValue(true)

local tk = Tab:AddToggleKeybind({...})
tk:SetToggle(false)
tk:SetKey(Enum.KeyCode.H)
```

