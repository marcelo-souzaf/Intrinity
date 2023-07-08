extends Node

const teleport_particles = preload("res://scenes/TeleportParticles.tscn")
var player
var game

var paused: bool = false

func spawn_particles(position: Vector2):
    var particles = teleport_particles.instance()
    particles.position = position
    game.add_child(particles)

func change_player_class(new_class: int, enemy: Entity):
    game.get_tree().paused = true
    player.class_ = new_class
    spawn_particles(player.position)
    player.position = enemy.position
    player.sprite.frames = enemy.sprite.frames
    enemy.queue_free()
    # yield(game.get_node("Camera2D").move(player.position), "tween_completed")