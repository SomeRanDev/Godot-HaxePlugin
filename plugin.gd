@tool
extends EditorPlugin

var button_scene: Control = null;

const HAXE_MENU_ITEM_NAME = "Make Haxe Script for Current Node";

const SETTING_RUN_TYPE = "haxe/compiler_run_type";
const SETTING_COMPILER_PATH = "haxe/compiler_path";
const SETTING_HXML_PATH = "haxe/hxml_path";

func _enter_tree():
	# Add button
	button_scene = preload("visuals/button.tscn").instantiate();
	add_control_to_container(CONTAINER_TOOLBAR, button_scene);
	
	# Add button signal
	button_scene.get_node("Button").connect("pressed", _on_haxe_compile_pressed);

	# Setup tool button
	add_tool_menu_item(HAXE_MENU_ITEM_NAME, _on_haxe_script_create_pressed);

	# Setup settings
	setup_settings();

func setup_settings():
	init_enum_setting(SETTING_RUN_TYPE, 0, ["Run \"haxe\" Command", "Use Haxe Compiler Path"]);
	init_settings(SETTING_COMPILER_PATH, TYPE_STRING, "", PROPERTY_HINT_NONE);
	init_settings(SETTING_HXML_PATH, TYPE_STRING, "../compile.hxml", PROPERTY_HINT_GLOBAL_FILE);
	ProjectSettings.save();

func init_settings(name: String, type: Variant.Type, value: Variant, hint: PropertyHint):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value);
	ProjectSettings.set_initial_value(name, value);
	ProjectSettings.add_property_info({
		"name": name,
		"type": type,
		"hint": hint
	});

func init_enum_setting(name: String, value: int, enums: Array[String]):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value);
	ProjectSettings.set_initial_value(name, value);
	ProjectSettings.add_property_info({
		"name": name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(enums)
	});

func _exit_tree():
	# Remove button
	remove_control_from_container(CONTAINER_TOOLBAR, button_scene);
	button_scene.free();

	remove_tool_menu_item(HAXE_MENU_ITEM_NAME);

func _on_haxe_compile_pressed():
	# Load settings
	var runType = ProjectSettings.get_setting(SETTING_RUN_TYPE, 0);
	var compilerPath: String = ProjectSettings.get_setting(SETTING_COMPILER_PATH, "");
	var hxmlPath: String = ProjectSettings.get_setting(SETTING_HXML_PATH, "");

	# Validate stuff
	assert(hxmlPath is String, "Haxe .hxml path is not a String.");
	assert(!hxmlPath.is_empty(), "Haxe .hxml path is not defined.");

	# Find command for running "haxe" compiler
	var haxeCommand = "haxe";
	if runType == 1:
		assert(!compilerPath.is_empty(), "Haxe compiler path is empty.");
		haxeCommand = "\"" + compilerPath + "\"";

	# Validate Haxe command and get version
	var versionOutput = [];
	var versionResult = OS.execute(
		"CMD.exe", [ "/C", ("%s --version" % [haxeCommand]) ],
		versionOutput, true, false
	);

	if versionResult == 1:
		printerr("Could not run Haxe command: " + haxeCommand);
		return;

	# Print version
	var version = versionOutput[0].strip_edges(true, true);
	print("\n--- Compiling with Haxe v" + version + " ---");

	# Ensure .hxml file exists
	assert(FileAccess.file_exists(hxmlPath), hxmlPath + " could not be found.");

	# Extract the folder and filename from the absolute .hxml path
	var regex = RegEx.new()
	regex.compile("^(.*)[/\\\\]([^\\\\/]+)\\.hxml$");
	var result = regex.search(hxmlPath);
	
	var folder = "";
	var hxml = "";
	if result:
		folder = result.strings[1];
		hxml = result.strings[2] + ".hxml";

	# Execute "haxe compile.hxml" in defined directory
	var output = [];
	var lsResult = OS.execute(
		"CMD.exe",
		[
			"/C",
			("cd \"%s\" && %s %s" % [folder, haxeCommand, hxml])
		],
		output,
		true,
		false
	);

	# Print result
	if lsResult == 0:
		print("Successfully compiled Haxe code! ✅");
	else:
		print("Haxe compilation failed with exit code: " + str(lsResult) + " ❌");

	# Print output if it exists
	if output.size() > 0 && output[0].length() > 0:
		print("\n-- Haxe Compiler Output --");
		print(output[0]);

func _on_haxe_script_create_pressed():
	print(get_editor_interface());
