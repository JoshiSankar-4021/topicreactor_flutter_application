import 'package:flutter/material.dart';
import 'TopicCreator.dart';
import 'utils/SessionManager.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // ⭐ VERY IMPORTANT
        children: [
          // HEADER
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage:
                  AssetImage('assets/images/topicreactor.png'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _drawerTile(
            context,
            icon: Icons.account_circle_outlined,
            title: "Profile",
            route: "/profile",
          ),

          const SizedBox(height: 20),

          // ⭐ Updated Topic Creator tile to open dialog like FAB
          _drawerTile(
            context,
            icon: Icons.add_circle_outline,
            title: "Topic Creator",
            onTap: () async {
              Navigator.pop(context); // close drawer
              final result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SizedBox(
                      width: 400,
                      height: 300,
                      child: TopicCreator(),
                    ),
                  );
                },
              );

              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Topic added successfully")),
                );
              }
            },
          ),

          const SizedBox(height: 20),

          _drawerTile(
            context,
            icon: Icons.list_alt_outlined,
            title: "Topics",
            route: "/topics",
          ),

          const SizedBox(height: 20),

          _drawerTile(
            context,
            icon: Icons.list_alt_outlined,
            title: "My Topics",
            route: "/mytopics",
          ),

          const SizedBox(height: 20),

          _drawerTile(
            context,
            icon: Icons.comment_outlined,
            title: "My Comments",
            route: "/mytopics",
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () async {
                await SessionManager.clearSession(); // ⭐ Clear session on logout
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? route,
        Function()? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        tileColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.green),
        ),
        onTap: onTap ??
                () {
              Navigator.pop(context); // close drawer
              if (route != null) Navigator.pushNamed(context, route);
            },
      ),
    );
  }
}
