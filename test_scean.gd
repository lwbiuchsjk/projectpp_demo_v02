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

	##TODO 正式功能中，下方就是调用新剧情段落的实现，需要按原样移动
	var avgManager = GameInfo.get_node("AVGManager")
	avgManager.emit_signal("new_plot")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
