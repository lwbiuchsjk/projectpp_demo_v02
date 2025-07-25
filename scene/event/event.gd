extends Control
var avgManager = GameInfo.get_node("AVGManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avgManager.connect("new_avg", _on_new_avg)
	avgManager.connect("clean_avg", _on_clean_avg)
	avgManager.connect("close_avg", _on_close_avg)
	$TextArea/NextAvgButton.pressed.connect(_check_next_avg)
	$SeatConfirmButton.pressed.connect(_confirm_seatSelect)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_child_item(child: Node) -> void:
	$PicCardArea/CardArea/Container.add_child(child)
	child.add_to_group("Seat")
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

	if avgBgPic != null:
		$PicCardArea/EventImage.texture = load(avgBgPic)

	if avg['seatList'].size() > 0:
		print("创建座位，AVGID：" + avg.ID)
		avgManager.emit_signal("build_seat", avg)


func _check_next_avg():
	print("执行下一步AVG")
	avgManager.emit_signal("next_avg")


func _on_close_avg():
	var parent = get_parent()
	if parent:
		print("尝试移除")
		parent.remove_child(self)
	queue_free()
	avgManager.emit_signal("next_plot")
	pass

func _confirm_seatSelect():
	avgManager.emit_signal('seatSelect_confirm')
	pass
