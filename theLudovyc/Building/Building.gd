@tool

extends EntityStatic
class_name Building2D

signal selected(type)

enum Datas {Texture, Width, Height}

const datas = {
	Buildings.Ids.Warehouse: {
		Datas.Texture: preload("res://theLudovyc/Building/warehouse.png"),
		Datas.Width: 3,
		Datas.Height: 3,
	},
	Buildings.Ids.Tent: {
		Datas.Texture: preload("res://theLudovyc/Building/residential.png"),
		Datas.Width: 2,
		Datas.Height: 2,
	},
	Buildings.Ids.Lumberjack: {
		Datas.Texture: preload("res://theLudovyc/Building/lumberjack.png"),
		Datas.Width: 2,
		Datas.Height: 2,
	},
}

var building_id: Buildings.Ids = -1:
	set(p_building_id):
		if p_building_id != building_id:
			building_id = p_building_id
			
			var building_data = datas.get(building_id)
			
			if building_data == null:
				push_error("Cannot find datas for this id: " + str(building_id))
				return
			
			width = building_data[Datas.Width]
			height = building_data[Datas.Height]
			texture = building_data[Datas.Texture]
			
			update_offset()

var event_bus: EventBus

var is_selected := false

func build():
	var current_scene = get_tree().current_scene
	if current_scene.has_node("EventBus"):
		event_bus = current_scene.get_node("EventBus")
		event_bus.send_building_selected.connect(_on_building_selected)
		
	var area2d := $Area2D
	area2d.input_event.connect(_on_Area2d_input_event)
	area2d.mouse_entered.connect(_on_Area2d_mouse_entered)
	area2d.mouse_exited.connect(_on_Area2d_mouse_exited)
	
	var collisionPolygon := $"Area2D/CollisionPolygon2D"
	
	# 0N 1W 2S 3E
	var col_points = collisionPolygon.polygon
	
	col_points[0] *= height
	col_points[2] *= height
	
	col_points[1] *= width
	col_points[3] *= width
	
	collisionPolygon.polygon = col_points
	
	if height % 2 == 0:
		collisionPolygon.position.y -= 16 * height / 2


func _on_Area2d_input_event(viewport, event, shape_idx):
	if not is_selected and event.is_action_pressed("alt_command"):
		is_selected = true
		modulate = Color.YELLOW
		if event_bus != null:
			event_bus.send_building_selected.emit(self)


func _on_Area2d_mouse_entered():
	if not is_selected:
		modulate = Color.YELLOW


func _on_Area2d_mouse_exited():
	if not is_selected:
		modulate = Color.WHITE


func _on_building_selected(building_node: Building2D):
	if is_selected and building_node != self:
		is_selected = false
		modulate = Color.WHITE


func select():
	is_selected = true
	modulate = Color.YELLOW


func deselect():
	is_selected = false
	modulate = Color.WHITE
