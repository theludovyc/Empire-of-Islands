extends Object
class_name Buildings

enum Types { Placeholder, Warehouse, Residential, Producing }

enum Ids { Warehouse, Tent, Lumberjack }

enum Datas { Name, Type, Cost, Produce, Max_Workers }

const datas = {
	Ids.Warehouse: {Datas.Name: &"Warehouse", Datas.Type: Types.Warehouse},
	Ids.Tent:
	{
		Datas.Name: &"Tent",
		Datas.Type: Types.Residential,
		Datas.Cost: [[Resources.Types.Wood, 1], [Resources.Types.Textile, 1]],
		Datas.Max_Workers: 4
	},
	Ids.Lumberjack:
	{
		Datas.Name: &"Lumberjack",
		Datas.Type: Types.Producing,
		Datas.Cost: [[Resources.Types.Wood, 1], [Resources.Types.Textile, 1]],
		Datas.Produce: Resources.Types.Wood,
		Datas.Max_Workers: 4
	}
}


# warning: conflict with get_name
static func get_building_name(building_id: Buildings.Ids) -> StringName:
	if not datas.has(building_id):
		push_warning('building of id "%d" was not found ' % building_id)
		return StringName()
	return datas[building_id][Datas.Name]


static func get_building_type(building_id: Buildings.Ids) -> Types:
	if not datas.has(building_id):
		return Types.Placeholder
	return datas[building_id].get(Datas.Type, Types.Placeholder)


static func get_building_cost(building_id: Buildings.Ids) -> Array:
	if not datas.has(building_id):
		return []
	var building_datas = datas[building_id]
	if not building_datas.has(Datas.Cost):
		return []
	return building_datas[Datas.Cost]


static func get_produce_resource(building_id: Buildings.Ids) -> Resources.Types:
	if not datas.has(building_id):
		return -1
	return datas[building_id].get(Datas.Produce, -1)


static func get_max_workers(building_id: Buildings.Ids) -> int:
	if not datas.has(building_id):
		return -1
	return datas[building_id].get(Datas.Max_Workers, -1)
