extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameInfo.connect("new_avg", _on_new_avg)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_child_item(child: Node) -> void:
	$PicCardArea/CardArea/Container.add_child(child)
	pass
	
func arrange_children_bottom_up() -> void:
	$PicCardArea/CardArea/Container.arrange_children_bottom_up()
	pass


func _on_new_avg():
	var segmentText = GameInfo.load_avg_config()
	$TextArea/ScrollContainer/Label.text = segmentText
