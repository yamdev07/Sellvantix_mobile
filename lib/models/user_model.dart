class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String initials;
  final int? tenantId;
  final String? tenantName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.initials,
    this.tenantId,
    this.tenantName,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:         j['id'],
    name:       j['name'] ?? '',
    email:      j['email'] ?? '',
    role:       j['role'] ?? '',
    initials:   j['initials'] ?? '',
    tenantId:   j['tenant_id'],
    tenantName: j['tenant']?['name'],
  );

  bool get isAdmin    => role == 'admin' || role == 'super_admin';
  bool get isCashier  => role == 'cashier';
  bool get isManager  => role == 'manager';
}
