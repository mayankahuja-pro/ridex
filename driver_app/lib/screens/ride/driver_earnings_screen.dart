import 'dart:convert';

import 'package:flutter/material.dart';


// import '../../core/constants/api_constants.dart';
// import '../../models/ride.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DriverEarningsScreen extends StatefulWidget {
  final String? token;

  const DriverEarningsScreen({
    super.key,
    this.token,
  });

  @override
  State<DriverEarningsScreen> createState() =>
      _DriverEarningsScreenState();
}

class _DriverEarningsScreenState
    extends State<DriverEarningsScreen> {
  final ApiService _apiService = ApiService();
  final AuthService authService = AuthService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {

      final token = await authService.getToken();
      final response = await _apiService.get(
        "/drivers/earnings",
          token: token,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          setState(() {
            _data = decoded;
            _isLoading = false;
          });
        } else {
          throw Exception("Invalid earnings response");
        }
      } else {
        throw Exception(
          "Failed to load earnings (${response.statusCode})",
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  dynamic _value(String key) {
    return _data[key];
  }

  double _amount(String key) {
    final value = _value(key);

    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(double value) {
    return "₹${value.toStringAsFixed(2)}";
  }

  List<dynamic> get _history {
    final value =
        _data["history"] ??
        _data["earnings"] ??
        _data["transactions"] ??
        [];

    if (value is List) {
      return value;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "My Earnings",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              const Text(
                "Unable to load earnings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loadEarnings,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEarnings,

      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTotalCard(),

          const SizedBox(height: 20),

          _buildSummaryCards(),

          const SizedBox(height: 28),

          const Text(
            "Earnings History",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    final total = _amount("total_earnings");

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF176B4D),
            Color(0xFF229866),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(.18),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                "Total Earnings",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _money(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Your total earnings",
            style: TextStyle(
              color: Colors.white.withOpacity(.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,

      children: [
        _summaryCard(
          title: "Today",
          value: _money(
            _amount("today_earnings"),
          ),
          icon: Icons.today_outlined,
          color: Colors.blue,
        ),

        _summaryCard(
          title: "This Week",
          value: _money(
            _amount("weekly_earnings"),
          ),
          icon: Icons.date_range_outlined,
          color: Colors.orange,
        ),

        _summaryCard(
          title: "This Month",
          value: _money(
            _amount("monthly_earnings"),
          ),
          icon: Icons.calendar_month_outlined,
          color: Colors.purple,
        ),

        _summaryCard(
          title: "Trips",
          value: "${_data["total_trips"] ?? 0}",
          icon: Icons.local_taxi_outlined,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const Spacer(),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 10),

            const Text(
              "No earnings history",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Your completed trips will appear here.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _history.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),

        itemBuilder: (context, index) {
          final item = _history[index];

          if (item is! Map) {
            return const SizedBox();
          }

          final amount =
              item["amount"] ??
              item["earnings"] ??
              item["total"] ??
              0;

          final date =
              item["date"] ??
              item["created_at"] ??
              item["createdAt"] ??
              "";

          final status =
              item["status"] ??
              "Completed";

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),

            leading: Container(
              width: 45,
              height: 45,

              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.1),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.local_taxi,
                color: Colors.green,
              ),
            ),

            title: Text(
              item["title"] ??
                  item["trip_id"]?.toString() ??
                  "Trip",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            subtitle: Text(
              "$date • $status",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            trailing: Text(
              "+ ₹${_parseAmount(amount).toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          );
        },
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }
}
