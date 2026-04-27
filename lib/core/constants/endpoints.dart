class Endpoints {
  // admin
  static const String loginAdmin = '/admins/login';
  static const String dashboardStats = '/admins/dashboard-stats';

  // restaurants
  static const String restaurants = '/restaurants';
  static String approveRestaurant(int id) => '/restaurants/$id/approve';

  // drivers
  static const String drivers = '/drivers';
  static String approveDriver(int id) => '/drivers/$id/approve';

  // orders
  static const String orders = '/orders';

  // offers
  static const String adminOffers = '/offers';
  static const String createOffer = '/offers';
  static String deleteOffer(int id) => '/offers/$id';
  static String toggleOfferStatus(int id) => '/offers/$id/toggle-status';
  static String approveOffer(int id) => '/offers/$id/approve';

  // settings
  static const String settings = '/settings';

  // categories
  static const String categories = '/categories';
  static String category(int id) => '/categories/$id';
}
