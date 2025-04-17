@tool
# INFO Todo Controller 的主要面板类
class_name TodoControllerPanel extends TabContainer

const SCRIPT_RMB_PANEL = preload("res://addons/todo_controller/ui/script_rmb_panel.tscn")
const STAR : String = "♥"
const NOT_STAR : String = "♡"

@onready var script_tree: Tree = %ScriptTree
@onready var star_script_tree: Tree = %StarScriptTree
@onready var annotation_code_tree: Tree = %AnnotationCodeTree

@onready var scrpit_list_h_split: HSplitContainer = %ScrpitListHSplit
@onready var tree_v_box: VBoxContainer = %TreeVBox
@onready var ex_control: Control = %EX_Control

@onready var scratch_edit: LineEdit = %ScratchEdit
@onready var case_sensitive_button: CheckButton = %CaseSensitiveButton

var star_list : Array:
	set(v):
		star_list = v
		var config : Config = Config.new()
		config.star_list = star_list
		ResourceSaver.save(config, "res://addons/todo_controller/config/config.tres")
var script_list : Array

var left_list_x : float
var keywords : Array
var keywords_notice : Array
var keywords_critical : Array
var current_tree : Tree
var is_case_sensitive : bool = false

func _ready() -> void:
	if not DirAccess.dir_exists_absolute("res://addons/todo_controller/config/"):
		DirAccess.make_dir_absolute("res://addons/todo_controller/config/")

	script_tree.item_activated.connect(_on_script_tree_item_activated.bind(script_tree))
	script_tree.item_collapsed.connect(_on_item_collapsed)
	script_tree.item_mouse_selected.connect(_on_script_tree_item_mouse_selected)

	star_script_tree.item_activated.connect(_on_script_tree_item_activated.bind(star_script_tree))
	star_script_tree.item_collapsed.connect(_on_item_collapsed)
	star_script_tree.item_mouse_selected.connect(_on_star_script_tree_item_mouse_selected)

	annotation_code_tree.item_selected.connect(_on_annotation_code_tree_item_selected)
	scratch_edit.text_changed.connect(_on_scratch_edit_text_changed)
	case_sensitive_button.toggled.connect(_on_case_sensitive_button_toggled)

	set_tab_title(0, "TODO管理器")
	set_tab_title(1, "设置")

	var settings = EditorInterface.get_editor_settings()
	keywords = settings.get_setting("text_editor/theme/highlighting/comment_markers/warning_list").split(",")
	keywords_notice = settings.get_setting("text_editor/theme/highlighting/comment_markers/notice_list").split(",")
	keywords_critical = settings.get_setting("text_editor/theme/highlighting/comment_markers/critical_list").split(",")

	reset_todo_controller()
	script_tree_can_selected()

# TODO 脚本树是否允许点击
func script_tree_can_selected() -> void:
	if star_list.is_empty():
		star_script_tree.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else :
		star_script_tree.mouse_filter = Control.MOUSE_FILTER_STOP

# TODO 生成脚本列表中的树的方法
func reset_todo_controller() -> void:
	script_list = get_scripte_list("res://")

	if FileAccess.file_exists("res://addons/todo_controller/config/config.tres"):
		var config : Config = ResourceLoader.load("res://addons/todo_controller/config/config.tres")
		if config:
			for i in config.star_list:
				if i in script_list:
					continue
				config.star_list.erase(i)
			star_list = config.star_list

	update_star_script_tree()
	update_script_tree()

# 更新脚本树
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

# 更新收藏脚本树
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
func _on_script_tree_item_activated(tree : Tree) -> void:
	var script_path : String
	if tree == script_tree:
		if not script_tree.get_selected().get_text(0) == "所有脚本":
			script_path = script_list[script_tree.get_selected().get_index()]
			EditorInterface.edit_resource(load(script_path))
	elif tree == star_script_tree:
		if not star_script_tree.get_selected().get_text(0) == "收藏脚本":
			script_path = star_list[star_script_tree.get_selected().get_index()]
			EditorInterface.edit_resource(load(script_path))

# TODO 树被折叠时的方法
func _on_item_collapsed(_item : TreeItem) -> void:
	# FIXME 这里使用了取巧的方式显示和隐藏实现了折叠树的空间刷新，后续尝试寻找解决方案
	update_item_collapsed()

# TODO 更新树物品折叠的空间刷新方法
func update_item_collapsed() -> void:
	star_script_tree.hide()
	star_script_tree.show()
	script_tree.hide()
	script_tree.show()

# TODO 收藏脚本树被鼠标点击的方法
func _on_star_script_tree_item_mouse_selected(_mouse_position: Vector2, mouse_button_index: int) -> void:
	# 鼠标左键输入
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		current_tree = star_script_tree
		annotation_code_tree.clear()

		var file = FileAccess.open(star_list[current_tree.get_selected().get_index()], FileAccess.READ)
		var script_text : String = file.get_as_text()
		var script_rows : Array = script_text.split("\n")

		if star_script_tree.get_selected().get_text(0) == "收藏脚本":
			var root_item : TreeItem = annotation_code_tree.create_item()
			root_item.set_text(0, "收藏脚本")
			root_item.set_custom_color(0, Color.AQUA)
			for i in star_list.size():
				var _item : TreeItem = annotation_code_tree.create_item()
				var item_has_annotation : bool = false
				_item.set_text(0, star_list[i].split("/")[-1])
				_item.set_custom_color(0, Color.AQUAMARINE)

				script_text = file.open(star_list[i], FileAccess.READ).get_as_text()
				script_rows = script_text.split("\n")

				for row in script_rows.size():
					var script_row : String = script_rows[row]
					if not script_row.begins_with("# "): continue

					script_row = script_row.erase(0, 2)

					if get_annotation_key(script_row) in keywords:
						var item : TreeItem = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.YELLOW)
						item_has_annotation = true
					if get_annotation_key(script_row) in keywords_critical:
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.INDIAN_RED)
						item_has_annotation = true
					if get_annotation_key(script_row) in keywords_notice:
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.PALE_GREEN)
						item_has_annotation = true
				if not item_has_annotation:
					root_item.remove_child(_item)
					_item.free()
			return

		var root_item : TreeItem = annotation_code_tree.create_item()
		root_item.set_text(0, star_list[star_script_tree.get_selected().get_index()].split("/")[-1])
		root_item.set_custom_color(0, Color.AQUAMARINE)

		for row in script_rows.size():
			var script_row : String = script_rows[row]
			if not script_row.begins_with("# "): continue

			script_row = script_row.erase(0, 2)

			if get_annotation_key(script_row) in keywords:
				var item : TreeItem = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.YELLOW)
			if get_annotation_key(script_row) in keywords_critical:
				var item = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.INDIAN_RED)
			if get_annotation_key(script_row) in keywords_notice:
				var item = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.PALE_GREEN)

	# 鼠标右键输入
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if star_script_tree.get_selected().get_text(0) == "收藏脚本": return
		var selected_script : String = star_list[star_script_tree.get_selected().get_index()]

		for i in ex_control.get_children():
			i.queue_free()
		var script_rmb_panel : ScriptRMBPanel = SCRIPT_RMB_PANEL.instantiate()
		ex_control.add_child(script_rmb_panel)
		script_rmb_panel.set_script_rmb(selected_script, self)

# TODO 所有脚本树被鼠标点击的方法
func _on_script_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	# 鼠标左键输入
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		current_tree = script_tree
		annotation_code_tree.clear()
		var file = FileAccess.open(script_list[current_tree.get_selected().get_index()], FileAccess.READ)
		var script_text : String = file.get_as_text()
		var script_rows : Array = script_text.split("\n")

		if script_tree.get_selected().get_text(0) == "所有脚本":
			var root_item : TreeItem = annotation_code_tree.create_item()
			root_item.set_text(0, "所有脚本")
			root_item.set_custom_color(0, Color.AQUA)

			for i in script_list.size():
				var _item : TreeItem = annotation_code_tree.create_item()
				var item_has_annotation : bool = false
				_item.set_text(0, script_list[i].split("/")[-1])
				_item.set_custom_color(0, Color.AQUAMARINE)

				script_text = file.open(script_list[i], FileAccess.READ).get_as_text()
				script_rows = script_text.split("\n")

				for row in script_rows.size():
					var script_row : String = script_rows[row]
					if not script_row.begins_with("# "): continue

					script_row = script_row.erase(0, 2)

					if get_annotation_key(script_row) in keywords:
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.YELLOW)
						item_has_annotation = true
					if get_annotation_key(script_row) in keywords_critical:
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.INDIAN_RED)
						item_has_annotation = true
					if get_annotation_key(script_row) in keywords_notice:
						var item = _item.create_child()
						item.set_text(0, "(%04d) - " % (row + 1) + script_row)
						item.set_custom_color(0, Color.PALE_GREEN)
						item_has_annotation = true

				if not item_has_annotation:
					root_item.remove_child(_item)
					_item.free()
			return

		var root_item : TreeItem = annotation_code_tree.create_item()
		root_item.set_text(0, script_list[script_tree.get_selected().get_index()].split("/")[-1])
		root_item.set_custom_color(0, Color.AQUAMARINE)

		for row in script_rows.size():
			var script_row : String = script_rows[row]
			if not script_row.begins_with("# "): continue

			script_row = script_row.erase(0, 2)

			if get_annotation_key(script_row) in keywords:
				var item : TreeItem = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.YELLOW)
			if get_annotation_key(script_row) in keywords_critical:
				var item = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.INDIAN_RED)
			if get_annotation_key(script_row) in keywords_notice:
				var item = root_item.create_child()
				item.set_text(0, "(%04d) - " % (row + 1) + script_row)
				item.set_custom_color(0, Color.PALE_GREEN)

	# 鼠标右键输入
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if script_tree.get_selected().get_text(0) == "所有脚本": return
		var selected_script : String = script_list[script_tree.get_selected().get_index()]

		for i in ex_control.get_children():
			i.queue_free()
		var script_rmb_panel : ScriptRMBPanel = SCRIPT_RMB_PANEL.instantiate()
		ex_control.add_child(script_rmb_panel)
		script_rmb_panel.set_script_rmb(selected_script, self)

# TODO 注释列表被点击时的方法
func _on_annotation_code_tree_item_selected() -> void:
	if annotation_code_tree.get_selected().get_text(0) == "所有脚本": return
	if annotation_code_tree.get_selected().get_text(0) == "收藏脚本": return
	if annotation_code_tree.get_selected().get_text(0).get_extension() == "gd":
		var script_path : String

		for i : String in script_list:
			if not i.contains(annotation_code_tree.get_selected().get_text(0)): continue
			script_path = i
			break

		EditorInterface.edit_resource(load(script_path))
		return

	var key : String = annotation_code_tree.get_selected().get_text(0).split(" ")[2]
	key = get_annotation_key(key)
	if key != "":
		var line : int = int(annotation_code_tree.get_selected().get_text(0).split(" ")[0].erase(0).left(5))
		var script_path : String

		for i : String in script_list:
			if not i.contains(annotation_code_tree.get_selected().get_parent().get_text(0)): continue
			script_path = i

		EditorInterface.edit_resource(load(script_path))
		EditorInterface.get_script_editor().goto_line(line - 1)

# TODO 获取某行注释的注释关键字的方法
func get_annotation_key(annotation : String) -> String:
	for i in keywords.size():
		if not annotation.contains(keywords[i]): continue
		return keywords[i]
	for i in keywords_critical.size():
		if not annotation.contains(keywords_critical[i]): continue
		return keywords_critical[i]
	for i in keywords_notice.size():
		if not annotation.contains(keywords_notice[i]): continue
		return keywords_notice[i]
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

# TODO 区分大小写
func _on_case_sensitive_button_toggled(toggled : bool) -> void:
	is_case_sensitive = toggled
	scratch_edit.text_changed.emit(scratch_edit.text)

# TODO 搜索编辑器中的文本改变时的方法
func _on_scratch_edit_text_changed(new_text: String) -> void:
	current_tree.item_mouse_selected.emit(Vector2.ZERO, 1)
	if new_text != "":
		for s in annotation_code_tree.get_root().get_children():
			var is_has_annotion : bool = false

			if annotation_code_tree.get_root().get_text(0).get_extension() == "gd":
				if is_case_sensitive:
					if s.get_text(0).contains(new_text): continue
				else :
					if s.get_text(0).to_lower().contains(new_text.to_lower()): continue

				s.remove_child(annotation_code_tree.get_root())
				s.free()
				continue

			for i in s.get_children():
				if is_case_sensitive:
					if i.get_text(0).contains(new_text):
						is_has_annotion = true
						continue
				else :
					if i.get_text(0).to_lower().contains(new_text.to_lower()):
						is_has_annotion = true
						continue
				s.remove_child(i)
				i.free()

			if not is_has_annotion:
				annotation_code_tree.get_root().remove_child(s)
				s.free()
