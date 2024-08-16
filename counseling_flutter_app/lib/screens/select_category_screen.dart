import 'package:counseling_flutter_app/screens/select_expert_screen.dart';
import 'package:flutter/material.dart';

class SelectCategoryScreen extends StatelessWidget {
  final List<String> existingChats;
  final Function refreshUI;

  SelectCategoryScreen(
      {Key? key, required this.existingChats, required this.refreshUI})
      : super(key: key);

  final List<Map<String, dynamic>> categories = [
    {'name': 'Mental', 'color': Colors.purple, 'icon': Icons.psychology},
    {'name': 'Career', 'color': Colors.blue, 'icon': Icons.business_center},
    {'name': 'Family', 'color': Colors.red, 'icon': Icons.family_restroom},
    {'name': 'Academic', 'color': Colors.orange, 'icon': Icons.school},
    {'name': 'Travel', 'color': Colors.teal, 'icon': Icons.travel_explore},
    {'name': 'Animals', 'color': Colors.green, 'icon': Icons.pets},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: category['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: Icon(
                  category['icon'],
                  color: Colors.white,
                ),
                title: Text(
                  category['name'],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectExpertScreen(
                        category: category['name'],
                        categoryColor: category['color'],
                        categoryIcon: category['icon'],
                        existingChats: existingChats,
                        refreshUI: refreshUI,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
