class_name UITown extends Control

var _language := "en"

func _start_dungeon() -> void:
	TownManager.remove_town_scene()
	DungeonManager.reset()
	DungeonManager.goto_next_floor()
	
func _do_recruitment() -> void:
	TownManager.show_town_ui(preload("res://ui/town/town_recruitment_ui.tscn"))
	
func _do_challenge_mode() -> void:
	TownManager.show_town_ui(preload("res://ui/town/town_challenge_mode_ui.tscn"))

func _update_locale() -> void:
	var current_locale := TranslationServer.get_locale()
	if current_locale == "jp" or current_locale == "en":
		_language = current_locale
	else:
		_language = "en"
	TranslationServer.set_locale(_language)
	_on_langauge_changed()
	
func _change_language() -> void:
	_language = "jp" if _language == "en" else "en"
	TranslationServer.set_locale(_language)
	_on_langauge_changed()
	
func _on_langauge_changed() -> void:
	($Menu/StartDungeon as Button).text = tr("UI_START_DUNGEON")
	($Menu/ChallengeMode as Button).text = tr("UI_CHALLENGE_MODE")
	($Menu/Recruitment as Button).text = tr("UI_RECRUITMENT")
	if _language == "en":
		($Menu/ChangeLanguage as Button).text = tr("UI_LANGUAGE_CHANGE_TO_JAPANESE")
	elif _language == "jp":
		($Menu/ChangeLanguage as Button).text = tr("UI_LANGUAGE_CHANGE_TO_ENGLISH")
	
	
var has_set_initial_locale := false
func _ready() -> void:
	($Menu/StartDungeon as Button).pressed.connect(_start_dungeon)
	($Menu/ChallengeMode as Button).pressed.connect(_do_challenge_mode)
	($Menu/Recruitment as Button).pressed.connect(_do_recruitment)
	($Menu/ChangeLanguage as Button).pressed.connect(_change_language)
	($Menu/StartDungeon as Button).grab_focus()
	_update_locale()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_on_langauge_changed()
