extends Node

## 用于标记AVG当前状态的参数
var nowAvgSegment:String
var nowPlace:String
var nowPlot:String
## 信息改变信号
signal new_avg()
signal new_plot()

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

func load_place_from_plot() -> Array:
	var output:Array
	var tempPlot = load_plot_from_ID(nowPlot)
	# 空值处理
	if tempPlot == null:
		return output

	var placeList = tempPlot['placeList'].split("/")
	print("检测配置地点数量：", placeList)

	for place in placeList:
		var checkPlace = load_place_from_ID(place)
		if checkPlace != null:
			output.append(checkPlace)
	return output


func load_place_from_ID(ID):
	for place in GameInfo.place.values():
		if place.ID == str(ID):
			return place
	return null

func load_plot_from_ID(ID):
	print("检测配置剧情ID：",ID)
	for plot in GameInfo.plot.values():
		if plot.ID == str(ID):
			return plot
	return null
