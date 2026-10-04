import 'dart:convert';

import 'package:flutter/material.dart';

import '/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({
    super.key,
    required this.token,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiService.get(
        'auth/me',
        token: widget.token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _user = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load profile (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('MY PROFILE'),
        centerTitle: true,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFB6FF00),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFFE600),
                size: 48,
              ),

              const SizedBox(height: 16),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _getProfile,
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text(
          'No profile found',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    final name = _user!['name'] ?? 'User';
    final email = _user!['email'] ?? '-';
    final phone = _user!['phone'] ?? '-';
    final image = _user!['profileImage'];

    final hasImage =
        image != null && image.toString().isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFFB6FF00),
      backgroundColor: const Color(0xFF0D0D0D),

      onRefresh: _getProfile,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          30,
        ),

        children: [
          // =====================================================
          // PROFILE HEADER
          // =====================================================

          Center(
            child: Container(
              padding: const EdgeInsets.all(4),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(
                  color: const Color(0xFFB6FF00),
                  width: 2,
                ),

                boxShadow: const [
                  BoxShadow(
                    color: Color(0x5533FF00),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),

              child: CircleAvatar(
                radius: 55,

                backgroundColor:
                    const Color(0xFF151515),

                backgroundImage: hasImage
                    ? NetworkImage(image.toString())
                    : null,

                child: !hasImage
                    ? const Icon(
                        Icons.person,
                        size: 58,
                        color: Color(0xFFB6FF00),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // =====================================================
          // NAME
          // =====================================================

          Center(
            child: Text(
              name.toString(),

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              'CUSTOMER PROFILE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB6FF00),
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // =====================================================
          // PROFILE DETAILS
          // =====================================================

          _profileItem(
            icon: Icons.email_outlined,
            title: 'EMAIL',
            value: email.toString(),
          ),

          _profileItem(
            icon: Icons.phone_outlined,
            title: 'PHONE',
            value: phone.toString(),
          ),

          _profileItem(
            icon: Icons.person_outline,
            title: 'USER ID',
            value: '${_user!['id'] ?? '-'}',
          ),

          const SizedBox(height: 20),

          // =====================================================
          // EDIT PROFILE
          // =====================================================

          SizedBox(
            height: 50,

            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Edit profile
              },

              icon: const Icon(
                Icons.edit_outlined,
              ),

              label: const Text(
                'EDIT PROFILE',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // // =====================================================
          // // RIDE HISTORY
          // // =====================================================

          // SizedBox(
          //   height: 50,

          //   child: OutlinedButton.icon(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) =>
          //               const RideHistoryScreen(),
          //         ),
          //       );
          //     },

          //     icon: const Icon(
          //       Icons.history,
          //     ),

          //     label: const Text(
          //       'RIDE HISTORY',
          //     ),
          //   ),
          // ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE ITEM
  // ============================================================

  Widget _profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFF292929),
          width: 1,
        ),
      ),

      child: Row(
        children: [
          // ------------------------------------------------------
          // ICON
          // ------------------------------------------------------

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFF151515),

              borderRadius: BorderRadius.circular(10),

              border: Border.all(
                color: const Color(0xFF334700),
              ),
            ),

            child: Icon(
              icon,
              color: const Color(0xFFB6FF00),
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          // ------------------------------------------------------
          // TEXT
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB6FF00),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
