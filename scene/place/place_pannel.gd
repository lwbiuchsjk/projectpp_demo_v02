extends Control

@export var place_count = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0,place_count):
		var place = preload("res://scene/place/NormalPlace.tscn").instantiate()
		var content = $ScrollContainer
		content.add_item(place)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
