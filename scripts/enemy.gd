extends CharacterBody2D

const SPEED = 60.0
var direction = 1
var is_dying: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if is_dying:
		return

	# Gravitasi saat melayang
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Terus balik arah begitu mentok tembok ATAU ketemu ujung jurang
	if is_on_wall() or (is_on_floor() and not ray_cast_2d.is_colliding()):
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
		ray_cast_2d.position.x *= -1

	# Musuh terus berjalan tanpa henti
	velocity.x = direction * SPEED
	
	# Pastikan animasi jalannya terus memutar
	if animated_sprite_2d.animation != "running":
		animated_sprite_2d.play("running")

	move_and_slide()

# Player menginjak kepala musuh
func _on_stomp_area_body_entered(body: Node2D) -> void:
	if is_dying:
		return
	if body.is_in_group("player") or body.name == "Player":
		is_dying = true
		body.velocity.y = -500.0
		queue_free()

# Player menabrak badan musuh dari samping
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dying:
		return
	if body.is_in_group("player") or body.name == "Player":
		if body.has_method("die"):
			body.die(global_position.x)
