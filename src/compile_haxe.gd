@tool
extends Object

static func compile_haxe(runType: int, compilerPath: String, hxmlPath: String):
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
