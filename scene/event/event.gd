extends Control
var avgManager = GameInfo.get_node("AVGManager")

signal show_seat_brief_status()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	avgManager.connect("new_avg", _on_new_avg)
	avgManager.connect("clean_avg", _on_clean_avg)
	avgManager.connect("close_avg", _on_close_avg)
	avgManager.connect("draw_npc", _set_npcInfo)
	avgManager.connect("show_event_result", open_card_result_panel)
	connect("show_seat_brief_status", set_seat_brief_status)
	$TextArea/NextAvgButton.pressed.connect(_check_next_avg)
	$SeatBriefPanel/SeatConfirmButton.pressed.connect(_confirm_seatSelect)
	$SeatBriefPanel/SeatPanelTriggerButton.pressed.connect(_on_seatPanelTrigger)
	$EventResult/CollectCardButton.pressed.connect(close_card_result_panel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_child_item(child: Node) -> void:
	$SeatPanel/CardArea/Container.add_child(child)
	child.add_to_group("Seat")
	pass

func arrange_children_bottom_up() -> void:
	$SeatPanel/CardArea/Container.arrange_children_bottom_up()
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
	avgManager.emit_signal("trigger_avg_control")


func _on_close_avg():
	var parent = get_parent()
	if parent:
		print("尝试移除")
		parent.remove_child(self)
	queue_free()
	avgManager.emit_signal("next_plot")
	pass

## 卡牌与座位匹配确认按钮
func _confirm_seatSelect():
	## 关闭 SeatPanel
	var seatPanel = get_node('SeatPanel') as Control
	seatPanel.visible = false
	## 移除座位
	var seatParentNode = $SeatPanel/CardArea/Container
	for child in seatParentNode.get_children():
		if child.is_in_group('Seat'):
			child.remove_from_group('Seat')
			seatParentNode.remove_child(child)
	## 移除 SeatBriefPanel 中的 SeatBrief 实例
	var seatBriefListNode = $SeatBriefPanel/ColorRect/SeatBriefList
	for child in seatBriefListNode.get_children():
		seatBriefListNode.remove_child(child)
	## 触发确认逻辑
	avgManager.emit_signal('seatSelect_confirm')
	pass

## 呼出 SeatPanel 面板。面板常驻，只是调整其是否显示。
func _on_seatPanelTrigger():
	var seatPanel = get_node('SeatPanel') as Control
	seatPanel.visible = !seatPanel.visible

func _set_npcInfo():
	var npcParent = $NPCArea/Container
	## 先清理之前的节点
	for item in npcParent.get_children():
		npcParent.remove_child(item)
	## 再加入新的节点
	##TODO 加入新节点需要读入NPC数据，并做出一定前端表现
	var avg = avgManager.load_avg_config()
	var npcList: Array = avg['NPC']
	for npcID in npcList:
		var npcItem = preload("res://scene/player/npc/npcInfoPanel.tscn").instantiate()
		npcItem.set_npc_data(str(npcID))
		npcItem.show_npc_mindState()
		npcParent.add_child(npcItem)
	pass

## 设置 seat_brief 相关状态
func set_seat_brief_status(index: int, status: bool) -> void:
	var seat_brief_rootNode = $SeatBriefPanel/ColorRect/SeatBriefList
	var seat_brief_node = seat_brief_rootNode.get_child(index)
	print(index)
	print(seat_brief_rootNode)
	print(seat_brief_node)
	seat_brief_node.emit_signal("change_seat_brief_status", status)

## 关闭展示弹板
func close_card_result_panel() -> void:
	if $EventResult.visible == true:
		$EventResult.visible = false
	avgManager.emit_signal("simple_show_next_avg")


## 打开展示弹板
func open_card_result_panel() -> void:
	if $EventResult.visible == false:
		$EventResult.visible = true
