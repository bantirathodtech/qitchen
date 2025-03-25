import 'package:flutter/material.dart';

import '../../../common/widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Notifications'),
      // ),
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png', // Path to your logo
        onBackPressed: () {
          // Define what happens when the back button is pressed
          Navigator.of(context).pop();
        },
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('New Offer Available'),
            subtitle: Text('Get 20% off on all items today!'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle notification tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Delivery Confirmation'),
            subtitle: Text('Your order_shared_common has been delivered.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle notification tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Upcoming Event'),
            subtitle: Text('Join us for our special event next week!'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle notification tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('New Message'),
            subtitle: Text('You have a new message from the admin.'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle notification tap
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
