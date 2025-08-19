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

var mindStateProperty_file_path = 'res://assets/data/mindStateProperty.csv'
var mindStateProperty:Dictionary

func _ready() -> void:
	itemCard=read_csv_as_nested_dict(itemCard_file_path)
	itemSeat = read_csv_as_nested_dict(itemSeat_file_path)
	plotSegment = read_csv_as_nested_dict(plotSegment_file_path)
	plotSegment_data_wash()
	avgPlot = read_csv_as_nested_dict(avgPlot_file_path)
	avgPlot_data_wash()
	place = read_csv_as_nested_dict(place_file_path)
	plot = read_csv_as_nested_dict(plot_file_path)
	plot_data_wash()
	bgPic = read_csv_as_nested_dict(bgPic_file_path)
	bgPic_data_wash()
	plotSegmentGroup = read_csv_as_nested_dict(plotSegmentGroup_file_path)
	plotSegmentGroup_data_wash()
	mindStateProperty = read_csv_as_nested_dict(mindStateProperty_file_path)

	# 基础配置读取完成后，将部分模板配置替换为实际配置
	card_template_changer()

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
	for avg in avgPlot.values():
		## 处理 seat_list 的列表配置
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
		var real_condition = {}
		var tmp_condition = raw_condition.split(",")
		for tmp_item in tmp_condition:
			## condition = -1，代表全空，用作特殊处理
			if tmp_item == "-1":
				real_condition = int(tmp_item)
				break
			var tmp_pair = tmp_item.split("/")
			## 否则将条件读取为 key/value 的字典。其中 key = seatID, value = 卡牌类型
			## 根据后续设置的 seat 和 卡牌 的匹配结果，来对应检查 condition 的得分。得分最高的 condition 视为匹配结果。
			if tmp_pair.size() != 2:
				continue
			var tmp_key = str(int(tmp_pair[0]))
			var tmp_value = int(tmp_pair[1])
			real_condition[tmp_key] = tmp_value
		## 将上述处理结果赋值回 condition
		segment['condition'] = real_condition

func plot_data_wash() -> void:
	for item in plot.values():
		var raw_condition = item['condition']
		var real_condition = {}
		var tmp_condition = raw_condition.split(",")
		for tmp_item in tmp_condition:
			## 否则将条件读取为 key/value 的字典。其中 key = 功能枚举, value = 功能参数
			var tmp_pair = tmp_item.split(":")
			## 对输入参数进行检查，无法解析为键值对的参数被抛弃。特别的，如果只填写了一个功能枚举，也被认为通过
			if tmp_pair.size() > 2:
				continue
			var tmp_key = tmp_pair[0]
			## 跳过空输入
			if tmp_key == "":
				continue

			## 解析 value 值
			var tmp_value
			if tmp_pair.size() == 2:
				tmp_value = int(tmp_pair[1])
			else:
				tmp_value = 1
			real_condition[tmp_key] = tmp_value
		## 将上述处理结果赋值回 condition
		item['condition'] = real_condition

## 将属性模板ID替换为对应属性配置。方便不同类型进行扩展
func card_template_changer() -> void:
	for item in itemCard.values():
		match item['property_type']:
			"MindState":
				var templateID = item['property_template']
				_append_property_from_template(item, mindStateProperty[templateID])
			_:
				print("没有匹配到对应卡牌属性：", item['property_type'])
				continue

## 内部函数。用于将属性模板中的配置直接赋值给对应项。
func _append_property_from_template(rawDic:Dictionary, templateProperty:Dictionary) -> void:
	var passKey = ['ID', 'Remarks']
	for key in templateProperty.keys():
		if key in passKey:
			continue
		rawDic[key] = templateProperty[key]

