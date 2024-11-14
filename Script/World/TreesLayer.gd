extends TileMapLayer

@onready var tileMap := get_parent()

func create_trees():
	var noise := FastNoiseLite.new()
	noise.frequency = 0.3
	
	for i in range(tileMap.minimap.size()):
		if tileMap.minimap[i] == MyTileMap.Minimap_Cell_Type.Ground:
			var pos = tileMap.minimap_get_pos(i)
			
			if noise.get_noise_2dv(pos) > 0.1:
				set_cell(pos, 1, Vector2(0, 1))
			
				tileMap.minimap[i] = MyTileMap.Minimap_Cell_Type.Tree
