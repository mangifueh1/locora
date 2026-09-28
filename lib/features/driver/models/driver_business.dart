class DriverBusiness {
  const DriverBusiness({required this.id, required this.name});

  final String id;
  final String name;

  factory DriverBusiness.fromJson(Map<String, dynamic> json) {
    return DriverBusiness(
      id: json['id'].toString(),
      name: json['name'].toString(),
    );
  }
}
