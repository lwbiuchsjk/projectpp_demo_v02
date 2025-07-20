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

func _ready() -> void:
	itemCard=read_csv_as_nested_dict(itemCard_file_path)
	itemSeat = read_csv_as_nested_dict(itemSeat_file_path)
	plotSegment = read_csv_as_nested_dict(plotSegment_file_path)
	avgPlot = read_csv_as_nested_dict(avgPlot_file_path)
	avgPlot_data_wash()
	place = read_csv_as_nested_dict(place_file_path)
	plot = read_csv_as_nested_dict(plot_file_path)
	bgPic = read_csv_as_nested_dict(bgPic_file_path)
	bgPic_data_wash()

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
func avgPlot_data_wash() -> void:
	for segment in avgPlot.values():
		## 处理 seat_list 的列表配置
		var raw_seat_list:String = segment['seatList']
		var seat_list = raw_seat_list.split("/")
		if seat_list[0] == "":
			segment['seatList'] = []
		else:
			segment['seatList'] = seat_list

## 对 bgPic 中的部分数据进行处理，将基础资源名拼接进去
func bgPic_data_wash() -> void:
	for pic in bgPic.values():
		var raw_pic_resource = pic['resource']
		var pic_resource = bgPic_base_resource_path + raw_pic_resource
		pic['resource'] = pic_resource
