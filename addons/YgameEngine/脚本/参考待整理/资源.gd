## 资源管理工具类
## 提供资源加载、缓存和操作的功能
##之前是用来读取.tres的
##_Resource参考 
extends Node
class_name 引擎资源

## 资源缓存字典
var _资源缓存 = {}

## 创建新的资源实例
## [br]返回:[br]
##   - 新创建的资源对象
##[codeblock]
## var 新资源 = 引擎.资源.新建资源()
##[/codeblock]
func 新建资源() -> Resource:
	return Resource.new()

## 加载指定路径的资源
## [br]参数:[br]
##   - tres资源路径: 资源的路径，如"res://my_resource.tres"
## [br]返回:[br]
##   - 加载的资源对象
##[codeblock]
## var 纹理 = 引擎.资源.加载资源("res://textures/icon.png")
##[/codeblock]
func 加载资源(tres资源路径) -> Resource:
	return load(tres资源路径)

## 从缓存加载资源，不存在则加载并缓存
## [br]参数:[br]
##   - 资源路径: 资源的路径
## [br]返回:[br]
##   - 缓存中的资源对象
##[codeblock]
## var 共享资源 = 引擎.资源.使用缓存加载资源("res://shared.tres")
##[/codeblock]
func 使用缓存加载资源(资源路径) -> Resource:
	if not (资源路径 in _资源缓存):
		_资源缓存[资源路径] = load(资源路径)
	return _资源缓存[资源路径]

## 保存资源到指定位置
## [br]参数:[br]
##   - _Resource: 要保存的资源对象[br]
##   - 储存的位置: 保存路径，如"user://saved_resource.tres"
## [br]返回:[br]
##   - 保存成功返回OK，失败返回错误码
##[codeblock]
## 引擎.资源.保存资源(my_resource, "user://savegame.tres")
##[/codeblock]
func 保存资源(_Resource, 储存的位置) -> int:
	return ResourceSaver.save(_Resource, 储存的位置)

## 获取资源的属性列表（过滤掉内置属性）
## [br]参数:[br]
##   - _Resource: 要获取属性的资源对象
## [br]返回:[br]
##   - 包含属性名和值的字典
##[codeblock]
## var 属性 = 引擎.资源.返回属性列表(my_resource)
## print(属性)
##[/codeblock]
func 返回属性列表(_Resource: Resource) -> Dictionary:
	var 返回字典 = {}
	for i in _Resource.get_property_list():
		if i.name not in ["RefCounted", "Built-in script","Resource", "resource_local_to_scene", "resource_path", "resource_name", "resource_scene_unique_id", "script", "道具.gd"]:
		#if i.name in _Resource:
	   #     print(i.name)
			返回字典[i.name] = _Resource[i.name]
	return 返回字典
