extends Node2D


@export var scene_1:Node
@export var scene_2:Node
@export var scene_3:Node


@export var maxRandomItemNum:int
@export var minRandomItemNum:int
@export var siteItems:Dictionary

var selectDeckButton_list: Dictionary

## 内部函数。用于初始化 deckList 结构
func _init_deckList() -> void:
	## 初始化 deckList 相关结构。目标在 cardDataManager 中
	var initDeckListStructure = {
		GameType.CardType.MINDSTATE: $MindState_handDeck,
		GameType.CardType.MEMORY: $Memory_handDeck
	}

	GameInfo.cardDataManager.init_deckList(initDeckListStructure)

	## 初始化 selectDeckButton 的 list 结构。
	selectDeckButton_list = {
		GameType.CardType.MINDSTATE: $deckSelectButtonList/VBoxContainer/MindState_SelectButton,
		GameType.CardType.MEMORY: $deckSelectButtonList/VBoxContainer/Memory_SelectButton
	}


#写一个随机生成几张卡片的函数，首先从给定的随机最大值和最小值之间生成卡牌数量，然后根据卡牌数量从可选择的卡牌中根据卡牌出现概率选择生成的卡牌并执行生成函数，可选择的卡牌以字典的形式储存，键名为卡牌名，键值为出现概率，概率为0到100
func get_some_card():
	var num_cards = randi() % (maxRandomItemNum - minRandomItemNum + 1) + minRandomItemNum
	var total_weight = get_total_weight(siteItems)
	var selected_cards = []

	for i in range(num_cards):
		var random_num = randi() % total_weight
		var cumulative_weight = 0
		for c in siteItems.keys():
			cumulative_weight += siteItems[c]
			if random_num < cumulative_weight:
				selected_cards.append(c)
				break

	for c in selected_cards:
		#var randomDeck = get_tree().get_nodes_in_group("cardDeck")[randi_range(0,0)]
		#var handDeck = $handDeck
		await get_tree().create_timer(0.1).timeout
		var searchCardData = GameInfo.search_card_from_cardName(c)
		var targetDeck = GameInfo.cardDataManager.get_targetDeck_from_card(searchCardData)
		PlayerInfo.add_new_card(searchCardData['base_cardName'],targetDeck,$Button)

	GameInfo.mindStateManager.get_randomCard_from_MindStateSwarm()

## 获得部分 mindStateCard。获取卡牌基于 mindStateSwarm 生成。
func get_some_mindStateCard() -> void:
	var num_cards = randi() % (maxRandomItemNum - minRandomItemNum + 1) + minRandomItemNum

	for i in range(num_cards):
		await get_tree().create_timer(0.1).timeout
		var searchCardData = GameInfo.mindStateManager.get_randomCard_from_MindStateSwarm()
		var targetDeck = GameInfo.cardDataManager.get_targetDeck_from_card(searchCardData)
		PlayerInfo.add_new_card(searchCardData['base_cardName'],targetDeck,$Button)


# 计算权重总和
func get_total_weight(card_dict):
	var total_weight = 0
	for weight in card_dict.values():
		total_weight += weight
	return total_weight

func _ready() -> void:
	## 设置 buttonGroup 使得 selectButton 均为单选
	var selectButtonGroup = ButtonGroup.new()
	_init_deckList()
	## 初始化 deck 和对应 selectButton 状态与关联关系
	for deckKey in selectDeckButton_list.keys():
		var hand_deck = GameInfo.cardDataManager.deckList[deckKey] as deck
		hand_deck.maxWeight = PlayerInfo.save.handMax
		hand_deck.loadCards()

		var targetButton = selectDeckButton_list[deckKey] as Button
		targetButton.button_group = selectButtonGroup
		targetButton.toggle_mode = true
		targetButton.pressed.connect(_on_select_deck)

	## 初始化第一个选中状态
	var firstIndex = selectDeckButton_list.keys()[0]
	var firstButton = selectDeckButton_list[firstIndex] as Button
	firstButton.button_pressed = true
	GameInfo.cardDataManager.deckList[firstIndex].visible = true

func _on_select_deck() -> void:
	for deckKey in selectDeckButton_list.keys():
		var targetDeck = GameInfo.cardDataManager.deckList[deckKey] as Control
		targetDeck.visible = !targetDeck.visible
