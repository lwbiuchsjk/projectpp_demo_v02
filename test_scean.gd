extends Control


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
	Infos.loadPlayerInfo()
	
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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
