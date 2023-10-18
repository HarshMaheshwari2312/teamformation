import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'pagination.dart';
import 'user.dart';
class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}
class _UserListScreenState extends State<UserListScreen> {
  UserPagination? userPagination;
  TextEditingController searchController = TextEditingController();
  List<User> filteredUsers = [];
  List<User> teamMembers = [];
  List<String> uniqueDomains = [];

  List<String> selectedDomains = [];
  List<String> selectedGenders = [];
  bool availableFilter = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/heliverse_mock_data.json');
      final jsonData = json.decode(jsonString);
      final userList = (jsonData as List<dynamic>).map((userJson) {
        return User(
          id: userJson['id'],
          firstName: userJson['first_name'],
          lastName: userJson['last_name'],
          email: userJson['email'],
          gender: userJson['gender'],
          avatar: userJson['avatar'],
          domain: userJson['domain'],
          available: userJson['available'],
        );
      }).toList();

      userPagination = UserPagination(userList);
      filteredUsers = userPagination?.getPaginatedUsers() ?? [];

      // Calculate unique domains
      uniqueDomains = userList.map((user) => user.domain).toSet().toList();

      setState(() {});
    } catch (e) {
      print('Error reading or parsing the JSON file: $e');
    }
  }

  void loadNextPage() {
    setState(() {
      userPagination?.nextPage();
      filteredUsers = userPagination?.getPaginatedUsers() ?? [];
    });
  }

  void filterUsers(String query) {
    filteredUsers = userPagination!.getPaginatedUsers();

    if (filteredUsers == null) {
      return;
    }

    if (selectedDomains.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return selectedDomains.contains(user.domain);
      }).toList();
    }

    if (selectedGenders.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return selectedGenders.contains(user.gender);
      }).toList();
    }

    if (availableFilter) {
      filteredUsers = filteredUsers.where((user) {
        return user.available;
      }).toList();
    }

    if (query.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    }

    setState(() {});
  }

  void toggleDomainFilter(String domain) {
    setState(() {
      if (selectedDomains.contains(domain)) {
        selectedDomains.remove(domain);
      } else {
        selectedDomains.add(domain);
      }
      filterUsers(searchController.text);
    });
  }

  void toggleGenderFilter(String gender) {
    setState(() {
      if (selectedGenders.contains(gender)) {
        selectedGenders.remove(gender);
      } else {
        selectedGenders.add(gender);
      }
      filterUsers(searchController.text);
    });
  }

  void toggleAvailableFilter() {
    setState(() {
      availableFilter = !availableFilter;
      filterUsers(searchController.text);
    });
  }

  void addToTeam(String domain) {
    final usersToAdd = filteredUsers
        .where((user) => user.available && user.domain == domain)
        .toList();
    teamMembers.addAll(usersToAdd);
  }

  void navigateToTeamDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailsScreen(teamMembers: teamMembers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              filterUsers(searchController.text);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (query) {
                    filterUsers(query);
                  },
                  decoration: InputDecoration(labelText: 'Search by Name'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => toggleDomainFilter('Marketing'),
                    style: ElevatedButton.styleFrom(
                      primary: selectedDomains.contains('Marketing') ? Colors.green : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    child: Text('Marketing'),
                  ),
                  ElevatedButton(
                    onPressed: () => toggleDomainFilter('Sales'),
                    style: ElevatedButton.styleFrom(
                      primary: selectedDomains.contains('Sales') ? Colors.green : Colors.grey,
                    ),
                    child: Text('Sales'),
                  ),
                  ElevatedButton(
                    onPressed: () => toggleGenderFilter('Male'),
                    style: ElevatedButton.styleFrom(
                      primary: selectedGenders.contains('Male') ? Colors.green : Colors.grey,
                    ),
                    child: Text('Male'),
                  ),
                  ElevatedButton(
                    onPressed: () => toggleGenderFilter('Female'),
                    style: ElevatedButton.styleFrom(
                      primary: selectedGenders.contains('Female') ? Colors.green : Colors.grey,
                    ),
                    child: Text('Female'),
                  ),
                  ElevatedButton(
                    onPressed: toggleAvailableFilter,
                    style: ElevatedButton.styleFrom(
                      primary: availableFilter ? Colors.green : Colors.grey,
                    ),
                    child: Text('Available'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  teamMembers.clear();
                  uniqueDomains.forEach(addToTeam);
                  navigateToTeamDetails(context);
                },
                child: Text('Add To Team'),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          User user = filteredUsers[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: loadNextPage,
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

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
