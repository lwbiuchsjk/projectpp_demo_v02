extends Control

@onready var collectButton = $CollectCardButton as Button
@onready var resultDeck = $ResultDeck as deck

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collectButton.pressed.connect(_close_panel)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _close_panel() -> void:
	print("关闭 ResultDeck")
	for target in resultDeck.get_node("cardDcek").get_children():
		GameInfo.cardDataManager.trans_card_to_handDeck.emit(target)
	## 清理工作
	## 清理结果弹板
	self.visible = false
	## 临时将 close_mindStateBattle_panel 写死在这里
	GameInfo.mindStateManager.close_mindStateBattle_panel.emit()
