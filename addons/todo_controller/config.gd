# INFO 插件配置文件类
class_name Config extends Resource

@export var star_list : Array
@export var line_number_show : bool
@export var complete_path_show : bool
@export var case_sensitive_default : bool

# NOTE 以下为所有关键字示例
# BUG DEPRECATED FIXME HACK TASK TBD TODO WARNING 这些代表警告
# INFO NOTE NOTICE TEST TESTING 这些代表注意
# ALERT ATTENTION CAUTION CRITICAL DANGER SECURITY 这些代表危机
# NOTE：你也可以在 编辑器设置 -> 文本编辑器 -> 主题 -> 对应关键字列表中修改自己想要的主题
