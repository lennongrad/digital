extends Node3D

@export var model_name: String
var model: Node3D
var animation_player: AnimationPlayer

func _ready() -> void:
	model = get_node(model_name)
	
	for child in get_children():
		child.visible = false
	model.visible = true
	
	animation_player = model.get_node("AnimationPlayer")


func _process(delta: float) -> void:
	if model_name == "Warrior":
		animation_player.play("Idle")
		
	if model_name == "Robot":
		animation_player.play("RobotArmature|Robot_Idle")
