extends Node2D

onready var fireball = $Fireball
onready var attack_timer = $AttackTimer
onready var explosion_area = $ExplosionArea

const FIREBALL_SPEED = 600
const ATTACK_DURATION = 0.1

var fireball_dir = Vector2.ZERO
var exploding = false

func _ready():
	attack_timer.wait_time = ATTACK_DURATION
	attack(get_global_mouse_position())

func attack(mouse_pos):
	var direction = mouse_pos - position
	direction = direction.normalized()

	fireball_dir = direction
	fireball.rotation = direction.angle()

func _physics_process(delta):
	if not exploding:
		var collision = fireball.move_and_collide(fireball_dir * FIREBALL_SPEED * delta)

		if collision:
			create_explosion()
	else:
		for body in explosion_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage()

func create_explosion():
	attack_timer.start()
	exploding = true

func _on_AttackTimer_timeout():
	queue_free()






