extends Control
class_name Seat

@export var accepted_types: Array[GameType.CardType]  # 在检查器中设置允许的类型

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Seat")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func is_type_match(type: GameType.CardType) -> bool:
	return type in accepted_types  # 检查卡牌类型是否匹配


func _on_area_entered(targetArea: Area2D):
	var targetCard = targetArea.get_parent() as card
	if targetCard.is_in_group("card") and is_type_match(targetCard.get_card_type()):
		print("卡牌类型匹配，可以放入！")

func _on_area_exited(targetCard: Area2D):
	if targetCard.is_in_group("card"):
		print("卡牌离开区域")
		
func set_seat_type(typeList: Array) -> void:
	accepted_types.clear()
	for targetType in typeList:
		accepted_types.append(targetType)
		print(targetType)
	pass
