extends deck
class_name Seat

var accepted_class: Array[GameType.CardClass]  # 在检查器中设置允许的类型
var seatType
var card_can_drop:bool = false
var seat_card
var seat_index: int
var seatID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Seat")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 内部函数。检查卡牌类型是否匹配。根据传入的卡牌数据，判断 type 完全相当，并且 class 包含卡牌。
func _is_type_match(targetCard: card) -> bool:
	var cardData = targetCard.cardInfo
	var cardType = GameType.get_cardType(cardData['base_cardType'])
	var nowSeatType = GameType.get_cardType(seatType)
	var cardClass = GameType.get_cardClass(cardData['base_cardClass'])
	if cardType != GameType.CardType.NONE and cardType == nowSeatType and cardClass in accepted_class:
		return true
	return false

func add_card(cardToAdd)->void:
	var cardBackground=preload("res://scene/cards/card_background.tscn").instantiate()
	cardPoiDeck.add_child(cardBackground)

	var global_poi = cardToAdd.global_position  # 获取节点的全局位置

	if cardToAdd.get_parent():
		cardToAdd.get_parent().remove_child(cardToAdd)
	cardDeck.add_child(cardToAdd)
	cardToAdd.global_position=global_poi

	cardToAdd.follow_target=cardBackground

	cardToAdd.preDeck=self

	cardToAdd.cardCurrentState=cardToAdd.cardState.following
	update_weight()
	trigger_deck_sort()

	_set_seat_card(cardToAdd)
	GameInfo.avgManager.set_seatPair(seatID, 1)
	GameInfo.avgManager.emit_signal("show_seat_brief_status", seat_index, true)

func update_weight() -> void:
	var nowWeight=0
	for i in cardDeck.get_children():
		if i.cardCurrentState==i.cardState.following:
			nowWeight+=i.cardWeight*i.num
	currentWeight=nowWeight
	pass

func check_seat_can_drop() -> bool:
	if seat_card != null:
		return false
	return card_can_drop


func _on_area_entered(targetArea: Area2D):
	var targetCard = targetArea.get_parent() as card
	card_can_drop = false
	if targetCard.is_in_group("card") and _is_type_match(targetCard):
		card_can_drop = true

func _on_area_exited(targetCard: Area2D):
	if targetCard.is_in_group("card"):
		card_can_drop = false

## 内部函数。用于通过配置来设置 seat 的 class 数据。
func _set_seat_class(config: String) -> void:
	accepted_class.clear()
	var targetType = GameType.get_cardClass(config)
	if targetType != GameType.CardClass.NONE:
		accepted_class.append(targetType)

func search_seat_property(ID: String):
	for seatInfo in GameInfo.itemSeat.values():
		if seatInfo.ID == ID:
			return GameType.get_cardType(seatInfo['base_cardType'])

func _set_seat_card(target: card) -> void:
	seat_card = target
	GameInfo.cardDataManager.SetCardToListFromIndex(seat_index, target)
	print(GameInfo.cardDataManager.seatedCardList[seat_index])

func clean_seat_card() -> void:
	_set_seat_card(null)
	GameInfo.avgManager.set_seatPair(seatID, -1)

## 外部函数。用于初始化本 seat 的数据
func set_seat_data(index: int, ID: String) -> void:
	seat_index = index
	seatID = ID

	var seatClassConfig
	for seatInfo in GameInfo.itemSeat.values():
		if seatInfo.ID == seatID:
			seatType = seatInfo['base_cardType']
			seatClassConfig = seatInfo['base_cardClass']
			break
	_set_seat_class(seatClassConfig)
