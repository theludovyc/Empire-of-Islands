extends PanelContainer

@onready var rtl := $VBoxContainer/PanelContainer/RichTextLabel


func set_building_info(building_id: Buildings.Ids):
	rtl.clear()

	var building_cost = Buildings.get_building_cost(building_id)

	if building_cost.is_empty():
		return

	rtl.add_text("%s\n" % Buildings.get_building_name(building_id))
	rtl.add_text("Cost :\n")

	for i in range(building_cost.size()):
		var cost = building_cost[i]

		if i > 0:
			rtl.add_text(" / ")

		rtl.add_text(str(cost[1]) + " ")
		rtl.add_image(Resources.Icons[cost[0]], 20)


func set_money_production_rate_info(production_rate: int = 0):
	rtl.clear()
	rtl.append_text("[center]")
	rtl.add_image(TheBank.money_icon, 20)

	var text_sign = "+" if production_rate >= 0 else ""

	rtl.append_text("(" + text_sign + str(production_rate) + ")")
	pass
