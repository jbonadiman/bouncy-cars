extends GameScreen

@onready var _quit := $Center/Buttons/Quit


func _ready() -> void:
	if OS.has_feature("HTML5") \
		or OS.get_name() == "iOS" \
		or OS.get_name() == "Android":

		_quit.visible = false


func _on_new_game_pressed() -> void:
	Screens.change_screen(Constants.screens.new_game)


func _on_quit_pressed() -> void:
	get_tree().quit()
