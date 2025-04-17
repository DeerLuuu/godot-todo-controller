@tool
# INFO 插件脚本
extends EditorPlugin

const TODO_CONTROLLER_PANEL = preload("res://addons/todo_controller/ui/todo_controller_panel.tscn")

var todo_controller_panel : TodoControllerPanel

# TODO：这是一段todo注释
# HACK：这是一段HACK注释
# WARNING：这是一段HACK注释
# FIXME：这是一段HACK注释

func _init() -> void:
	EditorInterface.get_resource_filesystem().script_classes_updated.connect(_on_script_classes_updated)

func _enter_tree() -> void:
	todo_controller_panel = TODO_CONTROLLER_PANEL.instantiate()
	add_control_to_bottom_panel(todo_controller_panel, "Todo Controller")
	## TEST 测试时用于方便观察输出
	#add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, todo_controller_panel)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(todo_controller_panel)
	## TEST 测试时用于方便观察输出
	#remove_control_from_docks(todo_controller_panel)

# TODO 新建或者删除代码文件执行的方法
func _on_script_classes_updated() -> void:
	var is_root : bool = false
	var child_index : int = 0
	var child_name : String = ""
	var tree : Tree
	var tree_item : TreeItem
	tree = todo_controller_panel.current_tree
	if tree: if tree.get_selected(): tree_item = tree.get_selected()

	if tree_item:
		tree.item_mouse_selected.emit(Vector2.ZERO, 1)
		if tree_item == tree.get_root():
			is_root = true
		child_name = tree_item.get_text(0)

	todo_controller_panel.reset_todo_controller()

	if not tree: return
	for i in tree.get_root().get_children():
		if child_name == "": return
		if i.get_text(0) == child_name:
			break
		child_index += 1

	if is_root:
		tree.set_selected(tree.get_root(), 0)
	else :
		if child_index + 1 > tree.get_root().get_child_count(): return
		tree.set_selected(tree.get_root().get_child(child_index), 0)
