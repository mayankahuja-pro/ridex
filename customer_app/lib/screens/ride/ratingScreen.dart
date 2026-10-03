import 'package:flutter/material.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/models/ride.dart';
import 'package:customer_app/core/constants/api_constants.dart';
class RatingScreen extends StatefulWidget {
  final Ride ride;

  const RatingScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RatingScreen> createState() =>
      _RatingScreenState();
}

class _RatingScreenState
    extends State<RatingScreen> {

  int selectedRating = 0;

  final commentController =
      TextEditingController();

  bool isSubmitting = false;

  Future<void> submitRating() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a rating",
          ),
        ),
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final token =
          await AuthService().getToken();

      final response =
          await ApiService().post(
        ApiConstants.ratings,
        {
          "ride_id": widget.ride.id,
          "rating": selectedRating,
          "comment":
              commentController.text.trim(),
        },
        token: token,
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        Navigator.popUntil(
          context,
          (route) => route.isFirst,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
    
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Rate Your Ride",
      ),
      automaticallyImplyLeading: false,
    ),

    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          const Text(
            "How was your ride?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) {
                final rating = index + 1;

                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRating = rating;
                    });
                  },
                  icon: Icon(
                    rating <= selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    size: 42,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          TextField(
            controller: commentController,
            maxLines: 3,
            decoration:
                const InputDecoration(
              hintText:
                  "Write a comment (optional)",
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : submitRating,
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Submit Rating",
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

}