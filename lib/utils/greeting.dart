/// Time-of-day greeting shown on the dashboard.
abstract final class Greeting {
  static String forTime(DateTime time) => switch (time.hour) {
    < 12 => 'Good Morning',
    < 17 => 'Good Afternoon',
    _ => 'Good Evening',
  };
}
