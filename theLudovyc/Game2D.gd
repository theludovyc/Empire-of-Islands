extends Node
class_name Game2D

@onready var rtl := $CanvasLayer/RichTextLabel

@onready var tm := %TileMap

@onready var cam := $Camera2D

@onready var node_entities := %Entities

@onready var the_storage := $TheStorage
@onready var the_bank := $TheBank
@onready var event_bus := $EventBus

@onready var the_factory := $TheFactory

@onready var gui := $GUI
@onready var pause_menu := %PauseMenu

const Buildings_Scenes = {
	Buildings.Ids.Warehouse: preload("res://theLudovyc/Building/Warehouse.tscn"),
	Buildings.Ids.Tent: preload("res://theLudovyc/Building/Residential.tscn"),
	Buildings.Ids.Lumberjack: preload("res://theLudovyc/Building/Lumberjack.tscn")
}

const Trees_Destroy_Cost = 1

# if not null follow the cursor
var cursor_entity: Building2D
# avoid create building on first clic
var cursor_entity_wait_release: bool = false

var population := 0:
	set(value):
		population = value
		event_bus.population_updated.emit(value)
		event_bus.available_workers_updated.emit(population - the_factory.workers)

var warehouse: Building2D

var current_selected_building: Building2D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	tm.create_island("res://theLudovyc/singularity_40.json")

	# spawn the warehouse
	warehouse = instantiate_building(Buildings.Ids.Warehouse)

	var warehouse_center_tile = Vector2i(1, 20)

	warehouse.position = tm.ground_layer.map_to_local(warehouse_center_tile)

	tm.build_entityStatic(warehouse, warehouse_center_tile)

	warehouse.build()

	# set camera limits
	var pos_limits = tm.get_pos_limits()

	cam.pos_limit_top_left = pos_limits[0]
	cam.pos_limit_bot_right = pos_limits[1]

	# force camera initial pos on warehouse
	cam.position = warehouse.global_position
	cam.reset_smoothing()

	# add some initial resources
	the_bank.money = 100

	the_storage.add_resource(Resources.Types.Wood, 2)
	the_storage.add_resource(Resources.Types.Textile, 16)

	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pause_menu.visible == false and Input.is_action_just_pressed("ui_cancel"):
		pause_menu.show()
		pause_menu.set_process(true)
		get_tree().paused = true

	var mouse_pos = get_viewport().get_mouse_position()

	rtl.text = ""

	rtl.text += str(mouse_pos) + "\n"

	rtl.text += str(cam.get_screen_center_position()) + "\n"

	# may be optimized
	mouse_pos += cam.get_screen_center_position() - get_viewport().get_visible_rect().size / 2

	rtl.text += str(mouse_pos) + "\n"

	var tile_pos = tm.ground_layer.local_to_map(mouse_pos)

	rtl.text += str(tile_pos) + "\n"
	
	rtl.text += str(tm.minimap_get_cell(tile_pos))

	rtl.text += str(tm.is_constructible(tile_pos)) + "\n"

	var tile_data = tm.get_cell_tile_data(0, tile_pos)

	if tile_data != null:
		rtl.text += str(tile_data.terrain_set) + " / " + str(tile_data.terrain) + "\n"

		rtl.text += str(tm.get_cell_atlas_coords(0, tile_pos))

	#spawn entity
	if cursor_entity:
		cursor_entity.position = tm.ground_layer.map_to_local(tile_pos)

		var building_id = cursor_entity.building_id

		var trees_to_destroy = tm.is_entityStatic_constructible(cursor_entity, tile_pos)

		var trees_to_destroy_final_cost := 0

		if trees_to_destroy > 0:
			trees_to_destroy_final_cost = trees_to_destroy * Trees_Destroy_Cost

			if trees_to_destroy_final_cost > 0:
				gui.set_rtl_info_text_money_cost(trees_to_destroy_final_cost)
				gui.set_rtl_visibility(true)
		else:
			gui.set_rtl_visibility(false)

		var is_constructible = false

		if (
			trees_to_destroy >= 0
			and (
				trees_to_destroy_final_cost == 0
				or (
					trees_to_destroy_final_cost > 0
					and trees_to_destroy_final_cost <= the_bank.money
				)
			)
			and the_storage.has_resources_to_construct_building(building_id)
		):
			is_constructible = true

		if is_constructible:
			if trees_to_destroy > 0:
				cursor_entity.modulate = Color(Color.ORANGE, 0.6)
			else:
				cursor_entity.modulate = Color(Color.GREEN, 0.6)
		else:
			cursor_entity.modulate = Color(Color.RED, 0.6)

		if cursor_entity_wait_release and Input.is_action_just_released("alt_command"):
			cursor_entity_wait_release = false

		if (
			not cursor_entity_wait_release
			and is_constructible
			and Input.is_action_just_pressed("alt_command")
		):
			match Buildings.get_building_type(building_id):
				Buildings.Types.Residential:
					var amount := Buildings.get_max_workers(building_id)

					population += amount

					the_factory.population_increase(amount)

				Buildings.Types.Producing:
					the_factory.add_workers(
						Buildings.get_produce_resource(building_id),
						Buildings.get_max_workers(building_id)
					)

			if trees_to_destroy_final_cost > 0:
				gui.set_rtl_visibility(false)

				the_bank.money -= trees_to_destroy_final_cost

			the_storage.conclude_building_construction(building_id)

			event_bus.send_building_created.emit(building_id)

			tm.build_entityStatic(cursor_entity, tile_pos)

			cursor_entity.modulate = Color.WHITE
			cursor_entity.build()
			cursor_entity = null

		if cursor_entity and Input.is_action_just_pressed("main_command"):
			if trees_to_destroy_final_cost > 0:
				gui.set_rtl_visibility(false)

			event_bus.send_building_creation_aborted.emit(building_id)

			cursor_entity.call_deferred("queue_free")
			cursor_entity = null


func instantiate_building(building_id: Buildings.Ids) -> Building2D:
	var instance = Buildings_Scenes[building_id].instantiate() as Building2D

	node_entities.add_child(instance)

	# TODO
	#instance.selected.connect(_on_building_selected)

	return instance


func _on_EventBus_ask_create_building(building_id: Buildings.Ids):
	var entity := instantiate_building(building_id)
	cursor_entity = entity
	cursor_entity_wait_release = true
	cursor_entity.modulate = Color(Color.RED, 0.6)


func _on_EventBus_send_building_selected(building_node):
	current_selected_building = building_node


func _on_EventBus_ask_deselect_building():
	if current_selected_building != null:
		current_selected_building.deselect()
		current_selected_building = null


func _on_EventBus_ask_select_warehouse():
	current_selected_building = warehouse

	warehouse.select()


func _on_EventBus_ask_demolish_current_building():
	tm.demolish_building(current_selected_building)

	var building_id = current_selected_building.building_id

	the_storage.recover_building_construction(building_id)

	match Buildings.get_building_type(building_id):
		Buildings.Types.Residential:
			var amount := Buildings.get_max_workers(building_id)

			population -= amount

			the_factory.population_decrease(amount)

		Buildings.Types.Producing:
			the_factory.rem_workers(
				Buildings.get_produce_resource(building_id), Buildings.get_max_workers(building_id)
			)
		_:
			pass

	current_selected_building.queue_free()
	current_selected_building = null

	event_bus.send_current_building_demolished.emit()
