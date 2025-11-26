extends Node
class_name MindStateManager

var battleID: String:
	set(ID): battleID = ID
	get: return battleID

var battleData: Dictionary:
	set(data): battleData = data
	get: return battleData

var battlePanel: MindStateBattlePanel:
	set(panel): battlePanel = panel
	get: return battlePanel

var battleNowTargetCard: card:
	set(card): battleNowTargetCard = card
	get: return battleNowTargetCard
var playerSelectCard: card:
	set(card): playerSelectCard = card
	get: return playerSelectCard

signal start_mindStateBattle()
signal show_mindStateBattle_panel()		## event中连接
signal close_mindStateBattle_panel() 	## event中连接

func _ready() -> void:
	connect("start_mindStateBattle", _on_start_mindStateBattle)


func _on_start_mindStateBattle() -> void:
	print("battle start")
	emit_signal("show_mindStateBattle_panel")
	_load_mindStateSwarmCard_from_battle()

func _load_mindStateSwarmCard_from_battle() -> void:
	battleData = _locate_battleData()
	if not battleData.is_empty():
		var cardData = battleData['CardsInfo'][0]
		var searchCard = GameInfo.search_card_from_cardName(cardData['base_cardName'])
		var cardToAdd=preload("res://scene/cards/MindStateCard/MindStateCard.tscn").instantiate() as card
		cardToAdd.initCard(searchCard)
		battleNowTargetCard = cardToAdd
		if battlePanel != null:
			battlePanel.emit_signal('load_battleCard', cardToAdd)
	else:
		print("battleData 检索结果为空，battleID: %s"%battleID)

## 内部函数。通过 battleID 获得配置数据
func _locate_battleData() -> Dictionary:
	for config in GameInfo.mindStateBattle.values():
		if config.ID == battleID:
			return config
	return {}

## 用于结合 playerInputCard 和 battleNowTargetCard 来判断是否为提升卡牌。
## TODO 当前写死为 true，为了跑通流程
func check_isIncreaseCard() -> bool:
	if playerSelectCard == null:
		return false
	return true


func _get_mindStatePropertyBaseConfig(searchProperty: String, searchBaesConfigKey: String) -> String:
	for property in GameInfo.propertyList:
		if property == searchProperty:
			var searchKey = searchProperty + searchBaesConfigKey
			return GameInfo.search_const_value(searchKey)['valueString']
	return ""

func get_mindStateColor(searchProperty: String) -> String:
	return _get_mindStatePropertyBaseConfig(searchProperty, "Color")

func get_mindStateName(searchProperty: String) -> String:
	return _get_mindStatePropertyBaseConfig(searchProperty, "Name")
