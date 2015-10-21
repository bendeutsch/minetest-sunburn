--[[

Sunburn [sunburn]
==========================

A mod where sunlight simply kills you outright.

Copyright (C) 2015 Ben Deutsch <ben@bendeutsch.de>

License
-------

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA

]]


sunburn = {

    -- configuration in sunburn.default.conf and related files

    -- per-player-stash (not persistent)
    players = {
        --[[
        name = {
            pending_dmg = 0.0,
            burn_factor = 1.0,
            damage_factor = 1.0,
            heal_factor = 1.0,
        }
        ]]
    },

    -- global things
    time_next_tick = 0.0,
}
local M = sunburn

dofile(minetest.get_modpath('sunburn')..'/configuration.lua')
local C = M.config

dofile(minetest.get_modpath('sunburn')..'/persistent_player_attributes.lua')
local PPA = M.persistent_player_attributes

dofile(minetest.get_modpath('sunburn')..'/hud.lua')

PPA.register({
    name = 'sunburn_sunburn',
    min  = 0,
    max  = 20,
    default = 0,
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local pl = M.players[name]
    if not pl then
        M.players[name] = {
            pending_dmg = 0.0,
            burn_factor = 1.0,
            damage_factor = 1.0,
            heal_factor = 1.0,
        }
        pl = M.players[name]
        M.hud_init(player)
    end
end)

minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()
    local pl = M.players[name]
    pl.pending_dmg = 0.0
    pl.burn_factor = 1.0
    pl.damage_factor = 1.0
    pl.heal_factor = 1.0
    local burn = 0
    PPA.set_value(player, "sunburn_sunburn", burn)
    M.hud_update(player, burn)
end)

minetest.register_globalstep(function(dtime)

    M.time_next_tick = M.time_next_tick - dtime
    while M.time_next_tick < 0.0 do
        M.time_next_tick = M.time_next_tick + C.tick_time
        for _,player in ipairs(minetest.get_connected_players()) do

            if player:get_hp() <= 0 then
                -- dead players don't fear the sun
                break
            end

            local name = player:get_player_name()
            local pl = M.players[name]
            local pos  = player:getpos()
            local pos_y = pos.y
            -- the middle of the block with the player's head
            pos.y = math.floor(pos_y) + 1.5
            local node = minetest.get_node(pos)

            local light_now   = minetest.get_node_light(pos) or 0
            if node.name == 'ignore' then
                -- can happen while world loads, set to something innocent
                light_now = 9
            end

            local bps = C.sunburn_for_light[light_now]
            if bps > 0 then
                bps = bps * pl.burn_factor
            else
                bps = bps * pl.heal_factor
            end
            --print("Standing in " .. node.name .. " at light " .. light_now .. " taking " .. bps);

            local burn = PPA.get_value(player, "sunburn_sunburn")

            burn = burn + bps * C.tick_time;
            if burn <  0 then burn =  0 end
            if burn > 20 then burn = 20 end
            --print("New burn "..burn)
            PPA.set_value(player, "sunburn_sunburn", burn)

            M.hud_update(player, burn)

            if burn > C.sunburn_threshold  and minetest.setting_getbool("enable_damage") then
                local burn_overrun = burn - C.sunburn_threshold
                local dps = burn_overrun * C.damage_per_sunburn * pl.damage_factor
                --print ("DPS: "..dps)
                pl.pending_dmg = pl.pending_dmg + dps * C.tick_time
                if pl.pending_dmg > 1.0 then
                    local dmg = math.floor(pl.pending_dmg)
                    --print("Deals "..dmg.." damage!")
                    pl.pending_dmg = pl.pending_dmg - dmg
                    player:set_hp( player:get_hp() - dmg )
                end
            end
        end
    end
end)

--[[

API

]]

function M.get_sunburn(player)
    return PPA.get_value(player, "sunburn_sunburn")
end

function M.set_sunburn(player, burn)
    PPA.set_value(player, "sunburn_sunburn", burn)
    M.hud_update(player, burn)
end

function M.add_sunburn(player, change)
    local burn = PPA.get_value(player, "sunburn_sunburn") + change
    PPA.set_value(player, "sunburn_sunburn", burn)
    M.hud_update(player, burn)
end


function M.get_burn_factor(player)
    local name = player:get_player_name()
    local pl = M.players[name] or {}
    return pl.burn_factor
end

function M.set_burn_factor(player, factor)
    local name = player:get_player_name()
    local pl = M.players[name] or {}
    pl.burn_factor = factor
end


function M.get_damage_factor(player)
    local name = player:get_player_name()
    local pl = M.players[name] or {}
    return pl.damage_factor
end

function M.set_damage_factor(player, factor)
    local name = player:get_player_name()
    local pl = M.players[name] or {}
    pl.damage_factor = factor
end


function M.get_heal_factor(player)
    local name = player:get_player_name()
    local pl = M.players[name] or {}
    return pl.heal_factor
end

function M.set_heal_factor(player, factor)
    local name = player:get_player_name()
    local pl = M.players[name] or {}
    pl.heal_factor = factor
end
