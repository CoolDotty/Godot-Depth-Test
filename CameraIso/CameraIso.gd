@tool
extends Camera3D
class_name CameraIso


@export_category("CameraIso")


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		if self.projection != Camera3D.PROJECTION_ORTHOGONAL:
			print_rich("""
[b][color=red]Hey![/color][/b]
As a baseline, CameraIso should be set to
	[code]Projection = Orthogonal[/code]
For a 1 to 1 pixel to viewport ratio set
	[code]Keep Aspect = Keep Height[/code]
and
	[code]size = viewport height / 100.0[/code]
(Vice-versa if using keep_width)
			""")
