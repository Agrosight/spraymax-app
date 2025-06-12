import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromRGBO(35, 35, 35, 1),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => _menuButtonWidget(context),
      ),
      elevation: 4,
      shadowColor: Colors.black
    );
  }

  Widget _menuButtonWidget(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Color.fromRGBO(35, 35, 35, 1)),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
