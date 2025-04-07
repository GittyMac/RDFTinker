extends Control

var milestones = []
var sounds
var active_ms = -1
var active_slide = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sounds = Sounds.new()
	for sound in sounds.sounds:
		$Slide_Side/SlideVoice.add_item(sound)
	
	var parser = XMLParser.new()
	parser.open_buffer(RDF.decode_bytes(FileAccess.get_file_as_bytes(Globals.gamePath + "/data/system/milestones.rdf")).to_ascii_buffer())
	var current_ms = null
	var is_text = false
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			var attributes_dict = {}
			for idx in range(parser.get_attribute_count()):
				attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
			if("name" in attributes_dict and attributes_dict["name"] != ""):
				if(current_ms != null):
					milestones.append(current_ms)
				if("zone" in attributes_dict):
					current_ms = Milestone.new(attributes_dict["name"], attributes_dict["id"], attributes_dict["ord"], [attributes_dict["id"], attributes_dict["ord"], attributes_dict["url"], attributes_dict["voice"], attributes_dict["t"]], attributes_dict["zone"])
				else:
					current_ms = Milestone.new(attributes_dict["name"], attributes_dict["id"], attributes_dict["ord"], [attributes_dict["id"], attributes_dict["ord"], attributes_dict["url"], attributes_dict["voice"], attributes_dict["t"]])
			elif(node_name == "slide"):
				current_ms.add_slide(attributes_dict["id"], attributes_dict["ord"], attributes_dict["url"], attributes_dict["voice"], attributes_dict["t"])
			if(node_name == "txt"):
				is_text = true
		elif parser.get_node_type() == XMLParser.NODE_TEXT and is_text:
			current_ms.add_text(parser.get_node_data()) 
			is_text = false
	milestones.append(current_ms)
	refresh_ms()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(active_slide == -1):
		toggle_slide_controls(true, true)
	else:
		toggle_slide_controls(false)
	if(active_ms == -1):
		toggle_ms_controls(true, true)
	else:
		toggle_ms_controls(false)
		
func toggle_slide_controls(disabled: bool, clear: bool = false) -> void:
	"""
	Activates/deactivates slide controls and clears if prompted.
	"""
	if(clear):
		var ph = PlaceholderTexture2D.new()
		ph.size = Vector2(300,200)
		$Slide_Side/ImagePreview.texture = ph
		$Slide_Side/SlideImg.text = ""
		$Slide_Side/SlideLength.text = ""
		$Slide_Side/SlideText.text = ""
		$Slide_Side/SlideVoice.selected = -1
	
	$MSInfo/SlideControls/SlideUp.disabled = disabled
	$MSInfo/SlideControls/SlideDown.disabled = disabled
	$MSInfo/SlideControls/SlideAdd.disabled = disabled
	$MSInfo/SlideControls/SlideRem.disabled = disabled

	$Slide_Side/SlideImg.editable = not disabled
	$Slide_Side/SlideLength.editable = not disabled
	$Slide_Side/SlideText.editable = not disabled
	$Slide_Side/SaveSlide.disabled = disabled
	for i in range($Slide_Side/SlideVoice.item_count):
		$Slide_Side/SlideVoice.set_item_disabled(i, disabled)
		
func toggle_ms_controls(disabled: bool, clear: bool = false) -> void:
	"""
	Activates/deactivates milestone controls and clears if prompted.
	"""
	if(clear):
		$MSInfo/MSNameText.text = ""
		$MSInfo/MSZoneText.text = ""
		$MSInfo/MSOrdIDText.text = ""
		$MSInfo/ScrollContainer/SlideList.clear()
	
	$MSSide/SaveMS.disabled = disabled
	$MSSide/GridContainer/AddMS.disabled = disabled
	$MSSide/GridContainer/RemMS.disabled = disabled
	$MSSide/GridContainer/UpMS.disabled = disabled
	$MSSide/GridContainer/DownMS.disabled = disabled
	for i in range($MSInfo/ScrollContainer/SlideList.item_count):
		$MSInfo/ScrollContainer/SlideList.set_item_disabled(i, disabled)
	$MSInfo/MSNameText.editable = not disabled
	$MSInfo/MSZoneText.editable = not disabled
	$MSInfo/MSOrdIDText.editable = not disabled
	$MSInfo/PrvMS.disabled = disabled
	$MSInfo/SaveMS.disabled = disabled
	
func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	"""
	Triggers a UI switch on the milestone viewed.
	"""
	if mouse_button_index == 1:
		if(active_ms != index): active_slide = -1
		active_ms = index
		
		$MSInfo/MSNameText.text = milestones[active_ms].mname
		$MSInfo/MSZoneText.text = milestones[active_ms].zone
		$MSInfo/MSOrdIDText.text = str(milestones[active_ms].ord)
		if(index + 1 == len(milestones)):
			$MSSide/GridContainer/DownMS.disabled = true
		else:
			$MSSide/GridContainer/DownMS.disabled = false
		if(index == 0):
			$MSSide/GridContainer/UpMS.disabled = true
		else:
			$MSSide/GridContainer/UpMS.disabled = false
		refresh_slides()
	
func _on_item_list_slide_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	"""
	Triggers a UI switch on the slide viewed.
	"""
	if mouse_button_index == 1:
		active_slide = index
		var img = Image.new() 
		img.load(Globals.gamePath + "/misc/" + milestones[active_ms].slides[index]["url"])
		var t = ImageTexture.create_from_image(img)
		$Slide_Side/ImagePreview.texture = t
		$Slide_Side/SlideImg.text = milestones[active_ms].slides[index]["url"]
		for i in range($Slide_Side/SlideVoice.item_count):
			if($Slide_Side/SlideVoice.get_item_text(i) == milestones[active_ms].slides[index]["voice"]):
				$Slide_Side/SlideVoice.selected = i
		$Slide_Side/SlideLength.text = milestones[active_ms].slides[index]["t"]
		$Slide_Side/SlideText.text = milestones[active_ms].slides[index]["txt"]
		print(len(milestones[active_ms].slides))
		if(index + 1 == len(milestones[active_ms].slides)):
			$MSInfo/SlideControls/SlideDown.disabled = true
		else:
			$MSInfo/SlideControls/SlideDown.disabled = false
		if(index == 0):
			$MSInfo/SlideControls/SlideUp.disabled = true
		else:
			$MSInfo/SlideControls/SlideUp.disabled = false
		if(len(milestones[active_ms].slides) == 1):
			$MSInfo/SlideControls/SlideRem.disabled = true
		else:
			$MSInfo/SlideControls/SlideRem.disabled = false

func refresh_ms():
	"""
	Reloads the UI for milestones.
	"""
	$MSSide/ScrollContainer/MSList.clear()
	for ms in milestones:
		var img = Image.new() 
		img.load(Globals.gamePath + "/misc/" + ms.slides[0]["url"])
		img.resize(300, 200)
		var t = ImageTexture.create_from_image(img)
		
		$MSSide/ScrollContainer/MSList.add_item(str(ms.ord) + " - " + ms.mname, t, true)
		
	if(active_ms != -1):
		$MSSide/ScrollContainer/MSList.select(active_ms)
		_on_item_list_item_clicked(active_ms, Vector2.ZERO, 1)

func refresh_slides():
	"""
	Reloads the UI for slides.
	"""
	$MSInfo/ScrollContainer/SlideList.clear()
	for slide in milestones[active_ms].slides:
		$MSInfo/ScrollContainer/SlideList.add_item(slide["txt"], null, true)
	if(active_slide != -1):
		$MSInfo/ScrollContainer/SlideList.select(active_slide)
		_on_item_list_slide_clicked(active_slide, Vector2.ZERO, 1)

func _add_slide() -> void:
	"""
	Adds a new slide to the end of a milestone.
	"""
	if(active_ms != -1):
		$MSInfo/ScrollContainer/SlideList.add_item("Placeholder!", null, true)
		milestones[active_ms].add_slide("0", str(len(milestones[active_ms].slides)), "image1_1.jpg", "ms_1", "8")
		milestones[active_ms].add_text("Placeholder!")
		
func _move_up() -> void:
	"""
	Moves up the list/down the indexes.
	"""
	var temp = milestones[active_ms].slides[active_slide - 1]
	milestones[active_ms].slides[active_slide - 1] = milestones[active_ms].slides[active_slide]
	milestones[active_ms].slides[active_slide] = temp
	active_slide = active_slide - 1
	refresh_ms()
	refresh_slides()

func _move_down() -> void:
	"""
	Moves down the list/up the indexes.
	"""
	var temp = milestones[active_ms].slides[active_slide + 1]
	milestones[active_ms].slides[active_slide + 1] = milestones[active_ms].slides[active_slide]
	milestones[active_ms].slides[active_slide] = temp
	active_slide = active_slide + 1
	refresh_ms()
	refresh_slides()
	
func _apply_changes() -> void:
	"""
	Applies slide changes.
	"""
	milestones[active_ms].slides[active_slide]["url"] = $Slide_Side/SlideImg.text
	milestones[active_ms].slides[active_slide]["voice"] = $Slide_Side/SlideVoice.get_item_text($Slide_Side/SlideVoice.selected)
	milestones[active_ms].slides[active_slide]["t"] = $Slide_Side/SlideLength.text
	milestones[active_ms].slides[active_slide]["txt"] = $Slide_Side/SlideText.text
	active_slide = -1
	refresh_slides()
	refresh_ms()

func _preview_ms() -> void:
	"""
	Plays the milestone preview like in-game.
	"""
	toggle_slide_controls(true)
	toggle_ms_controls(true)
	
	for i in range($MSSide/ScrollContainer/MSList.item_count):
		$MSSide/ScrollContainer/MSList.set_item_disabled(i, true)
	
	$MSInfo/ScrollContainer/SlideList.select(0)
	_on_item_list_slide_clicked(0, Vector2.ZERO, 1)
	var soundfx = Globals.gamePath + "/soundfx/"
	var sound = AudioStreamMP3.new()
	if(milestones[active_ms].is_island):
		var file = FileAccess.open(soundfx + "milestone_sting_island.mp3", FileAccess.READ)
		sound.data = file.get_buffer(file.get_length())
	else:
		var file = FileAccess.open(soundfx + "milestone_sting.mp3", FileAccess.READ)
		sound.data = file.get_buffer(file.get_length())
	$MSAudio.stream = sound
	$MSAudio.play()
	await $MSAudio.finished
	
	var audios = []
	var i = 0
	for slide in milestones[active_ms].slides:
		$MSInfo/ScrollContainer/SlideList.select(i)
		_on_item_list_slide_clicked(i, Vector2.ZERO, 1)
		audios.append(Globals.play_sound(soundfx + sounds.sounds[slide["voice"]]))
		await get_tree().create_timer(int(slide["t"])).timeout
		i += 1
	for audio in audios:
		if audio != null:
			Globals.stop_sound(audio)
	toggle_slide_controls(false)
	toggle_ms_controls(false)
	for i2 in range($MSSide/ScrollContainer/MSList.item_count):
		$MSSide/ScrollContainer/MSList.set_item_disabled(i2, false)

func _delete_slide() -> void:
	"""
	Removes slide from the milestone.
	"""
	milestones[active_ms].slides.remove_at(active_slide)
	active_slide = -1
	refresh_ms()
	refresh_slides()
	
func _ms_remove() -> void:
	"""
	Removes milestone from the collection.
	"""
	milestones.remove_at(active_ms)
	active_ms = -1
	refresh_ms()
	refresh_slides()

func _ms_add() -> void:
	"""
	Adds milestone to the collection.
	"""
	var current_ms = Milestone.new("New Milestone", "", "", ["0", "1", "image1_1.jpg", "ms_1", "8"])
	current_ms.add_text("Placeholder!")
	active_ms = len(milestones)
	milestones.append(current_ms)
	refresh_ms()
	refresh_slides()

func _save_ms() -> void:
	"""
	Repacks and saves milestone.rdf to the system folder.
	"""
	var xml = XML.new("milestones", {"version": "4.0.01"})
	var current_id = 0
	var zone_variants = {}
	for ms in milestones:
		var slide_id = 0
		
		for slide in ms.slides:
			var info = {"id": str(current_id), "ord": str(ms.ord) + "_" + str(slide_id), "url": slide["url"], "voice": slide["voice"], "t": slide["t"]}
			if(ms.zone != ""):
				info["zone"] = ms.zone
			if(slide_id == 0):
				info["name"] = ms.mname
			xml.add_element("slide", true, info)
			xml.add_element("txt", true)
			xml.add_text(slide["txt"])
			xml.close_element("txt")
			xml.close_element("slide")
			slide_id += 1
			current_id += 1
	var data = xml.finish_and_save(Globals.gamePath + "/data/system/milestones.rdf")
	Globals.show_msg("Milestones have been saved!", "Saved")

func _apply_ms_settings() -> void:
	"""
	Applies milestone settings.
	"""
	milestones[active_ms].mname = $MSInfo/MSNameText.text
	milestones[active_ms].zone = $MSInfo/MSZoneText.text
	milestones[active_ms].ord = $MSInfo/MSOrdIDText.text
	refresh_ms()

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
