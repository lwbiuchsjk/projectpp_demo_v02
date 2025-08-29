extends Control

var npcData: Dictionary
var mindStateKey = ["Happiness", "Sadness", "Anger", "Fear", "Disgust", "Surprise"]
var colorRectLength = [40, 20, 0]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## 外部设置npc的数值，并存储至内部 npcData 中
func set_npc_data(npcID: String) -> void:
	for npc in GameInfo.npcInfo.values():
		if npc["ID"] == npcID:
			npcData = npc
			return

## 处理 NpcMindState 的外显
func show_npc_mindState() -> void:
	var mindStateValueRankList: Array =  _set_npc_mindState_tag()

	for index in range(mindStateKey.size()):
		var key = mindStateKey[index]
		var colorRectNode = $VBoxContainer.get_node(key + "/ColorRect") as ColorRect
		## 设置颜色，颜色由 const 配置决定
		var colorCode = GameInfo.search_const_value(key + "Color")['valueString']
		colorRectNode.color = Color(colorCode)
		## 设置长度。长度根据得到的排名序列进行设置。排名序列对应长度参见 colorRectLength
		## TODO colorRectLength 可改为外部设置，而不是内部写死？
		var lengthIndex = mindStateValueRankList[index]
		if lengthIndex >= colorRectLength.size():
			colorRectNode.size.x = 0
		else:
			colorRectNode.size.x = colorRectLength[lengthIndex]


func _set_npc_mindState_tag() -> Array:
	var tagList = []

	## 获取所有属性值并存储在数组中
	for mindState in mindStateKey:
		tagList.append(int(npcData[mindState]))
	var ranks = _get_descending_rank(tagList)

	return ranks

## 去重并排序，获得从大到小的数值排序
func _get_descending_rank(arr: Array) -> Array:
	"""
	获取降序排名（0表示最大）
	"""
	var indexed_arr = []
	for i in range(arr.size()):
		indexed_arr.append({"value": arr[i], "index": i})

	# 按值排序
	indexed_arr.sort_custom(func(a, b): return a["value"] > b["value"])

	var ranks = []
	ranks.resize(arr.size())
	var current_rank = 0
	for i in range(indexed_arr.size()):
		if i > 0 and indexed_arr[i]["value"] == indexed_arr[i-1]["value"]:
			# 相同值，使用相同排名
			ranks[indexed_arr[i]["index"]] = ranks[indexed_arr[i-1]["index"]]
		else:
			ranks[indexed_arr[i]["index"]] = current_rank
			current_rank += 1

	return ranks
