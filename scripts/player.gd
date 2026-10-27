extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

const SPEED = 300.0
const JUMP_VELOCITY = -850.0

var is_dead: bool = false

func _physics_process(delta: float) -> void:
	# Jika player mati, terapkan gravitasi & gerakan pentalan (knockback) saja
	if is_dead:
		velocity += get_gravity() * delta
		move_and_slide()
		return

	# Add animation
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true

	move_and_slide()

# Fungsi Kematian Player saat disenggol Hitbox Musuh
func die(enemy_x: float = 0.0) -> void:
	if is_dead:
		return
	
	is_dead = true
	
	# Memutar animasi "dying"
	animated_sprite_2d.play("dying")
	
	# Efek terpental (knockback): terlempar ke atas dan ke samping berlawanan arah musuh
	var knockback_dir = -1.0 if position.x < enemy_x else 1.0
	velocity.x = knockback_dir * 200.0
	velocity.y = -500.0
	
	# Matikan kolisi agar player tembus/jatuh saat animasi mati diputar
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# Jeda waktu memutar animasi pentalan sebelum restart level
	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()
