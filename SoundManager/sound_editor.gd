extends GridContainer

var sound_or_music_tab = 0
var current_sound = ""
var sounds
var playing = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sounds = Sounds.new()
	for sound in sounds.sounds:
		$SoundList/ScrollContainer/Sounds.add_item(sound)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
	
func _on_sounds_pressed() -> void:
	sound_or_music_tab = 0
	refresh_sounds()
	
func _on_music_pressed() -> void:
	sound_or_music_tab = 1
	refresh_sounds()
		
func refresh_sounds():
	$SoundList/ScrollContainer/Sounds.clear()
	if sound_or_music_tab == 0:
		for sound in sounds.sounds:
			$SoundList/ScrollContainer/Sounds.add_item(sound)
	else:
		for sound in sounds.musics:
			$SoundList/ScrollContainer/Sounds.add_item(sound)
	$SoundInfo/ID.text = ""
	$SoundInfo/File.text = ""
	current_sound = ""

func _add_sound() -> void:
	if sound_or_music_tab == 0:
		sounds.sounds["New Sound"] = "milestone_sting.mp3"
		refresh_sounds()
		$SoundList/ScrollContainer/Sounds.select(len(sounds.sounds) - 1)
		_on_sounds_item_clicked(len(sounds.sounds) - 1, Vector2.ZERO, 1)
	else:
		sounds.musics["New Music"] = "milestone_sting.mp3"
		refresh_sounds()
		$SoundList/ScrollContainer/Sounds.select(len(sounds.musics) - 1)
		_on_sounds_item_clicked(len(sounds.musics) - 1, Vector2.ZERO, 1)
	
func _remove_sound() -> void:
	if current_sound != "":
		if sound_or_music_tab == 0:
			sounds.sounds.erase(current_sound)
			refresh_sounds()
		else:
			sounds.musics.erase(current_sound)
			refresh_sounds()
		

func _on_sounds_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		var id = $SoundList/ScrollContainer/Sounds.get_item_text(index)
		$SoundInfo/ID.text = id
		current_sound = id
		
		if sound_or_music_tab == 0:
			$SoundInfo/File.text = sounds.sounds[id]
		else:
			$SoundInfo/File.text = sounds.musics[id]

func _play_sound() -> void:
	if current_sound != "":
		if sound_or_music_tab == 0:
			if FileAccess.file_exists(Globals.gamePath + "/soundfx/" + sounds.sounds[current_sound]):
				playing.append(Globals.play_sound(Globals.gamePath + "/soundfx/" + sounds.sounds[current_sound]))
			else:
				Globals.show_msg("Sound does not exist in files!", "Error!")
		else:
			if FileAccess.file_exists(Globals.gamePath + "/Music/" + sounds.musics[current_sound]):
				playing.append(Globals.play_sound(Globals.gamePath + "/Music/" + sounds.musics[current_sound]))
			elif FileAccess.file_exists(Globals.gamePath + "/soundfx/" + sounds.musics[current_sound]):
				playing.append(Globals.play_sound(Globals.gamePath + "/soundfx/" + sounds.musics[current_sound]))
			else:
				Globals.show_msg("Music does not exist in files!", "Error!")
				
func _stop_sound() -> void:
	for audio in playing:
		if audio == null:
			playing.erase(audio)
		else:
			Globals.stop_sound(audio)
			playing.erase(audio)

func _save_sound() -> void:
	if current_sound != "":
		if sound_or_music_tab == 0:
			if($SoundInfo/ID.text != current_sound):
				sounds.sounds.erase(current_sound)
			sounds.sounds[$SoundInfo/ID.text] = $SoundInfo/File.text
		else:
			if($SoundInfo/ID.text != current_sound):
				sounds.musics.erase(current_sound)
			sounds.musics[$SoundInfo/ID.text] = $SoundInfo/File.text
		refresh_sounds()

func _save_file() -> void:
	"""
	Repacks and saves sounds.rdf to the system folder.
	"""
	var xml = XML.new("game-data", {"version": "4.0.02"})
	
	xml.add_element("musics", true)
	for music in sounds.musics:
		var info = {"id": music, "url": sounds.musics[music]}
		xml.add_element("music", false, info)
	xml.close_element("musics")
	
	xml.add_element("sounds", true)
	for sound in sounds.sounds:
		var info = {"id": sound, "url": sounds.sounds[sound]}
		xml.add_element("sound", false, info)
	xml.close_element("sounds")

	var data = xml.finish_and_save(Globals.gamePath + "/data/system/sounds.rdf")
	Globals.show_msg("Sounds have been saved!", "Saved")
