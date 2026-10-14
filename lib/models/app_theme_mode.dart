/// The user's appearance preference.
enum AppThemeMode {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemeMode(this.label);

  final String label;
}
