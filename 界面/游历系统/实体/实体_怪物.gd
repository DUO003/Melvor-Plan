@tool
extends 游历实体
class_name 游历实体_怪物
var 强度:float=1
@export var 怪物数据:梅怪物配置=null
func 状态跳转条件():
	状态机.add_transition(移动状态,待机状态,移动状态.EVENT_FINISHED,死亡检查.bind(false))
	状态机.add_transition(攻击状态,移动状态,攻击状态.EVENT_FINISHED,死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,移动状态,"状态切换移动",死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,攻击状态,"状态切换攻击",死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,受击状态,"状态切换受击",死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,死亡状态,"状态切换死亡")
func 加载实体数据():
	var 属性管理器:=怪物数据
	最大生命=属性管理器.血量
	生命值=计划.数据状态("生命值",int(最大生命))
	最大护盾=0
	护盾值=0
	最大魔法=属性管理器.魔法
	魔法值=计划.数据状态("魔法值",int(最大魔法))
	攻击力=属性管理器.攻击
	防具承伤比例=属性管理器.减伤
	暴击力=属性管理器.暴击
	暴击抗性=属性管理器.抗性
	击退力=Vector2(-属性管理器.击退力,-属性管理器.击退力)
	每秒回血=属性管理器.回血
	每秒回蓝=属性管理器.回蓝
	每秒回盾=0
	攻击间隔=属性管理器.攻速
	最大攻击距离=属性管理器.警戒距离+角色碰撞箱宽度
	近战攻击距离=属性管理器.攻击距离+角色碰撞箱宽度
	速度=横版单例.地图默认速度*属性管理器.移速倍率
	跳跃高度=横版单例.地图默认弹跳
	var 普通攻击:梅技能配置=梅技能配置.new("近战攻击",1)
	技能配置.append(普通攻击)
	武器名称=属性管理器.武器名称
	其他属性=属性管理器.计算其他属性()
	状态机配置=属性管理器.计算状态机配置()
func 初始化实体() -> void:
	super()
	动画节点.面向反转=false
	
#func _ready():
	#super._ready()
	#if Engine.is_editor_hint():
		#return
	#for 状态 in 怪物状态:
		#逆向状态[怪物状态[状态]]=状态
	#更新显示()
	#速度=340
	##print(怪物状态,逆向状态)
#func 更新显示():
	#var 状态时间:float=状态参数.get("状态时间",1)
	#var 通用文本:String="状态机:%s\r切换:%.1f/%d"%[逆向状态[状态机],状态持续时间,状态时间]
	#match 状态机:
		#怪物状态.游走:
			#var 游走方向:float=状态参数.get("游走方向",-0.5)
			#实体数据.text="速度:%.1f\r%s"%[游走方向,通用文本]
		#_:
			#实体数据.text=通用文本
	#
#func 移动更新(间隔: float) -> void:
	#match 状态机:
		#怪物状态.待机:
			#velocity.x=move_toward(velocity.x,0,50)
		#怪物状态.游走:
			#var 游走方向:float=状态参数.get("游走方向",-0.5)
			#velocity.x=move_toward(velocity.x,速度*游走方向,50)
		#怪物状态.追击:
			#var 目标:游历实体=状态参数.get("追击目标",null)
			#if 目标:
				#if abs(position.x-目标.position.x)<近战攻击距离 and abs(position.y-目标.position.y)<20:
					#状态切换(怪物状态.攻击)
					#velocity.x=0
				#elif abs(position.x-目标.position.x)>最大攻击距离*2:
					#状态切换(怪物状态.待机)
				#elif position.x<目标.position.x:
					#velocity.x=move_toward(velocity.x,速度,50)
				#else :
					#velocity.x=move_toward(velocity.x,-速度,50)
			#else :
				#print("错误,无目标对象")
		#怪物状态.攻击:
			#velocity.x=move_toward(velocity.x,0,50)
			#var 攻击计时器:float=状态参数["攻击计时器"]
			#var 攻击冷却:float=状态参数["攻击冷却"]
			#if 攻击计时器>=攻击冷却:
				#var 目标:游历实体=状态参数.get("追击目标",null)
				#var 距离:float=abs(position.x-目标.position.x)
				#if 目标 and 距离<最大攻击距离:
					##print("距离%d/%d"%[距离,近战攻击距离])
					#if 距离<近战攻击距离:
						#生成攻击("近战攻击","抓痕")
						#状态参数["攻击计时器"]=0
					#else :
						#生成攻击("远程攻击","默认子弹")
						#状态参数["攻击计时器"]=0
					#方向更新(sign(目标.position.x-position.x))
				#else :
					#状态切换(怪物状态.追击)
			#else :
				#状态参数["攻击计时器"]=攻击计时器+间隔
	#if sign(velocity.x) != 0:
		#方向更新(sign(velocity.x))
		#推动检查.force_raycast_update()
		#if 推动检查.is_colliding():
			#var 推动目标=推动检查.get_collider()
			##print("推动成功",推动目标)
			##推动碰撞对象(推动目标)
	#if 战线推动 and position.x<横版单例.关卡战线:
		#position.x=横版单例.关卡战线
	#状态持续时间+=间隔
	#velocity.y+=间隔*重力加速度
	#更新显示()
	#更新状态()
#func 方向更新(方向:int):
	#if 方向==1 or 方向==-1:
		#if not 自由移动:
			#方向=-1
		#推动检查.target_position=Vector2(方向*推动检查距离,0)
		#攻击检查.target_position=Vector2(方向*最大攻击距离,0)
		#近战攻击容器.scale=Vector2(-方向,1)
		#近战攻击容器.position=Vector2(方向*50,-75)
		#
#func 状态切换(新状态:怪物状态):
	#if 状态机==新状态:
		#return
	#var 状态时间:float=2
	#match 新状态:
		#怪物状态.待机:
			#状态参数["追击目标"] = null
		#怪物状态.游走:
			#var 方向: int = 1 if randi() % 2 == 0 else -1#随机生成方向
			#var 随机速度百分比: float = randf_range(0.25, 0.5)
			#状态参数["游走方向"] = 方向 * 随机速度百分比
		#怪物状态.追击:
			#攻击检查.force_raycast_update()
			#var 追击目标=攻击检查.get_collider()
			#if 追击目标 and 追击目标 is 游历实体:
				##print("追击目标",追击目标)
				#状态参数["追击目标"] = 追击目标
				#状态时间=10
			#else :
				#var 目标:游历实体=状态参数.get("追击目标",null)
				#if not 目标 or abs(position.x-目标.position.x)>最大攻击距离*2:
					#新状态=怪物状态.待机
		#怪物状态.攻击:
			##攻击检查.target_position=Vector2(-500,0)
			#状态参数["攻击计时器"]=0
			#状态参数["攻击冷却"]=2
	#状态机=新状态
	#状态持续时间=0
	#状态参数["状态时间"]=状态时间
#func 更新状态():
	#var 状态时间:float=状态参数.get("状态时间",1)
	#var 切换状态:bool=状态持续时间>状态时间
	#if 切换状态:
		#状态持续时间=0
	#match 状态机:
		#怪物状态.待机:
			#攻击检查.force_raycast_update()
			#if 攻击检查.is_colliding():
				#状态切换(怪物状态.追击)
			#elif 切换状态 and randf()>0.7:
				#状态切换(怪物状态.游走)
		#怪物状态.游走:
			#攻击检查.force_raycast_update()
			#if 攻击检查.is_colliding():
				#状态切换(怪物状态.追击)
			#elif 切换状态:
				#状态切换(怪物状态.待机)
		#怪物状态.追击:
			#if 切换状态:
				#状态切换(怪物状态.待机)
			
#
#func 推动碰撞对象(碰撞实体:游历实体) -> void:
	## 安全校验：避免空对象/推自己
	#if not 碰撞实体 or 碰撞实体 == self:
		#return
	##最大推动速度
	#var 推动力度: float = 200.0  
	#if sign(velocity.x) != 0:  # 只有有水平速度时才推动
		#碰撞实体.velocity.x=move_toward(碰撞实体.velocity.x,-速度,推动力度)
	#velocity.x *= 0
	#if 状态机==怪物状态.追击:
		#var 目标:游历实体=状态参数.get("追击目标",null)
		#if 目标 and abs(position.x-目标.position.x)<200:
			#状态切换(怪物状态.攻击)
