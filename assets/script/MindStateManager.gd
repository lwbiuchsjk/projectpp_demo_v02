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
signal show_battleResult_panel()

func _ready() -> void:
	start_mindStateBattle.connect(_on_start_mindStateBattle)
	show_inputCard_change_direction.connect(_show_change_direction)
	clean_change_direction.connect(_clean_change_direction)
	process_targetCard_property.connect(_process_targetCard_property)
	show_battleResult_panel.connect(_show_battleResult_panel)

func _on_start_mindStateBattle() -> void:
	print("battle start")
	show_mindStateBattle_panel.emit()
	_show_battleNowTargetCard()

	## TODO 此处可以改变进入战斗时的 spirit 值。可根据情况扩展。
	PlayerInfo.gamePlayerInfoManager.settle_spiritAttribute(-90)
	## 切换 avg 状态，方便控制流程
	GameInfo.avgManager.currentAvgStatus = GameInfo.avgManager.avgStatus.Battle

## 读取 SwarmCard 的配置。
## 读取时机放在 gameInfo 的 ready 中，确保必要数据结构已经建立。、
func load_mindStateSwarmCard_from_battle() -> void:
	battleID = GameInfo.get_mindStateBattleID()
	battleData = _locate_battleData()
	if not battleData.is_empty():
		## TODO 此处强制取了 MindStateBattle 中 CardsInfo 中的首个配置。暂不支持读入后续卡牌
		## TODO 此处 应当处理是否能够从内存中读入 battleNowTargetCard 的设计，避免其被反复 shuffle
		var cardData = battleData['CardsInfo'][0]
		var searchCard = GameInfo.search_card_from_cardName(cardData['base_cardName'])
		var cardToAdd=preload("res://scene/cards/MindStateCard/MindStateCard.tscn").instantiate() as card
		cardToAdd.initCard(searchCard)
		battleNowTargetCard = cardToAdd

		## 装载 batteleNowTargetCard，用于装载其属性相关组件
		self.add_child(battleNowTargetCard)
		battleNowTargetCard.visible = false	## 关闭外显

	else:
		print("battleData 检索结果为空，battleID: %s"%battleID)

func _show_battleNowTargetCard() -> void:
	if battleNowTargetCard != null:
		## 通过本行为来触发 battleNowTargetCard 中节点的创建逻辑
		if battlePanel != null:
			battlePanel.emit_signal('load_battleCard', battleNowTargetCard)

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
		GameInfo.mindStateManager.show_battleResult_panel.emit()
		print("修正属性值后，满足 playerSelectCard 模板。退出 MindStateBattle。")
		return
	elif spiritQuitFlag:
		GameInfo.mindStateManager.show_battleResult_panel.emit()
		print("操作后，精神降至最低，退出 MindStateBattle。")
		return

	print("继续 MindStateBattle.")

## 从 battleNowTargetCard 中获得精神卡牌
func get_randomCard_from_MindStateSwarm() -> Dictionary:
	var mindStatePropertyManager = battleNowTargetCard.cardAttributeManager as MindStateCardAttributeManager
	var mindStatePropertyRank = mindStatePropertyManager.get_mindStateProperty_rank()

	var mainPropertyPossibleList = []
	var secondPropertyPossibleList = []
	for index in range(mindStatePropertyRank.size()):
		if mindStatePropertyManager.check_mainProperty_satisfied(mindStatePropertyRank, index):
			mainPropertyPossibleList.append(index)
		elif mindStatePropertyManager.check_secondProperty_satisfied(mindStatePropertyRank, index):
			secondPropertyPossibleList.append(index)

	var mainPropertyRandomIndex = mainPropertyPossibleList[randi_range(0, mainPropertyPossibleList.size()-1)]
	var secondPropertyRandomIndex = secondPropertyPossibleList[randi_range(0, secondPropertyPossibleList.size()-1)]
	var mainPropertyRandom = GameInfo.propertyList[mainPropertyRandomIndex]
	var secondPropertyRandom = GameInfo.propertyList[secondPropertyRandomIndex]

	var satisfiedStandardCardID = _search_mindStateTargetCard_from_mainProperty_and_secondProperty(mainPropertyRandom, secondPropertyRandom)
	var targetCard = GameInfo.cardInfo[satisfiedStandardCardID].duplicate()

	return targetCard

## 根据主属性、副属性标记，来获取对应的模板卡牌
func _search_mindStateTargetCard_from_mainProperty_and_secondProperty(mainProperty: String, secondProperty: String) -> String:
	var outputTemplate
	for template in GameInfo.mindStateTemplate.values():
		outputTemplate = template
		if GameInfo.check_property_mainProperty(template, mainProperty) and GameInfo.check_property_secondProperty(template, secondProperty):
			break

	return outputTemplate['StandardCardID']

## 触发战斗结算时，显示 battleResult_panel。
func _show_battleResult_panel() -> void:
	battlePanel.closeButton.visible = false
	await get_tree().create_timer(0.5).timeout
	var battleResultPanel = preload("res://scene/event/ResultPanel/ResultPanel.tscn").instantiate() as Control
	battlePanel.add_child(battleResultPanel)
	var resultDeck = battleResultPanel.get_node("ResultDeck") as deck
	## TODO 临时方法，固定生成4张卡牌，卡牌类型根据 mindStateSwarm 随机生成
	for index in range(4):
		var cardRawInfo = get_randomCard_from_MindStateSwarm()
		var searchCard = PlayerInfo.add_new_card(cardRawInfo['base_cardName'],resultDeck,resultDeck)

