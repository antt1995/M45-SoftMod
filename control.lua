--Carl Frank Otto III
--carlotto81@gmail.com
local svers = "545-1-28-2021-0358p-exp"
require "todo" --To-Do-list
require "online" --Player-Online-window
require "logo" --In-Game-Logo
require "info" --Welcome/Info window
require "util" --Widely used utility stuff
--require "darkness"

--Process banish votes
local function update_banished_votes()
  --Reset banished list
  local banishedtemp = {}

  --Init if needed
  if not global.banishvotes then
    global.banishvotes = {
      voter = {},
      victim = {},
      reason = {},
      tick = {},
      withdrawn = {},
      overruled = {}
    }
  end

  if not global.thebanished then
    global.thebanished = {}
  end

  --Loop through votes, tally them
  for _, vote in pairs(global.banishvotes) do
    --only if everything seems to exist
    if vote and vote.voter and vote.victim then
      --only if data exists
      if vote.voter.valid and vote.victim.valid then
        --valid defendant
        if is_new(vote.victim) or is_member(vote.victim) then
          --valid voter
          if is_regular(vote.voter) or vote.voter.admin then
            --vote isn't overruled or withdrawn
            if vote.withdrawn == false and vote.overruled == false then
              if banishedtemp[vote.victim.index] then
                banishedtemp[vote.victim.index] = banishedtemp[vote.victim.index] + 1 --Add vote against them
              else
                --was empty, init
                banishedtemp[vote.victim.index] = 1
              end
            end
          end
        end
      end
    end
  end

  --Loop though players, look for matches
  for _, victim in pairs(game.players) do
    local prevstate = is_banished(victim)

    --Add votes to global list, erase old votes
    if banishedtemp[victim.index] then
      global.thebanished[victim.index] = banishedtemp[victim.index]
    else
      global.thebanished[victim.index] = 0 --Erase/init
    end

    --Was banished, but not anymore
    if is_banished(victim) == false and prevstate == true then
      local msg = victim.name .. " is no longer banished."
      print("[REPORT] SYSTEM " .. msg)
      message_all("[color=red](SYSTEM) " .. msg .. "[/color]")

      --Kill them, so items are left behind
      if victim.character and victim.character.valid then
        victim.character.die("player")
      end
      if not global.send_to_surface then
        global.send_to_surface = {}
      end
      local spawnpos = {0, 0}
      if global.cspawnpos and global.cspawnpos.x then
        spawnpos = global.cspawnpos
      end
      table.insert(global.send_to_surface, {victim = victim, surface = "nauvis", position = spawnpos})
    elseif is_banished(victim) == true and prevstate == false then
      --Was not banished, but is now.
      local msg = victim.name .. " has been banished."
      message_all("[color=red](SYSTEM) " .. msg .. "[/color]")
      print("[REPORT] SYSTEM " .. msg)

      --Create area if needed
      if game.surfaces["hell"] == nil then
        local my_map_gen_settings = {
          width = 100,
          height = 100,
          default_enable_all_autoplace_controls = false,
          property_expression_names = {cliffiness = 0},
          autoplace_settings = {
            tile = {
              settings = {
                ["sand-1"] = {
                  frequency = "normal",
                  size = "normal",
                  richness = "normal"
                }
              }
            }
          },
          starting_area = "none"
        }
        game.create_surface("hell", my_map_gen_settings)
      end

      --Kill them, so items are left behind
      if victim.character and victim.character.valid then
        victim.character.die("player")
      end

      if not global.send_to_surface then
        global.send_to_surface = {}
      end
      table.insert(global.send_to_surface, {victim = victim, surface = "hell", position = {0, 0}})
    end
  end
end

--Create player groups if they don't exist, and create global links to them
local function create_groups()
  global.defaultgroup = game.permissions.get_group("Default")
  global.membersgroup = game.permissions.get_group("Members")
  global.regularsgroup = game.permissions.get_group("Regulars")
  global.adminsgroup = game.permissions.get_group("Admins")

  if (not global.defaultgroup) then
    game.permissions.create_group("Default")
  end

  if (not global.membersgroup) then
    game.permissions.create_group("Members")
  end

  if (not global.regularsgroup) then
    game.permissions.create_group("Regulars")
  end

  if (not global.adminsgroup) then
    game.permissions.create_group("Admins")
  end

  global.defaultgroup = game.permissions.get_group("Default")
  global.membersgroup = game.permissions.get_group("Members")
  global.regularsgroup = game.permissions.get_group("Regulars")
  global.adminsgroup = game.permissions.get_group("Admins")
end

--Disable some permissions for new players
local function set_perms()
  --Auto set default group permissions

  if global.defaultgroup and not global.setperms then
    --Only set perms once, unless cleared
    global.setperms = true

    global.defaultgroup.set_allows_action(defines.input_action.wire_dragging, false)
    global.defaultgroup.set_allows_action(defines.input_action.activate_cut, false)
    global.defaultgroup.set_allows_action(defines.input_action.add_train_station, false)
    global.defaultgroup.set_allows_action(defines.input_action.build_terrain, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_arithmetic_combinator_parameters, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_decider_combinator_parameters, false)
    global.defaultgroup.set_allows_action(defines.input_action.switch_constant_combinator_state, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_alert_parameters, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_circuit_parameters, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_train_stop_station, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_train_wait_condition, false)
    global.defaultgroup.set_allows_action(defines.input_action.change_train_wait_condition_data, false)
    global.defaultgroup.set_allows_action(defines.input_action.connect_rolling_stock, false)
    global.defaultgroup.set_allows_action(defines.input_action.deconstruct, false)
    global.defaultgroup.set_allows_action(defines.input_action.disconnect_rolling_stock, false)
    global.defaultgroup.set_allows_action(defines.input_action.drag_train_schedule, false)
    global.defaultgroup.set_allows_action(defines.input_action.drag_train_wait_condition, false)
    global.defaultgroup.set_allows_action(defines.input_action.launch_rocket, false)
    global.defaultgroup.set_allows_action(defines.input_action.remove_cables, false)
    global.defaultgroup.set_allows_action(defines.input_action.remove_train_station, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_auto_launch_rocket, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_circuit_condition, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_circuit_mode_of_operation, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_logistic_filter_item, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_logistic_filter_signal, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_request_from_buffers, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_signal, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_train_stopped, false)
    --Added 12-2020
    global.defaultgroup.set_allows_action(defines.input_action.cancel_research, false)
    global.defaultgroup.set_allows_action(defines.input_action.upgrade, false)
    global.defaultgroup.set_allows_action(defines.input_action.cancel_upgrade, false)
    global.defaultgroup.set_allows_action(defines.input_action.build_rail, false)
    global.defaultgroup.set_allows_action(defines.input_action.activate_paste, false)
    global.defaultgroup.set_allows_action(defines.input_action.flush_opened_entity_fluid, false)
    global.defaultgroup.set_allows_action(defines.input_action.flush_opened_entity_specific_fluid, false)
    global.defaultgroup.set_allows_action(defines.input_action.paste_entity_settings, false)
    global.defaultgroup.set_allows_action(defines.input_action.set_auto_launch_rocket, false)
    global.defaultgroup.set_allows_action(defines.input_action.use_artillery_remote, false)
    global.defaultgroup.set_allows_action(defines.input_action.upgrade, false)
  end
end

--Create globals, if needed
local function create_myglobals()
  if global.restrict == nil then
    global.restrict = true
  end
  if not global.playeractive then
    global.playeractive = {}
  end
  if not global.active_playtime then
    global.active_playtime = {}
  end
  if not global.blueprint_throttle then
    global.blueprint_throttle = {}
  end

  if not global.last_speaker_warning then
    global.last_speaker_warning = 0
  end
  if not global.last_decon_warning then
    global.last_decon_warning = 0
  end

  if not global.corpselist then
    global.corpselist = {tag = {}, tick = {}}
  end
  if not global.banishvotes then
    global.banishvotes = {
      voter = {},
      victim = {},
      reason = {},
      tick = {},
      withdrawn = {},
      overruled = {}
    }
  end
  if not global.thebanished then
    global.thebanished = {}
  end
  if not global.no_fastreplace then
    global.no_fastreplace = false
  end
end

--Create player globals, if needed
local function create_player_globals(player)
  if player and player.valid then
    if global.playeractive and player and player.index then
      if not global.playeractive[player.index] then
        global.playeractive[player.index] = false
      end

      if not global.active_playtime[player.index] then
        global.active_playtime[player.index] = 0
      end

      if not global.blueprint_throttle[player.index] then
        global.blueprint_throttle[player.index] = 0
      end

      if not global.thebanished[player.index] then
        global.thebanished[player.index] = 0
      end
    end
  end
end

--Flag player as currently active
local function set_player_active(player)
  if (player and player.valid and player.connected and player.character and player.character.valid and global.playeractive) then
    --banished players don't get activity score
    if is_banished(player) == false then
      global.playeractive[player.index] = true
    end
  end
end

--Set our default game-settings
local function game_settings(player)
  if player and player.valid and player.force and not global.gset then
    global.gset = true --Only apply these once
    player.force.friendly_fire = false --friendly fire
    player.force.research_queue_enabled = true --nice to have
    game.disable_replay() --Smaller saves, prevent desync on script upgrade
  end
end

--Automatically promote users to higher levels
local function get_permgroup()
  if game.connected_players then
    --Check all connected players
    for _, player in pairs(game.connected_players) do
      if (player and player.valid) then
        --Check if groups are valid
        if (global.defaultgroup and global.membersgroup and global.regularsgroup and global.adminsgroup) then
          if player.permission_group then
            --(ADMINS) Check if they are in the right group, including se-remote-view
            if (player.admin and player.permission_group.name ~= global.adminsgroup.name and player.permission_group.name ~= global.adminsgroup.name .. "_satellite") then
              --(REGULARS) Check if they are in the right group, including se-remote-view
              global.adminsgroup.add_player(player)
              message_all(player.name .. " moved to Admins group")
            elseif (global.active_playtime and global.active_playtime[player.index] and global.active_playtime[player.index] > (4 * 60 * 60 * 60) and not player.admin) then
              --Check if player has hours for regulars status, but isn't a in regulars group.
              if (player.permission_group.name ~= global.regularsgroup.name and player.permission_group.name ~= global.regularsgroup.name .. "_satellite") then
                global.regularsgroup.add_player(player)
                message_all(player.name .. " is now a regular!")
                smart_print(player, "[color=red](SYSTEM) You have been active enough, that you have been promoted to the 'Regulars' group![/color]")
                smart_print(player, "[color=red](SYSTEM) You now have access to our 'Regulars' Discord role, and can get access to regulars-only Factorio servers, and Discord channels.[/color]")
                smart_print(player, "[color=red](SYSTEM) Find out more on our Discord server, the link can be copied from the text in the top-left of your screen.[/color]")
                smart_print(player, "[[color=red](SYSTEM) Select text with mouse, then press control-c. Or, just visit https://m45sci.xyz/[/color]")
              end
            elseif (global.active_playtime and global.active_playtime[player.index] and global.active_playtime[player.index] > (30 * 60 * 60) and not player.admin) then
              --Check if player has hours for members status, but isn't a in member group.
              if is_regular(player) == false and is_member(player) == false and is_new(player) == true then
                global.membersgroup.add_player(player)
                message_all(player.name .. " is now a member!")
                smart_print(player, "[color=red](SYSTEM) You have been active enough, that the restrictions on your character have been lifted.[/color]")
                smart_print(player, "[color=red](SYSTEM) You now have access to our 'Members' Discord role![/color]")
                smart_print(player, "[color=red](SYSTEM) Find out more on our Discord server, the link can be copied from the text in the top-left of your screen.[/color]")
                smart_print(player, "[color=red](SYSTEM) Select text with mouse, then press control-c. Or, just visit https://m45sci.xyz/[/color]")
              end
            end
          end
        end
      end
    end
  end
end

--Show players online to a player
function show_players(victim)
  local buf = ""
  local count = 0

  --Cleaned up 12-2020
  for i, target in pairs(global.player_list) do
    buf = buf .. string.format("~%16s: - Score: %d - Online: %dm - (%s)\n", target.victim.name, math.floor(target.score / 60 / 60), math.floor(target.time / 60 / 60), target.type)
  end
  --No one is online
  if global.player_count == 0 then
    smart_print(victim, "No players online.")
  else
    smart_print(victim, "Players Online: " .. global.player_count .. "\n" .. buf)
  end
end

function g_report(player, report)
  if player and player.valid and report then
    --Init limit list if needed
    if not global.reportlimit then
      global.reportlimit = {}
    end

    --Add or init player's limit
    if global.reportlimit[player.index] then
      global.reportlimit[player.index] = global.reportlimit[player.index] + 1
    else
      global.reportlimit[player.index] = 1
    end

    --Limit and list number of reports
    if global.reportlimit[player.index] <= 5 then
      print("[REPORT] " .. player.name .. " " .. report)
      smart_print(player, "Report sent! You have now used " .. global.reportlimit[player.index] .. " of your 5 available reports.")
    else
      smart_print("You are not allowed to send any more reports.")
    end
  else
    smart_print(player, "Usage: /report (your message to moderators here)")
  end
end

function g_banish(player, victim, reason)
  if player and player.valid then
    --Regulars/admins only
    if is_regular(player) or player.admin then
      --Must have arguments
      if victim and reason then
        if victim.name == player.name then
          smart_print(player, "You can't banish yourself. Have you considered therapy?")
          return
        end

        if string.len(reason) < 4 then
          smart_print(player, "You must supply a more descriptive complaint.")
          return
        else
          --Must have valid victim
          if victim and victim.valid and victim.character and victim.character.valid then
            --Victim must be new or member
            if is_new(victim) or is_member(victim) then
              --Check if we already voted against them
              if global.banishvotes and global.banishvotes ~= {} then
                local votecount = 1
                for _, vote in pairs(global.banishvotes) do
                  if vote and vote.voter and vote.victim then
                    --Count player's total votes, cap them
                    if vote.voter == player then
                      votecount = votecount + 1
                    end
                    --Limit number of votes player gets
                    if votecount >= 5 then
                      smart_print(player, "You have exhausted your voting privilege for this map.")
                      return
                    end

                    --Can't vote twice
                    if vote.voter == player and vote.victim == victim then
                      smart_print(player, "You already voted against them!")
                      smart_print(player, "/unbanish <player> to withdraw your vote.")
                      smart_print(player, "[color=red](WARNING) If you withdraw a vote, you CAN NOT reintroduce it.[/color]")
                      return
                    end
                  end
                end

                --Send report to discord and add to vote list
                local message = "[color=red](SYSTEM) " .. player.name .. " voted to banish: " .. victim.name .. " for: " .. reason .. "[/color]"
                message_all(message)
                print("[REPORT] " .. message)
                smart_print(player, "(SYSTEM): Your vote has been added, and posted on Discord!")
                smart_print(player, "/unbanish <player> to withdraw your vote.")
                smart_print(player, "[color=red](WARNING) If you withdraw a vote, you CAN NOT reintroduce it.[/color]")
                smart_print(player, "You have used " .. votecount .. " of your 5 available votes.")
              end

              --Init if needed
              if not global.banishvotes then
                global.banishvotes = {
                  voter = {},
                  victim = {},
                  reason = {},
                  tick = {},
                  withdrawn = {},
                  overruled = {}
                }
              end
              table.insert(
                global.banishvotes,
                {
                  voter = player,
                  victim = victim,
                  reason = reason,
                  tick = game.tick,
                  withdrawn = false,
                  overruled = false
                }
              )
              update_banished_votes() --Must do this to add to tally
            else
              smart_print(player, "You can only vote against new players, or members!")
            end
          else
            smart_print(player, "There are no players online by that name.")
          end
        end
      else
        smart_print(player, "Usage: /banish <player> <reason for banishment>")
      end
    else
      smart_print(player, "This command is for regulars-status players and admins only!")
      return
    end
  else
    smart_print(nil, "The console can't vote.")
  end
end

--Custom commands
script.on_load(
  function()
    --Only add if no commands yet
    if (not commands.commands.server_interface) then
      --adjust run speed
      commands.add_command(
        "run",
        "<float> (0 is normal speed)",
        function(param)
          local player
          local victim

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player and player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          if player and player.valid then
            if player.character and player.character.valid then
              if tonumber(param.parameter) then
                local speed = tonumber(param.parameter)

                --Factorio doesn't like speeds less than -1
                if speed < -0.99 then
                  speed = -0.99
                end

                --Cap to reasonable amount
                if speed > 1000 then
                  speed = 1000
                end

                player.character.character_running_speed_modifier = speed
              else
                smart_print(player, "Numbers only.")
              end
            else
              smart_print(player, "Can't set walk speed, because you don't have a body.")
            end
          else
            smart_print(player, "The console can't walk...")
          end
        end
      )

      --turn invincible
      commands.add_command(
        "immortal",
        "optional: <name> (toggle player immortality, default self)",
        function(param)
          local player
          local victim

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player and player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          local target = player

          if param and param.parameter then
            victim = game.players[param.parameter]
          end

          if victim and victim.valid then
            target = victim
          end

          if target and target.valid then
            if target.character and target.character.valid then
              if target.character.destructible then
                target.character.destructible = false
                smart_print(player, target.name .. " is now immortal.")
              else
                target.character.destructible = true
                smart_print(player, target.name .. " is now mortal.")
              end
            else
              smart_print(player, "They don't have a body right now.")
            end
          else
            smart_print(player, "Couldn't find a player by that name.")
          end
        end
      )

      --change new player restrictions
      commands.add_command(
        "restrict",
        "change player restrictions",
        function(param)
          local player

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player and player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          --Process argument
          if not param.parameter then
            smart_print(player, "options: on, off, perms, fast, nofast")
            return
          elseif param.parameter == "perms" then
            global.setperms = false
            set_perms()

            smart_print(player, "New player perms-restrictions set.")
            return
          elseif param.parameter == "off" then
            global.restrict = false
            smart_print(player, "New player restrictions disabled.")
            return
          elseif param.parameter == "on" then
            global.restrict = true
            smart_print(player, "New player restrictions enabled.")
            return
          elseif param.parameter == "fast" then
            global.no_fastreplace = false
            smart_print(player, "New player fast-replace is now allowed.")
            return
          elseif param.parameter == "nofast" then
            global.no_fastreplace = true
            smart_print(player, "New player fast-replace is no longer allowed.")
            return
          end
          create_player_globals()
        end
      )

      --game tick
      commands.add_command(
        "gt",
        "(Shows game tick)",
        function(param)
          local player

          if param and param.player_index then
            player = game.players[param.player_index]
          end

          smart_print(player, "[GT] " .. game.tick)
        end
      )

      --Damn them!
      commands.add_command(
        "damn",
        "<player>\n(sends player to hell, tfrom <player> to teleport them back out.)",
        function(param)
          local player

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player and player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          --Handle console too
          if (player and player.admin) or (not player) then
            if game.surfaces["hell"] == nil then
              local my_map_gen_settings = {
                width = 100,
                height = 100,
                default_enable_all_autoplace_controls = false,
                property_expression_names = {cliffiness = 0},
                autoplace_settings = {
                  tile = {
                    settings = {
                      ["sand-1"] = {
                        frequency = "normal",
                        size = "normal",
                        richness = "normal"
                      }
                    }
                  }
                },
                starting_area = "none"
              }
              game.create_surface("hell", my_map_gen_settings)
            end

            --Only if name provided
            if param.parameter then
              local victim = game.players[param.parameter]

              if (victim and victim.valid and victim.character and victim.character.valid) then
                --If they have a character, kill it to release items
                if victim.character and victim.character.valid then
                  victim.character.die("player")
                end
                if not global.send_to_surface then
                  global.send_to_surface = {}
                end
                table.insert(global.send_to_surface, {victim = victim, surface = "hell", position = {0, 0}})
              else
                smart_print(player, "Couldn't find that player.")
              end
            end
          else
            smart_print(player, "Admins only.")
          end
        end
      )
      --Admin vote overrrule
      commands.add_command(
        "overrule",
        "<defendant>\n(overrule votes against defendant)\n<clear>\n(clear all votes, will unbanish all)",
        function(param)
          if param and param.player_index then
            local player = game.players[param.player_index]

            --Admins only
            if (player and player.admin) then
              if global.banishvotes then
                --get arguments
                local args = mysplit(param.parameter, " ")

                --Must have arguments
                if args ~= {} and args[1] then
                  if args[1] == "clear" then
                    global.banishvotes = nil
                    smart_print(player, "All votes cleared.")
                    update_banished_votes()
                    return
                  end
                  local victim = game.players[args[1]]

                  --If victim found
                  if victim and victim.valid and victim.character and victim.character.valid then
                    local count = 0
                    for _, vote in pairs(global.banishvotes) do
                      if vote and vote.victim and vote.victim.valid then
                        if vote.victim == victim and vote.overruled == false then
                          vote.overruled = true
                          count = count + 1
                        end
                      end
                    end
                    if count > 0 then
                      smart_print(player, "Overruled " .. count .. " votes against " .. victim.name)
                    else
                      for _, vote in pairs(global.banishvotes) do
                        if vote and vote.victim and vote.victim.valid then
                          if vote.victim == victim and vote.overruled == true then
                            vote.overruled = false
                            count = count + 1
                          end
                        end
                      end
                      smart_print(player, "Withdrew " .. count .. " overrulings, against " .. victim.name)
                    end
                    update_banished_votes()
                    return
                  else
                    smart_print(player, "Couldn't find a player by that name.")
                  end
                else
                  smart_print(player, "Who do you want to overrule votes against? <player> or <clear> (clears/unbanishes all)")
                end
              else
                smart_print(player, "There are no votes to overrule.")
              end
            else
              smart_print(player, "Admins only.")
            end
          end
        end
      )

      --Print votes
      commands.add_command(
        "votes",
        "(Shows banish votes)",
        function(param)
          if param and param.player_index then
            local player = game.players[param.player_index]

            --Only if banish data found
            if global.banishvotes then
              --Print votes
              local pcount = 0
              for _, vote in pairs(global.banishvotes) do
                if vote and vote.voter and vote.voter.valid and vote.victim and vote.victim.valid then
                  local notes = ""
                  if vote.withdrawn then
                    notes = "(WITHDRAWN) "
                  end
                  if vote.overruled then
                    notes = "(OVERRULED) "
                  end
                  pcount = pcount + 1
                  smart_print(player, notes .. "plaintiff: " .. vote.voter.name .. ", defendant: " .. vote.victim.name .. ", complaint:\n" .. vote.reason)
                end
              end

              --Tally votes before proceeding
              update_banished_votes()

              --Print accused
              if global.thebanished then
                for _, victim in pairs(game.players) do
                  if global.thebanished[victim.index] and global.thebanished[victim.index] > 1 then
                    smart_print(player, victim.name .. " has had " .. global.thebanished[victim.index] .. " complaints against them.")
                    pcount = pcount + 1
                  end
                end
              end
              --Show summery of votes against them
              if global.banishvotes then
                for _, victim in pairs(game.players) do
                  local votecount = 0
                  for _, vote in pairs(global.banishvotes) do
                    if victim == vote.voter then
                      votecount = votecount + 1
                    end
                  end
                  if votecount > 2 then
                    smart_print(player, victim.name .. " has voted against " .. votecount .. " players.")
                    pcount = pcount + 1
                  end
                end
              end
              --Nothing found, report it
              if pcount <= 0 then
                smart_print(player, "The docket is clean.")
              end
              return
            else
              --No vote data
              smart_print(player, "The docket is clean.")
              update_banished_votes()
              return
            end
          end
        end
      )

      --Banish command
      commands.add_command(
        "unbanish",
        "<player>\n(Withdraws a banish vote)",
        function(param)
          if param and param.player_index then
            local player = game.players[param.player_index]
            if player and param.parameter then
              --regulars/admin players only
              if is_regular(player) or player.admin then
                --get arguments
                local args = mysplit(param.parameter, " ")

                --Must have arguments
                if args ~= {} and args[1] then
                  local victim = game.players[args[1]]

                  --Must have valid victim
                  if victim and victim.valid and victim.character and victim.character.valid then
                    --Check if we voted against them
                    if global.banishvotes and global.banishvotes ~= {} then
                      for _, vote in pairs(global.banishvotes) do
                        if vote and vote.voter and vote.victim then
                          if vote.voter == player and vote.victim == victim then
                            --Send report to discord and withdraw vote
                            local message = "[color=red](SYSTEM) " .. player.name .. " WITHDREW their vote to banish: " .. victim.name .. "[/color]"
                            message_all(message)
                            print("[REPORT] " .. message)
                            smart_print(player, "Your vote has been withdrawn, and posted on Discord.")
                            vote.withdrawn = true
                            update_banished_votes() --Must do this to delete from tally
                            return
                          end
                        end
                      end
                      smart_print(player, "I don't see a vote from you, against that player, to withdraw.")
                    end
                  else
                    smart_print(player, "There are no players online by that name.")
                  end
                else
                  smart_print(player, "Usage: /unbanish <player>")
                end
              else
                smart_print(player, "Only regulars/admin status players can vote.")
                return
              end
            else
              smart_print(player, "Usage: /unbanish <player>")
            end
          else
            smart_print(nil, "The console can't vote.")
          end
        end
      )

      --Banish command
      commands.add_command(
        "banish",
        "<player> <reason for banishment>\n(Sends player to a confined area, off-map)",
        function(param)
          if param and param.player_index then
            local player = game.players[param.player_index]

            if not param.parameter then
              smart_print(player, "Banish who?")
              return
            end
            local args = mysplit(param.parameter, " ")
            if not args[2] then
              smart_print(player, "You must specify a reason.")
              return
            end
            local victim = game.players[args[1]]

            --Quick arg combine
            local reason = args[2]
            for n, arg in pairs(args) do
              if n > 2 and n < 100 then -- at least two words, max 100
                reason = reason .. " " .. args[n]
              end
            end

            g_banish(player, victim, reason)
          end
        end
      )

      --User report command
      commands.add_command(
        "report",
        "<detailed report here>\n(Sends in a report to the moderators)",
        function(param)
          if param and param.player_index then
            local player = game.players[param.player_index]
            g_report(player, param.parameter)
          else
            smart_print(nil, "The console doesn't need to send in reports this way.")
          end
        end
      )

      --register command
      commands.add_command(
        "register",
        "<code>\n(Requires a registration code)",
        function(param)
          if param and param.player_index then
            local player = game.players[param.player_index]

            --Only if arguments
            if param.parameter and player and player.valid then
              --Init global if needed
              if not global.access_count then
                global.access_count = {}
              end

              --Init player if needed, else add to
              if not global.access_count[player.index] then
                global.access_count[player.index] = 1
              else
                if global.access_count[player.index] > 3 then
                  smart_print(player, "You have exhausted your registration attempts.")
                  return
                end
                global.access_count[player.index] = global.access_count[player.index] + 1
              end

              local ptype = "Error"

              if player.admin then
                ptype = "admin"
              elseif is_regular(player) then
                ptype = "regular"
              elseif is_member(player) then
                ptype = "trusted"
              else
                ptype = "normal"
              end

              --Send to ChatWire
              print("[ACCESS] " .. ptype .. " " .. player.name .. " " .. param.parameter)
              smart_print(player, "Sending registration code...")
              return
            end
            smart_print(player, "You need to provide a registration code!")
            return
          end
          smart_print(nil, "I don't think the console needs to use this command...")
        end
      )

      --softmod version
      commands.add_command(
        "sversion",
        "(Shows soft-mod version)",
        function(param)
          local player

          if param and param.player_index then
            player = game.players[param.player_index]
          end

          smart_print(player, svers)
        end
      )

      --Server name
      commands.add_command(
        "cname",
        "<name here>\n(Names the factorio server)",
        function(param)
          --Admins only
          if param and param.player_index then
            local player = game.players[param.player_index]
            if not player.admin then
              smart_print(player, "This command is for console and admin use only.")
              return
            end
          end

          --
          --Clear limbo surfaces on reboot, just in case
          --Could actually cause desync if run by admin with very bad timing.
          --
          if param.parameter then
            --Get limbo surface
            local surf = game.surfaces["limbo"]

            --Check if surface is valid
            if surf and surf.valid then
              --Clear surface
              surf.clear()
              console_print("Limbo surface cleared.")
            end

            global.servname = param.parameter
            global.drawlogo = false
            dodrawlogo()

            global.servers = nil
            global.ports = nil
            create_myglobals()

            set_perms()
          end
        end
      )

      --Server chat
      commands.add_command(
        "cchat",
        "<message here>\n(Used for Discord bridge)",
        function(param)
          --Console only, no players
          if param and param.player_index then
            local player = game.players[param.player_index]
            smart_print(player, "This command is for console use only.")
            return
          end

          if param.parameter then
            message_allp(param.parameter)
          end
        end
      )

      --Server whisper
      commands.add_command(
        "cwhisper",
        "<message here>\n(Used for Discord Bridge)",
        function(param)
          --Console only, no players
          if param and param.player_index then
            local player = game.players[param.player_index]
            smart_print(player, "This command is for console use only.")
            return
          end

          --Must have arguments
          if param.parameter then
            local args = mysplit(param.parameter, " ")

            --Require two args
            if args ~= {} and args[1] and args[2] then
              --Find player
              for _, player in pairs(game.connected_players) do
                if player.name == args[1] then
                  args[1] = ""
                  smart_print(player, table.concat(args, " "))
                  return
                end
              end
            end
          end
        end
      )

      --Reset players's time and status
      commands.add_command(
        "reset",
        "<player>\n(Set player to NEW)",
        function(param)
          local player

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player and player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          --Argument needed
          if param.parameter then
            local victim = game.players[param.parameter]

            if victim and victim.valid then
              if global.active_playtime and global.active_playtime[victim.index] then
                global.active_playtime[victim.index] = 0
                if victim and victim.valid and global.defaultgroup then
                  global.defaultgroup.add_player(victim)
                end
                smart_print(player, "Player set to 0.")
                return
              end
            end
          end
          smart_print(player, "Player not found.")
        end
      )

      --Trust player
      commands.add_command(
        "member",
        "<player>\n(Makes the player a member)",
        function(param)
          local player

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          --Argument required
          if param.parameter then
            local victim = game.players[param.parameter]

            if (victim) then
              if victim and victim.valid and global.membersgroup then
                smart_print(player, "Player given members status.")
                global.membersgroup.add_player(victim)
                return
              end
            end
          end
          smart_print(player, "Player not found.")
        end
      )

      --Set player to regular
      commands.add_command(
        "regular",
        "<player>\n(Makes the player a regular)",
        function(param)
          local player

          --Admins only
          if param and param.player_index then
            player = game.players[param.player_index]
            if player and player.admin == false then
              smart_print(player, "Admins only.")
              return
            end
          end

          --Argument required
          if param.parameter then
            local victim = game.players[param.parameter]

            if (victim) then
              if victim and victim.valid and global.regularsgroup then
                smart_print(player, "Player given regulars status.")
                global.regularsgroup.add_player(victim)
                return
              end
            end
          end
          smart_print(player, "Player not found.")
        end
      )

      --Change default spawn point
      commands.add_command(
        "cspawn",
        "<x,y> (OPTIONAL)\n(Sets spawn point to <x,y>, or where admin is standing)",
        function(param)
          local victim
          local new_pos_x = 0.0
          local new_pos_y = 0.0

          --Admins only
          if param and param.player_index then
            victim = game.players[param.player_index]

            if victim and victim.admin == false then
              smart_print(victim, "Admins only.")
              return
            end
          end

          local psurface = game.surfaces[1]
          local pforce = game.forces["player"]

          --use admin's force and position if available.
          if victim and victim.valid then
            pforce = victim.force

            new_pos_x = victim.position.x
            new_pos_y = victim.position.y
          end

          --Location supplied
          if param.parameter then
            local xytable = mysplit(param.parameter, ",")
            if xytable ~= {} and tonumber(xytable[1]) and tonumber(xytable[2]) then
              local argx = xytable[1]
              local argy = xytable[2]
              new_pos_x = argx
              new_pos_y = argy
            else
              smart_print(victim, "Invalid argument. /cspawn x,y. No argument uses your current location.")
              return
            end
          end

          --Set new spawn spot
          if pforce and psurface and new_pos_x and new_pos_y then
            pforce.set_spawn_position({new_pos_x, new_pos_y}, psurface)
            smart_print(victim, string.format("New spawn point set: %d,%d", math.floor(new_pos_x), math.floor(new_pos_y)))
            smart_print(victim, string.format("Force: %s", pforce.name))
            global.cspawnpos = {
              x = (math.floor(new_pos_x) + 0.5),
              y = (math.floor(new_pos_y) + 0.5)
            }

            --Set logo to be redrawn
            global.drawlogo = false
            --Redraw
            dodrawlogo()
          else
            smart_print(victim, "Couldn't find force...")
          end
        end
      )

      --Reveal map
      commands.add_command(
        "reveal",
        "<size> (OPTIONAL)\n(Reveals <size> units of the map, or 1024 by default. Min 128, Max 8192)",
        function(param)
          local victim

          --Admins only
          if param and param.player_index then
            victim = game.players[param.player_index]
            if victim and victim.admin == false then
              smart_print(victim, "Admins only.")
              return
            end
          end

          --Get surface and force
          local psurface = game.surfaces[1]
          local pforce = game.forces["player"]
          --Default size
          local size = 1024

          --Use admin's surface and force if possible
          if victim and victim.valid then
            psurface = victim.surface
            pforce = victim.force
          end

          --If size specified
          if param.parameter then
            if tonumber(param.parameter) then
              local rsize = tonumber(param.parameter)

              --Limit size of area
              if rsize > 0 then
                if rsize < 128 then
                  rsize = 128
                else
                  if rsize > 8192 then
                    rsize = 8192
                  end
                  size = rsize
                end
              end
            else
              smart_print(victim, "Numbers only.")
              return
            end
          end

          --Chart the area
          if psurface and pforce and size then
            pforce.chart(
              psurface,
              {
                lefttop = {x = -size / 2, y = -size / 2},
                rightbottom = {x = size / 2, y = size / 2}
              }
            )
            local sstr = math.floor(size)
            smart_print(victim, "Revealing " .. sstr .. "x" .. sstr .. " tiles")
          else
            smart_print(victim, "Invalid force or surface.")
          end
        end
      )

      --Rechart map
      commands.add_command(
        "rechart",
        "(Refreshes all chunks that exist)",
        function(param)
          local victim

          --Admins only
          if param and param.player_index then
            victim = game.players[param.player_index]
            if victim and victim.admin == false then
              smart_print(victim, "Admins only.")
              return
            end
          end

          local pforce = game.forces["player"]

          --Use admin's force
          if victim and victim.valid then
            pforce = victim.force
          end

          if pforce then
            pforce.clear_chart()
            smart_print(victim, "Recharting map...")
          else
            smart_print(victim, "Couldn't find force.")
          end
        end
      )

      --Online
      commands.add_command(
        "online",
        "(See who is online)",
        function(param)
          local victim

          if param and param.player_index then
            victim = game.players[param.player_index]
          end
          show_players(victim)
        end
      )

      --Game speed
      commands.add_command(
        "gspeed",
        "<x.x>\n(Changes game speed)\nDefault speed: 1.0 (60 UPS), Min 0.1 (6 UPS), Max  10.0 (600 UPS)",
        function(param)
          local player

          if param and param.player_index then
            player = game.players[param.player_index]
          end

          --Admins only
          if player and player.admin == false then
            smart_print(player, "Admins only.")
            return
          end

          --Need argument
          if (not param.parameter) then
            smart_print(player, "But what speed? 0.1 to 10")
            return
          end

          --Decode arg
          if tonumber(param.parameter) then
            local value = tonumber(param.parameter)

            --Limit speed range
            if (value >= 0.1 and value <= 10.0) then
              game.speed = value

              --Get default force
              local pforce = game.forces["player"]

              --Use admin's force
              if victim and victim.valid then
                pforce = player.force
              end

              --If force found
              if pforce then
                --Calculate walk speed for UPS
                pforce.character_running_speed_modifier = ((1.0 / value) - 1.0)
                smart_print(player, "Game speed: " .. value .. " Walk speed: " .. pforce.character_running_speed_modifier)

                --Don't show message if run via console (ChatWire)
                if (player) then
                  message_all("Game speed set to " .. (game.speed * 100.00) .. "%")
                end
              else
                smart_print(player, "Couldn't find a valid force")
              end
            else
              smart_print(player, "That doesn't seem like a good idea...")
            end
          else
            smart_print(player, "Numbers only.")
          end
        end
      )

      --Teleport to
      commands.add_command(
        "tto",
        "<player> -- teleport to <player>",
        function(param)
          --No console :P
          if not param.player_index then
            smart_print(nil, "You want me to teleport a remote console somewhere???")
            return
          end
          local player = game.players[param.player_index]

          --Admin only
          if (player and player.valid and player.connected and player.character and player.character.valid) then
            if (player.admin == false) then
              smart_print(player, "Admins only.")
              return
            end

            --Argument required
            if param.parameter then
              local victim = game.players[param.parameter]

              if (victim and victim.valid) then
                local newpos = victim.surface.find_non_colliding_position("character", victim.position, 100, 0.1, false)
                if (newpos) then
                  player.teleport(newpos, victim.surface)
                  smart_print(player, "*Poof!*")
                else
                  smart_print(player, "Area appears to be full.")
                  console_print("error: tto: unable to find non_colliding_position.")
                end
                return
              end
            end
            smart_print(player, "Teleport to who?")
          end
        end
      )

      --Teleport x,y
      commands.add_command(
        "tp",
        "<x,y> -- teleport to <x,y>",
        function(param)
          --No console :P
          if not param.player_index then
            smart_print(nil, "You want me to teleport a remote console somewhere???")
            return
          end
          local player = game.players[param.player_index]

          --Admins only
          if (player and player.valid and player.connected and player.character and player.character.valid) then
            if (player.admin == false) then
              smart_print(player, "Admins only.")
              return
            end

            local surface = player.surface

            --Argument required
            if param.parameter then
              local str = param.parameter
              local xpos = "0.0"
              local ypos = "0.0"

              --Find surface from argument
              local n = game.surfaces[param.parameter]
              if n then
                surface = n
                local position = {x = xpos, y = ypos}
                local newpos = surface.find_non_colliding_position("character", position, 100, 0.1, false)
                if newpos then
                  player.teleport(newpos, surface)
                  return
                else
                  player.teleport(position, surface)
                  console_print("error: tp: unable to find non_colliding_position.")
                end
              end

              --Find x/y from argument
              xpos,
                ypos = str:match("([^,]+),([^,]+)")
              if tonumber(xpos) and tonumber(ypos) then
                local position = {x = xpos, y = ypos}

                if position then
                  if position.x and position.y then
                    local newpos = surface.find_non_colliding_position("character", position, 100, 0.1, false)
                    if (newpos) then
                      player.teleport(newpos, surface)
                      smart_print(player, "*Poof!*")
                    else
                      smart_print(player, "Area appears to be full.")
                      console_print("error: tp: unable to find non_colliding_position.")
                    end
                  else
                    smart_print(player, "Invalid location.")
                  end
                end
                return
              else
                smart_print(player, "Numbers only.")
              end
            end
            smart_print(player, "Teleport where? x,y or surface name")
          end
        end
      )

      --Teleport player to me
      commands.add_command(
        "tfrom",
        "<player> -- teleport <player> to me",
        function(param)
          --No console :P
          if not param.player_index then
            smart_print(nil, "You want me to teleport a remote console somewhere???")
            return
          end
          local player = game.players[param.player_index]

          --Admins only
          if (player and player.valid and player.connected and player.character and player.character.valid) then
            if (player.admin == false) then
              smart_print(player, "Admins only.")
              return
            end

            --Argument required
            if param.parameter then
              local victim = game.players[param.parameter]

              if (victim and victim.valid) then
                local newpos = player.surface.find_non_colliding_position("character", player.position, 100, 0.1, false)
                if (newpos) then
                  victim.teleport(newpos, player.surface)
                  smart_print(player, "*Poof!*")
                else
                  smart_print(player, "Area appears to be full.")
                  console_print("error: tfrom: unable to find non_colliding_position.")
                end
              else
                smart_print(player, "Who do you want to teleport to you?")
              end
            end
          end
        end
      )
    end
  end
)

--EVENTS--
--Command logging
local function on_console_command(event)
  if event and event.command and event.parameters then
    local command = ""
    local args = ""

    if event.command then
      command = event.command
    end

    if event.parameters then
      args = event.parameters
    end

    if event.player_index then
      local player = game.players[event.player_index]
      print(string.format("[CMD] NAME: %s, COMMAND: %s, ARGS: %s", player.name, command, args))
    elseif command ~= "time" and command ~= "online" and command ~= "server-save" then --Ignore spammy console commands
      print(string.format("[CMD] NAME: CONSOLE, COMMAND: %s, ARGS: %s", command, args))
    end
  end
end

--Deconstruction planner warning
local function on_player_deconstructed_area(event)
  if event and event.player_index and event.area then
    local player = game.players[event.player_index]
    local area = event.area

    if player and area and area.left_top then
      --Don't bother if selection is zero.
      if area.left_top == area.right_bottom.x and area.left_top.y == area.right_bottom.y then
        local msg = player.name .. " decon [gps=" .. math.floor(area.left_top.x) .. "," .. math.floor(area.left_top.y) .. "] to [gps=" .. math.floor(area.right_bottom.x) .. "," .. math.floor(area.right_bottom.y) .. "]"
        console_print(msg)

        if is_new(player) or is_member(player) then --Dont bother with regulars/admins
          if (global.last_decon_warning and game.tick - global.last_decon_warning >= 60) then
            global.last_decon_warning = game.tick
            message_all("[color=red](SYSTEM)" .. msg .. "[/color]")
          end
        end
      end
    end
  end
end

--Player connected, make variables, draw UI, set permissions, and game settings
local function on_player_joined_game(event)
  update_player_list() --online.lua

  --Gui stuff
  if event and event.player_index then
    local player = game.players[event.player_index]
    if player then
      create_myglobals()
      create_player_globals(player)
      create_groups()
      game_settings(player)
      set_perms()
      get_permgroup()

      --Delete old UIs (migrate old saves)
      if player.gui.top.dicon then
        player.gui.top.dicon.destroy()
      end
      if player.gui.top.discordurl then
        player.gui.top.discordurl.destroy()
      end
      if player.gui.top.zout then
        player.gui.top.zout.destroy()
      end
      if player.gui.top.serverlist then
        player.gui.top.serverlist.destroy()
      end
      if player.gui.center.dark_splash then
        player.gui.center.dark_splash.destroy()
      end
      if player.gui.center.splash_screen then
        player.gui.center.splash_screen.destroy()
      end

      dodrawlogo() --logo.lua

      if player.gui and player.gui.top then
        make_info_button(player) --info.lua
        make_online_button(player) --online.lua
      end

      if is_new(player) then
        make_m45_online_window(player) --online.lua
        make_m45_info_window(player) --info.lua
      end
    end
  end
end

--Player disconnect messages, with reason (Fact >= v1.1)
local function on_player_left_game(event)
  update_player_list() --online.lua

  if event and event.player_index and event.reason then
    local player = game.players[event.player_index]
    if player and player.valid then
      local reason = {
        "(Quit)",
        "(Dropped)",
        "(Reconnecting)",
        "(WRONG INPUT)",
        "(TOO MANY DESYNC)",
        "(CPU TOO SLOW!!!)",
        "(AFK)",
        "(KICKED)",
        "(KICKED AND DELETED)",
        "(BANNED)",
        "(Switching servers)",
        "(Unknown)"
      }
      message_alld(player.name .. " disconnected. " .. reason[event.reason + 1])
    end
  end
end

--New player created, insert items set perms, show players online, welcome to map.
local function on_player_created(event)
  if event and event.player_index then
    local player = game.players[event.player_index]
    if player and player.valid then
      player.insert {name = "iron-plate", count = 8}
      player.insert {name = "wood", count = 1}
      player.insert {name = "pistol", count = 1}
      player.insert {name = "firearm-magazine", count = 10}
      player.insert {name = "burner-mining-drill", count = 1}
      player.insert {name = "stone-furnace", count = 1}

      set_perms()
      show_players(player)
      message_all("[color=green](SYSTEM) Welcome " .. player.name .. " to the map![/color]")
    end
  end
end

--Build stuff -- activity
local function on_built_entity(event)
  if event and event.player_index and event.created_entity and event.stack then
    local player = game.players[event.player_index]
    local created_entity = event.created_entity
    local stack = event.stack

    if player and player.valid then
      --Blueprint safety
      if stack and stack.valid and stack.valid_for_read and stack.is_blueprint then
        local count = stack.get_blueprint_entity_count()

        --Add item to blueprint throttle, (new) 5 items a second
        if is_new(player) and global.restrict then
          if global.blueprint_throttle and global.blueprint_throttle[player.index] then
            global.blueprint_throttle[player.index] = global.blueprint_throttle[player.index] + 12
          end
        end

        --Silently destroy blueprint items, if blueprint is too big
        if player.admin then
          return
        elseif is_new(player) and count > 500 and global.restrict then
          if created_entity then
            created_entity.destroy()
          end
          stack.clear()
          return
        elseif count > 10000 then
          if created_entity then
            created_entity.destroy()
          end
          stack.clear()
          return
        end
      end

      if created_entity and created_entity.valid then
        if created_entity.name == "programmable-speaker" then
          console_print(player.name .. " placed a speaker at [gps=" .. math.floor(created_entity.position.x) .. "," .. math.floor(created_entity.position.y) .. "]")
          global.last_speaker_warning = game.tick

          if (global.last_speaker_warning and game.tick - global.last_speaker_warning >= 30) then
            if player.admin == false then --Don't bother with admins
              message_all("[color=red](SYSTEM) " .. player.name .. " placed a speaker at [gps=" .. math.floor(created_entity.position.x) .. "," .. math.floor(created_entity.position.y) .. "][/color]")
              global.last_speaker_warning = game.tick
            end
          end
        end
      end

      if created_entity.name ~= "tile-ghost" and created_entity.name ~= "tile" then
        if created_entity.name == "entity-ghost" then
          --Log item placement
          console_print(player.name .. " +ghost " .. created_entity.ghost_name .. " [gps=" .. math.floor(created_entity.position.x) .. "," .. math.floor(created_entity.position.y) .. "]")
        else
          --Log item placement
          console_print(player.name .. " +" .. created_entity.name .. " [gps=" .. math.floor(created_entity.position.x) .. "," .. math.floor(created_entity.position.y) .. "]")
        end
      end
    end
  end
end

--Cursor stack, block huge blueprints
local function on_player_cursor_stack_changed(event)
  if event and event.player_index then
    local player = game.players[event.player_index]

    if player and player.valid then
      if player.cursor_stack then
        local stack = player.cursor_stack
        if stack and stack.valid and stack.valid_for_read and stack.is_blueprint then
          local count = stack.get_blueprint_entity_count()

          --blueprint throttle if needed
          if not player.admin and global.restrict then
            if global.blueprint_throttle and global.blueprint_throttle[player.index] then
              if global.blueprint_throttle[player.index] > 0 then
                console_print(player.name .. " wait " .. round(global.blueprint_throttle[player.index] / 60, 2) .. "s to bp")
                smart_print(player, "[color=red](SYSTEM) You are blueprinting too quickly. You must wait " .. round(global.blueprint_throttle[player.index] / 60, 2) .. " seconds before blueprinting again.[/color]")
                player.insert(player.cursor_stack)
                stack.clear()
                return
              end
            end
          end
          if player.admin then
            return
          elseif is_new(player) and count > 500 and global.restrict then --new player limit
            console_print(player.name .. " tried to bp " .. count .. " items (DELETED).")
            smart_print(player, "[color=red](SYSTEM) You aren't allowed to use blueprints that large yet.[/color]")
            stack.clear()
            return
          elseif count > 10000 then --lag protection
            console_print(player.name .. " tried to bp " .. count .. " items (DELETED).")
            smart_print(player, "[color=red](SYSTEM) That blueprint is too large![/color]")
            stack.clear()
            return
          end
        end
      end
    end
  end
end

--Pre-Mined item, block some users
local function on_pre_player_mined_item(event)
  --Sanity check
  if event and event.player_index and event.entity then
    local player = game.players[event.player_index]
    local obj = event.entity

    if global.restrict then
      --Check player, surface and object are valid
      if player and player.valid and player.index and player.surface and player.surface.valid and obj and obj.valid then
        --New players can't mine objects that they don't own!
        if is_new(player) and obj.last_user ~= nil and obj.last_user.name ~= player.name then
          --Create limbo surface if needed
          if game.surfaces["limbo"] == nil then
            local my_map_gen_settings = {
              default_enable_all_autoplace_controls = false,
              property_expression_names = {cliffiness = 0},
              autoplace_settings = {
                tile = {
                  settings = {
                    ["sand-1"] = {
                      frequency = "normal",
                      size = "normal",
                      richness = "normal"
                    }
                  }
                }
              },
              starting_area = "none"
            }
            game.create_surface("limbo", my_map_gen_settings)
          end

          --Get surface
          local surf = game.surfaces["limbo"]

          --Check if surface is valid
          if surf and surf.valid then
            --Clone object to limbo
            local saveobj = obj.clone({position = obj.position, surface = surf, force = obj.force})

            --Check that object was able to be cloned
            if saveobj and saveobj.valid then
              local signal_wires
              local copper_wires

              --Fix wires... grr
              signal_wires = obj.circuit_connection_definitions
              if obj.type == "electric-pole" then
                copper_wires = obj.neighbours["copper"]
              end
              --game.print("SIGNALS: "..dump(signal_wires))
              --game.print("COPPER: "..dump(copper_wires))

              --Destroy original object.
              obj.destroy()

              --Create list if needed
              if not global.repobj then
                global.repobj = {
                  obj = {},
                  victim = {},
                  surface = {},
                  swires = {},
                  cwires = {}
                }
              end

              --Add obj to list
              table.insert(
                global.repobj,
                {
                  obj = saveobj,
                  victim = player,
                  surface = player.surface,
                  swires = signal_wires,
                  cwires = copper_wires
                }
              )
            else
              console_print("pre_player_mined_item: unable to clone object.")
            end
          else
            console_print("pre_player_mined_item: unable to get limbo-surface.")
          end
        else
          --Normal player, just log it
          console_print(player.name .. " -" .. obj.name .. " [gps=" .. math.floor(obj.position.x) .. "," .. math.floor(obj.position.y) .. "]")
        end
      else
        console_print("pre_player_mined_item: invalid player, obj or surface.")
      end
    end
  end
end

--Rotated item, block some users
local function on_player_rotated_entity(event)
  --Sanity check
  if event and event.player_index and event.previous_direction then
    local player = game.players[event.player_index]
    local obj = event.entity
    local prev_dir = event.previous_direction

    if global.restrict then
      --If player and object are valid
      if player and player.valid and obj and obj.valid then
        --Don't let new players rotate other players items, unrotate and untouch the item.
        if is_new(player) and obj.last_user ~= nil and obj.last_user.name ~= player.name then
          --Unrotate
          obj.direction = prev_dir

          --Create untouch list if needed
          if not global.untouchobj then
            global.untouchobj = {object = {}, prev = {}}
          end

          --Add to list
          table.insert(global.untouchobj, {object = obj, prev = obj.last_user})
          smart_print(player, "[color=red](SYSTEM) You are a new player, and are not allowed to rotate other people's objects yet![/color]")

          if player and player.valid and player.character and player.character.valid then
            player.character.damage(15, "enemy") --Little discouragement
          end
        else
          --Normal player, just log it
          console_print(player.name .. " *" .. obj.name .. " [gps=" .. math.floor(obj.position.x) .. "," .. math.floor(obj.position.y) .. "]")
        end
      end
    end
  end
end

--Create map tag -- log
local function on_chart_tag_added(event)
  if event and event.player_index then
    local player = game.players[event.player_index]

    if player and player.valid and event.tag then
      console_print(player.name .. " + tag [gps=" .. math.floor(event.tag.position.x) .. "," .. math.floor(event.tag.position.y) .. "] " .. event.tag.text)
    end
  end
end

--Edit map tag -- log
local function on_chart_tag_modified(event)
  if event and event.player_index then
    local player = game.players[event.player_index]
    if player and player.valid and event.tag then
      console_print(player.name .. " -+ tag [gps=" .. math.floor(event.tag.position.x) .. "," .. math.floor(event.tag.position.y) .. "] " .. event.tag.text)
    end
  end
end

--Delete map tag -- log
local function on_chart_tag_removed(event)
  if event and event.player_index then
    local player = game.players[event.player_index]

    if player and player.valid and event.tag then
      console_print(player.name .. "- tag [gps=" .. math.floor(event.tag.position.x) .. "," .. math.floor(event.tag.position.y) .. "] " .. event.tag.text)
    end
  end
end

--Banned -- kill player to return items
local function on_player_banned(event)
  if event and event.player_index then
    local player = game.players[event.player_index]
    if player and player.valid and player.character then
      if global.cspawnpos then
        player.teleport(global.cspawnpos)
      else
        player.teleport({0, 0})
      end
      player.character.die("player")
    end
  end
end

--Corpse Map Marker
local function on_pre_player_died(event)
  if event and event.player_index then
    local player = game.players[event.player_index]
    --Sanity check
    if player and player.valid and player.character then
      --Make map pin
      local centerPosition = player.position
      local label = ("Body of: " .. player.name)
      local chartTag = {position = centerPosition, icon = nil, text = label}
      local qtag = player.force.add_chart_tag(player.surface, chartTag)

      create_myglobals()
      create_player_globals(player)

      --Add to list of pins
      table.insert(global.corpselist, {tag = qtag, tick = game.tick})

      --Log to discord
      if event.cause and event.cause.valid then
        cause = event.cause.name
        message_all("[color=red](SYSTEM) " .. player.name .. " was killed by " .. cause .. " at [gps=" .. math.floor(player.position.x) .. "," .. math.floor(player.position.y) .. "][/color]")
      else
        message_all("[color=red](SYSTEM) " .. player.name .. " was killed at [gps=" .. math.floor(player.position.x) .. "," .. math.floor(player.position.y) .. "][/color]")
      end
    end
  end
end

--Research Finished -- discord
local function on_research_finished(event)
  if event and event.research then
    message_alld("Research " .. event.research.name .. " completed.")
  end
end

--Handle killing ,and teleporting users to other surfaces
local function on_player_respawned(event)
  --Anything queued?
  if global.send_to_surface then
    --Event and player?
    if event and event.player_index then
      local player = game.players[event.player_index]

      --Valid player?
      if player and player.valid and player.character and player.character.valid then
        local index = nil
        --Check list
        for i, item in pairs(global.send_to_surface) do
          --Check if item is valid
          if item and item.victim and item.victim.valid and item.victim.character and item.victim.character.valid and item.position and item.surface then
            --Check if names match
            if item.victim.name == player.name then
              --If surface is valid
              local surf = game.surfaces[item.surface]
              if surf and surf.valid then
                local newpos = surf.find_non_colliding_position("character", item.position, 100, 0.1, false)
                if newpos then
                  player.teleport(newpos, surf)
                else
                  player.teleport(item.position, surf) -- screw it
                  console_print("error: send_to_surface(respawn): unable to find non_colliding_position.")
                end
                index = i
                break
              end
            end
          end
        end
        --Remove item we processed
        if index then
          game.print("item removed: " .. index)
          table.remove(global.send_to_surface, index)
        end
      end
    end
  end

  if event and event.player_index then
    local player = game.players[event.player_index]
    if player and player.valid then
      player.insert {name = "firearm-magazine", count = 10}
      player.insert {name = "pistol", count = 1}
    end
  end
end

--Replace an item with a clone, from limbo
function replace_with_clone(item)
  local rep = item.obj.clone({position = item.obj.position, surface = item.surface, force = item.obj.force})

  if rep then
    if item.cwires then
      for ind, pole in pairs(item.cwires) do
        rep.connect_neighbour(pole)
      end
    end

    --If we saved signal wire data, reconnect them now
    if item.swires then
      for ind, pole in pairs(item.swires) do
        rep.connect_neighbour(pole)
      end
    end

    if rep then
      smart_print(item.victim, "[color=red](SYSTEM) You are a new player, and are not allowed to mine or replace other people's objects yet![/color]")
      if item.victim and item.victim.valid and item.victim.character and item.victim.character.valid then
        item.victim.character.damage(15, "enemy") --Little discouragement
      end
    end
  end
end

--Looping timer, 30 seconds
--delete old corpse map pins
--Check spawn area map pin
--Add to player active time if needed
--Refresh players online window

script.on_nth_tick(
  1800,
  function(event)
    update_player_list() --online.lua

    --Remove old corpse tags
    if (global.corpselist) then
      local toremove = nil
      local index = nil
      for i, corpse in pairs(global.corpselist) do
        if (corpse.tick and (corpse.tick + (15 * 60 * 60)) < game.tick) then
          if (corpse.tag and corpse.tag.valid) then
            corpse.tag.destroy()
          end
          toremove = corpse
          index = i
          break
        end
      end
      --Properly remove items
      if global.corpselist and index then
        table.remove(global.corpselist, index)
      end
    else
      create_myglobals()
    end

    --Server tag
    if (global.servertag and not global.servertag.valid) then
      global.servertag = nil
    end
    if (global.servertag and global.servertag.valid) then
      global.servertag.destroy()
      global.servertag = nil
    end
    if (not global.servertag) then
      local label = "Spawn Area"
      local xpos = 0
      local ypos = 0

      if global.servname and global.servname ~= "" then
        label = global.servname
      end

      if global.cspawnpos and global.cspawnpos.x then
        xpos = global.cspawnpos.x
        ypos = global.cspawnpos.y
      end

      local chartTag = {
        position = {xpos, ypos},
        icon = {type = "item", name = "heavy-armor"},
        text = label
      }
      local pforce = game.forces["player"]
      local psurface = game.surfaces[1]

      if pforce and psurface then
        global.servertag = pforce.add_chart_tag(psurface, chartTag)
      end
    end

    --Add time to connected players
    if global.active_playtime then
      for _, player in pairs(game.connected_players) do
        if global.playeractive[player.index] then
          if global.playeractive[player.index] == true then
            global.playeractive[player.index] = false --Turn back off

            if global.active_playtime[player.index] then
              global.active_playtime[player.index] = global.active_playtime[player.index] + 1800 --Same as loop time
            else
              --INIT
              global.active_playtime[player.index] = 0
            end
          end
        else
          --INIT
          global.playeractive[player.index] = false
        end
      end
    end

    get_permgroup() --See if player qualifies now
  end
)

--Blueprint throttle countdown
script.on_nth_tick(
  1,
  function(event)
    --game.force_crc()
    --testing only, host server does not trigger join

    if global.restrict then
      if global.blueprint_throttle then
        --Loop through players, countdown blueprint throttle
        for _, player in pairs(game.connected_players) do
          --Init if needed
          if not global.blueprint_throttle[player.index] then
            global.blueprint_throttle[player.index] = 0
          end

          --Subtract from count
          if global.blueprint_throttle[player.index] > 0 then
            global.blueprint_throttle[player.index] = global.blueprint_throttle[player.index] - 1
          end

          --blueprint throttle if needed.
          if not player.admin then
            if player.cursor_stack then
              local stack = player.cursor_stack
              if stack and stack.valid and stack.valid_for_read and stack.is_blueprint then
                if global.blueprint_throttle and global.blueprint_throttle[player.index] then
                  if global.blueprint_throttle[player.index] > 0 then
                    console_print(player.name .. " wait" .. round(global.blueprint_throttle[player.index] / 60, 2) .. "s to bp.")
                    smart_print(player, "[color=red](SYSTEM) You must wait " .. round(global.blueprint_throttle[player.index] / 60, 2) .. " seconds before blueprinting again.[/color]")
                    player.insert(player.cursor_stack)
                    stack.clear()
                  end
                end
              end
            end
          end
        end
      end

      --Replace object list
      if global.repobj then
        for _, item in ipairs(global.repobj) do
          --Sanity check
          if item.obj and item.obj.valid then
            --Check if an item is in our way ( fast replace )
            local fast_replaced =
              item.surface.find_entities_filtered {
              position = item.obj.position,
              radius = 0.99,
              force = item.obj.force,
              limit = 100
            }

            local fixed_obj = false --Item is cloned or untouched
            local clone_obj = false --Do put a clone in place

            --If there are items in our way from fast replace
            if fast_replaced then
              --Loop through items in our way
              for _, fastobj in pairs(fast_replaced) do
                local do_untouch = true

                --Valid object please
                if fastobj and fastobj.valid then
                  --Skip these, we have to do this because fast replace can change item type...
                  if fastobj.type ~= "character" and fastobj.type ~= "item-on-ground" then
                    --Fast replace disabled? Delete fast-replace object, put clone in place.
                    if global.no_fastreplace then
                      --If the item changed type, replace with clone
                      if fastobj.type ~= "electric-pole" then
                        fastobj.destroy()
                        do_untouch = false
                        clone_obj = true
                      end
                    elseif fastobj.type ~= item.obj.type then
                      fastobj.destroy()
                      do_untouch = false
                      clone_obj = true
                    end

                    --If allow the fast replace ( same type ) untouch and restore rotation
                    if do_untouch then
                      fixed_obj = true

                      --Untouch object
                      if item.obj.last_user and item.obj.last_user.valid then
                        --Untouched
                        fastobj.last_user = item.obj.last_user
                      else
                        --Just in case
                        fastobj.last_user = game.players[1]
                      end

                      --Fix for players fast-replacing items to get around rotation block
                      if fastobj.supports_direction then
                        fastobj.direction = item.obj.direction
                      end
                    end
                  end
                end
              end
              --We deleted item in the way, put clone in place now.
              if clone_obj then
                replace_with_clone(item)
                fixed_obj = true
              end
            end

            --If there was no fast replace, just put a clone back in the place of the item
            if not fixed_obj then
              replace_with_clone(item)
            end
          else
            console_print("repobj: Invalid data")
          end

          --Clean up limbo object
          item.obj.destroy()
        end

        --Done with list, invalidate it.
        global.repobj = nil
      end

      --Untouch rotated objects
      if global.untouchobj then
        for _, item in pairs(global.untouchobj) do
          --Sanity Check
          if item.object and item.object.valid then
            --Set last user to previous state
            if item.prev and item.prev.valid then
              item.object.last_user = item.prev
            else --just in case
              item.object.last_user = game.players[1]
            end
          end
        end

        --Done with list, invalidate it
        global.untouchonj = nil
      end
    end
  end
)

--Main event handler
script.on_event(
  {
    --Player join/leave respawn
    defines.events.on_player_created,
    defines.events.on_pre_player_died,
    defines.events.on_player_respawned,
    --
    defines.events.on_player_joined_game,
    defines.events.on_player_left_game,
    --activity
    defines.events.on_player_changed_position,
    defines.events.on_console_chat,
    defines.events.on_player_repaired_entity,
    --gui
    defines.events.on_gui_click,
    defines.events.on_gui_text_changed,
    --log
    defines.events.on_console_command,
    defines.events.on_chart_tag_removed,
    defines.events.on_chart_tag_modified,
    defines.events.on_chart_tag_added,
    defines.events.on_research_finished,
    -- anti-grief
    defines.events.on_player_deconstructed_area,
    defines.events.on_player_banned,
    defines.events.on_player_rotated_entity,
    defines.events.on_pre_player_mined_item,
    defines.events.on_player_cursor_stack_changed,
    --darkness
    defines.events.on_chunk_charted,
    defines.events.on_player_dropped_item,
    defines.events.on_built_entity,
    defines.events.on_post_entity_died,
    defines.events.on_robot_mined,
    defines.events.on_sector_scanned
  },
  function(event)
    --If no event, or event is a tick
    if not event or (event and event.name == defines.events.on_tick) then
      return
    end

    --Mark player active
    if event.player_index then
      local player = game.players[event.player_index]
      if player and player.valid then
        --Only mark active on movement if walking
        if event.name == defines.events.on_player_changed_position then
          if player.walking_state then
            if player.walking_state.walking == true and (player.walking_state.direction == defines.direction.north or player.walking_state.direction == defines.direction.northeast or player.walking_state.direction == defines.direction.east or player.walking_state.direction == defines.direction.southeast or player.walking_state.direction == defines.direction.south or player.walking_state.direction == defines.direction.southwest or player.walking_state.direction == defines.direction.west or player.walking_state.direction == defines.direction.northwest) then
              set_player_active(player)
            end
          end
        else
          set_player_active(player)
        end
      end
    end

    --Player join/leave respawn
    if event.name == defines.events.on_player_created then
      on_player_created(event)
    elseif event.name == defines.events.on_pre_player_died then
      on_pre_player_died(event)
    elseif event.name == defines.events.on_player_respawned then
      --
      on_player_respawned(event)
    elseif event.name == defines.events.on_player_joined_game then
      on_player_joined_game(event)
    elseif event.name == defines.events.on_player_left_game then
      --activity
      --changed-position
      --console_chat
      --repaired_entity
      --
      --gui
      on_player_left_game(event)
    elseif event.name == defines.events.on_gui_click then
      on_gui_click(event)
      online_on_gui_click(event) --online.lua
    elseif event.name == defines.events.on_gui_text_changed then
      --log
      on_gui_text_changed(event)
    elseif event.name == defines.events.on_console_command then
      on_console_command(event)
    elseif event.name == defines.events.on_chart_tag_removed then
      on_chart_tag_removed(event)
    elseif event.name == defines.events.on_chart_tag_modified then
      on_chart_tag_modified(event)
    elseif event.name == defines.events.on_chart_tag_added then
      on_chart_tag_added(event)
    elseif event.name == defines.events.on_research_finished then
      --anti-grief
      on_research_finished(event)
    elseif event.name == defines.events.on_player_deconstructed_area then
      on_player_deconstructed_area(event)
    elseif event.name == defines.events.on_player_banned then
      on_player_banned(event)
    elseif event.name == defines.events.on_player_rotated_entity then
      on_player_rotated_entity(event)
    elseif event.name == defines.events.on_pre_player_mined_item then
      on_pre_player_mined_item(event)
    elseif event.name == defines.events.on_player_cursor_stack_changed then
      on_player_cursor_stack_changed(event)
    end

    --darkness--
    --chunk_charted
    --player_dropped_item
    --built_entity
    --entity_died

    --To-Do--
    --player_joined_game
    --on_gui_click
    todo_event_handler(event)

    --External module event send
    --dark_event_handler(event)
  end
)
