##引擎的按钮类
@tool
extends Node
class_name 引擎按钮
var ID=0
##用法
##[codeblock]
##引擎.按钮.按下事件.connect(func(按钮控件):
##		var 按钮名称=按钮控件.name
##		if 按钮名称=="开始界面_开始按钮":
##			print("开始界面的开始按钮被点击")
##	)
##[/codeblock]
signal 按下事件(按钮控件)

#默认按钮配置音效
var 点击音效:AudioStream=load("uid://cj6u6t8o8spy6")
var 焦点音效:AudioStream=load("uid://bppuuc31od7bm")
