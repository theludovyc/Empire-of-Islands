extends Object
class_name Resources

enum Types { Wood, Textile }

const Icons = {
	Types.Wood: preload("res://Art/Image/Gui/Icons/Resources/32/008.png"),
	Types.Textile: preload("res://Art/Image/Gui/Icons/Resources/32/003.png")
}

enum Datas { Name, Type, }

const datas = {
	Types.Wood: {
		Datas.Name: &"Wood", 
		Datas.Type: Types.Wood
	},
	Types.Textile:
	{
		Datas.Name: &"Textile",
		Datas.Type: Types.Textile,
	},
}

static func get_resource_icon(resource_type: Types) -> Texture2D:
	return Icons.get(resource_type)

# warning: conflict with get_name
static func get_resource_name(resource_type: Types) -> StringName:
	if not datas.has(resource_type):
		push_warning('resource of id "%d" was not found ' % resource_type)
		return StringName()
	return datas[resource_type][Datas.Name]

enum LevelTypes { Gathered, TransformedOnce, TransformedTwice }

const Levels = {Types.Wood: LevelTypes.Gathered, Types.Textile: LevelTypes.TransformedTwice}
