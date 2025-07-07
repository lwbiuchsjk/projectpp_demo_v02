extends Node
var itemCard_file_path="res://assets/data/cardsInfo.CSV"
var itemCard:Dictionary

var itemSeat_file_path = 'res://assets/data/seatsInfo.csv'
var itemSeat:Dictionary

var plotSegment_file_path = 'res://assets/data/plotSegment.csv'
var plotSegment:Dictionary

func _ready() -> void:
	itemCard=read_csv_as_nested_dict(itemCard_file_path)
	itemSeat = read_csv_as_nested_dict(itemSeat_file_path)
	plotSegment = read_csv_as_nested_dict(plotSegment_file_path)
	plotSegment_data_wash()

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

## 对 plotSegment 中的部分数据进行清理，确保生成数据实际可读
func plotSegment_data_wash() -> void:
	for segment in plotSegment.values():
		## 处理 seat_list 的列表配置
		var raw_seat_list:String = segment['seat_list']
		var seat_list = raw_seat_list.split("/")
		segment['seat_list'] = seat_list