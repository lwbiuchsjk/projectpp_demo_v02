extends Control
class_name AVGPanel

@onready var nowText:Label = $ScrollContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_new_avg(avgText:String) -> void:
	if nowText.text == "":
		nowText.text = avgText
	else:
		nowText.text = nowText.text + "\n\n" + avgText

func on_clean_avg():
	nowText.text = ""
