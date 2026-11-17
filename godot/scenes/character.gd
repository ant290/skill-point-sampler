extends CharacterBody3D

@export_category("Skill Points")
@export var Health_Skill := 0
@export var Speed_Skill := 0
@export var Range_Skill := 0

@export_category("Physique Skill Multipliers")
@export var Health_Multi := 0.08
@export var Speed_Multi := 0.15
@export var Range_Multi := 0.2

@export_category("Base Stats")
@export var base_health := 100
@export var base_move_speed := 3
@export var base_range := 0.5

@export_category("Base Stat Skill Multipliers")
@export var Health_Base_Multi := 10
@export var Speed_Base_Multi := 0.3 #0.1
#@export var Range_Base_Multi := 0.333

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var range_collision_shape_3d: CollisionShape3D = $RangeCollisionShape3D
@onready var range_shape_cast_3d: ShapeCast3D = $RangeShapeCast3D

@onready var health_label: Label3D = $HealthLabel
@onready var range_label: Label3D = $RangeLabel


var move_speed := 5
var max_health := base_health
var max_range := base_range
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
		Enums.StatType.RANGE:
			Range_Skill = value
	
	update_physique()
	update_base_stats()
	update_labels()

func update_physique() -> void:
	# get the collision and mesh shapes
	var collisionShape = collision_shape_3d.shape as CapsuleShape3D
	var meshShape = mesh_instance_3d.mesh as CapsuleMesh
	var rangeShape = range_shape_cast_3d.shape as CylinderShape3D
	if collisionShape and meshShape and rangeShape:
		#set width based on health
		var newRadius = 0.2 + (Health_Multi * Health_Skill)
		collisionShape.radius = newRadius
		meshShape.radius = newRadius
		var rangeRadius = newRadius + (base_range + (Range_Multi * (Range_Skill * Range_Skill)))
		rangeShape.radius = rangeRadius
	
		#set height based on speed
		var newHeight = 1 + (Speed_Multi * Speed_Skill)
		collisionShape.height = newHeight
		collision_shape_3d.position.y = newHeight/2
		meshShape.height = newHeight
		mesh_instance_3d.position.y = newHeight/2
		
		max_range = rangeRadius
		print_debug("max_range: ", max_range)
		
		health_label.position.y = newHeight + 0.5
		range_label.position.y = newHeight/2
		range_label.position.x = newRadius + 0.5
	
	print_debug("radius: ", meshShape.radius)
	print_debug("height: ", meshShape.height)

func update_base_stats() -> void:
	max_health = base_health + (Health_Base_Multi * Health_Skill)
	move_speed = base_move_speed + (Speed_Base_Multi * Speed_Skill)
	
	print_debug("max_health: ", max_health)
	print_debug("move speed: ", move_speed)

func update_labels() -> void:
	var format_health_string = "Health: %s"
	health_label.text = format_health_string % max_health
	
	var format_range_string = "Range: %s"
	range_label.text = format_range_string % max_range
