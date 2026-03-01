# QuantomLib — Documentação

## 📦 Carregar no Script

```lua
local QuantomLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dimess1/ui/refs/heads/main/library.lua'))()
```

---

## 🎨 Temas

A lib inclui 5 temas prontos: `Dark`, `Purple`, `Red`, `Green` e `Rose`.

```lua
QuantomLib:SetTheme("Purple")
```

Para tema customizado:

```lua
QuantomLib:SetCustomTheme({
    Primary = Color3.fromRGB(255, 165, 0),
    Accent  = Color3.fromRGB(255, 200, 50),
})
```

Também pode passar o tema direto na criação da janela:

```lua
local Window = QuantomLib:CreateWindow({
    Name  = "MEU HUB",
    Theme = "Red"
})
```

---

## 🪟 Criar Janela Principal

```lua
local Window = QuantomLib:CreateWindow({
    Name        = "MEU HUB",
    Version     = "v1.0.0",
    MinimizeKey = Enum.KeyCode.RightShift,
    Theme       = "Dark"
})
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do hub exibido no header |
| `Version` | string | Versão exibida no header |
| `MinimizeKey` | Enum.KeyCode | Tecla para minimizar/abrir (padrão: `RightShift`) |
| `Theme` | string ou table | Nome do tema ou tabela de cores customizada |

> A tab **⚙ Config** é criada automaticamente no final da sidebar com watermark, keybind list, tema, atalhos e perfis.

---

## 🎮 Controles da Janela

```lua
Window:Show()     -- Mostrar com animação
Window:Hide()     -- Esconder com animação
Window:Toggle()   -- Alternar visibilidade
Window:Destroy()  -- Destrói a UI e limpa todas as conexões
```

---

## 🏷️ Sistema de Flags

Todos os elementos aceitam `config.Flag`. O valor fica acessível via `Window.Flags`:

```lua
Tab:AddToggle({
    Name     = "Auto Farm",
    Default  = false,
    Flag     = "autoFarm",
    Callback = function(v) end
})

print(Window.Flags.autoFarm) -- true ou false
```

Também pode acessar direto:

```lua
Window:SetFlag("customFlag", 123)
Window:GetFlag("customFlag") -- 123
```

---

## 💾 Sistema de Perfis (Save/Load)

Salva e carrega todos os `Flags` em JSON via `writefile`/`readfile`.

```lua
Window:SaveConfig("meuPerfil")
Window:LoadConfig("meuPerfil")
Window:DeleteConfig("meuPerfil")

local configs = Window:GetConfigs() -- retorna {"meuPerfil", "default", ...}
```

Suporta múltiplos perfis nomeados. Ao carregar, todos os elementos com `Flag` são atualizados automaticamente.

> A tab Config já inclui interface visual para gerenciar perfis.

---

## 🔗 Dependências entre Elementos

Qualquer elemento aceita `config.DependsOn = "flagName"`. Ele só funciona quando a flag referenciada está `true`:

```lua
Tab:AddToggle({
    Name = "ESP Master",
    Flag = "espMaster",
})

Tab:AddToggle({
    Name      = "ESP Names",
    Flag      = "espNames",
    DependsOn = "espMaster", -- bloqueado até espMaster estar true
})
```

---

## 💬 Tooltips

Qualquer elemento aceita `config.Tooltip` — mostra texto ao passar o mouse:

```lua
Tab:AddToggle({
    Name    = "God Mode",
    Tooltip = "Ativa imortalidade no personagem",
})
```

---

## 📑 Criar Tabs/Categorias

```lua
local Tab = Window:CreateTab({
    Name = "Principal",
    Icon = "🏠"
})
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome da tab |
| `Icon` | string | Ícone emoji |

**Badges na tab:**

```lua
Tab:SetBadge(3)  -- mostra "3" na sidebar
Tab:SetBadge(0)  -- esconde o badge
```

**Barra de busca:** A sidebar tem uma barra de busca automática que filtra tabs por nome.

---

## 🔑 Keybind Global

Keybind que funciona sem estar numa tab:

```lua
local kb = Window:AddGlobalKeybind({
    Key = Enum.KeyCode.H,
    Callback = function()
        print("Pressionou H")
    end
})

kb:SetKey(Enum.KeyCode.J)
kb:GetKey()
```

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

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Title` | string | Título |
| `Message` | string | Mensagem |
| `Type` | string | `"Success"`, `"Error"`, `"Warning"` ou `"Info"` |
| `Duration` | number | Duração em segundos (padrão: 5) |

---

## 🔧 Elementos da UI

### AddSection

```lua
Tab:AddSection("CONFIGURAÇÕES GERAIS")
```

Texto separador em maiúsculas.

---

### AddSeparator

```lua
Tab:AddSeparator()
```

Linha divisória simples entre elementos.

---

### AddLabel

```lua
local label = Tab:AddLabel("Texto informativo")
-- ou
local label = Tab:AddLabel({Text = "Texto informativo"})

label:SetText("Novo texto")
label:GetText()
```

---

### AddParagraph

```lua
local para = Tab:AddParagraph({
    Title   = "Changelog v2.0",
    Content = "Adicionado suporte a temas, perfis, color picker e muito mais."
})

para:SetTitle("Novo título")
para:SetContent("Novo conteúdo")
```

---

### AddImage

```lua
local img = Tab:AddImage({
    Image  = "rbxassetid://123456",
    Height = 150
})

img:SetImage("rbxassetid://789012")
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Image` | string | Asset ID da imagem |
| `Height` | number | Altura em pixels (padrão: 150 desktop, 120 mobile) |

---

### AddToggle

```lua
local toggle = Tab:AddToggle({
    Name      = "Auto Farm",
    Default   = false,
    Flag      = "autoFarm",
    Tooltip   = "Ativa farm automático",
    DependsOn = "masterToggle",
    Callback  = function(value)
        _G.AutoFarm = value
    end
})

toggle:SetValue(true)
toggle:GetValue() -- boolean
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do toggle |
| `Default` | boolean | Valor inicial |
| `Flag` | string | Flag para salvar no perfil |
| `Tooltip` | string | Texto ao passar o mouse |
| `DependsOn` | string | Flag que precisa estar true |
| `Callback` | function | Recebe `value` (boolean) |

---

### AddToggleKeybind

Toggle + tecla de atalho numa única linha. Pressionar a tecla alterna o estado. Registra automaticamente no **Keybind List overlay**.

```lua
local tk = Tab:AddToggleKeybind({
    Name    = "Aimbot",
    Default = false,
    Key     = Enum.KeyCode.X,
    Flag    = "aimbot",
    Callback = function(state)
        _G.Aimbot = state
    end,
    KeyChanged = function(newKey)
        print("Nova tecla:", newKey.Name)
    end
})

tk:SetValue(true)
tk:SetToggle(true)
tk:SetKey(Enum.KeyCode.F)
tk:GetValue()  -- boolean
tk:GetState()  -- boolean
tk:GetKey()    -- Enum.KeyCode
```

> **Teclas bloqueadas:** W, A, S, D, Space, LeftShift, LeftControl.

---

### AddButton

```lua
Tab:AddButton({
    Name      = "Kill All",
    Confirm   = true,
    DependsOn = "masterToggle",
    Tooltip   = "Mata todos os NPCs",
    Callback  = function()
        print("Executando...")
    end
})
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do botão |
| `Confirm` | boolean | Exige duplo clique para confirmar |
| `DependsOn` | string | Flag que precisa estar true |
| `Tooltip` | string | Texto ao passar o mouse |
| `Callback` | function | Chamada ao clicar |

---

### AddSlider

```lua
local slider = Tab:AddSlider({
    Name    = "WalkSpeed",
    Min     = 16,
    Max     = 200,
    Default = 16,
    Step    = 5,
    Flag    = "walkSpeed",
    Tooltip = "Velocidade do personagem",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

slider:SetValue(100)
slider:GetValue() -- number
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do slider |
| `Min` | number | Valor mínimo |
| `Max` | number | Valor máximo |
| `Default` | number | Valor inicial |
| `Step` | number | Incremento (padrão: 1) |
| `Flag` | string | Flag para salvar no perfil |
| `Tooltip` | string | Texto ao passar o mouse |
| `Callback` | function | Recebe `value` (number) |

---

### AddTextbox

```lua
local textbox = Tab:AddTextbox({
    Name           = "Player Name",
    Default        = "",
    Placeholder    = "Digite o nome...",
    Flag           = "targetPlayer",
    FireOnFocusLost = true,
    Callback = function(value)
        print("Texto:", value)
    end
})

textbox:SetValue("NovoTexto")
textbox:GetValue() -- string
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `Name` | string | Nome do textbox |
| `Default` | string | Texto inicial |
| `Placeholder` | string | Texto exibido quando vazio |
| `Flag` | string | Flag para salvar no perfil |
| `FireOnFocusLost` | boolean | Dispara callback ao perder foco (não só Enter) |
| `Callback` | function | Recebe `value` (string) |

---

### AddDropdown

```lua
local dropdown = Tab:AddDropdown({
    Name    = "Weapon",
    Options = {"Sword", "Gun", "Knife"},
    Default = "Sword",
    Flag    = "weapon",
    Callback = function(value)
        _G.Weapon = value
    end
})

dropdown:SetValue("Gun")
dropdown:GetValue() -- string
```

---

### AddMultiDropdown

Permite selecionar várias opções. Cada item mostra `✓` quando ativo.

```lua
local multi = Tab:AddMultiDropdown({
    Name        = "Farm Targets",
    Options     = {"Mobs", "Bosses", "Players", "Chests"},
    Default     = {"Mobs"},
    Placeholder = "Selecionar...",
    Flag        = "farmTargets",
    Callback = function(selected)
        print(table.concat(selected, ", "))
    end
})

multi:SetValues({"Gun", "Knife"})
multi:GetValues()
multi:AddOption("Grenade")
```

---

### AddColorPicker

Painel HSV completo com barra de hue.

```lua
local cp = Tab:AddColorPicker({
    Name    = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag    = "espColor",
    Callback = function(color)
        _G.ESPColor = color
    end
})

cp:SetValue(Color3.fromRGB(0, 255, 0))
cp:GetValue() -- Color3
```

---

### AddKeybind

```lua
local kb = Tab:AddKeybind({
    Name    = "Ativar ESP",
    Default = Enum.KeyCode.Z,
    Flag    = "espKey",
    KeyChanged = function(newKey)
        print("Nova tecla:", newKey.Name)
    end,
    Callback = function()
        print("ESP ativado!")
    end
})

kb:SetKey(Enum.KeyCode.X)
kb:GetKey() -- Enum.KeyCode
```

> Para toggle com keybind integrado, usa `AddToggleKeybind`.

---

### AddProgressBar

Barra de progresso visual com animação.

```lua
local bar = Tab:AddProgressBar({
    Name    = "Farm Progress",
    Default = 0,
    Flag    = "farmProgress",
})

bar:SetValue(75)  -- 0 a 100
bar:GetValue()    -- number
```

---

### AddConsole

Mini terminal de log dentro da UI.

```lua
local console = Tab:AddConsole({
    Name     = "Log",
    MaxLines = 50,
    Height   = 160,
})

console:Log("Mensagem normal")
console:Warn("Aviso importante")
console:Error("Algo deu errado")
console:Success("Operação concluída")
console:Clear()
```

---

## 📋 Keybind List Overlay

Painel flutuante no canto inferior esquerdo que mostra todos os `AddToggleKeybind` que estão ativos, com nome e tecla.

- Atualiza em tempo real ao ligar/desligar toggles ou rebindar teclas
- Draggable
- Mostra "Nenhum ativo" quando tudo está desligado
- Ativado na tab **⚙ Config** → "Mostrar Keybinds Ativos"

---

## 📱 Suporte Mobile

A biblioteca detecta automaticamente dispositivos mobile e ajusta:

- Tamanho de todos os elementos (touch-friendly)
- Botão flutuante draggable para abrir/fechar
- Layout e fontes otimizados para telas pequenas
- Detecção melhorada (descarta laptops touch com viewport > 1200px)

---

## 💡 Exemplo Completo

```lua
local QuantomLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dimess1/ui/refs/heads/main/library.lua'))()

local Window = QuantomLib:CreateWindow({
    Name    = "BLOX FRUITS HUB",
    Version = "v3.0.0",
    Theme   = "Dark"
})

Window:Notify({Title = "Bem-vindo!", Message = "Hub carregado", Type = "Success", Duration = 3})

local MainTab   = Window:CreateTab({Name = "Main",    Icon = "🏠"})
local CombatTab = Window:CreateTab({Name = "Combat",  Icon = "⚔️"})
local VisualTab = Window:CreateTab({Name = "Visuals", Icon = "👁"})

-- MAIN
MainTab:AddSection("AUTO FARM")

MainTab:AddToggleKeybind({
    Name    = "Auto Farm",
    Default = false,
    Key     = Enum.KeyCode.F,
    Flag    = "autoFarm",
    Tooltip = "Farma automaticamente o quest selecionado",
    Callback = function(state)
        _G.AutoFarm = state
    end
})

MainTab:AddSlider({
    Name    = "Farm Speed",
    Min     = 1,
    Max     = 100,
    Default = 50,
    Step    = 5,
    Flag    = "farmSpeed",
    Callback = function(value)
        _G.FarmSpeed = value
    end
})

MainTab:AddSeparator()

MainTab:AddDropdown({
    Name    = "Quest",
    Options = {"Quest 1", "Quest 2", "Quest 3"},
    Default = "Quest 1",
    Flag    = "selectedQuest",
})

MainTab:AddMultiDropdown({
    Name    = "Farm Targets",
    Options = {"Mobs", "Bosses", "Players", "Chests"},
    Default = {"Mobs"},
    Flag    = "farmTargets",
})

MainTab:AddSection("STATUS")

local progressBar = MainTab:AddProgressBar({
    Name    = "Farm Progress",
    Default = 0,
    Flag    = "farmProgress",
})

local console = MainTab:AddConsole({
    Name     = "Farm Log",
    MaxLines = 30,
    Height   = 120,
})

-- COMBAT
CombatTab:AddSection("AIMBOT")

CombatTab:AddToggleKeybind({
    Name    = "Aimbot",
    Default = false,
    Key     = Enum.KeyCode.X,
    Flag    = "aimbot",
    Callback = function(state) _G.Aimbot = state end
})

CombatTab:AddSlider({
    Name    = "FOV Size",
    Min     = 50,
    Max     = 500,
    Default = 150,
    Flag    = "fovSize",
    DependsOn = "aimbot",
})

CombatTab:AddColorPicker({
    Name    = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag    = "fovColor",
    DependsOn = "aimbot",
})

CombatTab:AddButton({
    Name    = "Kill All",
    Confirm = true,
    Callback = function()
        Window:Notify({Title = "Kill All", Message = "Executando...", Type = "Info"})
    end
})

-- VISUALS
VisualTab:AddSection("ESP")

VisualTab:AddToggle({
    Name = "ESP Master",
    Flag = "espMaster",
})

VisualTab:AddToggle({
    Name      = "ESP Names",
    Flag      = "espNames",
    DependsOn = "espMaster",
})

VisualTab:AddToggle({
    Name      = "ESP Boxes",
    Flag      = "espBoxes",
    DependsOn = "espMaster",
})

VisualTab:AddColorPicker({
    Name      = "ESP Color",
    Default   = Color3.fromRGB(255, 0, 0),
    Flag      = "espColor",
    DependsOn = "espMaster",
})

VisualTab:AddSection("INFO")

VisualTab:AddParagraph({
    Title   = "Sobre",
    Content = "QuantomLib v3.0 — Biblioteca de UI para Roblox com temas, perfis, keybind list e mais."
})

VisualTab:AddLabel("Build: 2025.06.01")

Window:Show()
```

---

## ⚙️ Recursos Avançados

### Loops com Toggle

```lua
Tab:AddToggle({
    Name    = "Auto Farm",
    Flag    = "autoFarm",
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

### Perfis em Runtime

```lua
Window:SaveConfig("PvP")
Window:SaveConfig("Farm")
Window:LoadConfig("PvP")

local all = Window:GetConfigs() -- {"PvP", "Farm"}
```

### Acessar Flags Direto

```lua
if Window.Flags.aimbot then
    -- aimbot está ativo
end

local speed = Window.Flags.walkSpeed -- valor do slider
local color = Window.Flags.espColor  -- Color3 do color picker
```

### Console como Debug

```lua
local console = Tab:AddConsole({Name = "Debug"})

console:Log("Script iniciado")
console:Success("Conectado ao servidor")
console:Warn("Ping alto: 200ms")
console:Error("Falha ao teleportar")
```

### Multi-seleção Dinâmica

```lua
local multi = Tab:AddMultiDropdown({
    Name    = "Layers",
    Options = {"ESP", "Chams", "Tracers"},
})

multi:AddOption("Names")
local current = multi:GetValues()
```

---

## 📖 Referência Rápida de Métodos

| Elemento | SetValue | GetValue | Extras |
|---|---|---|---|
| Toggle | `SetValue(bool)` | `GetValue()` | — |
| ToggleKeybind | `SetValue(bool)` / `SetToggle(bool)` | `GetValue()` / `GetState()` | `SetKey()`, `GetKey()` |
| Slider | `SetValue(num)` | `GetValue()` | — |
| Textbox | `SetValue(str)` | `GetValue()` | — |
| Dropdown | `SetValue(str)` | `GetValue()` | — |
| MultiDropdown | `SetValues(tbl)` | `GetValues()` | `AddOption(str)` |
| ColorPicker | `SetValue(Color3)` | `GetValue()` | — |
| Keybind | `SetKey(KeyCode)` | `GetKey()` | — |
| ProgressBar | `SetValue(0-100)` | `GetValue()` | — |
| Label | `SetText(str)` | `GetText()` | — |
| Paragraph | `SetTitle(str)` | — | `SetContent(str)` |
| Image | `SetImage(str)` | — | — |
| Console | — | — | `Log()`, `Warn()`, `Error()`, `Success()`, `Clear()` |

---

## 📖 Referência de config Globais

| Parâmetro | Onde | Descrição |
|---|---|---|
| `Flag` | Todos | Registra valor em `Window.Flags` e permite save/load |
| `Tooltip` | Todos | Texto exibido ao passar o mouse |
| `DependsOn` | Toggle, Button, Slider | Bloqueia até a flag referenciada ser `true` |
| `Confirm` | Button | Exige duplo clique |
| `FireOnFocusLost` | Textbox | Dispara callback ao perder foco |
| `Step` | Slider | Incremento do valor |
