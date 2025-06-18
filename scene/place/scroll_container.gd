extends ScrollContainer

@export var rows := 2           # 固定行数
@export var item_size := Vector2(300, 300)
@export var spacing := 10       # 子节点间距
@export var content_count_control := 10

func _ready():
	update_layout()

func add_item(item: Control):
	item.custom_minimum_size = item_size
	$Content.add_child(item)  # Content 是一个普通的 Control 节点
	update_layout()

func update_layout():
	var children = $Content.get_children()
	if children.is_empty():
		return
	
	# 计算需要的列数
	var columns = ceili(children.size() / float(rows))
	
	# 排列子节点（先从上到下，再从左到右）
	for col in columns:
		for row in rows:
			var index = col * rows + row
			if index >= children.size():
				break
			var child = children[index]
			child.position = Vector2(
				col * (item_size.x + spacing),
				row * (item_size.y + spacing))
	
	# 更新 Content 容器大小（触发滚动）
	$Content.custom_minimum_size = Vector2(
		columns * (item_size.x + spacing),
		rows * (item_size.y + spacing))
	
	# 根据子节点数量调整对齐
	if children.size() <= content_count_control:
		$Content.position.x = (size.x - $Content.custom_minimum_size.x) / 2  # 居中
		scroll_horizontal = false
		#horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		#scroll_horizontal_enabled = false
	else:
		$Content.position.x = 0  # 左对齐
		scroll_horizontal = true
		#horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		#scroll_horizontal_enabled = true
