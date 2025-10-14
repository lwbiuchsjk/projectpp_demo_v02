extends deck
class_name handDeck
@export var deckType: GameType.CardType = GameType.CardType.NONE

func _ready() -> void:
	$ProgressBar.max_value = maxWeight
	update_weight()
	pass

## 外部函数，检查传入的卡牌 type 与当前的 deckType 是否匹配
func check_cardType_match(cardToAdd: card) -> bool:
	var targetCardType = GameType.get_cardType(cardToAdd.cardInfo['base_cardType'])
	if targetCardType != GameType.CardType.NONE and targetCardType == deckType:
		return true
	return false

## 外部函数。覆盖基类方法。在原有功能上，判断 type 是否匹配
##func add_card(cardToAdd)->void:
##	if _check_cardType_match(cardToAdd):
##		super.add_card(cardToAdd)
