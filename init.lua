local VECTOR_ZERO = {x = 0, y = 0, z = 0}
local SMELL_RANGE = tonumber(minetest.settings:get("baecon.range")) or 50

local function steam_particle(pos1, pos2)
    if pos2 then
        minetest.add_particle({
            pos = pos1,
            velocity = vector.rotate(vector.multiply(vector.normalize(vector.direction(pos1, pos2)), 1), vector.new(math.random(-3, 3) * 0.1, math.random(-3, 3) * 0.1, 0)),
            acceleration = VECTOR_ZERO,
            expirationtime = 1,
            size = math.random(7, 13),
            texture = "baecon_steam.png",
        })
    end
end

local function steam_path(pos1, pos2)
    local dist = vector.distance(pos1, pos2)
    local path = minetest.find_path(pos1, pos2, dist * 2, dist, dist, "A*")
    if path then
        for i = 1, #path do
            steam_particle(path[i], path[i + 1])
        end
    end
end

local function attract_players(pos1, range)
    for _, player in pairs(minetest.get_connected_players()) do
        local ppos = vector.add(player:get_pos(), {x = 0, y = 1, z = 0})
        if vector.distance(pos1, ppos) <= range then
            local airpos = minetest.find_nodes_in_area(vector.add(pos1, {x = -1, y = -1, z = -1}), vector.add(pos1, {x = 1, y = 1, z = 1}), {"air"})[1]
            if airpos then
                steam_path(airpos, ppos)
            end
        end
    end
end

local old_timer = minetest.registered_nodes["default:furnace_active"].on_timer
minetest.override_item("default:furnace_active", {
    on_timer = function(pos, ...)
        if minetest.get_meta(pos):get_inventory():get_list("src")[1]:get_name() == "baecon:baecon" then
            attract_players(pos, SMELL_RANGE)
        end

        return old_timer(pos, ...)
    end,
})

minetest.register_craftitem("baecon:baecon", {
    description = "Raw Baecon",
    inventory_image = "baecon.png",
    on_use = minetest.item_eat(1),
})

minetest.register_craftitem("baecon:baecon_cooked", {
    description = "Cooked Baecon",
    inventory_image = "baecon_cooked.png",
    on_use = minetest.item_eat(6),
})

minetest.register_craft({
    output = "baecon:baecon_cooked",
    type = "cooking",
    recipe = "baecon:baecon",
    cooktime = 10,
})
