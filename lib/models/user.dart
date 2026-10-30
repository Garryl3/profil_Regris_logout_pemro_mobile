class User {
  final String name;
  final String email;
  final bool isLoggedIn;

  User({
    required this.name,
    required this.email,
    required this.isLoggedIn,
  });

  factory User.guest() {
    return User(
      name: 'Tamu',
      email: '',
      isLoggedIn: false,
    );
  }
}