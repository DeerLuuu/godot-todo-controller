@tool
extends EditorPlugin

const TODO_CONTROLLER_PANEL = preload("res://addons/todo_controller/ui/todo_controller_panel.tscn")

var todo_controller_panel : TodoControllerPanel

# TODO：这是一段TODO注释
# HACK：这是一段HACK注释
# WARNING：这是一段HACK注释
# FIXME：这是一段HACK注释

func _init() -> void:
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(_on_editor_filesystem_changed)

func _enter_tree() -> void:
	todo_controller_panel = TODO_CONTROLLER_PANEL.instantiate()
	add_control_to_bottom_panel(todo_controller_panel, "Todo Controller")

func _exit_tree() -> void:
	remove_control_from_bottom_panel(todo_controller_panel)

func _on_editor_filesystem_changed() -> void:
	var tree : Tree = todo_controller_panel.current_tree
	var item : TreeItem = tree.get_selected()
	tree.item_mouse_selected.emit(Vector2.ZERO, 1)
