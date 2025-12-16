extends Seat
class_name MindStateSelectSeat

#var seat_mindStateCard: card:
#	set(cardToAdd): seat_mindStateCard = cardToAdd
#	get(): return seat_mindStateCard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.

## 复写 super 函数，仅调用基础逻辑，不受其他业务影响
func add_card(cardToAdd) -> void:
	super._add_card_base_func(cardToAdd)
	_add_cardToSeat(cardToAdd)

## 本地函数，用于在业务逻辑中添加逻辑。其中 seat_card 已经在父函数中定义。
func _add_cardToSeat(cardToAdd) -> void:
	seat_card = cardToAdd
	## 调用 mindStateManager 信号 show_inputCard_change_direction，将 index 传入，用于索引对应的 inputPanel 和 property
	GameInfo.mindStateManager.emit_signal("show_inputCard_change_direction", seat_card, seat_index)

## 复写 super 函数，仅调用基础逻辑，不受其他业务影响
func clean_seat_card() -> void:
	seat_card = null
	## 调用 battlePanel 中对应 index 的 inputPanel 信号 clean_change_direction
	GameInfo.mindStateManager.emit_signal("clean_change_direction", seat_index)
