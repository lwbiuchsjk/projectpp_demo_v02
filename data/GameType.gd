# CardTypes.gd
extends Node

enum CardType {
	NONE, 		# 初始空值
	SKILL,		# 技能
	ITEM,		# 道具
	MEMORY,		# 记忆
	MINDSTATE,	# 心相
}

func get_cardType(typeString: String) -> int:
	match typeString.to_upper():
		"SKILL":
			return CardType.SKILL
		"ITEM":
			return CardType.ITEM
		"MEMORY":
			return CardType.MEMORY
		"MINDSTATE":
			return CardType.MINDSTATE
		_:
			return CardType.NONE

enum CardClass {
	NONE,		# 初始空值
	ITEM
}

func get_cardClass(typeString: String) -> int:
	match typeString.to_upper():
		"ITEM":
			return CardClass.ITEM
		_:
			return CardClass.NONE
