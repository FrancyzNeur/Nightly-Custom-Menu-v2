include('openurl2.lua')
local RNB = RNB or {}
local R = function(a, b, c, d, e) return function() return RunConsoleCommand(a, b, c, d, e) end end
local M = function(x) return function() return RunGameUICommand(x) end end
local NOT = function(f) return function(...) return not f(...) end end

if RNB.menu and RNB.menu:IsValid() then
    RNB.menu:Remove()
end

RNB.menu = vgui.Create('DPanelList', nil, 'RNB.menu')
RNB.menu:EnableVerticalScrollbar(true)
RNB.menu:Dock(BOTTOM)
RNB.menu:DockMargin(0, 0, 0, 5)
local gameslist

function CreateGames()
    if gameslist and gameslist:IsValid() then
        gameslist:Remove()
        gameslist = nil
    end

    gameslist = vgui.Create('DForm', menulist_wrapper, 'gameslist')
    gameslist:Dock(BOTTOM)
    gameslist:SetName"#mounted_games"
    gameslist:SetExpanded(false)
    gameslist.Header:SetIcon'icon16/joystick.png'
    gameslist:SetCookieName"gameslist"
    gameslist:LoadCookies()
    menulist_wrapper:AddItem(gameslist)
    menulist_wrapper:InvalidateLayout(true)
    gameslist:InvalidateLayout(true)

    local function AddButton(data, title, mounted, owned, installed, depot)
        local btn = vgui.Create("DCheckBoxLabel", gameslist, 'gameslist_button')
        gameslist:AddItem(btn)
        btn:SetText(title)
        btn:SetChecked(mounted)
        btn:SetBright(true)
        btn:SetDisabled(not owned or not installed)
        btn:SizeToContents()

        function btn:OnChange(val)
            engine.SetMounted(depot, val)
            btn:SetChecked(IsMounted(depot))
        end

        btn:InvalidateLayout(true)
    end

    local t = engine.GetGames()

    table.sort(t, function(a, b)
        if a.mounted == b.mounted then
            if a.mounted then
                return a.depot < b.depot
            else
                return ((a.installed and a.owned) and 0 or 1) < ((b.installed and b.owned) and 0 or 1)
            end
        else
            return (a.mounted and 0 or 1) < (b.mounted and 0 or 1)
        end
    end)

    for _, data in next, t do
        AddButton(data, data.title, data.mounted, data.owned, data.installed, data.depot)
    end
end

function RNB.Open_Menu()
    if IsValid(RNB.bonus_menu) then
        RNB.bonus_menu:Remove()
    end

    RNB.bonus_menu = vgui.Create("DFrame") 
    RNB.bonus_menu:SetSize(ScrW(), 28)
    RNB.bonus_menu:SetPos(0, ScrH() - 30)
    RNB.bonus_menu:SetTitle("")
    RNB.bonus_menu:SetDraggable(false)
    RNB.bonus_menu:ShowCloseButton(false)

    RNB.bonus_menu.Paint = function()
        surface.SetDrawColor(40, 40, 40, 255)
        surface.DrawRect(0, 0, RNB.bonus_menu:GetWide(), RNB.bonus_menu:GetTall())
    end

    local function CreateButton(pos, command, icon, tip)
        local bonus_boutton = vgui.Create("DButton", RNB.bonus_menu)
        bonus_boutton:SetText("")
        bonus_boutton:SetPos(unpack(pos))

        bonus_boutton.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        end

        bonus_boutton.DoClick = function()
            M(command)()
            bonus_boutton:SetSelected(false)
        end

        bonus_boutton:SetImage(icon)
        bonus_boutton:InvalidateLayout(true)
        bonus_boutton:SetTextInset(16 + 16, 0)
        bonus_boutton:SetContentAlignment(4)
        local tall = bonus_boutton:GetTall() + 4
        tall = tall < 16 and 16 or tall
        bonus_boutton:SetTall(tall)
        bonus_boutton:SetTooltip(tip)
    end


    -- Retry to server button
    CreateButton({5, -0.1}, "retry", "icon16/connect.png", "Retry to server")

    -- Start Game button
    CreateButton({35, -0.1}, "opencreatemultiplayergamedialog", "icon16/server.png", "Start new game")

    -- ServerBrowser button
    CreateButton({65, -0.1}, "openserverbrowser", "icon16/world_delete.png", "Server Browser")

    -- settings button
    CreateButton({95, -0.1}, "openoptionsdialog", "icon16/wrench.png", "Settings")

    --right side
    --clock
    local TimeStamp = os.time()
    local TimeString = os.date("%H:%M", TimeStamp)
    local bonus_hour = vgui.Create("DLabel", RNB.bonus_menu)
    bonus_hour:SetPos(ScrW() - 75, 3)
    bonus_hour:SetFont("TargetID")
    bonus_hour:SetColor(Color(180, 180, 180))
    bonus_hour:SetText(TimeString)

    timer.Create("refresh_hour_menu2", 5, 0, function()
        bonus_hour:SetText(os.date("%H:%M", TimeStamp))
    end)

    --quit button
    CreateButton({ScrW() - 115, -0.6}, "quitnoconfirm", "icon16/door.png", "Quit the game")
end

hook.Add("InGame", "CreateMenu", function(is)
    RNB.Open_Menu()
end)

hook.Add("ConsoleVisible", "CreateMenu", function(is)
    RNB.Open_Menu()
end)

R"showconsole"()
