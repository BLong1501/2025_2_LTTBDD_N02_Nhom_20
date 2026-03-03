class DashboardModel {
  final int totalUsers;
  final int totalFoods;
  final int pendingFoods;
  final int featuredFoods;

  // Biểu đồ theo 12 tháng
  final List<int> monthlyUsers;
  final List<int> monthlyRecipes;
  final List<int> monthlyBloggerPosts;

  DashboardModel({
    required this.totalUsers,
    required this.totalFoods,
    required this.pendingFoods,
    required this.featuredFoods,
    required this.monthlyUsers,
    required this.monthlyRecipes,
    required this.monthlyBloggerPosts,
  });

  factory DashboardModel.empty() {
    return DashboardModel(
      totalUsers: 0,
      totalFoods: 0,
      pendingFoods: 0,
      featuredFoods: 0,
      monthlyUsers: List.filled(12, 0),
      monthlyRecipes: List.filled(12, 0),
      monthlyBloggerPosts: List.filled(12, 0),
    );
  }
}