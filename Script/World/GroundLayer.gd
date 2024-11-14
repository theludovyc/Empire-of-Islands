extends TileMapLayer

@onready var tileMap := get_parent()

func create_terrain(deep_tiles_json, shallow_tiles_json, sand_tiles_json, ground_tiles_json):
	var set_cells = func(array_in, atlas_pos, array_out, type:MyTileMap.Minimap_Cell_Type):
		for i in range(0, array_in.size(), 2):
			var tile_vec = Vector2i(array_in[i], array_in[i + 1])
			
			tileMap.minimap_set_cell_vec(tile_vec, type)
			
			array_out.push_back(tile_vec)
			
			set_cell(tile_vec, 1, atlas_pos)
	
	var deep_tiles:PackedVector2Array
	var shallow_tiles:PackedVector2Array
	var sand_tiles:PackedVector2Array
	var ground_tiles:PackedVector2Array
	
	set_cells.call(deep_tiles_json, Vector2i(1, 2),
		deep_tiles, MyTileMap.Minimap_Cell_Type.Deep)
	set_cells.call(shallow_tiles_json, Vector2i(4, 2),
		shallow_tiles, MyTileMap.Minimap_Cell_Type.Shallow)
	set_cells.call(sand_tiles_json, Vector2i(7, 2),
		sand_tiles, MyTileMap.Minimap_Cell_Type.Sand)
	set_cells.call(ground_tiles_json, Vector2i(7, 6),
		ground_tiles, MyTileMap.Minimap_Cell_Type.Ground)

	set_cells_terrain_connect(ground_tiles, 0, 3)
	set_cells_terrain_connect(sand_tiles, 0, 2)
	set_cells_terrain_connect(shallow_tiles, 0, 1)
