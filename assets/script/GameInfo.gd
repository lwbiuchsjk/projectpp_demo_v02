extends Node
var cardInfo_file_path="res://assets/data/cardsInfo.CSV"
var cardInfo:Dictionary

var itemSeat_file_path = 'res://assets/data/seatsInfo.csv'
var itemSeat:Dictionary

var eventConfig_file_path = 'res://assets/data/eventConfig.csv'
var eventConfig:Dictionary

var avgPlot_file_path = 'res://assets/data/avgPlot.csv'
var avgPlot:Dictionary

var place_file_path = 'res://assets/data/placeConfig.csv'
var place:Dictionary

var plot_file_path = 'res://assets/data/plotConfig.csv'
var plot:Dictionary

var bgPic_file_path = 'res://assets/data/pic.csv'
var bgPic:Dictionary
var bgPic_base_resource_path = 'res://assets/image/'

var mindStateProperty_file_path = 'res://assets/data/mindStateProperty.csv'
var mindStateProperty:Dictionary

var npcInfo_file_path = 'res://assets/data/npcInfo.csv'
var npcInfo:Dictionary

var const_file_path = "res://assets/data/const.csv"
var constInfo:Dictionary

var eventSeatsInfo_file_path = "res://assets/data/eventSeatsInfo.csv"
var eventSeatsInfo:Dictionary

var eventResultInfo_file_path = "res://assets/data/eventResultInfo.csv"
var eventResultInfo:Dictionary

var mindStateSwarm_file_path = "res://assets/data/mindStateSwarm.csv"
var mindStateSwarm:Dictionary

var mindStateTemplate_file_path = 'res://assets/data/mindStateTemplate.csv'
var mindStateTemplate:Dictionary

var mindStateBattle_file_path = 'res://assets/data/mindStateBattle.csv'
var mindStateBattle:Dictionary

var mindStateLevelExp_file_path = 'res://assets/data/mindStateLevelExp.csv'
var mindStateLevelExp:Dictionary

## 子节点结构
var cardDataManager: CardDataManager
var avgManager: AVGManager
var mindStateManager: MindStateManager

## 核心数据结构
const HAPPY_ATTRIBUTE_NAME = "Happiness"
const SADNESS_ATTRIBUTE_NAME = "Sadness"
const ANGER_ATTRIBUTE_NAME = "Anger"
const FEAR_ATTRIBUTE_NAME = "Fear"
const DISGUST_ATTRIBUTE_NAME = "Disgust"
const SURPRISE_ATTRIBUTE_NAME = "Surprise"
var propertyList = [HAPPY_ATTRIBUTE_NAME, SADNESS_ATTRIBUTE_NAME, ANGER_ATTRIBUTE_NAME, FEAR_ATTRIBUTE_NAME, DISGUST_ATTRIBUTE_NAME, SURPRISE_ATTRIBUTE_NAME]

func _ready() -> void:
	eventSeatsInfo = read_csv_as_nested_dict(eventSeatsInfo_file_path)
	cardInfo=read_csv_as_nested_dict(cardInfo_file_path)
	card_data_wash()
	itemSeat = read_csv_as_nested_dict(itemSeat_file_path)
	eventConfig = read_csv_as_nested_dict(eventConfig_file_path)
	eventConfig_data_wash()
	avgPlot = read_csv_as_nested_dict(avgPlot_file_path)
	avgPlot_data_wash()
	place = read_csv_as_nested_dict(place_file_path)
	plot = read_csv_as_nested_dict(plot_file_path)
	plot_data_wash()
	bgPic = read_csv_as_nested_dict(bgPic_file_path)
	bgPic_data_wash()
	mindStateProperty = read_csv_as_nested_dict(mindStateProperty_file_path)
	npcInfo = read_csv_as_nested_dict(npcInfo_file_path)
	npcInfo_template_changer()
	constInfo = read_csv_as_nested_dict(const_file_path)
	eventResultInfo = read_csv_as_nested_dict(eventResultInfo_file_path)
	mindStateSwarm = read_csv_as_nested_dict(mindStateSwarm_file_path)
	mindStateSwarm_data_wash()
	mindStateTemplate = read_csv_as_nested_dict(mindStateTemplate_file_path)
	mindStateBattle = read_csv_as_nested_dict(mindStateBattle_file_path)
	mindStateBattle_data_wash()
	mindStateLevelExp = read_csv_as_nested_dict(mindStateLevelExp_file_path)

	# 基础配置读取完成后，将部分模板配置替换为实际配置
	card_template_changer()

	## 子节点结构
	cardDataManager = $CardDataManager as CardDataManager
	avgManager = $AVGManager as AVGManager
	mindStateManager = $MindStateManager as MindStateManager

	## 初始化高优先级数据
	init_highPriorityData()

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
	for checkCard in cardInfo.values():
		if checkCard['base_cardName'] == cardName:
			return checkCard.duplicate()
	return cardInfo[0]

## 对 avgPlot 中的部分数据进行清理，确保生成数据实际可读
func avgPlot_data_wash() -> void:
	for avg in avgPlot.values():
		## 处理 NPC 的列表配置
		avg['NPC'] = split_slash_list(avg['NPC'])

## 通用方法，用于将 '/' 列表配置分离为真正的列表
func split_slash_list(input:String) -> Array:
	var tmp = input.replace(" ","")
	var output = tmp.split("/")
	if output[0] == "":
		return []
	else:
		return output

## 对 bgPic 中的部分数据进行处理，将基础资源名拼接进去
func bgPic_data_wash() -> void:
	for pic in bgPic.values():
		var raw_pic_resource = pic['resource']
		var pic_resource = bgPic_base_resource_path + raw_pic_resource
		pic['resource'] = pic_resource

## 对 eventConfig 中部分数据进行清理，将列表进行数据拆分
func eventConfig_data_wash() -> void:
	for event in eventConfig.values():
		## 处理 conditon
		var raw_condition = event['condition']
		var real_condition = {}
		var tmp_condition = raw_condition.split(",")
		for tmp_item in tmp_condition:
			## condition = -1，代表全空，用作特殊处理
			if tmp_item == "-1":
				real_condition = int(tmp_item)
				break
			var tmp_pair = tmp_item.split(":")
			## 否则将条件读取为 key/value 的字典。其中 key = seatID, value = 卡牌类型
			## 根据后续设置的 seat 和 卡牌 的匹配结果，来对应检查 condition 的得分。得分最高的 condition 视为匹配结果。
			if tmp_pair.size() != 2:
				continue
			var tmp_key = str(int(tmp_pair[0]))
			var tmp_value = int(tmp_pair[1])
			real_condition[tmp_key] = tmp_value
		## 将上述处理结果赋值回 condition
		event['condition'] = real_condition

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
	for item in cardInfo.values():
		match item['property_type']:
			"MindState":
				var templateID = item['property_template']
				append_property_from_template(item, mindStateProperty[templateID])
			_:
				print("没有匹配到对应卡牌属性：", item['property_type'])
				continue

## 通用函数。用于将属性模板中的配置直接赋值给对应项。
func append_property_from_template(rawDic:Dictionary, templateProperty:Dictionary) -> void:

	var passKey = ['ID', 'Remarks']
	for key in templateProperty.keys():
		if key in passKey:
			continue
		rawDic[key] = templateProperty[key]

## 将属性模板ID替换为对应属性配置。方便不同类型进行扩展
func npcInfo_template_changer() -> void:
	for item in npcInfo.values():
		var mindStateTemplateID = item['MindStateTemplate']
		append_property_from_template(item, mindStateProperty[mindStateTemplateID])

## 根据传入的 key 检索 const 中的对应值。注意，返回的是整行数据，具体如何使用值应当根据业务具体确定。
func search_const_value(searchKey:String) -> Dictionary:
	for key in constInfo.keys():
		if key == searchKey:
			return constInfo[key]
	return {}

## 将 cardInfo 的部分配置规范化处理
func card_data_wash() -> void:
	for config in cardInfo.values():
		## 处理 stackFlag，规范化为 true/false
		if config['stackFlag'].is_empty():
			config['stackFlag'] = false
		elif not config['stackFlag'].is_valid_int():
			config['stackFlag'] = false
		else:
			var flag = config['stackFlag'].to_int()
			if flag >= 1:
				config['stackFlag'] = true
			else:
				config['stackFlag'] = false

## 将 MindStateSwarm 的部分配置规范化处理
func mindStateSwarm_data_wash() -> void:
	for config in mindStateSwarm.values():
		## 处理 cardsInfo
		var inputValue = config['CardsInfo'].replace(" ", "").split("/")
		var outputValue = []
		for value in inputValue:
			if value.is_valid_int():
				var swarmCardInfo = cardInfo[value]
				outputValue.append(swarmCardInfo)
		config['CardsInfo'] = outputValue

## 将 MindStateBattle 的部分配置规范化处理
func mindStateBattle_data_wash() -> void:
	for config in mindStateBattle.values():
		## 处理 cardsInfo
		var inputValue = config['CardsInfo'].replace(" ", "").split("/")
		var outputValue = []
		for value in inputValue:
			if value.is_valid_int():
				var swarmCardInfo = cardInfo[value]
				outputValue.append(swarmCardInfo)
		config['CardsInfo'] = outputValue

		## 处理 AvgList
		var avgValue = config['AvgList'].replace(" ", "").split("/")
		var outputAvgValue = []
		for value in avgValue:
			if value.is_valid_int():
				outputAvgValue.append(value)
		config['AvgList'] = outputAvgValue

## 根据传入的 TypeName 来返回对应的 templateData
func get_mindStateTemplaterData(input: String) -> Dictionary:
	for value in mindStateTemplate.values():
		if value['TypeName'] == input:
			return value
	return {}

func check_property_mainProperty(templateData:Dictionary, propertyKey:String) -> bool:
	if templateData[propertyKey] == "F":
		return true
	return false

func check_property_secondProperty(templateData:Dictionary, propertyKey:String) -> bool:
	if templateData[propertyKey] == "H":
		return true
	return false

func get_mindStateBattleID() -> String:
	return search_const_value('MindStateBattleID')['value']

## 用于初始化重要的数据
func init_highPriorityData() -> void:
	## 读入 mindStateSwarm，并将其保存为实时数据，方便改变
	cardDataManager.init_MindStateSwarm()
	avgManager.eventConfig_data_wash()

	## 初始化 swarm 数据。用于将 MindStateSwarm 从 battle 提升至【全局】
	mindStateManager.load_mindStateSwarmCard_from_battle()
