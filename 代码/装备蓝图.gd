#@tool  # 启用编辑器内预览
extends Resource
class_name 装备蓝图数据
# 导出属性，可在编辑器中编辑
@export var 装备蓝图: Array = []  # 存储装备蓝图的数组数据
func 保存():
	装备蓝图=梅表格.装备蓝图
	ResourceSaver.save(self,"res://表格/装备蓝图数据.tres")
	print("更新表格数据成功")
func 读取():
	var 缓存数据=load("res://表格/装备蓝图数据.tres")
	梅表格.装备蓝图=缓存数据.装备蓝图.duplicate(true)
	print(缓存数据.装备蓝图)
