@tool
extends EditorPlugin

var button_scene: Control = null;

var popup_menu: PopupMenu = null;
var window: Window = null;

const HAXE_MENU_ITEM_NAME = "Make Haxe Script for Current Node";

func _enter_tree():
	# Add button
	button_scene = preload("visuals/button.tscn").instantiate();
	add_control_to_container(CONTAINER_TOOLBAR, button_scene);
	
	# Add button signal
	button_scene.get_node("Button").connect("pressed", _on_pressed);

	# Setup tool buttons
	popup_menu = preload("dialog/popup_menu.tscn").instantiate();
	add_tool_menu_item(HAXE_MENU_ITEM_NAME, func():
		print("test");
	);
	
	init_enum_setting("haxe/compiler_run_type", ["Run \"haxe\" Command", "Use Haxe Compiler Path"], 0);
	init_settings("haxe/compiler_call", TYPE_STRING, "haxe");
	ProjectSettings.save();

func init_settings(name: String, type: Variant.Type, value: Variant):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value);
	ProjectSettings.set_initial_value(name, value);
	ProjectSettings.add_property_info({
		"name": name,
		"type": type
	});

func init_enum_setting(name: String, enums: Array[String], value: int):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value);
	ProjectSettings.set_initial_value(name, value);
	ProjectSettings.add_property_info({
		"name": name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ", ".join(enums)
	});

func _exit_tree():
	# Remove button
	remove_control_from_container(CONTAINER_TOOLBAR, button_scene);
	button_scene.free();

	remove_tool_menu_item(HAXE_MENU_ITEM_NAME);

func _on_pressed():
	# Execute "haxe compile.hxml" in parent directory
	var output = [];
	var lsResult = OS.execute("CMD.exe", ["/C", "cd .. && haxe compile.hxml"], output, true, false);

	# Print result
	if lsResult == 0:
		print("Successfully compiled Haxe code! ✅");
	else:
		print("Haxe compilation failed with exit code: " + str(lsResult) + " ❌");

	# Print output if it exists
	if output.size() > 0 && output[0].length() > 0:
		print("\n-- Haxe Compiler Output --");
		print(output[0]);
