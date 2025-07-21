extends Node

## 用于标记AVG当前状态的参数
var nowAvgID:String
var nowPlace:String
var nowPlot:String
var nowPlotSegmentID:String
var nowPlotSegmentGroupID:String

## 面板调用节点配置
@onready var rootNode:Node = get_tree().root.get_node("testScean")
## 信息改变信号
## 以下是avg开始时调用的信号
signal new_avg()
signal clean_avg()
signal next_avg()
signal close_avg()
signal build_seat()
signal seatSelect_confirm()
## 以下是剧情开始时调用的信号
signal new_plot()
signal select_place()

func _ready() -> void:
	connect("next_avg", set_next_avg)
	connect("build_seat", _on_build_seat)
	connect("seatSelect_confirm", _on_seatSelect_confirm)


func set_avg_now(ID):
	if ID == null:
		return
	nowAvgID = str(ID)

func set_place_now(ID):
	if ID == null:
		return
	nowPlace = str(ID)

func set_plot_now(ID):
	if ID == null:
		return
	nowPlot = str(ID)

func set_plotSegment_now(ID):
	if ID == null:
		return
	nowPlotSegmentID = str(ID)

func set_plotSegmentGroup_now(ID):
	if ID == null:
		return
	nowPlotSegmentGroupID = str(ID)

func load_avg_config():
	for avg in GameInfo.avgPlot.values():
		if nowAvgID == avg.ID:
			return avg

func load_avg_config_value(avg, key):
	return avg[key]

## 返回 place 的配置列表
func load_place_from_plot() -> Array:
	var output:Array
	var tempPlot = load_plot_from_ID(nowPlot)
	# 空值处理
	if tempPlot == null:
		return output

	var placeList = tempPlot['placeList'].split("/")

	for place in placeList:
		var checkPlace = load_place_from_ID(place)
		if checkPlace != null:
			output.append(checkPlace)
	return output


func load_place_from_ID(ID):
	for place in GameInfo.place.values():
		if place.ID == str(ID):
			return place

func load_plot_from_ID(ID):
	for plot in GameInfo.plot.values():
		if plot.ID == str(ID):
			return plot
	return null

func load_plotSegment_from_ID(ID):
	var output
	for segment in GameInfo.plotSegment.values():
		if segment.ID == str(ID):
			output = segment
			break
	return output

func load_plotSegmentGroup_from_ID(ID):
	var output
	for group in GameInfo.plotSegmentGroup.values():
		if group.ID == str(ID):
			output = group
			break
	return output


func load_picImagePath_from_ID(ID):
	var output
	for pic in GameInfo.bgPic.values():
		if pic.ID == ID:
			output = pic['resource']
			break
	return output

## 信号激活函数。将会在配置的根节点上创建事件面板，并根据配置加载槽位，文字。
func build_event(placeID):
	var place = load_place_from_ID(placeID)
	if place == null:
		return

	var plotSegmentGroup = load_plotSegmentGroup_from_ID(place['plotSegmentGroup'])
	print("检测成功: ", plotSegmentGroup.ID)
	##TODO 此处强制写死初始的 group 和 segment 后续需要处理
	set_plotSegmentGroup_now(plotSegmentGroup.ID)
	set_plotSegment_now(plotSegmentGroup['beginSegment'])

	## 根据参数设置加载事件节点
	var eventNode = preload("res://scene/event/event.tscn").instantiate()
	rootNode.add_child(eventNode)

	var nowPlotSegment = load_plotSegment_from_ID(nowPlotSegmentID)
	set_avg_now(nowPlotSegment['avg_plot'])

	## 触发信号
	emit_signal("clean_avg")
	await get_tree().create_timer(0.1).timeout
	emit_signal("new_avg")
	pass

## 创建seat功能，允许外部单独调用
func _on_build_seat(nowPlotSegment):
	var eventNode = rootNode.get_node('Event')
	for preSeat in nowPlotSegment['seatList']:
		var testCard = preload("res://scene/Seat/seat.tscn").instantiate() as Seat
		eventNode.add_child_item(testCard)
		var card_type = testCard.search_seat_property(preSeat)
		testCard.set_seat_type([card_type])
	eventNode.arrange_children_bottom_up()

	## 如果作为列表不为空，那么显示确认按钮
	if nowPlotSegment['seatList'].size() > 0:
		set_seatConfirmButton_status(true)

	pass

func set_seatConfirmButton_status(status:bool):
	var button = rootNode.get_node('Event/SeatConfirmButton') as Button
	button.visible = status


func set_next_avg():
	## 如果当前正在选择，那么阻断点击
	if check_nowAvg_seating():
		return
	## 否则触发新avg
	var nowAvg = load_avg_config()
	nowAvgID = nowAvg['nextID']
	emit_signal("new_avg")

func _on_seatSelect_confirm():
	## 隐藏按钮
	set_seatConfirmButton_status(false)

	##TODO 设置卡牌数据变化

	## 移除座位
	var seatParentNode = rootNode.get_node('Event/PicCardArea/CardArea/Container')
	for child in seatParentNode.get_children():
		if child.is_in_group('Seat'):
			child.remove_from_group('Seat')
			seatParentNode.remove_child(child)

	##TODO 触发检查条件，执行本组内下一段AVG
	pass

func check_nowAvg_seating() -> bool:
	var nowAvg = load_avg_config()
	var nowPlotSegment = load_plotSegment_from_ID(nowPlotSegmentID)

	if (nowAvg['nextID'] == null or nowAvg['nextID'] == "") and nowPlotSegment['seatList'].size() > 0:
		return true
	else:
		return false
