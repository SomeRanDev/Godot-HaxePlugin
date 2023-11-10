@tool
extends EditorPlugin

# Constants
const HAXE_MENU_ITEM_NAME = "Make Haxe Script for Current Node";

# Singletons
const Compiler = preload("./src/compile_haxe.gd");
const Settings = preload("./src/settings.gd");

# Variables
var button_scene: Control = null;

# On plugin start...
func _enter_tree():
	# Add button
	button_scene = preload("visuals/button.tscn").instantiate();
	add_control_to_container(CONTAINER_TOOLBAR, button_scene);
	
	# Add button signal
	button_scene.get_node("Button").connect("pressed", _on_haxe_compile_pressed);

	# Setup tool button
	add_tool_menu_item(HAXE_MENU_ITEM_NAME, _on_haxe_script_create_pressed);

	# Setup settings
	Settings.setup_settings();

# On plugin stop...
func _exit_tree():
	# Remove button
	remove_control_from_container(CONTAINER_TOOLBAR, button_scene);
	button_scene.free();

	remove_tool_menu_item(HAXE_MENU_ITEM_NAME);

func _on_haxe_compile_pressed():
	Compiler.compile_haxe(
		Settings.get_run_type(),
		Settings.get_compiler_path(),
		Settings.get_hxml_path()
	);

func _on_haxe_script_create_pressed():
	print(get_editor_interface());
