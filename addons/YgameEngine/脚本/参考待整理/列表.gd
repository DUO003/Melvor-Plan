## 列表操作工具类
## 提供对 Godot ItemList 节点的常用操作封装
extends Node
class_name 引擎列表
## 选中列表中的指定索引项
## [br]参数:[br]
##   - _列表节点: ItemList 控件实例[br]
##   - _索引: 要选中的项索引（从0开始）
##[codeblock]
## 引擎.列表.选择索引($ItemList, 2)  # 选中第3项
##[/codeblock]
func 选择索引(_列表节点:ItemList, _索引):
	_列表节点.select(_索引)

## 获取列表中指定索引项的文本内容
## [br]参数:[br]
##   - _列表节点: ItemList 控件实例[br]
##   - _索引: 要获取的项索引（从0开始）
## [br]返回:[br]
##   - 指定索引项的文本内容
##[codeblock]
## var 文本 = 引擎.列表.取项目文本($ItemList, 0)
##[/codeblock]
func 取项目文本(_列表节点:ItemList, _索引):
	return _列表节点.get_item_text(_索引)

## 向列表中添加新项
## [br]参数:[br]
##   - _列表节点: ItemList 控件实例[br]
##   - _文本: 项目显示的文本内容，默认为空字符串[br]
##   - _图片: 项目关联的图标纹理，默认为null[br]
##   - _可选: 项目是否可选，默认为true
##[codeblock]
## 引擎.列表.增加项目($ItemList, "新选项", preload("icon.png"))
##[/codeblock]
func 增加项目(_列表节点:ItemList, _文本:String="", _图片:Texture2D=null, _可选:bool=true):
	_列表节点.add_item(_文本, _图片, _可选)

## 清空列表中的所有项目
## [br]参数:[br]
##   - _列表节点: ItemList 控件实例
##[codeblock]
## 引擎.列表.清空所有项目($ItemList)
##[/codeblock]
func 清空所有项目(_列表节点:ItemList):
	_列表节点.clear()

## 获取列表中的项目数量
## [br]参数:[br]
##   - _列表节点: ItemList 控件实例
## [br]返回:[br]
##   - 列表中的项目总数
##[codeblock]
## var 数量 = 引擎.列表.获取数量($ItemList)
##[/codeblock]
func 获取数量(_列表节点:ItemList) -> int:
	return _列表节点.item_count
