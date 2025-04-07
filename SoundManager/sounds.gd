extends Node

class_name Sounds

"""
A very basic container for sounds. 
They're simply 2 dictionaries.
"""

var sounds = {}
var musics = {}

func _init():
	var parser = XMLParser.new()
	parser.open_buffer(RDF.decode_bytes(FileAccess.get_file_as_bytes(Globals.gamePath + "/data/system/sounds.rdf")).to_ascii_buffer())
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			var attributes_dict = {}
			for idx in range(parser.get_attribute_count()):
				attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
			if(node_name == "music"):
				musics[attributes_dict["id"]] = attributes_dict["url"]
			if(node_name == "sound"):
				sounds[attributes_dict["id"]] = attributes_dict["url"]
				
func add_sound(id, url) -> int:
	if(id not in sounds):
		sounds[id] = url
		return 0
	else: 
		return 1
		
func add_music(id, url) -> int:
	if(id not in musics):
		musics[id] = url
		return 0
	else: 
		return 1
	
