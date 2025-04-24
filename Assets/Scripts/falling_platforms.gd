extends RigidBody2D

@export var fall_delay: float = 0.5

@onready var timer = $Timer
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	sprite.play("on")
	# Met le corps en mode statique pour qu’il reste immobile
	PhysicsServer2D.body_set_mode(self.get_rid(), PhysicsServer2D.BODY_MODE_STATIC)
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", _on_body_entered)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body):
	if body.name == "Player":
		timer.start(fall_delay)

func _on_timer_timeout():
	# Met le corps en mode rigide pour qu’il tombe
	PhysicsServer2D.body_set_mode(self.get_rid(), PhysicsServer2D.BODY_MODE_RIGID)
