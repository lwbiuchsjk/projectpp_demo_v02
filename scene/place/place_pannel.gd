extends Control

@export var place_count = 6
@onready var content = $ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameInfo.avgManager.connect('new_plot', _on_new_plot)
	GameInfo.avgManager.connect('next_plot', _on_new_plot)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_place():
	var placeList:Array = GameInfo.avgManager.load_place_from_plot()
	for placeConfig in placeList:
		var place = preload("res://scene/place/NormalPlace.tscn").instantiate()
		set_place_status(place, placeConfig)
		content.add_item(place)

func set_place_status(place, placeConfig):
	place.set_placeID(placeConfig.ID)
	var image2Load = place.get_node('TextureRect') as TextureRect
	var imagePath = GameInfo.avgManager.load_picImagePath_from_ID(placeConfig['pic'])
	print("资源路径：",imagePath)
	image2Load.texture = load(imagePath)
	pass



func clean_place():
	content.clean_item()



func _on_new_plot():
	clean_place()
	## 判断条件
	if GameInfo.avgManager.locate_nowPlot():
		print("nowPlot: ", GameInfo.avgManager.nowPlot)
		if GameInfo.avgManager.check_mindStateSwarm():
			print("当前 mindStateSwarm: %s"%[GameInfo.cardDataManager.nowMindStateSwarm])
		build_place()

