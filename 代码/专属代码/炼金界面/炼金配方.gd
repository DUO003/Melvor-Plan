extends FoldableContainer
var 配方格子
@export var 配方编号=0
var 配方: Dictionary=	{"材料名称"=[],
						"材料数量"=[],
						"催化剂"=null}
func _ready() -> void:
	配方格子=%"配方格子"
	配方格子.配方编号=配方编号
	配方格子.配方=配方
	加载配方信息()

func 加载配方信息():
	配方格子.加载配方信息()
#func _process(_delta: float) -> void:
	#print("文本:",%"制作数量".value)
