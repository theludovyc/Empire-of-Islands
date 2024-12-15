extends Node
class_name TheFactory

@onready var game: Game2D = get_parent()
@onready var storage = $"../TheStorage"
@onready var event_bus = $"../EventBus"

enum Production_Line { current_workers, production_rate, current_ticks }
var production_lines := {}

var workers := 0:
	set(value):
		workers = value
		event_bus.available_workers_updated.emit(game.population - workers)

enum Waiting_Lines { resource_type, needed_workers }
var waiting_lines := []


func get_production_rate_per_tick(resource_type: Resources.Types) -> int:
	if not production_lines.has(resource_type):
		return 0

	return production_lines[resource_type][Production_Line.production_rate]


func create_or_update_line(resource_type: Resources.Types, workers_amount: int):
	var needed_workers = Recipes.get_recipe_needed_workers(resource_type)

	if production_lines.has(resource_type):
		var line = production_lines[resource_type]

		line[Production_Line.current_workers] += workers_amount

		line[Production_Line.production_rate] = int(
			line[Production_Line.current_workers] / needed_workers
		)
	else:
		var production_rate: int = 0

		if workers_amount >= needed_workers:
			production_rate = workers_amount / needed_workers

		production_lines[resource_type] = [workers_amount, production_rate, 0]

	storage.update_global_production_rate(resource_type)


func add_workers(resource_type: Resources.Types, workers_amount: int):
	if workers_amount == 0:
		return
	elif workers_amount < 0:
		rem_workers(resource_type, -workers_amount)
		return

	workers += workers_amount

	if (game.population - workers) < 0:
		waiting_lines.push_back([resource_type, workers_amount])
	else:
		create_or_update_line(resource_type, workers_amount)


func rem_workers(resource_type: Resources.Types, workers_amount: int):
	if workers_amount == 0:
		return
	elif workers_amount < 0:
		add_workers(resource_type, -workers_amount)
		return

	workers -= workers_amount

	if not waiting_lines.is_empty():
		var i := waiting_lines.rfind([resource_type, workers_amount])

		if i != -1:
			waiting_lines.remove_at(i)
			return

	if production_lines.has(resource_type):
		var line = production_lines[resource_type]

		line[Production_Line.current_workers] -= workers_amount

		if line[Production_Line.current_workers] == 0:
			production_lines.erase(resource_type)
			return

		line[Production_Line.production_rate] = int(
			line[Production_Line.current_workers] / Recipes.get_recipe_needed_workers(resource_type)
		)

		storage.update_global_production_rate(resource_type)


func population_increase(amount: int):
	var population_pool = amount

	var i := 0

	while i < waiting_lines.size():
		if waiting_lines[i][Waiting_Lines.needed_workers] <= population_pool:
			var waiting_line = waiting_lines.pop_at(i)

			var waiting_line_needed_workers = waiting_line[Waiting_Lines.needed_workers]

			create_or_update_line(
				waiting_line[Waiting_Lines.resource_type], waiting_line_needed_workers
			)

			population_pool -= waiting_line_needed_workers

			if population_pool <= 0:
				break
		else:
			i += 1


func population_decrease(amount: int):
	var population_pool = amount

	while not production_lines.is_empty():
		var resource_type = production_lines.keys().pick_random()

		var line = production_lines[resource_type]

		var current_workers = line[Production_Line.current_workers]

		if current_workers >= amount:
			line[Production_Line.current_workers] -= amount

			waiting_lines.push_back([resource_type, amount])

			population_pool -= amount
		else:
			line[Production_Line.current_workers] = 0

			waiting_lines.push_back([resource_type, current_workers])

			population_pool -= current_workers

		if line[Production_Line.current_workers] == 0:
			production_lines.erase(resource_type)

		storage.update_global_production_rate(resource_type)

		if population_pool <= 0:
			break


func _on_TheTicker_tick():
	for resource_type in production_lines:
		var line = production_lines[resource_type]

		line[Production_Line.current_ticks] += 1

		if line[Production_Line.current_ticks] >= Recipes.get_recipe_needed_ticks(resource_type):
			line[Production_Line.current_ticks] = 0

			storage.add_resource(resource_type, line[Production_Line.production_rate])

func get_factory_save() -> Dictionary:
	return {"Factory":[workers, production_lines, waiting_lines]}
	
func load_factory_save() -> Error:
	if SaveHelper.last_loaded_data.is_empty():
		return FAILED
		
	var factory_data:Array = SaveHelper.last_loaded_data.get("Factory", [])
	
	if factory_data.is_empty():
		return FAILED
		
	workers = factory_data[0]
	
	waiting_lines = factory_data[2]
	
	for line:String in factory_data[1]:
		var resource_type:int = line.to_int()
		
		if not Resources.Types.values().has(resource_type):
			push_error("Cannot create a production line from an unknow resource type: " + line)
			
			continue
		
		production_lines[resource_type] = factory_data[1][line]
		
		storage.update_global_production_rate(resource_type)
		
	return OK
