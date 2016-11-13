local clustersize = 5

local getarea = function (pos,radius)
	-- get nodes in an area around origin pos
	-- nearer the centre, greater chance of capturing a node
	-- at the edges, minimal chance
	-- for y, y-1 and y+1
	
	local nodeset = {}
	for dy=-1,1 do
	  for dx=-radius,radius do
	    for dz=-radius,radius do
		local tpos = {
		  x=pos.x+dx,
		  y=pos.y+dy,
		  z=pos.z+dz,
		  }
		local tnode = minetest.get_node(tpos).name
		if tnode == "air"
			or tnode == "default:water_source"
			or tnode == "default:river_water_source"
			or tnode == "default:lava_source"
			or tnode == "default:water_flowing"
			or tnode == "default:river_water_flowing"
			or tnode == "default:lava_flowing"
		  then
			local amp = vector.distance(pos,tpos)
			if (1-amp/radius)*math.random(1,radius) > amp then
				nodeset[#nodeset+1] = tpos
			end
		end
	    end -- dz
	  end -- dx
	end
	return nodeset
end

local clusterize = function(pos)

	minetest.swap_node(pos, {name = "air" })

	local targetnodes = getarea(pos,clustersize)
	for _,fpos in pairs(targetnodes) do
		minetest.place_node(fpos, {name = "tnt:tnt_burning" })
	end
end

minetest.register_node("cluster_tnt:tnt",{
	tiles = {"tnt_side.png^[colorize:yellow:100"},
	description = "TNT Cluster Bomb",
	after_place_node = function(pos,player)
		local pname = player:get_player_name()

		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end
		clusterize(pos)

	end
})

-- Make burning TNT diggable

local btnt = minetest.registered_nodes["tnt:tnt_burning"]
local tntblock = "tnt:tnt_burning"

if btnt.groups == nil then
	btnt.groups = {}
end

btnt.groups.snappy = 1
btnt.drop = nil
btnt.description = "Ignited TNT"

minetest.register_node(":tnt:tnt_burning",btnt)

-- Make craft depend on burning TNT :)

minetest.register_craft({
	output = "cluster_tnt:tnt",
	recipe = {
		{tntblock,"default:coalblock",tntblock},
		{"default:coalblock","default:steelblock","default:coalblock"},
		{tntblock,"default:coalblock",tntblock},
	}
})
