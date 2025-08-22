extends Node
class_name AVGManager

## 用于标记AVG当前状态的参数
var nowAvgID:String
var nowPlace:String
var nowPlot:String
var nowPlotSegmentID:String
var nowPlotSegmentGroupID:String
var seatPair:Dictionary

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
signal draw_npc()
## 以下是剧情开始时调用的信号
signal new_plot()
signal next_plot()
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
	var output
	for plot in GameInfo.plot.values():
		if plot.ID == str(ID):
			output = plot
			break
	return output

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
	##TODO 此处强制写死初始的 group 和 segment 后续需要处理
	set_plotSegmentGroup_now(place['plotSegmentGroup'])
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
func _on_build_seat(avg):
	var eventNode = rootNode.get_node('Event')
	var raw_seatPair = {}
	for preSeat in avg['seatList']:
		var testCard = preload("res://scene/Seat/seat.tscn").instantiate() as Seat
		eventNode.add_child_item(testCard)
		var card_type = testCard.search_seat_property(preSeat)
		testCard.set_seat_type([card_type])
		## 将座位数据提取出来，制作字典，用于检查匹配情况
		raw_seatPair[preSeat] = -1
	eventNode.arrange_children_bottom_up()
	seatPair = raw_seatPair

	## 如果作为列表不为空，那么显示确认按钮
	if avg['seatList'].size() > 0:
		set_seatConfirmButton_status(true)

	pass

## 设置 seatPair
func set_seatPair(key:String, value):
	seatPair[key] = value

func set_seatConfirmButton_status(status:bool):
	var button = rootNode.get_node('Event/SeatConfirmButton') as Button
	button.visible = status


func set_next_avg(nextAvgID = null):
	## 如果当前正在选择，那么阻断点击
	if nextAvgID == null and check_nowAvg_seating():
		return
	## 否则触发新avg
	var nowAvg = load_avg_config()

	if nextAvgID == null:
		nowAvgID = nowAvg['nextID']
	else:
		nowAvgID = nextAvgID

	if nowAvgID != null and nowAvgID != "":
		emit_signal("new_avg")
		emit_signal("draw_npc")
		return

	if nowAvg['nextID'] == null or nowAvg['nextID'] == "":
		emit_signal("close_avg")


func _on_seatSelect_confirm():
	## 隐藏按钮
	set_seatConfirmButton_status(false)

	##TODO 设置卡牌数据变化

	## 移除座位
	var seatParentNode = rootNode.get_node('Event/CardArea/Container')
	for child in seatParentNode.get_children():
		if child.is_in_group('Seat'):
			child.remove_from_group('Seat')
			seatParentNode.remove_child(child)

	## 触发检查条件，执行本组内下一段AVG。AVG跳转分支功能在函数内部实现。
	check_next_segment_condition()
	pass

func check_nowAvg_seating() -> bool:
	var nowAvg = load_avg_config()

	if (nowAvg['nextID'] == null or nowAvg['nextID'] == "") and nowAvg['seatList'].size() > 0:
		return true
	else:
		return false

## 根据当前座位设置条件，判断下一个执行的segment
func check_next_segment_condition():
	var blank_segmentID
	var maxPoint_segmentID
	var now_maxPoint = 0
	for segment in GameInfo.plotSegment.values():
		if segment['group'] == nowPlotSegmentGroupID:
			var condition_point = _check_segment_condition_point_gen(segment['condition'])
			if condition_point == -1:
				blank_segmentID = segment.ID
				continue
			if condition_point >= now_maxPoint:
				maxPoint_segmentID = segment.ID
				continue

	print("检查到全空的AVG跳转ID: ", blank_segmentID)
	print("检查到当前最匹配的AVG跳转ID: ", maxPoint_segmentID)
	var nextSegment
	if maxPoint_segmentID != null:
		nextSegment = load_plotSegment_from_ID(maxPoint_segmentID)
	else:
		nextSegment = load_plotSegment_from_ID(blank_segmentID)
	emit_signal("next_avg", nextSegment['avg_plot'])
	pass

## 条件计分函数。通过最终得分，来给condition的匹配情况进行评价。分数越高，评价结果越好。正常 condition 的得分都会大于 0 。
## 但特别的，condition 只有全部被满足，才会得分，否则计分为 -999。
## 特别的，对于【全空条件】，计分自动为 -1。
func _check_segment_condition_point_gen(condition) -> int:
	## 如果是全空的结果，那么得分为 -1
	if typeof(condition) == TYPE_INT and condition == -1:
		return condition

	## 空字典自动给最小分数，会被忽略
	if condition.size() == 0:
		return -999

	## 其他情况下，从0开始积分，每有一个 condition_pair 被 seatPair 中结果匹配，那么就得到1分。
	##TODO 如果有更细致的匹配结果，例如【类型继承】的匹配，那么此处计分规则需要改变
	var point = 0
	for key in condition.keys():
		if key in seatPair.keys() and condition[key] == seatPair[key]:
			point += 1
	## 特别的，此处得分为【且】。也即，如果不是条件全部满足，那么不会得到任何分数。默认返回-999，在外部会忽略此结果
	if point != condition.size():
		point = -999
	return point


## 检查满足条件的 plot.
func locate_nowPlot():
	## 首先检查 nowPlot 是否未被初始化。如果是，那么通过 prePlot = -1，定位第一个plot.
	if nowPlot == "":
		for plotItem in GameInfo.plot.values():
			if plotItem['prePlot'] == "-1":
				set_plot_now(plotItem.ID)
				return

	## 然后检查是否为最后一个Plot。通过检查 condition = END，定位最后一个plot.
	if check_end_plot():
		##TODO 此处需要对结束plot做后续前端表现处理
		print("END PLOT")
		return

	## 通过上述检查后，正常执行 prePlot 和 condition 的检查，定位下一个 plot.
	for plotItem in GameInfo.plot.values():
		if plotItem['prePlot'] == nowPlot:
			## 只有 prePlot 为当前 plot 并且通过 condition 检查的 plot，才会被设置，然后继续下去。
			if check_plot_condition():
				set_plot_now(plotItem.ID)
				return


func check_end_plot():
	var plot = load_plot_from_ID(nowPlot)
	for key in plot['condition'].keys():
		if key == "END":
			return true
	return false

##TODO 本方法为检查 plot conditon 的具体实现。需要根据需求细化。
func check_plot_condition() -> bool:
	return true
