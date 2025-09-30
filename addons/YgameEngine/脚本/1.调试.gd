## 调试工具类
## 提供调试模式下的增强打印功能
extends Node
class_name 引擎调试

## 带颜色的调试打印
## [br]参数:[br]
##   - 打印的内容: 要打印的文本或变量[br]
##   - 颜色: 打印文本的颜色，默认为绿色
##[codeblock]
## 引擎.调试.打印("重要信息", "red")
##[/codeblock]
func 打印(打印的内容, 颜色:String = "green") -> void:
	var 来源 = get_stack()[1]
	#if 取调试模式():
	print_rich("%s\t%s:%s\t [color=%s]%s[/color]" % [来源["source"],来源["function"],来源["line"],颜色, 打印的内容])
	
## 带注释的调试打印（仅在调试模式下输出）
## [br]参数:[br]
##   - 注释: 打印内容的前缀说明[br]
##   - 打印的内容: 要打印的具体内容
##[codeblock]
## 引擎.调试.注释打印("玩家位置", player.position)
##[/codeblock]
func 注释打印(注释:String, 打印的内容) -> void:
	var 来源 = get_stack()[1]
	#if 取调试模式():
	print_rich("%s\t%s:%s\t[color=red]%s:\t[/color][color=green]%s[/color]" %[来源["source"],来源["function"],来源["line"],注释, 打印的内容])
#		
## 格式化打印字典内容
## [br]参数:[br]
##   - 字典: 要打印的字典对象[br]
##   - 注释: 打印标题，默认为"无"
##[codeblock]
## 引擎.调试.打印字典(player.stats, "玩家属性")
##[/codeblock]
func 打印字典(字典:Dictionary, 注释:String = "无"):
	if 取调试模式():
		var 来源 = get_stack()[1]
		print_rich("[color=yellow]%s-----------------------------------字典打印开始---------------------------------[/color]" % [注释])
		print("{")
		for i in 字典:
			print("  %s = %s" % [i, 字典[i]])
		print("} \t [color=yellow] -%s\t%s:%s\t [/color]" % [来源["source"],来源["function"],来源["line"]])
		print_rich("[color=yellow]%s-----------------------------------字典打印结束---------------------------------[/color]\n\n" % [注释])

## 格式化打印数组中的字典
## [br]参数:[br]
##   - 数组字典: 包含字典的数组[br]
##   - 注释: 打印标题，默认为"无"
##[codeblock]
## 引擎.调试.打印数组字典(items_list, "物品列表")
##[/codeblock]
func 打印数组(数组:Array, 注释:String = "无"):
	if 取调试模式():
		var 来源 = get_stack()[1]
		#p#rint_rich("%s\t%s:%s\t" % [来源["source"],来源["function"],来源["line"]])
		print_rich("[color=cyan]%s-----------------------------------数组打印开始---------------------------------[/color]" % [注释])
		print("[")
		for i in range(数组.size()):
			print("  [%d] = %s" % [i, 数组[i]])
		print("]\t [color=yellow] -%s\t%s:%s\t [/color]" % [来源["source"],来源["function"],来源["line"]])
		print_rich("[color=cyan]%s-----------------------------------数组打印结束---------------------------------[/color]\n\n" % [注释])

## 检查当前是否处于调试模式
## [br]返回:[br]
##   - 如果是调试构建返回true，发布版本返回false
##[codeblock]
## if 引擎.调试.取调试模式():
##     print("当前处于调试模式")
##[/codeblock]
func 取调试模式() -> bool:
	return OS.is_debug_build()
