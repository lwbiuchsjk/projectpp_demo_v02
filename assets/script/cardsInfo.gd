extends Node
var itemCard_file_path="res://assets/data/cardsInfo.CSV"
var itemCard:Dictionary

func _ready() -> void:
	itemCard=read_csv_as_nested_dict(itemCard_file_path)

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
	for itemKey in itemCard.keys():
		if itemCard[itemKey]['base_cardName'] == cardName:
			return itemCard[itemKey]
	return itemCard[0]
