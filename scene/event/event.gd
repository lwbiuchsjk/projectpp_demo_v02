extends Control
var avgManager = GameInfo.get_node("AVGManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avgManager.connect("new_avg", _on_new_avg)
	avgManager.connect("clean_avg", _on_clean_avg)
	$TextArea/NextAvgButton.pressed.connect(_check_next_avg)
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


func _on_clean_avg():
	$TextArea/ScrollContainer/Label.text = ""

func _on_new_avg():
	var avg = avgManager.load_avg_config()
	## 设置文字
	var avgText = avg.words
	## 设置图片
	var avgBgPic = avgManager.load_picImagePath_from_ID(avg.backgroundPic)
	var nowText = $TextArea/ScrollContainer/Label.text
	if nowText == "":
		$TextArea/ScrollContainer/Label.text = avgText
	else:
		$TextArea/ScrollContainer/Label.text = nowText + "\n\n" + avgText
	$PicCardArea/EventImage.texture = load(avgBgPic)

func _check_next_avg():
	avgManager.emit_signal("next_avg")
	print("执行下一步AVG")
