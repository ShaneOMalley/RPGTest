class_name UIBattleMenuEntry extends Button

func disconnect_all() -> void:
	for connection in pressed.get_connections():
		pressed.disconnect(connection.callable)
		
	for connection in mouse_entered.get_connections():
		mouse_entered.disconnect(connection.callable)
		
	for connection in mouse_exited.get_connections():
		mouse_exited.disconnect(connection.callable)
