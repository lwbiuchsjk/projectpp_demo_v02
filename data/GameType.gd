# CardTypes.gd
extends Node

enum CardType {
	NONE, 		# 初始空值
	SKILL,      # 技能
	ITEM,       # 道具
	MEMORY      # 记忆
}

func get_cardType(type_string: String) -> int:
	match type_string.to_upper():
		"SKILL":
			return CardType.SKILL
		"ITEM":
			return CardType.ITEM
		"MEMORY":
			return CardType.MEMORY
		_:
			return CardType.NONE
