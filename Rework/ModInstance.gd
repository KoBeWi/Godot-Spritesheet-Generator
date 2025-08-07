extends Control

@onready var name_label: Label = %NameLabel
@onready var container: HBoxContainer = %Container

var frame: SpriteSheet.Frame
var modifier: SpriteSheet.FrameModifier
var monitors: Array[MonitoredProperty]

func _ready() -> void:
	name_label.text = modifier.name
	
	var options := modifier._get_options()
	if options.is_empty():
		set_physics_process(false)
		return
	
	assert(options.size() % 4 == 0)
	for i in options.size() / 4:
		container.add_child(VSeparator.new())
		
		var option_name: String = options[i * 3]
		var node: Control = options[i * 3 + 1]
		var property: StringName = options[i * 3 + 2]
		var parameter: StringName = options[i * 3 + 3]
		
		node.set(property, modifier.get(parameter))
		
		var label := Label.new()
		label.text = option_name
		container.add_child(label)
		container.add_child(node)
		
		var monitor := MonitoredProperty.new()
		monitor.parameter = parameter
		monitor.object = node
		monitor.property = property
		monitor.last_value = node.get(property)
		monitors.append(monitor)

func _physics_process(delta: float) -> void:
	for monitor in monitors:
		var current = monitor.object.get(monitor.property)
		if current != monitor.last_value:
			monitor.last_value = current
			modifier.set(monitor.parameter, current)
			frame.update_image()

func delete() -> void:
	frame.modifiers.erase(modifier)
	frame.update_image()
	queue_free()

class MonitoredProperty:
	var parameter: StringName
	var object: Object
	var property: StringName
	var last_value: Variant
