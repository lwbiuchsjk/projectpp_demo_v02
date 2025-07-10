extends Control

@export var place_count = 6
var avgManager = GameInfo.get_node("AVGManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avgManager.connect('new_plot', build_place)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_place():
	var placeList:Array = avgManager.load_place_from_plot()
	print("检测生成地点数量：",placeList.size())
	for i in range(0,placeList.size()):
		var place = preload("res://scene/place/NormalPlace.tscn").instantiate()
		set_place_status()
		var content = $ScrollContainer
		content.add_item(place)

func set_place_status():
	pass
