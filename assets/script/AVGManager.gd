extends Node

## 用于标记AVG当前状态的参数
var nowAvgSegment:String
var nowPlace:String
var nowPlot:String

## 面板调用节点配置
@onready var rootNode:Node = get_tree().root.get_node("testScean")
## 信息改变信号
## 以下是avg开始时调用的信号
signal new_avg()
signal clean_avg()
signal next_avg()
signal close_avg()
signal build_seat()
## 以下是剧情开始时调用的信号
signal new_plot()
signal select_place()

func _ready() -> void:
	connect("next_avg", set_next_avg)
	connect("build_seat", _on_build_seat)


func set_avg_now(ID):
	if ID == null:
		return
	nowAvgSegment = str(ID)

func set_place_now(ID):
	if ID == null:
		return
	nowPlace = str(ID)

func set_plot_now(ID):
	if ID == null:
		return
	nowPlot = str(ID)


func load_avg_config():
	for avg in GameInfo.avgPlot.values():
		if nowAvgSegment == avg.ID:
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

	var plotSegment = load_plotSegment_from_ID(place['plotSegment'])
	print("检测成功: ", plotSegment.ID)

	## 根据参数设置加载事件节点
	var eventNode = preload("res://scene/event/event.tscn").instantiate()
	rootNode.add_child(eventNode)

	set_avg_now(plotSegment['avg_plot'])

	## 触发信号
	emit_signal("clean_avg")
	await get_tree().create_timer(0.1).timeout
	emit_signal("new_avg")
	pass

## 创建seat功能，允许外部单独调用
func _on_build_seat(nowAvg):
	var eventNode = rootNode.get_node('Event')
	for preSeat in nowAvg['seatList']:
		var testCard = preload("res://scene/Seat/seat.tscn").instantiate() as Seat
		eventNode.add_child_item(testCard)
		var card_type = testCard.search_seat_property(preSeat)
		testCard.set_seat_type([card_type])
	eventNode.arrange_children_bottom_up()
	pass


func set_next_avg():
	var nowAvg = load_avg_config()

	if nowAvg['seatList'].size() > 0:
		print("等待设置卡牌座位")
		return

	if nowAvg['nextID'] == null or nowAvg['nextID'] == "":
		emit_signal("close_avg")
	else:
		nowAvgSegment = nowAvg['nextID']
		emit_signal("new_avg")
