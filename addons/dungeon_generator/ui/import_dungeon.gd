@tool
extends Button

func _on_file_loaded(filename: String) -> void:
    var json_file := FileAccess.open(filename, FileAccess.READ)
    var data := JSON.parse_string(json_file.get_as_text())
    DungeonSceneGenerator.generate_dungeon(data)
    print(filename)

func _onpressed():
    var file_dialog := FileDialog.new()
    file_dialog.clear_filters()
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    file_dialog.filters = ["*.tmj ; Tiled Json Files"]
    # file_dialog.position = Vector2(100, 100)
    file_dialog.size = Vector2(800, 600)
    add_child(file_dialog)
    file_dialog.file_selected.connect(_on_file_loaded)
    file_dialog.popup()

    print("pressed")
    pass

func _enter_tree() -> void:
    pressed.connect(_onpressed)
    print("READY")