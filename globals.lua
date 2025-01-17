-- Carl Frank Otto III
-- carlotto81@gmail.com
-- GitHub: https://github.com/M45-Science/SoftMod
-- License: MPL 2.0
-- Create globals, if needed
function create_myglobals()
    global.svers = "613-08.31.2023-0304p"

    -- Adjust look
    game.surfaces[1].show_clouds = false

    -- This mod complely screws player permissions
    if game.active_mods["RemoteConfiguration"] then
        global.disableperms = true
    else
        global.disableperms = false
    end

    if not global.resetdur then
        global.resetdur = ""
    end
    if not global.resetint then
        global.resetint = ""
    end
    if not global.restrict == nil then
        global.restrict = true
    end
    if not global.playeractive then
        global.playeractive = {}
    end
    if not global.playermoving then
        global.playermoving = {}
    end
    if not global.active_playtime then
        global.active_playtime = {}
    end
    if not global.last_playtime then
        global.last_playtime = {}
    end

    if not global.patreons then
        global.patreons = {}
    end
    if not global.nitros then
        global.nitros = {}
    end

    if not global.patreonlist then
        global.patreonlist = {}
    end
    if not global.nitrolist then
        global.nitrolist = {}
    end

    if not global.last_speaker_warning then
        global.last_speaker_warning = 1
    end
    if not global.last_decon_warning then
        global.last_decon_warning = 1
    end
    if not global.last_ghost_log then
        global.last_decon_warning = 1
    end

    if not global.corpselist then
        global.corpselist = {}
    end
    make_banish_globals()

    if not global.info_shown then
        global.info_shown = {}
    end

    if not global.hide_clock then
        global.hide_clock = {}
    end

    if not global.lastonlinestring then
        global.lastonlinestring = ""
    end

    if not global.cleaned_players then
        global.cleaned_players = {}
    end
end

-- Create player globals, if needed
function create_player_globals(player)
    if player and player.valid then
        if global.playeractive and player and player.index then
            if not global.playeractive[player.index] then
                global.playeractive[player.index] = false
            end
            if not global.playermoving[player.index] then
                global.playermoving[player.index] = false
            end

            if not global.active_playtime[player.index] then
                global.active_playtime[player.index] = 0
            end

            if not global.thebanished[player.index] then
                global.thebanished[player.index] = 0
            end

            if not global.hide_clock[player.index] then
                global.hide_clock[player.index] = false
            end

            if not global.last_playtime[player.index] then
                global.last_playtime[player.index] = false
            end

            if not global.cleaned_players[player.index] then
                global.cleaned_players[player.index] = true
            end

        end
    end
end
