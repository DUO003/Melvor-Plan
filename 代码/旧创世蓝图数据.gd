#@tool  # 启用编辑器内预览
extends Resource
##原计划用于存储资源类的创世蓝图,解决无法将数据导出的问题,但现在问题已经解决了,这个不在需要了
class_name 创世蓝图数据
# 导出属性，可在编辑器中编辑
@export var 装备蓝图: Array = []  # 存储装备蓝图的数组数据
func 保存():
	装备蓝图=计划.表格.创世蓝图
	ResourceSaver.save(self,"res://表格/装备蓝图数据.tres")
	print("更新表格数据成功")
func 读取():
	var 缓存数据=load("res://表格/装备蓝图数据.tres")
	计划.表格.创世蓝图=缓存数据.装备蓝图.duplicate(true)
	print(缓存数据.装备蓝图)
