extends Control

@export var characters: Array[PlayerInfoPannel] = []
@export var cardCound := 3

func _init() -> void:
	var newPlayerInfo = player.new()
	playerInit(newPlayerInfo)

func playerInit(newPlayer:player):
	newPlayer.playerName="lwbiuchsjk"
	newPlayer.location="res://site/site1.tscn"
	newPlayer.handMax = 100
	var folderPath = "user://save/"
	var savePath = folderPath+"autoSave.tres"
	create_folder(folderPath)
	newPlayer.folderPath=folderPath
	ResourceSaver.save(newPlayer,savePath)
	PlayerInfo.loadPlayerInfo()

# 创建文件夹的函数
func create_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir!=null:
		print("Directory already exists: " + folder_path)
	else:
		var result = DirAccess.make_dir_absolute(folder_path)
		if result == OK:
			print("Directory created: " + folder_path)
		else:
			print("Failed to create directory: " + folder_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("...测试属性")
	for _player in characters:
		var attribute_set = _player.get_attribute_set() as AttributeSet
		for _name in attribute_set.attributes_runtime_dict:
			print(_name)

	var avgManager = GameInfo.get_node("AVGManager")
	avgManager.set_plot_now(1)

	avgManager.emit_signal("new_plot")

	var placePannel = get_node('PlacePannel')

	## TODO: 此处调用逻辑课写在专门函数中
	#print("……测试卡牌脚本")
	#var plotSegment = GameInfo.plotSegment.values()[0]
	#avgManager.set_avg_now(plotSegment['avg_plot'])
	#for i in plotSegment['seat_list']:
	#	var testCard = preload("res://scene/Seat/seat.tscn").instantiate() as Seat
	#	$Event.add_child_item(testCard)
	#	var card_type = testCard.search_seat_property(i)
	#	testCard.set_seat_type([card_type])
	#$Event.arrange_children_bottom_up()
	### 触发信号
	#avgManager.emit_signal("new_avg")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
