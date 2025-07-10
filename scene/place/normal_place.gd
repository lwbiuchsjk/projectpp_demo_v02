extends Control

var placeID
@onready var selectButton = $SelectButton
var avgManager = GameInfo.get_node("AVGManager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectButton.connect("button_up", _on_button_up)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_placeID(ID):
	placeID = ID

func _on_button_up():
	avgManager.build_event(placeID)
