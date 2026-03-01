class DashboardModel {
  final int totalUsers;
  final int totalFoods;
  final int pendingFoods;
  final int featuredFoods;

  // Biểu đồ theo 12 tháng
  final List<int> monthlyPending;   
  final List<int> monthlyApproved; 

  DashboardModel({
    required this.totalUsers,
    required this.totalFoods,
    required this.pendingFoods,
    required this.featuredFoods,
    required this.monthlyPending,
    required this.monthlyApproved,
  });

  /// Factory mặc định (tránh null)
  factory DashboardModel.empty() {
    return DashboardModel(
      totalUsers: 0,
      totalFoods: 0,
      pendingFoods: 0,
      featuredFoods: 0,
      monthlyPending: List.filled(12, 0),
      monthlyApproved: List.filled(12, 0),
    );
  }
}