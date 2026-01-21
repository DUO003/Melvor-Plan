@tool
extends Resource
class_name 梅噪声  # 定义类名，方便在编辑器中识别
# 噪声随机种子
@export var 噪声种子: int = -1:
	set(值):
		噪声种子 = 值
		内部资源更新.emit()

# 噪声类型
@export var 噪声类型: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX:
	set(值):
		噪声类型 = 值
		内部资源更新.emit()

# 分形八度数（越高细节越多）
@export var 八度数量: int = 4:
	set(值):
		八度数量 = 值
		内部资源更新.emit()

# 噪声频率（越高纹理越密）
@export var 噪声频率: float = 2.0:
	set(值):
		噪声频率 = 值
		内部资源更新.emit()

# 分形增益（影响八度权重）
@export var 分形增益: float = 0.5:
	set(值):
		分形增益 = 值
		内部资源更新.emit()

# 分形维度（影响八度频率）
@export var 分形维度: float = 2.0:
	set(值):
		分形维度 = 值
		内部资源更新.emit()
signal 内部资源更新()
# 资源专属：根据当前配置创建 FastNoiseLite 实例
func 创建噪声实例() -> FastNoiseLite:
	var 噪声 = FastNoiseLite.new()
	噪声.set_seed(噪声种子)
	噪声.set_noise_type(噪声类型)
	噪声.set_fractal_octaves(八度数量)
	噪声.set_frequency(噪声频率)
	噪声.set_fractal_gain(分形增益)
	噪声.set_fractal_lacunarity(分形维度)
	return 噪声
