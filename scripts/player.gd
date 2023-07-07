extends "./entity.gd"
class_name Player

func _process(delta):
	var moving = false
	if Input.is_action_pressed("move_up"):
		lin_speed.y -= acceleration * delta
		moving = true
	if Input.is_action_pressed("move_down"):
		lin_speed.y += acceleration * delta
		moving = true
	if Input.is_action_pressed("move_left"):
		sprite.flip_h = true
		lin_speed.x -= acceleration * delta
		moving = true
	if Input.is_action_pressed("move_right"):
		sprite.flip_h = false
		lin_speed.x += acceleration * delta
		moving = true
	# Deaccelerate
	if not moving:
		lin_speed = lin_speed.linear_interpolate(Vector2(), 0.2)
	
	lin_speed = lin_speed.limit_length(max_speed)
	lin_speed = move_and_slide(lin_speed)

func on_kill(enemy):
	self.position = enemy.position
	self.sprite.frames = enemy.sprite.frames
	enemy.queue_free()

func change_class(new_class):
	self.class_ = new_class

