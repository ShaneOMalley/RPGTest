class_name UITownRecruitment extends Control

var recruit_buttons: Dictionary[StringName, Button]

func on_click_recruit(config_id: StringName) -> void:
	var recruit_entry := TownManager.current_recruit_data[config_id]
	
	if PlayerPartyManager.gold >= recruit_entry.price:
		PlayerPartyManager.add_participants_async([config_id])
		PlayerPartyManager.gold -= recruit_entry.price
		recruit_entry.is_recruited = true;
		
	update_ui()

func setup_ui() -> void:
	var recruit_data := TownManager.current_recruit_data
	
	for config_id in recruit_data:
		var recruit_entry: TownManager.RecruitEntry = recruit_data[config_id]
		var button = ($Menu/RecruitCharacterTemplate.duplicate() as Button)
		button.pressed.connect(on_click_recruit.bind(recruit_entry.config_id))
		button.show()
		$Menu/RecruitCharacterTemplate.add_sibling(button)
		
		recruit_buttons[config_id] = button
		
	update_ui()

func update_ui() -> void:
	for config_id in recruit_buttons:
		var recruit_entry := TownManager.current_recruit_data[config_id]
		var button = (recruit_buttons[config_id] as Button)
		button.disabled = PlayerPartyManager.gold < recruit_entry.price or recruit_entry.is_recruited
		
		if recruit_entry.is_recruited:
			button.text = "Recruited %s!" % recruit_entry.config_id
		else:
			button.text = "Recruit %s (%d gold)" % [recruit_entry.config_id, recruit_entry.price]
			
	$GoldText.text = "Gold: %d" % PlayerPartyManager.gold
			
func go_back() -> void:
	TownManager.show_town_ui(load("res://ui/town/town_ui.tscn")) # preload doesn't work for some reason

func _ready() -> void:
	$Menu/RecruitCharacterTemplate.hide()
	($Menu/Back as Button).pressed.connect(go_back)
	setup_ui()
