# INFO 黑名单条类
@tool
class_name BlackBar extends PanelContainer

var black_label: Label
var remove_black_bar_button: Button

var black_name : String

# TODO 黑名单条初始化
func set_black_bar(_black_name : String = "") -> void:
	black_name = _black_name

	black_label = %BlackLabel
	remove_black_bar_button = %RemoveBlackBarButton

	black_label.text = black_name
