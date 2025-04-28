![image](https://github.com/DeerLuuu/godot-todo-controller/blob/main/addons/todo_controller/icon/icon.png)
# Godot TODO Controller
  这是一个用来管理gds代码中的TODO注释的插件
---
### Getting Started

1. [Install the plugin](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html) by copying over the `addons` folder from the full package.

2. Enable the plugin in `Project > Project Settings > Plugins`.
---
### 主要功能
1. 在脚本列表区域显示项目中所有的 GDScript 脚本
2. 脚本列表中的右键菜单（包含收藏、取消收藏、打开脚本、脚本描述等功能）
3. 记录所有被收藏的脚本，被收藏的脚本将会被一个额外的Tree单独渲染
4. 单击脚本后会在注释区域显示该脚本的所有TODO关键字注释
5. 点击的如果是收藏列表或者脚本列表的 TreeItem 将会显示列表中所有的脚本的TODO关键字注释
6. 单击某条注释将会跳转到对应的关键字注释的对应行数
7. 右键菜单中可以给脚本添加脚本描述，脚本描述将会在鼠标悬停到脚本名上时显示
8. 注释区域最上面的搜索允许搜索注释快速找到某个注释
9. 注释区域允许开启大小写区分设置
10. 可以在设置界面设置注释区域显示的注释是否显示行号
11. 可以在设置界面设置注释区域的脚本名是否显示完整路径
12. 可以在设置界面设置注释区域的搜索框默认的大小写区分模式
13. 可以在设置界面的关键字设置中新增新的注释关键字
14. 可以在设置界面的关键字设置中修改不同类型的关键字注释的高亮颜色（该设置同时影响注释区域的注释字体颜色）
15. 可以在设置界面的文件黑名单界面添加文件或者文件夹进行黑名单处理（被加入黑名单的文件或者文件夹中的文件将会被过滤掉不会在插件中显示）
---
### 未来更新路线
- [ ] 脚本列表中的排序方式设置
- [ ] 主题设置
- [ ] 允许用户自定义新类型的注释关键字
- [ ] 时限注释
- [ ] 任务清单注释
