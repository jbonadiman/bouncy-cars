extends GameScreen

@onready var _phrase := $Center/Buttons/Seed/Phrase as LineEdit


func _on_back_pressed():
	Screens.change_screen(Types.screens.menu)


func _ready() -> void:
	var phrase = Generation.get_three_words_phrase()
	Variables.current_phrase = phrase
	_phrase.text = phrase


func _on_phrase_text_changed(_new_text: String) -> void:
	Variables.current_phrase = _phrase.text


func _on_play_pressed() -> void:
	Screens.change_screen(Types.screens.play)
