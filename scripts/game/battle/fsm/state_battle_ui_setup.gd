class_name StateBattleUISetup extends FSMState

func on_enter() -> void:
	BattleManager.request_battle_ui_setup()
