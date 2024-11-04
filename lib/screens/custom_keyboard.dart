// onKey: ((event) {
// // if (event.i) {
// if (event is RawKeyDownEvent) {
// if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
// command = AppConstants.removeLastLetter(command);
// }
//
// // if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// // } else
// if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// String newCommand =
// AppConstants.getMostRecentCommand(commands, command);
// command = "";
// command = newCommand;
// setState(() {});
// } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// if (commandIndex > 0) {
// command = commands[
// --commandIndex]; // Pre-decrement before accessing the element
// } else {
// commandIndex = 0;
// command = commands[commandIndex];
// }
// log("$commandIndex up");
// } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// if (commandIndex < commands.length - 1) {
// command = commands[
// ++commandIndex]; // Pre-increment before accessing the element
// } else {
// commandIndex = commands.length - 1;
// command = commands[commandIndex];
// }
// log("$commandIndex down");
// }
//
// if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
// if (hasCommand(prefix, command)) {
// execute(command);
// _scrollController.animateTo(
// _scrollController.position.maxScrollExtent,
// duration: Duration(milliseconds: 500),
// curve: Curves.easeOut,
// );
// }
// }
//
// String keyLabel = event.logicalKey.keyLabel;
// if (keyLabel != null &&
// keyLabel.length == 1 &&
// !keyLabel.startsWith(new RegExp(r'[a-zA-Z0-9]'))) {
// command += event.data.keyLabel.toString();
// }
//
// if ((event.logicalKey.keyId >= LogicalKeyboardKey.keyA.keyId &&
// event.logicalKey.keyId <=
// LogicalKeyboardKey.keyZ.keyId) ||
// (event.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId &&
// event.logicalKey.keyId <=
// LogicalKeyboardKey.digit9.keyId)) {
// command += event.data.keyLabel.toString();
// }
//
// log(event.data.keyLabel.toString());
//
// setState(() {});
// }
//
// // if (command == "type your command here") {
// //   command = "";
// // }
//
// // }
// }),
