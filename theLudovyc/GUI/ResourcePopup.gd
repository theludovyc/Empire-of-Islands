extends Window

@onready var grid_container = $PanelContainer/ScrollContainer/GridContainer

signal result(resource_type)


func _ready():
	for resource_type in range(Resources.Types.size()):
		var resource_button = GUI.scenes[GUI.ResourceButton].instantiate()
		
		resource_button.tooltip_text = Resources.get_resource_name(resource_type)

		resource_button.pressed.connect(_on_ResourceButton_pressed.bind(resource_type))

		grid_container.add_child(resource_button)

		resource_button.set_resource_icon(resource_type)
	pass


func _on_ResourceButton_pressed(resource_type: Resources.Types):
	result.emit(resource_type)

	hide()
	pass
