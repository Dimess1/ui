
### 2. Carregar no Script
```lua
local QuantomLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dimess1/ui/refs/heads/main/library.lua'))()
```

---

## 🎨 Criar Janela Principal

```lua
local Window = QuantomLib:CreateWindow({
    Name = "MEU HUB",
    Version = "v1.0.0"
})
```

**Parâmetros:**
- `Name` (string) - Nome do hub
- `Version` (string) - Versão exibida no header

---

## 📑 Criar Tabs/Categorias

```lua
local Tab = Window:CreateTab({
    Name = "Principal",
    Icon = "🏠"
})
```

**Parâmetros:**
- `Name` (string) - Nome da tab
- `Icon` (string) - Ícone emoji

**Exemplo com múltiplas tabs:**
```lua
local MainTab = Window:CreateTab({Name = "Main", Icon = "🏠"})
local CombatTab = Window:CreateTab({Name = "Combat", Icon = "⚔️"})
local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "👁"})
local MiscTab = Window:CreateTab({Name = "Misc", Icon = "⚙️"})
```

---

## 🔧 Elementos da UI

### 1️⃣ AddSection (Separador)

```lua
Tab:AddSection("CONFIGURAÇÕES GERAIS")
```

**Parâmetros:**
- `title` (string) - Texto do separador

---

### 2️⃣ AddToggle (Botão On/Off)

```lua
Tab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
        print("Auto Farm:", value)
    end
})
```

**Parâmetros:**
- `Name` (string) - Nome do toggle
- `Default` (boolean) - Valor inicial (true/false)
- `Callback` (function) - Função executada ao mudar

**Métodos:**
```lua
local MyToggle = Tab:AddToggle({...})
MyToggle:SetValue(true)
```

---

### 3️⃣ AddButton (Botão)

```lua
Tab:AddButton({
    Name = "Teleport Spawn",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        print("Teleportado!")
    end
})
```

**Parâmetros:**
- `Name` (string) - Nome do botão
- `Callback` (function) - Função executada ao clicar

---

### 4️⃣ AddSlider (Controle Deslizante)

```lua
Tab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        print("Speed:", value)
    end
})
```

**Parâmetros:**
- `Name` (string) - Nome do slider
- `Min` (number) - Valor mínimo
- `Max` (number) - Valor máximo
- `Default` (number) - Valor inicial
- `Callback` (function) - Função executada ao mudar

**Métodos:**
```lua
local MySlider = Tab:AddSlider({...})
MySlider:SetValue(100)
```

---

### 5️⃣ AddTextbox (Campo de Texto)

```lua
Tab:AddTextbox({
    Name = "Player Name",
    Default = "",
    Placeholder = "Digite o nome...",
    Callback = function(value)
        local player = game.Players:FindFirstChild(value)
        if player then
            print("Jogador encontrado:", player.Name)
        end
    end
})
```

**Parâmetros:**
- `Name` (string) - Nome do textbox
- `Default` (string) - Texto inicial
- `Placeholder` (string) - Texto placeholder
- `Callback` (function) - Função executada ao pressionar Enter

**Métodos:**
```lua
local MyTextbox = Tab:AddTextbox({...})
MyTextbox:SetValue("NovoTexto")
```

---

### 6️⃣ AddDropdown (Menu Suspenso)

```lua
Tab:AddDropdown({
    Name = "Weapon",
    Options = {"Sword", "Gun", "Knife", "Bomb"},
    Default = "Sword",
    Callback = function(value)
        _G.SelectedWeapon = value
        print("Arma selecionada:", value)
    end
})
```

**Parâmetros:**
- `Name` (string) - Nome do dropdown
- `Options` (table) - Lista de opções
- `Default` (string) - Opção inicial
- `Callback` (function) - Função executada ao selecionar

**Métodos:**
```lua
local MyDropdown = Tab:AddDropdown({...})
MyDropdown:SetValue("Gun")
```


### 7️⃣ AddColorPicker (Seletor de Cor)

```lua
Tab:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        _G.ESPColor = color
        print("Cor selecionada:", color)
    end
})
```

**Parâmetros:**

- `Name` (string) - Nome do color picker
- `Default` (Color3) - Cor inicial
- `Callback` (function) - Função executada ao mudar a cor

**Métodos:**

```lua
local MyColorPicker = Tab:AddColorPicker({...})
MyColorPicker:SetValue(Color3.fromRGB(0, 255, 0))
```

---

---

## 🔔 Sistema de Notificações

```lua
Window:Notify({
    Title = "Título",
    Message = "Mensagem aqui",
    Type = "Success",
    Duration = 5
})
```

**Parâmetros:**
- `Title` (string) - Título da notificação
- `Message` (string) - Mensagem
- `Type` (string) - Tipo: "Success", "Error", "Warning", "Info"
- `Duration` (number) - Duração em segundos (padrão: 5)

**Tipos de notificação:**
```lua
-- Sucesso (verde)
Window:Notify({
    Title = "Sucesso!",
    Message = "Operação concluída",
    Type = "Success"
})

-- Erro (vermelho)
Window:Notify({
    Title = "Erro!",
    Message = "Algo deu errado",
    Type = "Error"
})

-- Aviso (amarelo)
Window:Notify({
    Title = "Atenção!",
    Message = "Cuidado com isso",
    Type = "Warning"
})

-- Informação (azul)
Window:Notify({
    Title = "Info",
    Message = "Informação importante",
    Type = "Info"
})
```

---

## 🎮 Controles da Janela

```lua
-- Mostrar UI
Window:Show()

-- Esconder UI
Window:Hide()

-- Alternar visibilidade
Window:Toggle()
```

**Atalho de teclado:** Pressione `RightShift` para abrir/fechar a UI

---

## 📱 Suporte Mobile

A biblioteca detecta automaticamente dispositivos mobile e ajusta:
- Tamanho dos elementos
- Botão flutuante arrastável
- Layout otimizado para toque

---

## 💡 Exemplo Completo

```lua
local QuantomLib = loadstring(game:HttpGet('SEU-LINK-RAW'))()

local Window = QuantomLib:CreateWindow({
    Name = "BLOX FRUITS HUB",
    Version = "v2.0.0"
})

Window:Notify({
    Title = "Bem-vindo!",
    Message = "Hub carregado com sucesso",
    Type = "Success",
    Duration = 3
})

local MainTab = Window:CreateTab({
    Name = "Principal",
    Icon = "🏠"
})

local CombatTab = Window:CreateTab({
    Name = "Combate",
    Icon = "⚔️"
})

MainTab:AddSection("AUTO FARM")

MainTab:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
        while _G.AutoFarm do
            wait(0.1)
            -- Seu código de farm aqui
        end
    end
})

MainTab:AddSlider({
    Name = "Farm Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Callback = function(value)
        _G.FarmSpeed = value
    end
})

MainTab:AddSection("TELEPORTS")

MainTab:AddDropdown({
    Name = "Teleport Location",
    Options = {"Spawn", "Shop", "Boss", "Quest"},
    Default = "Spawn",
    Callback = function(value)
        if value == "Spawn" then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end
})

CombatTab:AddSection("COMBATE")

CombatTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(value)
        _G.Aimbot = value
    end
})

CombatTab:AddSlider({
    Name = "FOV Size",
    Min = 50,
    Max = 500,
    Default = 150,
    Callback = function(value)
        _G.FOVSize = value
    end
})

CombatTab:AddButton({
    Name = "Kill All",
    Callback = function()
        Window:Notify({
            Title = "Kill All",
            Message = "Executando...",
            Type = "Info"
        })
        -- Seu código aqui
    end
})

Window:Show()
```

---

## 🎨 Personalização de Cores

As cores são definidas no Theme (linha ~20 do código):

```lua
local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Surface = Color3.fromRGB(18, 18, 22),
    Primary = Color3.fromRGB(66, 135, 245),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 200, 80),
    Error = Color3.fromRGB(255, 80, 80),
    -- ... outras cores
}
```

---

## ⚙️ Recursos Avançados

### Variáveis Globais
Use `_G.NomeVariavel` para compartilhar valores entre scripts:

```lua
Tab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(value)
        _G.ESPEnabled = value
    end
})
```

### Loops com Toggle
```lua
local farmToggle = MainTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
    end
})

task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFarm then
            -- Código do farm
        end
    end
end)
```

### Atualizar Valores Dinamicamente
```lua
local speedSlider = Tab:AddSlider({...})

-- Depois, você pode atualizar:
speedSlider:SetValue(100)
```

---

## 🛠️ Solução de Problemas

### UI não aparece
```lua
-- Certifique-se de chamar:
Window:Show()
```

### Mobile: Botão não aparece
O botão flutuante aparece automaticamente em dispositivos mobile. Se não aparecer, a UI está configurada para desktop.

### Notificações não funcionam
Certifique-se de que a janela foi criada antes de chamar `Window:Notify()`

---

## 📝 Notas Importantes

1. **Keybind padrão:** `RightShift` para abrir/fechar
2. **Mobile:** Botão flutuante arrastável automático
3. **Performance:** Use `task.spawn()` para loops pesados
4. **Segurança:** Nunca compartilhe links raw com código malicioso

---

## 🔗 Links Úteis

- GitHub: Crie repositório público para hospedar
- WeAreDevs: Para executores Roblox
- V3rmillion: Comunidade de scripting

---

## ✨ Créditos

**Quantom UI Library v1.0**
Desenvolvido com TweenService e modern design
Suporte completo para PC e Mobile

---

**Última atualização:** Fevereiro 2026
