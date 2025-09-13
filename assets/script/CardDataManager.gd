extends Node
class_name CardDataManager

var seatedCardList:Array
signal trans_card_to_handDeck()

@onready var handDeck:deck = get_tree().root.get_node("testScean/site1/handDeck")

func _ready() -> void:
	connect("trans_card_to_handDeck", card_to_handDeck)

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
