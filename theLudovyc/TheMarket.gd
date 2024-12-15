extends Node

@onready var the_storage = $"../TheStorage"
@onready var the_bank = $"../TheBank"
@onready var event_bus: EventBus = $"../EventBus"


class Order:
	var buy_amount := 0
	var sell_amount := 0

	func _to_json() -> Array:
		return [buy_amount, sell_amount]
		
	func _from_json(data:Array):
		buy_amount = data[0]
		sell_amount = data[1]

var orders := {}


func _ready():
	event_bus.ask_create_new_order.connect(_on_ask_create_new_order)
	event_bus.ask_remove_order.connect(_on_ask_remove_order)
	event_bus.ask_update_order_buy.connect(_on_ask_update_order_buy)
	event_bus.ask_update_order_sell.connect(_on_ask_update_order_sell)


func get_resource_cost(resource_type: Resources.Types) -> int:
	if not Resources.Levels.has(resource_type):
		# ERROR
		return 0

	return Resources.Levels[resource_type] + 1


func get_production_rate_per_cycle(resource_type: Resources.Types) -> int:
	if not orders.has(resource_type):
		return 0

	var order = orders[resource_type]

	return order.buy_amount - order.sell_amount


func _on_ask_create_new_order(resource_type: Resources.Types):
	if orders.has(resource_type):
		# ERROR
		return

	orders[resource_type] = Order.new()

	if event_bus != null:
		event_bus.send_create_new_order.emit(resource_type)


func _on_ask_remove_order(resource_type: Resources.Types):
	if event_bus != null:
		event_bus.send_remove_order.emit(resource_type)

	if orders.erase(resource_type):
		the_storage.update_global_production_rate(resource_type)

		the_bank.recalculate_orders_cost()


func _on_ask_update_order_buy(resource_type: Resources.Types, buy_amount: int):
	if not orders.has(resource_type):
		# ERROR
		return

	if buy_amount < 0:
		# ERROR
		return

	orders[resource_type].buy_amount = buy_amount

	the_bank.recalculate_orders_cost()

	the_storage.update_global_production_rate(resource_type)


func _on_ask_update_order_sell(resource_type: Resources.Types, sell_amount: int):
	if not orders.has(resource_type):
		# ERROR
		return

	if sell_amount < 0:
		# ERROR
		return

	orders[resource_type].sell_amount = sell_amount

	the_bank.recalculate_orders_cost()

	the_storage.update_global_production_rate(resource_type)


func _on_TheTicker_cycle():
	for order_key in orders:
		var order = orders[order_key]

		if the_bank.try_to_buy_resource(order_key, order.buy_amount):
			the_storage.add_resource(order_key, order.buy_amount)

		if the_storage.try_to_sell_resource(order_key, order.sell_amount):
			the_bank.conclude_sale(order_key, order.sell_amount)
			
func get_market_save() -> Dictionary:
	var data_to_save := {}
	
	for resource_type in orders:
		var order = orders[resource_type]
		
		data_to_save[resource_type] = order._to_json()
	
	return {"Market": data_to_save}
	
func load_market_save() -> Error:
	if SaveHelper.last_loaded_data.is_empty():
		return FAILED
		
	var market_data:Dictionary = SaveHelper.last_loaded_data.get("Market", {})
	
	if market_data.is_empty():
		return FAILED
	
	for resource_type_str in market_data:
		var resource_type:int = resource_type_str.to_int()
	
		if not Resources.Types.values().has(resource_type):
			push_error("Cannot create a production line \
				from an unknow resource type: " + resource_type_str)
			
			continue
			
		var order = Order.new()
		order._from_json(market_data[resource_type_str])
		
		orders[resource_type] = order
			
		if event_bus != null:
			event_bus.send_create_new_order_with_values.emit(
				resource_type, order.buy_amount, order.sell_amount)
			
		the_storage.update_global_production_rate(resource_type)
	
	the_bank.recalculate_orders_cost()
	
	return OK
