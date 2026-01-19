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

## 通过 MindStateSwarn 创建的 TargetCard，指本次 MindStateBattle 面对的 card
var battleNowTargetCard: card:
	set(card): battleNowTargetCard = card
	get: return battleNowTargetCard
## 通过 MindStateBattlePanel 中，玩家手动指定的 card。本次战斗的目的是将 TargetCard 改变为 SelectCard。
## 改变结果通过 TargetCard 最终属性是否能够与 SelectCard 对应的模板【匹配】。
var playerSelectCard: card:
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
		## TODO 此处强制取了 MindStateBattle 中 CardsInfo 中的首个配置。暂不支持读入后续卡牌
		var cardData = battleData['CardsInfo'][0]
		print(cardData)
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
	var propertyLevelKey = GameInfo.propertyList[propertyIndex]
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
	var propertyLevelKey = GameInfo.propertyList[propertyIndex]
	var isIncrease = _check_change_direction_increase(battleNowTargetCard, inputCard, propertyLevelKey)
	if not isIncrease:
		inputLevel = -inputLevel
	var changeLevel = attributerManager.add_MindStateProperty_exp(propertyKey, inputLevel)
	print("本次变化等级：" + str(changeLevel))

	## 此处精神变化。暂定根据变化等级进行恢复
	var isSeatInPropertyTemplate = attributerManager.check_propertyTemplate_flag(playerSelectCard, propertyIndex)

	var spiritChangeValue = abs(changeLevel) * 10
	if not isSeatInPropertyTemplate:
		spiritChangeValue = -spiritChangeValue
	var spiritQuitFlag = PlayerInfo.gamePlayerInfoManager.settle_spiritAttribute(spiritChangeValue)

	## 变化结束后，需要更新 battlePanel 中相关信息的显示
	battlePanel.show_CardInfo(battleNowTargetCard, true)

	print("本次精神变化计算值：", spiritChangeValue)

	## 此处判断提交卡牌后，数值变化是否与 PlayerSelectCard 的模板相匹配
	var selectMindStateClass = playerSelectCard.cardInfo['TypeName']
	var selectMindStateTemplate = GameInfo.get_mindStateTemplaterData(selectMindStateClass)
	var isSatisfiedTemplate = attributerManager.check_mindStateProperty_satisfied_template(selectMindStateTemplate)

	attributerManager.write_cardData_to_cardInfo()

	## 判断是否满足退出机制
	## 退出机制，仅会被2种情况触发：满足 selectCard 的 MindStateTemplate，或精神达到最低。
	## TODO 补充 battleResult 环节。让玩家精力可以恢复，或补充卡牌
	## 此时精神到最低后，应当有恢复机制，让玩家不至于又快速被迫面对 MindStateBattle
	## 固定恢复机制？如果满足 selectCard，那么大回复。否则，小回复。
	if isSatisfiedTemplate:
		GameInfo.mindStateManager.emit_signal('close_mindStateBattle_panel')
		print("修正属性值后，满足 playerSelectCard 模板。退出 MindStateBattle。")
		return
	elif spiritQuitFlag:
		GameInfo.mindStateManager.emit_signal('close_mindStateBattle_panel')
		print("操作后，精神降至最低，退出 MindStateBattle。")
		return

	print("继续 MindStateBattle.")
