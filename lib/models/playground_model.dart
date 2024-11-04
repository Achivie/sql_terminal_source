class PlaygroundModel {
  final String name;
  final DateTime lastEdited;
  final String commands;
  final String id;
  final DateTime created;
  final String databaseUsername;
  final String databasePassword;

  PlaygroundModel({
    required this.name,
    required this.lastEdited,
    required this.commands,
    required this.id,
    required this.created,
    required this.databaseUsername,
    required this.databasePassword,
  });
}
