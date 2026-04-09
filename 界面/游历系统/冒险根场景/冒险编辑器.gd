@tool
extends 冒险地图
@export var 启用保存:bool=false:
	set(值):
		if 值:
			启用保存 = false
			保存地图(true)
@export var 启用另存:bool=false:
	set(值):
		if 值:
			启用保存 = false
			保存地图(false)
@export var 启用读取:bool=false:
	set(值):
		if 值:
			启用读取 = false
			if 地图信息:加载地图(地图信息)
