extends RigidBody2D
@onready var area_2d: Area2D = $Area2D
@onready var marker_2d: Marker2D = $Area2D/Marker2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"): 
		var head = marker_2d.position
		if body.position >= head or body.position <= head:
			body.jump_start()
			body.jump()
		else:
			return
			
