import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({super.key, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo image on the left
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset(
              "assets/images/Enayatak(2).png",
              height: height * 1.2,
            ),
          ),
          // Notification icon and profile image on the right
          Row(
            children: [
              IconButton(
                icon: const CustomGradiantIconWidget(
                    icon: Icons.notifications, iconSize: 30),
                onPressed: () {
                  // Handle notification icon press
                },
              ),
              // const SizedBox(width: 8),
              // const CircleAvatar(
              //   radius: 18,
              //   backgroundImage: AssetImage(
              //       "assets/images/profile.jpg"), // Replace with your profile image
              // ),
              const SizedBox(width: 30), // Add some padding on the right
            ],
          ),
        ],
      ),
    );
  }
}
