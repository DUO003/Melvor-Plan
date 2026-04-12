@tool
extends 游历地区地图
@export var 启用保存:bool=false:
	set(值):
		if 值:
			启用保存 = false
			保存地区(true)
			print("保存成功")
@export var 启用另存:bool=false:
	set(值):
		if 值:
			启用另存 = false
			保存地区(false)
@export var 启用读取:bool=false:
	set(值):
		if 值:
			启用读取 = false
			if 当前地区数据:加载地区(当前地区数据)
