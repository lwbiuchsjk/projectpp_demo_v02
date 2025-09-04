extends deck
class_name Seat

@export var accepted_types: Array[GameType.CardType]  # 在检查器中设置允许的类型
var card_can_drop:bool = false
var seat_card
var avgManager = GameInfo.get_node("AVGManager")
var seat_index: int
var seatID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Seat")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func is_type_match(type: GameType.CardType) -> bool:
	return type in accepted_types  # 检查卡牌类型是否匹配

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
	avgManager.set_seatPair(seatID, 1)
	avgManager.emit_signal("show_seat_brief_status", seat_index, true)

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
	if targetCard.is_in_group("card") and is_type_match(targetCard.get_card_type()):
		card_can_drop = true

func _on_area_exited(targetCard: Area2D):
	if targetCard.is_in_group("card"):
		card_can_drop = false

func set_seat_type(typeList: Array) -> void:
	accepted_types.clear()
	for targetType in typeList:
		if targetType != GameType.CardType.NONE:
			accepted_types.append(targetType)

func search_seat_property(ID: String):
	for seatInfo in GameInfo.itemSeat.values():
		if seatInfo.ID == ID:
			return GameType.get_cardType(seatInfo['base_cardType'])

func _set_seat_card(target: card) -> void:
	seat_card = target

func clean_seat_card() -> void:
	_set_seat_card(null)
	avgManager.set_seatPair(seatID, -1)

func set_seat_data(index: int, ID: String) -> void:
	seat_index = index
	seatID = ID
