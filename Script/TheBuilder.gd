extends Node

const Buildings_Scenes = {
	Buildings.Ids.Warehouse: preload("res://theLudovyc/Building/Warehouse.tscn"),
	Buildings.Ids.Tent: preload("res://theLudovyc/Building/Residential.tscn"),
	Buildings.Ids.Lumberjack: preload("res://theLudovyc/Building/Lumberjack.tscn")
}

var warehouse: Building2D

@onready var node_buildings:Node = %Buildings

@onready var tilemap:TileMap = %TileMap

func instantiate_building(building_id: Buildings.Ids) -> Building2D:
	if not Buildings_Scenes.has(building_id):
		push_error("Cannot instanciate a building with this Id: " + str(building_id))
		
		return null
	
	var instance = Buildings_Scenes[building_id].instantiate() as Building2D

	node_buildings.add_child(instance)

	return instance
	
func build(building_id:Buildings.Ids, pos:Vector2) -> Building2D:
	var building = instantiate_building(building_id)
	
	if building == null:
		push_error("Cannot create a building from null instance")
		
		return null
	
	building.position = pos
	
	tilemap.conclude_building_construction(building)

	building.build()
	return building
	
func build_warehouse(pos:Vector2):
	warehouse = build(Buildings.Ids.Warehouse, pos)

func get_buildings_save() -> Dictionary:
	var datas:Array
	
	for child:Building2D in node_buildings.get_children():
		datas.append([child.building_id, child.position.x, child.position.y])
	
	return {"Buildings":datas}
	
func load_buildings_save() -> Error:
	if SaveHelper.last_loaded_data.is_empty():
		return FAILED
		
	var buildings_data:Array = SaveHelper.last_loaded_data.get("Buildings", [])
	
	if buildings_data.is_empty():
		return FAILED
	
	for building_data in SaveHelper.last_loaded_data["Buildings"]:
		var building = build(building_data[0],
				Vector2(building_data[1], building_data[2]))
		
		if build(building_data[0],
			Vector2(building_data[1], building_data[2])) == null:
			# TODO handle error with a popup and return to MainMenu
			
			pass
		
		if building_data[0] == 0:
			warehouse = building
	
	return OK
