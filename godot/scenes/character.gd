extends CharacterBody3D

@export_category("Skill Points")
@export var Health_Skill := 0
@export var Speed_Skill := 0

@export_category("Physique Skill Multipliers")
@export var Health_Multi := 0.08
@export var Speed_Multi := 0.15

@export_category("Base Stats")
@export var base_health := 100
@export var base_move_speed := 3

@export_category("Base Stat Skill Multipliers")
@export var Health_Base_Multi := 10
@export var Speed_Base_Multi := 0.3 #0.1

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var health_label: Label3D = $HealthLabel

var move_speed := 5
var max_health := base_health
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	# do setup here
	update_physique()
	update_base_stats()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

func update_stat(stat: Enums.StatType, value: int) -> void:
	match stat:
		Enums.StatType.HEALTH:
			Health_Skill = value
		Enums.StatType.SPEED:
			Speed_Skill = value
	
	update_physique()
	update_base_stats()
	update_labels()

func update_physique() -> void:
	# get the collision and mesh shapes
	var collisionShape = collision_shape_3d.shape as CapsuleShape3D
	var meshShape = mesh_instance_3d.mesh as CapsuleMesh
	if collisionShape and meshShape:
		#set width based on health
		collisionShape.radius = 0.2 + (Health_Multi * Health_Skill)
		meshShape.radius = .2 + (Health_Multi * Health_Skill)
	
		#set height based on speed
		collisionShape.height = 1 + (Speed_Multi * Speed_Skill)
		meshShape.height = 1 + (Speed_Multi * Speed_Skill)
	
	print_debug("radius: ", meshShape.radius)
	print_debug("height: ", meshShape.height)

func update_base_stats() -> void:
	max_health = base_health + (Health_Base_Multi * Health_Skill)
	move_speed = base_move_speed + (Speed_Base_Multi * Speed_Skill)
	print_debug("max_health: ", max_health)
	print_debug("move speed: ", move_speed)

func update_labels() -> void:
	var format_string = "Health: %s"
	health_label.text = format_string % max_health
