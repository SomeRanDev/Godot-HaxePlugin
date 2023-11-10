@tool
extends Object

const SETTING_RUN_TYPE = "haxe/compiler_run_type";
const SETTING_COMPILER_PATH = "haxe/compiler_path";
const SETTING_HXML_PATH = "haxe/hxml_path";

static func get_run_type() -> int:
	return ProjectSettings.get_setting(SETTING_RUN_TYPE, 0);

static func get_compiler_path() -> String:
	return ProjectSettings.get_setting(SETTING_COMPILER_PATH, "");

static func get_hxml_path() -> String:
	return ProjectSettings.get_setting(SETTING_HXML_PATH, "");

static func setup_settings():
	init_enum_setting(SETTING_RUN_TYPE, 0, ["Run \"haxe\" Command", "Use Haxe Compiler Path"]);
	init_settings(SETTING_COMPILER_PATH, TYPE_STRING, "", PROPERTY_HINT_NONE);
	init_settings(SETTING_HXML_PATH, TYPE_STRING, "../compile.hxml", PROPERTY_HINT_GLOBAL_FILE);
	ProjectSettings.save();

static func init_settings(name: String, type: Variant.Type, value: Variant, hint: PropertyHint):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value);
	ProjectSettings.set_initial_value(name, value);
	ProjectSettings.add_property_info({
		"name": name,
		"type": type,
		"hint": hint
	});

static func init_enum_setting(name: String, value: int, enums: Array[String]):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value);
	ProjectSettings.set_initial_value(name, value);
	ProjectSettings.add_property_info({
		"name": name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(enums)
	});
