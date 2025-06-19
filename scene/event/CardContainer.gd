extends Container

@export var item_size := Vector2(220, 320)
@export var spacing := Vector2(30, 30)  # x: 水平间隔, y: 垂直间隔
@export var columns := 3

func _ready():
	arrange_children_bottom_up()

# 从左到右、从下至上排列子节点
func arrange_children_bottom_up():
	var children = get_children()
	if children.is_empty():
		return
	
	# 计算总行数（向上取整）
	var row_count = ceili(children.size() / float(columns))
	
	# 遍历所有子节点
	for i in children.size():
		var child = children[i]
		# 计算当前行列（从下往上数）
		var col = i % columns
		var row_from_bottom = row_count - 1 - (i / columns)  # 关键：反向计算行号
		# 设置子节点位置和大小
		child.position = Vector2(
			col * (item_size.x + spacing.x),
			row_from_bottom * (item_size.y + spacing.y)
		)
		child.size = item_size
	
	# 更新父容器尺寸（可选，用于滚动区域）
	var total_width = columns * (item_size.x + spacing.x)
	var total_height = row_count * (item_size.y + spacing.y)
	custom_minimum_size = Vector2(total_width, total_height)

# 必须重写此方法
func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_children()

func _arrange_children():
	var children = get_children()
	var row_count = ceili(children.size() / float(columns))
	var parent_height = size.y
	
	for i in children.size():
		var child = children[i]
		var col = i % columns
		var row = i / columns
		# 关键修改：Y 坐标从底部计算
		var pos_y = parent_height - (row + 1) * (item_size.y + spacing.y)
		var pos = Vector2(
			col * (item_size.x + spacing.x),
			pos_y
		)
		fit_child_in_rect(child, Rect2(pos, item_size))
	
	# 更新容器最小尺寸
	custom_minimum_size = Vector2(
		columns * (item_size.x + spacing.x),
		row_count * (item_size.y + spacing.y)
	)
