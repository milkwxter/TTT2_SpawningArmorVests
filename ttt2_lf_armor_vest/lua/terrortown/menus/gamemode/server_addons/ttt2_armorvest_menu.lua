CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "ttt2_armorvest_title"

-- actual menu stuff
function CLGAMEMODESUBMENU:Populate(parent)
    local form = vgui.CreateTTT2Form(parent, "ttt2_armorvest_form1")
	form:MakeHelp({
        label = "ttt2_armorvest_help1",
    })
	form:MakeCheckBox({
        label = "ttt2_armorvest_label_enabled",
        serverConvar = "loot_armorvest_can_spawn",
    })
	form:MakeSlider({
        label = "ttt2_armorvest_label_maxItems",
        serverConvar = "loot_armorvest_max_per_round",
        min = 0,
        max = 10,
        decimal = 0,
    })
	form:MakeSlider({
        label = "ttt2_armorvest_label_pctRounds",
        serverConvar = "loot_armorvest_spawn_chance",
        min = 0,
        max = 100,
        decimal = 0,
    })
end