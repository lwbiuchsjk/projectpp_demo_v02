extends Node

#存储所有的存档
var saves:Dictionary

var save:player

var playerInfoPath:String

func add_new_card(cardName,cardDeck,caller = get_tree().get_first_node_in_group("cardDeck"))->Node:
		print("开始创建新卡牌："+str(cardName))
		var searchCard = GameInfo.search_card_from_cardName(cardName)
		var cardClass=searchCard["base_cardClass"]
		print("添加的卡的类型为:%s"%cardClass)
		var cardToAdd

		##TODO 需要根据卡牌类型，或牌库类型，来加载对应类型的卡牌。当前写死了加载类型。
		print("添加卡牌信息：%s"%[searchCard])
		cardToAdd=preload("res://scene/cards/MindStateCard/MindStateCard.tscn").instantiate() as card

		cardToAdd.initCard(searchCard)

		cardToAdd.global_position=caller.global_position
		cardToAdd.z_index=100
		cardDeck.add_card(cardToAdd)
		return cardToAdd

func loadPlayerInfo(savePath:String="autoSave"):
	var path = "user://save/"+savePath+".tres"
	playerInfoPath=path
	save = load(playerInfoPath) as player



func savePlayerInfo(newSavePath:String):
	for d in get_tree().get_nodes_in_group("saveableDecks"):
		d.storCard()
	var path = save.folderPath+newSavePath+".tres"
	ResourceSaver.save(save,path)
	print("存档保存至"+path)
