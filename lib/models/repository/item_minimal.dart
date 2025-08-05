class ItemMinimal {
  int id;
  String name;
  int icon;
  int iLvl;

  ItemMinimal({
    required this.id,
    required this.name,
    required this.icon,
    required this.iLvl
  });

  ItemMinimal.withId(String idStr, Map<String, dynamic> data)
    : id = int.parse(idStr),
      name = data["name"],
      icon = data["icon"],
      iLvl = data["iLvl"];
}