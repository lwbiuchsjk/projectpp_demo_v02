extends Control

var npcData: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_npc_data(npcID: String) -> void:
	for npc in GameInfo.npcInfo.values():
		if npc["ID"] == npcID:
			npcData = npc
			print(npcData)
			return

