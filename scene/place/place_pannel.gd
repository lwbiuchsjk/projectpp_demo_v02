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
	for placeConfig in placeList:
		var place = preload("res://scene/place/NormalPlace.tscn").instantiate()
		set_place_status(place, placeConfig)
		var content = $ScrollContainer
		content.add_item(place)

func set_place_status(place, placeConfig):
	place.set_placeID(placeConfig.ID)
	var image2Load = place.get_node('TextureRect') as TextureRect
	var imagePath = avgManager.load_picImagePath_from_ID(placeConfig['pic'])
	print("资源路径：",imagePath)
	image2Load.texture = load(imagePath)
	pass
