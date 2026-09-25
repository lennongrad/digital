extends Node3D

@export var model: Node3D
var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player = model.get_node("AnimationPlayer")


func _process(delta: float) -> void:
	animation_player.play("RobotArmature|Robot_Idle")
