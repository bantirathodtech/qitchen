import 'package:flutter/material.dart';

class LoyaltyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loyalty Program'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Loyalty Points:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                SizedBox(width: 8),
                Text(
                  '100 Points', // Replace with actual points
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Benefits:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('10% off on your next purchase'),
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('Free dessert on your birthday'),
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Exclusive access to new menu items'),
            ),
          ],
        ),
      ),
    );
  }
}