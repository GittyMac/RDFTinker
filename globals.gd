extends Node

var gamePath = "";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_msg(msg, title="Title"):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = msg
	dialog.title = title
	dialog.connect('confirmed', Callable(dialog, 'queue_free'))
	dialog.connect('canceled', Callable(dialog, 'queue_free'))
	Engine.get_main_loop().current_scene.add_child(dialog)
	dialog.popup_centered()
	return dialog
	
func play_sound(file) -> AudioStreamPlayer:
	var sound_file = FileAccess.open(file, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = sound_file.get_buffer(sound_file.get_length())
	var audio = AudioStreamPlayer.new()
	Engine.get_main_loop().current_scene.add_child(audio)
	audio.connect('finished', Callable(audio, 'queue_free'))
	audio.stream = sound
	audio.play()
	return audio

func stop_sound(audio):
	audio.stop()
