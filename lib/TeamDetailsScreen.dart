import 'package:flutter/material.dart';
import 'package:teamformation/user.dart';

class TeamDetailsScreen extends StatelessWidget {
  final List<User> teamMembers;

  TeamDetailsScreen({required this.teamMembers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Details'),
      ),
      body: ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          User user = teamMembers[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatar),
              ),
              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Email: ${user.email}'),
                  Text('Gender: ${user.gender}'),
                  Text('Domain: ${user.domain}'),
                  Text('Available: ${user.available ? 'Yes' : 'No'}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
