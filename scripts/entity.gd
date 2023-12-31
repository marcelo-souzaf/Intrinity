extends KinematicBody2D
class_name Entity

onready var cooldown = $CooldownTimer
export var class_: int
var health_bar = null

var sprite: AnimatedSprite
var health: int = 100
var max_health: int = 100
var max_speed: int
var acceleration: int
var sight_radius: int
var is_player := false

var lin_speed := Vector2.ZERO

func attack(direction: Vector2):
	cooldown.start(Classes.attack_cooldown[class_])
	var attack = Classes.attacks[class_].instance()
	attack.position = self.position
	attack.init(direction, self.is_player)
	Game.attacks_container.add_child(attack)

func take_damage(amount: int, attacker_class: int):
	var weakness: int = Classes.weakness[class_]
	# Doubles the damage if the entity is weak against the attacker's class
	health -= amount * (1 + int(weakness == attacker_class or weakness == Classes.All))

	# update the lifebar
	health_bar.update_bar(self)

func update_stats():
	self.health = (float(self.health) / self.max_health) * Classes.health[class_]
	self.max_health = Classes.health[class_]
	self.max_speed = Classes.max_speed[class_]
	self.acceleration = Classes.acceleration[class_]
	self.sight_radius = Classes.sight_radius[class_]
	if self.is_player:
		self.max_speed += Game.player_boost_speed
		if class_ == Classes.Swordsman:
			self.max_speed += Game.swordsman_speed
func update_appearance():
	self.sprite.frames = Classes.animations[class_]

func create_health_bar():
	var health_bar_inst = Game.health_bar_scene.instance()
	add_child(health_bar_inst)
	health_bar_inst.init(self)
	self.health_bar = health_bar_inst

func become_invulnerable(duration: float = 0.4):
	$Invulnerability.start(duration)
	sprite.material = Game.blinking_shader
