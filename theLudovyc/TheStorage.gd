extends Node
class_name TheStorage

var storage := {}

@onready var event_bus = $"../EventBus"

@onready var the_factory := $"../TheFactory"

@onready var the_market := $"../TheMarket"

@onready var the_ticker := $"../TheTicker"


func add_resource(resource_type: Resources.Types, amount: int):
	if sign(amount) < 0 and abs(amount) > storage[resource_type]:
		push_error(name, "Error: cannot consume " + str(amount) + " of " + str(resource_type))

		storage[resource_type] = 0
	else:
		if storage.has(resource_type):
			storage[resource_type] += amount
		else:
			storage[resource_type] = amount

	event_bus.resource_updated.emit(resource_type, storage[resource_type])

	if storage[resource_type] == 0:
		storage.erase(resource_type)


func get_resource_amount(resource_type: Resources.Types):
	if not storage.has(resource_type):
		return 0

	return storage[resource_type]


func try_to_sell_resource(resource_type: Resources.Types, amount: int) -> bool:
	if not storage.has(resource_type) or amount <= 0:
		return false

	if storage[resource_type] >= amount:
		storage[resource_type] -= amount

		event_bus.resource_updated.emit(resource_type, storage[resource_type])

		return true

	return false


func update_global_production_rate(resource_type: Resources.Types):
	var factory_per_cycle = (
		the_factory.get_production_rate_per_tick(resource_type) * the_ticker.cycle_cooldown
	)

	event_bus.resource_prodution_rate_updated.emit(
		resource_type, factory_per_cycle + the_market.get_production_rate_per_cycle(resource_type)
	)


func has_resources_to_construct_building(building_cost:Array) -> bool:
	if building_cost.is_empty():
		return true

	for cost in building_cost:
		if abs(cost[1]) > storage.get(cost[0], 0):
			return false

	return true


func conclude_building_construction(building_cost:Array):
	if building_cost.is_empty():
		return

	for cost in building_cost:
		add_resource(cost[0], cost[1])


func recover_building_construction(building_id: Buildings.Ids):
	var building_cost = Buildings.get_building_cost(building_id)

	if building_cost.is_empty():
		return

	for cost in building_cost:
		add_resource(cost[0], cost[1])

func get_storage_save() -> Dictionary:
	return {"Storage":storage}
	
func load_storage_save() -> Error:
	if SaveHelper.last_loaded_data.is_empty():
		return FAILED
		
	var storage_data:Dictionary = SaveHelper.last_loaded_data.get("Storage", {})
	
	if storage_data.is_empty():
		return FAILED
	
	for resource_type_str:String in storage_data:
		add_resource(resource_type_str.to_int(), storage_data[resource_type_str])
	
	return OK
