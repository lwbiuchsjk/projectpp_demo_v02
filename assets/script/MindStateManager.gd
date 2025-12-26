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
var playerSelectCard: card:		## 待废弃，因为本配置可以通过 battlePanel 中的 inputPanelList 中的 seat 查询得到
	set(card): playerSelectCard = card
	get: return playerSelectCard

signal start_mindStateBattle()
signal show_mindStateBattle_panel()		## event中连接
signal close_mindStateBattle_panel() 	## event中连接
signal select_mindState_to_change()		## mindStateBattlePanel 中连接
signal show_inputCard_change_direction()	## mindStateSelectSeat 中被调用
signal clean_change_direction()				## mindStateSelectSeat 中被调用
signal process_targetCard_property()

func _ready() -> void:
	connect("start_mindStateBattle", _on_start_mindStateBattle)
	show_inputCard_change_direction.connect(_show_change_direction)
	clean_change_direction.connect(_clean_change_direction)
	process_targetCard_property.connect(_process_targetCard_property)

func _on_start_mindStateBattle() -> void:
	print("battle start")
	emit_signal("show_mindStateBattle_panel")
	_load_mindStateSwarmCard_from_battle()

	## TODO 此处可以改变进入战斗时的 spirit 值。可根据情况扩展。
	PlayerInfo.gamePlayerInfoManager.settle_spiritAttribute(-50)

func _load_mindStateSwarmCard_from_battle() -> void:
	battleData = _locate_battleData()
	if not battleData.is_empty():
		var cardData = battleData['CardsInfo'][0]
		var searchCard = GameInfo.search_card_from_cardName(cardData['base_cardName'])
		var cardToAdd=preload("res://scene/cards/MindStateCard/MindStateCard.tscn").instantiate() as card
		cardToAdd.initCard(searchCard)
		battleNowTargetCard = cardToAdd
		## 通过本行为来触发 battleNowTargetCard 中节点的创建逻辑
		self.add_child(battleNowTargetCard)
		battleNowTargetCard.visible = false	## 关闭外显

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


## 根据传入的 inputCard 参数与 battleNowTargetCard 之间的关系，显示 changeDirection 对应信息。
func _show_change_direction(inputCard: card, propertyIndex: int) -> void:
	var attributerManager = inputCard.cardAttributeManager as MindStateCardAttributeManager
	var propertyLevelKey = GameInfo.propertyList[propertyIndex] + attributerManager.ATTRIBUTE_LEVEL_NAME
	var isIncrease = _check_change_direction_increase(battleNowTargetCard, inputCard, propertyLevelKey)
	var inputPanel = battlePanel.mindStateInputList[propertyIndex] as MindStateBattleInputPanel
	inputPanel.set_change_direction_status(isIncrease, !isIncrease)


## 内部方法，用于根据传入的两个卡牌来决定是增加还是减少。targetCard 使用 attributeLevelKey 进行判断，inputCard 直接使用其 rarity 来判断
func _check_change_direction_increase(targetCard: card, inputCard: card, targetAttributeLevelKey: String) -> bool:
	var targetLevel = targetCard.cardInfo[targetAttributeLevelKey]
	var selectLevel = inputCard.cardInfo['rarity']
	if targetLevel >= selectLevel:
		return true
	else:
		return false

## 内部方法，用于响应信号，被 seat 调用，清理 InputPanel 的 changeDirection 外显
func _clean_change_direction(inputPanelIndex: int) -> void:
	var inputPanel = battlePanel.mindStateInputList[inputPanelIndex] as MindStateBattleInputPanel
	inputPanel.set_change_direction_status(false, false)

## 内部方法，通过信号调用。将卡牌属性进行变化。
## TODO 退出机制可以统一在此处调用。
func _process_targetCard_property(inputCard: card, propertyIndex: int) -> void:
	var inputLevel = inputCard.cardInfo['rarity'].to_int()
	var attributerManager = battleNowTargetCard.cardAttributeManager as MindStateCardAttributeManager
	var propertyKey = GameInfo.propertyList[propertyIndex]
	var propertyLevelKey = GameInfo.propertyList[propertyIndex] + attributerManager.ATTRIBUTE_LEVEL_NAME
	var isIncrease = _check_change_direction_increase(battleNowTargetCard, inputCard, propertyLevelKey)
	if not isIncrease:
		inputLevel = -inputLevel
	var changeLevel = attributerManager.add_MindStateProperty_exp(propertyKey, inputLevel)
	## TODO 需要补充等级变化逻辑，是否考虑提交卡牌时消耗精神等，限制流程长度

	print("本次变化等级：" + str(changeLevel))

	## TODO 此处恢复精神。暂定根据变化等级进行恢复
	var spiritChangeValue = abs(changeLevel) * 10
	PlayerInfo.gamePlayerInfoManager.settle_spiritAttribute(spiritChangeValue)
