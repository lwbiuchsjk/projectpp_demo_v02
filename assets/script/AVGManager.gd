extends Node

## 用于标记AVG当前状态的参数
var nowAvgSegment:String
## 信息改变信号
signal new_avg()

func load_avg_config():
	for avg in get_parent().avgPlot.values():
		if nowAvgSegment == avg.ID:
			var words = avg['words']
			return words

func set_avg_now(ID):
	nowAvgSegment = str(ID)