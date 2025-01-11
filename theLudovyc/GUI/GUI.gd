extends CanvasLayer
class_name GUI

@onready var rtl_info := $RichTextLabelInfo

enum { ResourceButton }

const scenes = {ResourceButton: preload("res://theLudovyc/GUI/ResourceButton.tscn")}


func set_rtl_info_text(text: String):
	rtl_info.text = text


func set_rtl_info_text_money_cost(amount: int):
	rtl_info.clear()

	rtl_info.append_text("[center]" + str(amount) + " ")
	rtl_info.add_image(TheBank.money_icon, 20)

func set_rtl_info_buiding_info(building_total_cost:Array):
	rtl_info.clear()

	if building_total_cost.is_empty():
		return

	rtl_info.append_text("[center]")
	
	if building_total_cost[0] != 0:
		rtl_info.append_text("[color=orange]" + \
			Helper.get_string_from_signed_int(building_total_cost[0]) + "[/color] ")
			
		rtl_info.add_image(TheBank.money_icon, 20)
		rtl_info.add_text(" / ")

	for i in range(building_total_cost[1].size()):
		var cost = building_total_cost[1][i]

		if i > 0:
			rtl_info.add_text(" / ")
			
		var color_str = "green"
		
		if cost[1] < 0:
			color_str = "orange"

		rtl_info.append_text("[color=" + color_str + "]" + \
			Helper.get_string_from_signed_int(cost[1]) + "[/color] ")
			
		rtl_info.add_image(Resources.Icons[cost[0]], 20)

func set_rtl_visibility(b: bool):
	rtl_info.visible = b
