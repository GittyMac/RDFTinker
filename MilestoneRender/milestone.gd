extends Node

class_name Milestone

var slides = []
var mname = "PLACEHOLDER"
var id = 0
var ord = 1
var zone = ""
var is_island = false

func _init(mname, id, ord, slide_info, zone=""):
	self.mname = mname
	self.id = id
	self.ord = int(ord.split("_")[0])
	self.zone = zone
	self.is_island = zone.is_valid_int() and int(zone) <= 30
	add_slide(slide_info[0], slide_info[1], slide_info[2], slide_info[3], slide_info[4])
	
func add_slide(id, ord, img, voice, t):
	slides.append({"id": id, "ord": ord, "url": img, "voice": voice, "t": t})

func add_text(txt):
	slides[-1]["txt"] = txt
