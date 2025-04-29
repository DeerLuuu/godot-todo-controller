@tool
# INFO 脚本列表右键菜单面板类
class_name ScriptRMBPanel extends PanelContainer

var open_script_button: Button
var cancel_button: Button
var star_button: Button
var un_star_button: Button

var desc_v_box: VBoxContainer
var desc_text_edit: TextEdit
var desc_yes_button: Button
var desc_no_button: Button

var current_script : String

var current_panel : TodoControllerPanel

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if get_viewport().gui_get_hovered_control().name == "ScriptRMBPanel": return
		if get_viewport().gui_get_hovered_control() is Button: return
		if get_viewport().gui_get_hovered_control() is TextEdit: return
		if event.is_pressed():
			queue_free()

# TODO 脚本列表右键菜单初始化
func set_script_rmb(_current_script : String = "", _current_panel : TodoControllerPanel = null) -> void:
	current_script = _current_script
	current_panel = _current_panel

	global_position = get_global_mouse_position()
	if get_viewport().get_visible_rect().size.y < get_global_mouse_position().y + 280:
		global_position = get_global_mouse_position() + Vector2.UP * 280

	star_button = %StarButton
	un_star_button = %UnStarButton
	open_script_button = %OpenScriptButton
	cancel_button = %CancelButton

	desc_v_box = %DescVBox
	desc_text_edit = %DescTextEdit
	desc_yes_button = %DescYesButton
	desc_no_button = %DescNoButton

	star_button.disabled = current_panel.star_list.has(current_script)
	un_star_button.disabled = not star_button.disabled

# TODO 点击收藏按钮的方法
func _on_star_button_pressed() -> void:
	var _star_list : Array = current_panel.star_list
	_star_list.append(current_script)
	current_panel.star_list = _star_list
	current_panel.update_star_script_tree()
	current_panel.update_script_tree()
	current_panel.update_item_collapsed()

	# 更新脚本列表树中的聚焦模式
	current_panel.script_tree_can_selected()
	queue_free()

# TODO 点击取消收藏按钮的方法
func _on_un_star_button_pressed() -> void:
	var _star_list : Array = current_panel.star_list
	_star_list.erase(current_script)
	current_panel.star_list = _star_list
	current_panel.update_star_script_tree()
	current_panel.update_script_tree()
	current_panel.update_item_collapsed()

	# 更新脚本列表树中的聚焦模式
	current_panel.script_tree_can_selected()
	queue_free()

# TODO 点击打开脚本按钮的方法
func _on_open_script_button_pressed() -> void:
	EditorInterface.edit_resource(load(current_script))
	current_panel.script_list_meta_update(
		current_script,
		current_panel.star_script_tree.get_selected().get_text(0) if current_panel.star_script_tree.get_selected() else -1,
		current_panel.script_tree.get_selected().get_text(0)if current_panel.script_tree.get_selected() else -1)
	queue_free()

# TODO 点击取消按钮的方法
func _on_cancel_button_pressed() -> void:
	queue_free()

# TODO 编辑简介按钮的方法
func _on_tool_tip_button_pressed() -> void:
	desc_v_box.visible = not desc_v_box.visible

# TODO 确定简介按钮的方法
func _on_desc_yes_button_pressed() -> void:
	var _script_tool_tip_list : Dictionary = current_panel.script_tool_tip_list
	_script_tool_tip_list[current_script] = desc_text_edit.text
	current_panel.script_tool_tip_list = _script_tool_tip_list
	queue_free()

# TODO 取消简介按钮的方法
func _on_desc_no_button_pressed() -> void:
	queue_free()
