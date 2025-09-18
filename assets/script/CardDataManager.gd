extends Node
class_name CardDataManager

var seatedCardList:Array
var eventResultCondition:Array = []
var nextResultIndex:int = -1
signal trans_card_to_handDeck()
signal gen_result_index()

@onready var handDeck:deck = get_tree().root.get_node("testScean/site1/handDeck")

func _ready() -> void:
	connect("trans_card_to_handDeck", card_to_handDeck)
	connect("gen_result_index", gen_event_result_index_from_eventResultCondition)

## 跟剧传入 index 的情况，处理作为列表
func CleanSeatedCardList(index:int = -1) -> void:
	if index < 0:
		seatedCardList.clear()
	elif index > seatedCardList.size():
		return
	else:
		seatedCardList[index] = null

## 根据参数，创建对应长度的seatedCardList
func InitSeatedCardList(size: int) -> void:
	## 对非法的数据进行处理
	if size < 0 :
		return
	## 实际重置 seatedCardList
	var arr = []
	arr.resize(size)
	seatedCardList = arr

## 在指定位置设置卡牌
func SetCardToListFromIndex(index:int, target) -> void:
	## 边界情况处理
	if index >= seatedCardList.size() or index < 0:
		#TODO 此处可以添加报错
		return

	seatedCardList[index] = target


func card_to_handDeck(cardToAdd) -> void:
	handDeck.add_card(cardToAdd)

## 将 eventResultCondition 设置为指定列表，通常被 avg 设置调用。参数默认为空列表。
func set_eventResultCondition(condition:Array = []) -> void:
	eventResultCondition = condition

## 传入参数用于控制是否为初始化模式。如果是，那么将 index 初始化为 -1，防止被错误调用。否则从 eventResultCondition 中选择最匹配的结果。默认关闭初始化模式。
func gen_event_result_index_from_eventResultCondition(initMode:bool = false) -> void:
	if initMode:
		nextResultIndex = -1
		return

	## TODO 待功能实现参数
	if eventResultCondition.size() == 0:
		## TODO 此处为配置错误，应当有报错或保底实现
		nextResultIndex = eventResultCondition[0]
		return
	print(eventResultCondition)
	nextResultIndex = eventResultCondition.size()

## TODO 根据 nextResultIndex 来生成实际的 eventResultCardList
func gen_card_from_eventResult() -> Array:
	var output = []
	for targetCard in seatedCardList:
		if targetCard != null:
			output.append(targetCard)

	return output
