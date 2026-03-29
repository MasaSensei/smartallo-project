class ApiConstants {
  // Ganti IP ini dengan IP laptop Bos kalau pakai Emulator Android (10.0.2.2)
  // Atau pakai URL Supabase Edge Functions / Backend URL kalau sudah deploy
  // static const String baseUrl = "http://10.0.2.2:8080/api/v1";
  static const String baseUrl = "http://localhost:8080/api/v1";

  // --- AUTH ENDPOINTS ---
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";

  // --- ORGANIZATIONS (BARU) ---
  static const String organizations = "$baseUrl/organizations";

  // --- POCKETS ---
  static const String pockets = "$baseUrl/pockets";
  static const String pocketsDashboard = "$baseUrl/pockets/dashboard";

  // --- TRANSACTIONS ---
  static const String transactions = "$baseUrl/transactions";
  static const String transactionHistory = "$baseUrl/transactions/history";

  // --- DASHBOARD ---
  static const String mainDashboard = "$baseUrl/dashboard/main";

  // --- SUBSCRIPTIONS (BARU) ---
  static const String subscriptionPlans = "$baseUrl/subscriptions/plans";
  static const String subscribe = "$baseUrl/subscriptions/subscribe";

  static const String categories = "$baseUrl/categories";
}
