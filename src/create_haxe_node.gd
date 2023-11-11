@tool
extends Object

static func prepare_dialog(node: Node, source_path: String, dialog: Window):
	assert(!source_path.is_empty(), "Source path is not defined in Project Settings.");

	var superClassName = node.get_class();

	var basePath = "MarginContainer/MainContainer/InputsContainer/Inputs/";
	var nameInput = dialog.get_node(basePath + "Name") as LineEdit;
	var nodeClassInput = dialog.get_node(basePath + "NodeClass") as LineEdit;
	var sourceFileInput = dialog.get_node(basePath + "SourceFile") as LineEdit;

	# Figure out a starting class name
	if nameInput.name == superClassName:
		nameInput.text = "My" + superClassName;
	else:
		nameInput.text = node.name;

	# Put super class here
	nodeClassInput.text = superClassName;
	
	# The file that will be created
	sourceFileInput.text = source_path + "/" + nameInput.text + ".hx";
	
	dialog.popup_window = true;
	dialog.popup_centered();
