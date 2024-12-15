extends Node
class_name TheBank

const money_icon = preload("res://Art/Image/Gui/Icons/Resources/32/001.png")

@onready var event_bus := $"../EventBus"

@onready var the_market := $"../TheMarket"

@onready var the_storage := $"../TheStorage"

var money := 0:
	set(value):
		money = value
		event_bus.money_updated.emit(value)

var money_production_rate := 0:
	set(value):
		money_production_rate = value
		event_bus.money_production_rate_updated.emit(value)

var orders_cost := 0:
	set(value):
		orders_cost = value

		update_money_production_rate()


#in futur it will also have buildings_cost
func update_money_production_rate():
	money_production_rate = orders_cost


func try_to_buy_resource(resource_type: Resources.Types, amount: int) -> bool:
	if amount == 0:
		return false

	var cost: int = the_market.get_resource_cost(resource_type) * amount

	if money >= cost:
		money -= cost
		return true

	return false


func conclude_sale(resource_type: Resources.Types, amount: int):
	if amount <= 0:
		return

	money += the_market.get_resource_cost(resource_type) * amount

	recalculate_orders_cost()


# can be optimised if we know the resource type
# remove the resource cost then readd if it is needed
func recalculate_orders_cost():
	var market_orders = the_market.orders

	if market_orders.is_empty():
		orders_cost = 0
		return

	# do not update the orders_cost directly
	# it will be updated at each iteration of the loop
	# so it will be update money production rate at each iteration
	var tmp_orders_cost := 0

	for order_key in market_orders:
		var order = market_orders[order_key]

		var resource_cost = the_market.get_resource_cost(order_key)

		if order.buy_amount > 0:
			tmp_orders_cost -= resource_cost * order.buy_amount

		if order.sell_amount == 0 or order.sell_amount > the_storage.get_resource_amount(order_key):
			continue

		tmp_orders_cost += resource_cost * order.sell_amount

	orders_cost = tmp_orders_cost

func get_bank_save() -> Dictionary:
	return {"Money": [money, money_production_rate]}
	
func load_bank_save() -> Error:
	if SaveHelper.last_loaded_data.is_empty():
		return FAILED
		
	var bank_data:Array = SaveHelper.last_loaded_data.get("Money", [])
	
	if bank_data.is_empty():
		return FAILED
	
	money = bank_data[0]
	money_production_rate = bank_data[1]
	
	return OK
