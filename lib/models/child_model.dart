class Child {
  String id;
  String parentId;
  String name;
  int exp;
  int level;

  Child({
    required this.id,
    required this.parentId,
    required this.name,
    this.exp = 0,
    this.level = 1,
  });
}
