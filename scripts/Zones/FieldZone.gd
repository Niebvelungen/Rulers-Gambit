extends BaseZone

@export var x: int
@export var y: int
@export var spacing: int
@export var field_prefab: PackedScene

func _ready():
	create_grid()
	
func create_grid():
	for i in range(x):
		for j in range(y):
			var field_instance = field_prefab.instantiate()
			if field_instance is Control:
				# Position for Control nodes
				field_instance.position = Vector2(
					i * (field_instance.size.x + spacing) * 0.25,
					j * (field_instance.size.y + spacing) * 0.25
				)
			elif field_instance is Node2D:
				# Position for Node2D nodes
				field_instance.position = Vector2(
					i * (field_instance.get_rect().size.x + spacing) * 0.25,
					j * (field_instance.get_rect().size.y + spacing) * 0.25
				)
			add_child(field_instance)
