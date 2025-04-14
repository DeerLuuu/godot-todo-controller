@tool
class_name TodoControllerPanel extends TabContainer

const STAR : String = "🩷"
const NOT_STAR : String = "🩶"

@onready var script_tree: Tree = %ScriptTree
@onready var annotation_code_tree: Tree = %AnnotationCodeTree
@onready var scrpit_list_h_split: HSplitContainer = %ScrpitListHSplit
@onready var star_script_tree: Tree = %StarScriptTree
@onready var tree_v_box: VBoxContainer = %TreeVBox

var star_list : Array = ["res://addons/todo_controller/todo_controller.gd"]
var left_list_x : float
var script_list : Array
var keywords
var is_selected_mode : bool = false
var is_star_mode : bool = false
var is_selected_mode_index : int

func _ready() -> void:
	script_tree.item_activated.connect(_on_script_tree_item_activated)
	script_tree.item_collapsed.connect(_on_item_collapsed)
	script_tree.item_mouse_selected.connect(_on_script_tree_item_mouse_selected)
	star_script_tree.item_activated.connect(_on_star_script_tree_item_activated)
	star_script_tree.item_collapsed.connect(_on_item_collapsed)
	star_script_tree.item_mouse_selected.connect(_on_star_script_tree_item_mouse_selected)
	annotation_code_tree.item_selected.connect(_on_annotation_code_tree_item_selected)

	var settings = EditorInterface.get_editor_settings()
	keywords = settings.get_setting("text_editor/theme/highlighting/comment_markers/warning_list")

	reset_todo_controller()


# TODO 生成脚本列表中的树的方法
func reset_todo_controller() -> void:
	script_list = get_scripte_list("res://")

	update_script_tree()
	update_star_script_tree()

	var root : TreeItem = script_tree.get_root()
	script_tree.set_selected(root, 0)

func update_script_tree() -> void:
	script_tree.clear()
	var root : TreeItem = script_tree.create_item()
	root.set_custom_font_size(0, 20)
	root.set_text(0, "所有脚本")
	root.set_custom_color(0, Color.AQUA)

	for d : String in script_list:
		var script_tree_item : Array = d.split("/")
		var script_name : String = script_tree_item.pop_back()
		var tree_item : TreeItem = script_tree.create_item(root)
		tree_item.set_custom_font_size(0, 16)
		tree_item.set_text(0, "%3s" % NOT_STAR + script_name)
		if d in star_list:
			tree_item.set_text(0, "%3s" % STAR + script_name)
		tree_item.set_custom_color(0, Color.AQUAMARINE)

		left_list_x = \
			left_list_x \
			if left_list_x > (tree_item.get_custom_font_size(0) - 2) * tree_item.get_text(0).length() else \
			(tree_item.get_custom_font_size(0) - 3) * tree_item.get_text(0).length()

		scrpit_list_h_split.split_offset = left_list_x

func update_star_script_tree() -> void:
	star_script_tree.clear()
	var star_root = star_script_tree.create_item()
	star_root.set_custom_font_size(0, 20)
	star_root.set_text(0, "收藏脚本")
	star_root.set_custom_color(0, Color.AQUA)

	for d : String in star_list:
		var script_tree_item : Array = d.split("/")
		var script_name : String = script_tree_item.pop_back()
		var tree_item : TreeItem = star_script_tree.create_item(star_root)
		tree_item.set_custom_font_size(0, 16)
		tree_item.set_text(0, "%3s" % STAR + script_name)
		tree_item.set_custom_color(0, Color.AQUAMARINE)

# TODO 脚本列表双击时的方法
func _on_script_tree_item_activated() -> void:
	if script_tree.get_selected().get_text(0) == "所有脚本": return
	var script_path : String = script_list[script_tree.get_selected().get_index()]
	EditorInterface.edit_resource(load(script_path))

# TODO 收藏列表双击时的方法
func _on_star_script_tree_item_activated() -> void:
	if star_script_tree.get_selected().get_text(0) == "收藏脚本": return
	var script_path : String = star_list[star_script_tree.get_selected().get_index()]
	EditorInterface.edit_resource(load(script_path))

# TODO 树被折叠时的方法
func _on_item_collapsed(_item : TreeItem) -> void:
	# FIXME 这里使用了取巧的方式显示和隐藏实现了折叠树的空间刷新，后续尝试寻找解决方案
	star_script_tree.hide()
	star_script_tree.show()
	script_tree.hide()
	script_tree.show()

# TODO 收藏脚本树被鼠标点击的方法
func _on_star_script_tree_item_mouse_selected(_mouse_position: Vector2, mouse_button_index: int) -> void:
	# 鼠标左键输入
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		is_star_mode = true
		annotation_code_tree.clear()
		var file = FileAccess.open(star_list[star_script_tree.get_selected().get_index()], FileAccess.READ)
		var script_text : String = file.get_as_text()
		var script_rows : Array = script_text.split("\n")

		if star_script_tree.get_selected().get_text(0) == "收藏脚本":
			is_selected_mode = false
			var root_item : TreeItem = annotation_code_tree.create_item()
			root_item.set_text(0, "收藏脚本")
			root_item.set_custom_color(0, Color.AQUA)
			for i in star_list.size():
				var _item : TreeItem = annotation_code_tree.create_item()
				_item.set_text(0, star_list[i].split("/")[-1])
				_item.set_custom_color(0, Color.AQUAMARINE)

				script_text = file.open(star_list[i], FileAccess.READ).get_as_text()
				script_rows = script_text.split("\n")

				for row in script_rows.size():
					var script_row : String = script_rows[row]
					if not script_row.begins_with("# "): continue

					script_row = script_row.erase(0, 2)
					var keywords_list : Array = keywords.split(",")

					for k in keywords_list.size():
						if not script_row.begins_with(keywords_list[k]): continue
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.YELLOW)
			return

		is_selected_mode = true
		is_selected_mode_index = star_script_tree.get_selected().get_index()
		var root_item : TreeItem = annotation_code_tree.create_item()
		root_item.set_text(0, star_list[is_selected_mode_index].split("/")[-1])
		root_item.set_custom_color(0, Color.AQUAMARINE)

		for row in script_rows.size():
			var script_row : String = script_rows[row]
			if not script_row.begins_with("# "): continue

			script_row = script_row.erase(0, 2)
			var keywords_list : Array = keywords.split(",")

			for k in keywords_list.size():
				if not script_row.begins_with(keywords_list[k]): continue
				var item : TreeItem = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.YELLOW)

	# 鼠标右键输入
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if star_script_tree.get_selected().get_text(0) == "收藏脚本": return
		var selected_script : String = star_list[star_script_tree.get_selected().get_index()]
		star_list.erase(selected_script)

		# FIXME 这里后面得写一个右键菜单，否则刷新会有bug
		#update_script_tree()
		#update_star_script_tree()

# TODO 所有脚本树被鼠标点击的方法
func _on_script_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	# 鼠标左键输入
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		is_star_mode = false
		annotation_code_tree.clear()
		var file = FileAccess.open(script_list[script_tree.get_selected().get_index()], FileAccess.READ)
		var script_text : String = file.get_as_text()
		var script_rows : Array = script_text.split("\n")

		if script_tree.get_selected().get_text(0) == "所有脚本":
			is_selected_mode = false
			var root_item : TreeItem = annotation_code_tree.create_item()
			root_item.set_text(0, "所有脚本")
			root_item.set_custom_color(0, Color.AQUA)
			for i in script_list.size():
				var _item : TreeItem = annotation_code_tree.create_item()
				_item.set_text(0, script_list[i].split("/")[-1])
				_item.set_custom_color(0, Color.AQUAMARINE)

				script_text = file.open(script_list[i], FileAccess.READ).get_as_text()
				script_rows = script_text.split("\n")

				for row in script_rows.size():
					var script_row : String = script_rows[row]
					if not script_row.begins_with("# "): continue

					script_row = script_row.erase(0, 2)
					var keywords_list : Array = keywords.split(",")

					for k in keywords_list.size():
						if not script_row.begins_with(keywords_list[k]): continue
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.YELLOW)
			return

		is_selected_mode = true
		is_selected_mode_index = script_tree.get_selected().get_index()
		var root_item : TreeItem = annotation_code_tree.create_item()
		root_item.set_text(0, script_list[is_selected_mode_index].split("/")[-1])
		root_item.set_custom_color(0, Color.AQUAMARINE)

		for row in script_rows.size():
			var script_row : String = script_rows[row]
			if not script_row.begins_with("# "): continue

			script_row = script_row.erase(0, 2)
			var keywords_list : Array = keywords.split(",")

			for k in keywords_list.size():
				if not script_row.begins_with(keywords_list[k]): continue
				var item : TreeItem = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.YELLOW)

	# 鼠标右键输入
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if script_tree.get_selected().get_text(0) == "所有脚本": return
		var selected_script : String = script_list[script_tree.get_selected().get_index()]
		if star_list.has(selected_script):
			star_list.erase(selected_script)
		else :
			star_list.append(selected_script)
		update_script_tree()
		update_star_script_tree()

# TODO 注释列表被点击时的方法
func _on_annotation_code_tree_item_selected() -> void:
	if annotation_code_tree.get_selected().get_text(0) == "所有脚本": return
	if annotation_code_tree.get_selected().get_text(0) == "收藏脚本": return
	if annotation_code_tree.get_selected().get_text(0).get_extension() == "gd":
		var script_path : String = \
			star_list[annotation_code_tree.get_selected().get_parent().get_index()] \
			if is_star_mode else \
			script_list[annotation_code_tree.get_selected().get_parent().get_index()]
		if is_selected_mode:
			script_path = star_list[is_selected_mode_index] if is_star_mode else script_list[is_selected_mode_index]
		EditorInterface.edit_resource(load(script_path))
		return

	var key : String = annotation_code_tree.get_selected().get_text(0).split(" ")[2]
	key = get_annotation_key(key)
	if key != "":
		var line : int = int(annotation_code_tree.get_selected().get_text(0).split(" ")[0].erase(0).left(5))
		print(line)
		var script_path : String = \
			star_list[annotation_code_tree.get_selected().get_parent().get_index()] \
			if is_star_mode else \
			script_list[annotation_code_tree.get_selected().get_parent().get_index()]
		if is_selected_mode:
			script_path = star_list[is_selected_mode_index] if is_star_mode else script_list[is_selected_mode_index]
		EditorInterface.edit_resource(load(script_path))
		EditorInterface.get_script_editor().goto_line(line - 1)

# TODO 获取某行注释的注释关键字的方法
func get_annotation_key(annotation : String) -> String:
	var keywords_list : Array = keywords.split(",")
	for i in keywords_list.size():
		if not annotation.begins_with(keywords_list[i]): continue
		return keywords_list[i]
	return ""

# TODO 插件脚本列表的方法
func get_scripte_list(root_path : String) -> Array:
	var scripts := []
	var dir = DirAccess.open(root_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			var full_path = root_path.path_join(file_name)

			if dir.current_is_dir() and not _is_special_dir(file_name):
				# 递归处理子目录
				scripts.append_array(get_scripte_list(full_path))
			else:
				# 判断文件扩展名
				if file_name.get_extension() == "gd":
					scripts.append(full_path)

			file_name = dir.get_next()
	return scripts

# TODO 判断是否是不需要的文件夹
func _is_special_dir(name: String) -> bool:
	return name in [".", ".."]
