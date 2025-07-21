extends Node
var itemCard_file_path="res://assets/data/cardsInfo.CSV"
var itemCard:Dictionary

var itemSeat_file_path = 'res://assets/data/seatsInfo.csv'
var itemSeat:Dictionary

var plotSegment_file_path = 'res://assets/data/plotSegment.csv'
var plotSegment:Dictionary

var avgPlot_file_path = 'res://assets/data/avgPlot.csv'
var avgPlot:Dictionary

var place_file_path = 'res://assets/data/placeConfig.csv'
var place:Dictionary

var plot_file_path = 'res://assets/data/plotConfig.csv'
var plot:Dictionary

var bgPic_file_path = 'res://assets/data/pic.csv'
var bgPic:Dictionary
var bgPic_base_resource_path = 'res://assets/image/'

var plotSegmentGroup_file_path = 'res://assets/data/plotSegmentGroup.csv'
var plotSegmentGroup:Dictionary

func _ready() -> void:
	itemCard=read_csv_as_nested_dict(itemCard_file_path)
	itemSeat = read_csv_as_nested_dict(itemSeat_file_path)
	plotSegment = read_csv_as_nested_dict(plotSegment_file_path)
	plotSegment_data_wash()
	avgPlot = read_csv_as_nested_dict(avgPlot_file_path)
	##avgPlot_data_wash()
	place = read_csv_as_nested_dict(place_file_path)
	plot = read_csv_as_nested_dict(plot_file_path)
	bgPic = read_csv_as_nested_dict(bgPic_file_path)
	bgPic_data_wash()
	plotSegmentGroup = read_csv_as_nested_dict(plotSegmentGroup_file_path)
	plotSegmentGroup_data_wash()

	# 函数读取CSV文件并将其转换为嵌套字典
func read_csv_as_nested_dict(path: String) -> Dictionary:
	var data = {}
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size()>=2:
			var key = values[0]
			var row_dict = {}
			for i in range(0, headers.size()):
				row_dict[headers[i]] = values[i]
			data[key] = row_dict
	file.close()
	return data

func search_card_from_cardName(cardName: String):
	for checkCard in itemCard.values():
		if checkCard['base_cardName'] == cardName:
			return checkCard
	return itemCard[0]

## 对 avgPlot 中的部分数据进行清理，确保生成数据实际可读
## 废弃
func avgPlot_data_wash() -> void:
	for avg in avgPlot.values():
		## 【废弃】处理 seat_list 的列表配置
		var raw_seat_list:String = avg['seatList']
		var seat_list = raw_seat_list.split("/")
		if seat_list[0] == "":
			avg['seatList'] = []
		else:
			avg['seatList'] = seat_list

## 对 bgPic 中的部分数据进行处理，将基础资源名拼接进去
func bgPic_data_wash() -> void:
	for pic in bgPic.values():
		var raw_pic_resource = pic['resource']
		var pic_resource = bgPic_base_resource_path + raw_pic_resource
		pic['resource'] = pic_resource

## 对 plotSegmentGroup 中部分数据进行清理，将 segmentList 进行数据拆分
func plotSegmentGroup_data_wash() -> void:
	for group in plotSegmentGroup.values():
		## 处理 segmentList
		var raw_list = group['segmentList']
		var real_list =raw_list.split("/")
		if real_list[0] == "":
			group['segmentList'] = []
		else:
			group['segmentList'] = real_list
		##TODO 处理 group 的 condition


## 对 plotSegment 中部分数据进行清理，将列表进行数据拆分
func plotSegment_data_wash() -> void:
	for segment in plotSegment.values():
		## 处理 conditon
		var raw_condition = segment['condition']
		var real_condition =raw_condition.split("/")
		if real_condition[0] == "":
			segment['condition'] = []
		else:
			segment['condition'] = real_condition
		## 处理 seatList
		var raw_seat_list:String = segment['seatList']
		var seat_list = raw_seat_list.split("/")
		if seat_list[0] == "":
			segment['seatList'] = []
		else:
			segment['seatList'] = seat_list
