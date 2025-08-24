class_name StateBattleUISetup extends FSMState

func on_enter() -> void:
	BattleManager.request_ui_setup()
