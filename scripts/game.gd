extends Node

enum Mode {
	Playing,
	Paused,
	LevelingUp,
	GameOver
}
const teleport_particles = preload("res://scenes/TeleportParticles.tscn")
const death_particles = preload("res://scenes/DeathParticles.tscn")
const blinking_shader = preload("res://resources/entity_damaged.tres")
const health_bar_scene = preload("res://scenes/HealthBar.tscn")
const enemy = preload("res://scenes/Enemy.tscn")
# Measured in physics_process calls. These happen in 60 Hz
const TRANSITION_DURATION = 20
const DECREASE_INTERVAL = 10
const DECREASE_FRACTION = 0.5

export var kills_to_level_up := 5

var frames_left := TRANSITION_DURATION
var mode: int = Mode.Playing
var total_kill_count := 0
var player_level := 1
var enemy_count := 0
var score := 0
var player: Player
var game: Node2D
var ui: CanvasLayer
var attacks_container
var message_sys
var upgrade_sys
var main


var upgrades = []
var wave = 1

var player_damage = 3
var player_boost_speed = 150
var arrow_speed_boost = 0
var swordsman_speed = 0
var mage_damage = 0

func init(player_node: Player, game_node: Node2D):
	game = game_node
	player = player_node
	ui = game.get_node("HUD")
	ui.init(health_bar_scene.instance())

func _ready():
	set_physics_process(false)
	self.pause_mode = Node.PAUSE_MODE_PROCESS

func _unhandled_input(event):
	if event is InputEventKey and event.scancode == KEY_F11 and not event.is_pressed():
		OS.window_fullscreen = not OS.window_fullscreen
	elif event.is_action_released("ui_cancel") and mode == Mode.Playing:
		get_tree().paused = not get_tree().paused
		Game.ui.get_node("Pause").visible = get_tree().paused

func _physics_process(_delta):
	if frames_left <= 0:
		set_physics_process(false)
		Engine.time_scale = 1.0
		if mode >= Mode.LevelingUp:
			get_tree().paused = true
			if mode == Mode.GameOver:
				game.get_node("HUD/GameOver").show()
		return
	Engine.time_scale *= 0.9
	frames_left -= 1

func spawn_particles(position: Vector2, type = "teleport_particles"):
	var particles
	match type:
		"teleport_particles":
			particles = teleport_particles.instance()
		"death_particles":
			particles = death_particles.instance()
	particles.position = position
	game.add_child(particles)

func transform_player_into(enemy):
	Music.play_music_for_class(enemy.class_)
	spawn_particles(enemy.position, "death_particles")
	frames_left = TRANSITION_DURATION

	score += 1
	enemy_count -= 1
	if enemy.spawner != null:
		message_sys.show_message(str(enemy_count) + " enemies left", 2)
	
		if enemy_count <= 0:
			message_sys.show_message("Wave " + str(wave) + " cleared!", 3)
			start_count_down()

	total_kill_count += 1
	if score >= kills_to_level_up:
		score = 0
		player_level += 1
		kills_to_level_up = int(clamp(3 + total_kill_count / 5, 5, 10))
		show_upgrades()
		ui.update_skulls()

		mode = Mode.LevelingUp
		game.get_node("HUD/LevelUp").show()
	
	player.class_ = enemy.class_
	player.update_stats()
	player.update_appearance()
	player.position = enemy.position
	player.lin_speed = enemy.lin_speed

	player.cooldown.start(0.1)
	player.health_bar.init(player)
	ui.health_bar.init(player)
	spawn_particles(player.position)
	player.become_invulnerable()

	enemy.queue_free()

func game_over():
	# Check to prevent endless resets of the game over transition
	if mode != Mode.GameOver:
		mode = Mode.GameOver
		set_physics_process(true)
		frames_left = 1.5 * TRANSITION_DURATION

func show_upgrades():
	upgrade_sys.show()
	get_tree().paused = true

func upgrade_selected(upgrade : int):
	print("Upgrade selected: " + str(upgrade))
	upgrade_sys.hide()
	get_tree().paused = false

	
	match upgrade:
		0:
			player.health = player.max_health
		1:
			player_damage += 0.2
		2:
			player_boost_speed += 20
		3:
			arrow_speed_boost += 100
		4:
			swordsman_speed += 40
		5:
			mage_damage += 0.4

func call_wave():
	enemy_count = 0
	main.call_wave()

func start_count_down():
	var wait_time = 5 if wave < 5 else 10
	for i in range(wait_time):
		message_sys.show_message("Next wave in " + str(5 - i), 1)
		yield(get_tree().create_timer(1.0), "timeout")
	
	wave += 1
	main.call_wave()
