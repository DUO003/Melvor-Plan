## 窗口操作工具类
## 提供对应用窗口的控制和管理功能
extends Node
class_name 引擎程序窗口

## 设置窗口标题
## [br]参数:[br]
##   - 标题文本: 要设置的窗口标题，默认为"新游戏标题"
##[codeblock]
## 引擎.程序窗口.设置标题("我的游戏")
##[/codeblock]
func 设置标题(标题文本:String = "新游戏标题"):
	DisplayServer.window_set_title(标题文本)

## 设置窗口位置
## [br]参数:[br]
##   - 坐标: 窗口左上角的屏幕坐标
##[codeblock]
## 引擎.程序窗口.设置坐标(Vector2(100, 100))
##[/codeblock]
func 设置坐标(坐标:Vector2):
	DisplayServer.window_set_position(坐标)

## 获取窗口当前位置
## [br]返回:[br]
##   - 窗口左上角的屏幕坐标
##[codeblock]
## var 位置 = 引擎.程序窗口.获取坐标()
## print("窗口位置: ", 位置)
##[/codeblock]
func 获取坐标() -> Vector2:
	return DisplayServer.window_get_position()

## 设置窗口大小
## [br]参数:[br]
##   - 尺寸: 窗口的宽度和高度
##[codeblock]
## 引擎.程序窗口.设置窗口大小(Vector2(800, 600))
##[/codeblock]
func 设置窗口大小(尺寸:Vector2):
	DisplayServer.window_set_size(尺寸)

## 获取窗口当前大小
## [br]返回:[br]
##   - 窗口的宽度和高度
##[codeblock]
## var 大小 = 引擎.程序窗口.获取窗口大小()
## print("窗口大小: ", 大小)
##[/codeblock]
func 获取窗口大小() -> Vector2:
	return DisplayServer.window_get_size()


## 显示模态弹窗（阻塞式对话框）
## [br]参数:[br]
##   - 弹窗文本: 要显示的提示信息
##[codeblock]
## 引擎.程序窗口.弹窗("游戏已保存")
##[/codeblock]
func 弹窗(弹窗文本:String):
	OS.alert(弹窗文本)

## 在系统默认浏览器中打开指定网页
## [br]参数:[br]
##   - 网址: 要打开的URL，默认为"www.godotengine.org"
##[codeblock]
## 引擎.程序窗口.打开网页("https://docs.godotengine.org")
##[/codeblock]
func 打开网页(网址:String = "www.godotengine.org"):
	OS.shell_open(网址)
