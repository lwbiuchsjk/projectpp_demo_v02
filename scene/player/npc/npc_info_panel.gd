extends Control

var npcData: Dictionary
var mindStateKey = ["Happiness", "Sadness", "Anger", "Fear", "Disgust", "Surprise"]


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
	for key in mindStateKey:
		## 设置颜色，颜色由 const 配置决定
		var colorCode = GameInfo.search_const_value(key + "Color")['valueString']
		var colorRectNode = $VBoxContainer.get_node(key + "/ColorRect") as ColorRect
		colorRectNode.color = Color(colorCode)
		print(key, colorCode)
	pass
