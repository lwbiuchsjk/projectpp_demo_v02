extends Seat
class_name MindStatePlayerSelectSeat

func add_card(cardToAdd)->void:
	super.add_card(cardToAdd)
	GameInfo.mindStateManager.battlePanel.show_CardInfo(cardToAdd, false)
