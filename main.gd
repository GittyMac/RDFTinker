extends Control

var tools = {"Milestone Editor": "res://MilestoneRender/MilestoneEditor.tscn",
			 "Sound Editor": "res://SoundManager/SoundEditor.tscn"}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Globals.gamePath == ""):
		$FileDialog.show()
	else:
		for tool in tools:
			$ItemList.add_item(tool)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_dir_selected(dir: String) -> void:
	Globals.gamePath = dir
	if(not FileAccess.file_exists(Globals.gamePath + "/Main.swf")):
		var msg = Globals.show_msg("This is not a valid game path.", "Error")
		await msg.tree_exiting
		$FileDialog.show()
	else:
		for tool in tools:
			$ItemList.add_item(tool)

func _on_file_dialog_canceled() -> void:
	get_tree().quit()

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	get_tree().change_scene_to_file(tools[$ItemList.get_item_text(index)])

func _on_change_dir_pressed() -> void:
	Globals.gamePath = ""
	$FileDialog.show()

func _on_about_pressed() -> void:
	Globals.show_msg("RDFTinker " + ProjectSettings.get_setting("application/config/version") + "\n\nDeveloped by Lako\nLicensed under MIT License.\n\nUses adapted code from py-rdf:\nhttps://github.com/JakeSESaunders/py-rdf", "About RDFTinker")
