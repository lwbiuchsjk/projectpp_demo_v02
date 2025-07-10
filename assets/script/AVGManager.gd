extends Node

## 用于标记AVG当前状态的参数
var nowAvgSegment:String
var nowPlace:String
var nowPlot:String
## 信息改变信号
signal new_avg()
signal new_plot()
signal select_place()

func set_avg_now(ID):
	nowAvgSegment = str(ID)

func set_place_now(ID):
	nowPlace = str(ID)

func set_plot_now(ID):
	nowPlot = str(ID)


func load_avg_config():
	for avg in GameInfo.avgPlot.values():
		if nowAvgSegment == avg.ID:
			var words = avg['words']
			return words

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
	for segment in GameInfo.plotSegment.values():
		if segment.ID == str(ID):
			return segment
	return null

func build_event(placeID):
	var place = load_place_from_ID(placeID)
	if place == null:
		return

	var plotSegment = load_plotSegment_from_ID(place['plotSegment'])
	print("检测成功: ", plotSegment.ID)

	#avgManager.set_avg_now(plotSegment['avg_plot'])
	#for i in plotSegment['seat_list']:
	#	var testCard = preload("res://scene/Seat/seat.tscn").instantiate() as Seat
	#	$Event.add_child_item(testCard)
	#	var card_type = testCard.search_seat_property(i)
	#	testCard.set_seat_type([card_type])
	#$Event.arrange_children_bottom_up()
	### 触发信号
	#avgManager.emit_signal("new_avg")
	pass
