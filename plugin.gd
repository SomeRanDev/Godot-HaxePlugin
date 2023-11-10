@tool
extends EditorPlugin

# Constants
const HAXE_MENU_ITEM_NAME = "Make Haxe Script for Current Node";

# Singletons
const Compiler = preload("./src/compile_haxe.gd");
const Settings = preload("./src/settings.gd");

const CreateHaxeScriptScene = preload("dialog/create_haxe_script.tscn");

# Variables
var button_scene: Control = null;
var create_haxe_script_popup: Control = null;
var window: Window = null;

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

	create_haxe_script_popup = CreateHaxeScriptScene.instantiate();
	add_control_to_container(CONTAINER_TOOLBAR, create_haxe_script_popup);

	var window = create_haxe_script_popup.get_node("Window");
	window.connect("close_requested", _on_haxe_script_close_requested);

# On plugin stop...
func _exit_tree():
	# Remove button
	remove_control_from_container(CONTAINER_TOOLBAR, button_scene);
	button_scene.free();

	# Clean up tool menu
	remove_tool_menu_item(HAXE_MENU_ITEM_NAME);
	
	_on_haxe_script_close_requested();
	
	window.free();

func _on_haxe_compile_pressed():
	Compiler.compile_haxe(
		Settings.get_run_type(),
		Settings.get_compiler_path(),
		Settings.get_hxml_path()
	);

func _on_haxe_script_create_pressed():
	var selection = get_editor_interface().get_selection();
	var nodes = selection.get_selected_nodes();

	assert(!nodes.is_empty(), "Must have a Node selected.");
	assert(nodes.size() == 1, "Must have only one Node selected.");

	var node = nodes[0];
	var superClassName = node.get_class();

	window.popup_centered();

func _on_haxe_script_close_requested():
	window.hide();
