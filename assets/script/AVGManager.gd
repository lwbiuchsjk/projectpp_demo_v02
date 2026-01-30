extends Node
class_name AVGManager

## 用于标记AVG当前状态的参数
var nowAvgID:String
var nowPlace:String
var nowPlot:String
var nowEventID:String
var seatPair:Dictionary

enum finishFunc{Seat, EventResult, Battle, Choice}
var finishFuncEnum = []

enum avgStatus{Adventure, Battle}
var currentAvgStatus = avgStatus.Adventure

## 面板调用节点配置
@onready var rootNode:Node = get_tree().root.get_node("testScean")
## 信息改变信号
## 以下是avg开始时调用的信号
signal new_avg()
signal clean_avg()
signal trigger_avg_control()
signal simple_show_next_avg()
signal close_avg()
signal seatSelect_confirm()
signal draw_npc()
## 以下是剧情开始时调用的信号
signal new_plot()
signal next_plot()
signal select_place()
signal show_seat_brief_status()
## 以下是其他界面流程控制用面板
signal show_event_result()

func _ready() -> void:
	trigger_avg_control.connect(avg_control)
	simple_show_next_avg.connect(set_next_avg)
	seatSelect_confirm.connect(_on_seatSelect_confirm)
	show_seat_brief_status.connect(set_seat_brief_status)

	## 将 finishFunc 写入 finishFuncEnum，方便外部调用
	for key in finishFunc:
		finishFuncEnum.append(key)

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

func set_eventConfig_now(ID):
	if ID == null:
		return
	nowEventID = str(ID)

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

func load_event_from_ID(ID):
	var output
	for event in GameInfo.eventConfig.values():
		if event.ID == str(ID):
			output = event
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

	##TODO 此处强制写死初始的 group 和 event 后续需要处理
	set_eventConfig_now(place['eventConfigID'])

	## 根据参数设置加载事件节点
	var eventNode = preload("res://scene/event/event.tscn").instantiate()
	rootNode.add_child(eventNode)

	var nowEvent = load_event_from_ID(nowEventID)
	set_avg_now(nowEvent['avg_plot'])

	## 触发信号
	clean_avg.emit()
	await get_tree().create_timer(0.1).timeout
	new_avg.emit()
	pass


## 设置 seatPair
func set_seatPair(key:String, value):
	seatPair[key] = value

func avg_control(nextEvent = null):
	var nowAvg = load_avg_config()

	match currentAvgStatus:
		avgStatus.Adventure:
			## 通过 nowAvg 相关配置，来决定是否关闭 avg 面板。
			if nowAvg == null:
				close_avg.emit()
				return

			if nowAvg['nextID'] == null or nowAvg['nextID'] == "":
				## 如果当前正在显示事件结果，那么弹出事件结果面板
				if _check_nowAvg_finishFunc(finishFunc.EventResult):
					show_event_result.emit()
					return

				## 如果当前准备进入战斗，那么转入战斗面板，由战斗流程接管
				if _check_nowAvg_finishFunc(finishFunc.Battle):
					var nowEvent = load_event_from_ID(nowEventID)
					#GameInfo.mindStateManager.battleID = nowEvent['plot_finish_func_param']
					GameInfo.mindStateManager.start_mindStateBattle.emit()
					return

				## 如果当前正在选择，那么阻断点击
				if _check_nowAvg_seating(nextEvent):
					var eventNode = rootNode.get_node('Event') as Event
					eventNode.build_seat.emit()
					return
		avgStatus.Battle:
			return

	## 否则触发新avg
	set_next_avg(nextEvent)


func set_next_avg(nextEvent = null) -> void:
	var nowAvg = load_avg_config()

	if nextEvent == null:
		nowAvgID = nowAvg['nextID']
	else:
		nowEventID = nextEvent.ID
		nowAvgID = nextEvent['avg_plot']

	if nowAvgID != null and nowAvgID != "":
		new_avg.emit()
		draw_npc.emit()
		return

func _on_seatSelect_confirm():
	## 隐藏按钮
	var eventNode = rootNode.get_node('Event')
	eventNode.set_seatConfirmButton_status(false)

	## 触发检查条件，执行本组内下一段AVG。AVG跳转分支功能在函数内部实现。
	check_next_event_condition()
	pass

## 内部函数，用于检测是否打开 seatPanel。传入的 checkEvent 用于流程控制。如果其 checkEvent = null，则代表当前没有开启新的 event，因此可以在 AVG 结束时打开 seatPanel
func _check_nowAvg_seating(checkEvent) -> bool:
	var nowEvent = load_event_from_ID(nowEventID)

	if checkEvent == null and nowEvent['seatList'].size() > 0:
		return true
	else:
		return false

func _check_nowAvg_finishFunc(funcIndex: int) -> bool:
	if _check_nowEvent_finishFunc(funcIndex):
		return true
	else:
		return false

## 内部函数，用于判断当前事件的 finishFunc 类型。类型作为参数传入
func _check_nowEvent_finishFunc(funcIndex: int) -> bool:
	var nowEvent = load_event_from_ID(nowEventID)
	if nowEvent['plot_finish_func'] == finishFuncEnum[funcIndex]:
		return true
	return false

## 根据当前座位设置条件，判断下一个执行的event
func check_next_event_condition(setNextEventID = null):
	var blank_eventID
	var maxPoint_eventID

	if setNextEventID == null:
		var now_maxPoint = 0
		for event in GameInfo.eventConfig.values():
			var condition_point = _check_event_condition_point_gen(event['condition'])
			if condition_point == -1:
				blank_eventID = event.ID
				continue
			if condition_point >= now_maxPoint:
				maxPoint_eventID = event.ID
				continue

	print("检查到全空的AVG跳转ID: ", blank_eventID)
	print("检查到当前最匹配的AVG跳转ID: ", maxPoint_eventID)
	var nextEvent
	if setNextEventID != null:
		nextEvent = load_event_from_ID(setNextEventID)
	elif maxPoint_eventID != null:
		nextEvent = load_event_from_ID(maxPoint_eventID)
	else:
		nextEvent = load_event_from_ID(blank_eventID)
	trigger_avg_control.emit(nextEvent)
	pass

## 条件计分函数。通过最终得分，来给condition的匹配情况进行评价。分数越高，评价结果越好。正常 condition 的得分都会大于 0 。
## 但特别的，condition 只有全部被满足，才会得分，否则计分为 -999。
## TODO 对于 eventConfig 中的 condition 判断与参数编写，需要进行优化，以支持更多可能性。例如 condition 支持宽匹配。
## 特别的，对于【全空条件】，计分自动为 -1。
func _check_event_condition_point_gen(condition) -> int:
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


## 检查满足条件的 plot。如果检查到，则返回 true，否则返回 false。特别的，如果当前是最后一个 plot，那么也返回 false。
func locate_nowPlot() -> bool:
	## 首先检查 nowPlot 是否未被初始化。如果是，那么通过 prePlot = -1，定位第一个plot.
	if nowPlot == "":
		for plotItem in GameInfo.plot.values():
			if plotItem['prePlot'] == "-1":
				set_plot_now(plotItem.ID)
				return true

	## 然后检查是否为最后一个Plot。通过检查 condition = END，定位最后一个plot.
	if check_end_plot():
		##TODO 此处需要对结束plot做后续前端表现处理
		print("END PLOT")
		return false

	## 通过上述检查后，正常执行 prePlot 和 condition 的检查，定位下一个 plot.
	for plotItem in GameInfo.plot.values():
		if plotItem['prePlot'] == nowPlot:
			## 只有 prePlot 为当前 plot 并且通过 condition 检查的 plot，才会被设置，然后继续下去。
			if check_plot_condition():
				set_plot_now(plotItem.ID)
				return true

	## 最终返回 false，代表未通过验证
	return false


func check_end_plot():
	var plot = load_plot_from_ID(nowPlot)
	for key in plot['condition'].keys():
		if key == "END":
			return true
	return false

##TODO 本方法为检查 plot conditon 的具体实现。需要根据需求细化。
func check_plot_condition() -> bool:
	return true

## 设置 seat_brief 相关状态
func set_seat_brief_status(index: int, status: bool) -> void:
	var eventNode = rootNode.get_node('Event')
	eventNode.emit_signal("show_seat_brief_status", index, status)

## 外部函数，检测当前是否为 MindStateSwarm 节点
func check_mindStateSwarm() -> bool:
	var plotInfo = load_plot_from_ID(nowPlot)
	if plotInfo['plotType'] == "MindSwarn":
		return true
	return false

## 外部函数。用于修正 eventConfig 中部分需要处理的功能与参数
func eventConfig_data_wash() -> void:
	var seatFunc = finishFuncEnum[0]
	var eventResultFunc = finishFuncEnum[1]
	var battleFunc = finishFuncEnum[2]
	var choiceFunc = finishFuncEnum[3]

	for event in GameInfo.eventConfig.values():
		match event['plot_finish_func']:
			seatFunc:
				print(seatFunc)
				var seatConfigID = event['plot_finish_func_param']
				GameInfo.append_property_from_template(event, GameInfo.eventSeatsInfo[seatConfigID])

				## 处理 seat_list 的列表配置
				event['seatList'] = GameInfo.split_slash_list(event['seatList'] )
				## 处理 resultCondition 的列表配置
				event['resultCondition'] = GameInfo.split_slash_list(event['resultCondition'])
			## TODO 后续扩展其他功能
			eventResultFunc:
				print(eventResultFunc)
			battleFunc:
				print(battleFunc)
			_:
				print("未匹配")
