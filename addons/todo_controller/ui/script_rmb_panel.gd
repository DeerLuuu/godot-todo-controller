@tool
class_name ScriptRMBPanel extends PanelContainer

var star_button: Button
var un_star_button: Button

var current_script : String

var current_panel : TodoControllerPanel

# TODO 脚本列表右键菜单初始化
func set_script_rmb(_current_script : String = "", _current_panel : TodoControllerPanel = null) -> void:
	current_script = _current_script
	current_panel = _current_panel

	global_position = get_global_mouse_position()

	star_button = %StarButton
	un_star_button = %UnStarButton
	star_button.disabled = current_panel.star_list.has(current_script)
	un_star_button.disabled = not star_button.disabled

# TODO 点击收藏按钮的方法
func _on_star_button_pressed() -> void:
	current_panel.star_list.append(current_script)
	current_panel.update_star_script_tree()
	current_panel.update_script_tree()
	current_panel.update_item_collapsed()
	queue_free()

# TODO 点击取消收藏按钮的方法
func _on_un_star_button_pressed() -> void:
	current_panel.star_list.erase(current_script)
	current_panel.update_star_script_tree()
	current_panel.update_script_tree()
	current_panel.update_item_collapsed()
	queue_free()

# 点击打开脚本按钮的方法
func _on_open_script_button_pressed() -> void:
	EditorInterface.edit_resource(load(current_script))
	queue_free()

# 点击取消按钮的方法
func _on_cancel_button_pressed() -> void:
	queue_free()
