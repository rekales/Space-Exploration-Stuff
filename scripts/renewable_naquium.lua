local data_util = require("data_util")

local function on_rocket_launch_ordered(event)
    if event.rocket and event.rocket.valid then
        local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.rocket.surface.index}) -- needs optimization such as not getting full zone data
        if event.rocket.get_item_count(data_util.mod_prefix .. "naquium-harvester") > 0 then
            if not (zone and zone.type == "asteroid-field") then
              local probe_count = event.rocket.get_item_count(data_util.mod_prefix .. "naquium-harvester")
              event.rocket.remove_item({name=data_util.mod_prefix.."naquium-harvester", count=probe_count})

              event.rocket.force.print({"space-exploration-stuff.naquium_harvester_invalid_launch_field"})

            --   local tick_task = new_tick_task("force-message")
            --   tick_task.force_name = event.rocket.force.name
            --   tick_task.message = {"space-exploration.probe_invalid_launch_field"}
            --   tick_task.delay_until = game.tick + 750 --5s
            end
        end
    end
end

local function on_rocket_launched(event)
    if event.rocket and event.rocket.valid then
        local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.rocket.surface.index})
        if event.rocket.get_item_count(data_util.mod_prefix .. "naquium-harvester") > 0 then
            if zone and zone.type == "asteroid-field" then
                local inv = event.rocket_silo.get_inventory(defines.inventory.rocket_silo_result)
                local fsr = event.rocket.surface.map_gen_settings.autoplace_controls["se-naquium-ore"]
                inv.insert({name="ses-naquium-clump", count=math.floor((fsr.frequency+fsr.size+fsr.richness)
                *settings.global[data_util.mod_prefix.."naquium-harvest-multiplier"].value
                *(event.rocket_silo.force.mining_drill_productivity_bonus+1)
                *(math.random()*0.2+0.9)
                +10)})
            end
        end
    end
end

if settings.startup[data_util.mod_prefix.."renewable-naquium"].value 
then 
Event.add_listener(defines.events.on_rocket_launch_ordered, on_rocket_launch_ordered)
Event.add_listener(defines.events.on_rocket_launched, on_rocket_launched)
end