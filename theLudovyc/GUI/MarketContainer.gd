extends VBoxContainer

var event_bus: EventBus = null

var resource_order_scene = preload("res://theLudovyc/GUI/ResourceOrder.tscn")

@onready var resource_popup = %ResourcePopup

@onready var order_container = %OrderContainer

@onready var tooltip := %WidgetTooltip

var order_nodes = {}


func _ready():
	var current_scene = get_tree().current_scene

	if current_scene.has_node("EventBus"):
		event_bus = current_scene.get_node("EventBus") as EventBus

		event_bus.send_create_new_order.connect(_on_receive_create_new_order)
		event_bus.send_create_new_order_with_values.connect(_on_receive_create_new_order_with_values)
		event_bus.send_remove_order.connect(_on_receive_remove_order)
		event_bus.send_update_order_buy.connect(_on_receive_update_order_buy)
		event_bus.money_production_rate_updated.connect(_on_receive_money_production_rate_updated)

	resource_popup.result.connect(_on_ResourcePopup_result)


func _on_ResourcePopup_result(resource_type: Resources.Types):
	event_bus.ask_create_new_order.emit(resource_type)


func _on_NewOrderButton_pressed():
	resource_popup.popup_centered()


func _on_receive_create_new_order(resource_type: Resources.Types):
	var resource_order = resource_order_scene.instantiate()

	order_container.add_child(resource_order)

	resource_order._resource_type = resource_type

	order_nodes[resource_type] = resource_order

func _on_receive_create_new_order_with_values(resource_type: Resources.Types,
	buy_amount:int, sell_amount:int):
	var resource_order = resource_order_scene.instantiate()

	order_container.add_child(resource_order)

	resource_order._resource_type = resource_type
	resource_order.force_buy_value(buy_amount)
	resource_order.force_sell_value(sell_amount)

	order_nodes[resource_type] = resource_order

func _on_receive_remove_order(resource_type: Resources.Types):
	order_nodes[resource_type].queue_free()

	order_nodes.erase(resource_type)


func _on_receive_update_order_buy(resource_type: Resources.Types, buy_amount: int):
	if not order_nodes.has(resource_type):
		#ERROR
		pass

	order_nodes[resource_type].force_buy_amount(buy_amount)


func _on_receive_money_production_rate_updated(production_rate):
	tooltip.set_money_production_rate_info(production_rate)
