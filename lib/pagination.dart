import 'user.dart';

class UserPagination {
  List<User> users;
  int currentPage = 1;
  int itemsPerPage = 10;

  UserPagination(List<User> initialUsers) : users = initialUsers;

  List<User> getPaginatedUsers() {
    final startIndex = (currentPage - 1) * itemsPerPage;

    if (startIndex >= users.length) {
      currentPage = 1; // Handle the case where there are no more users to display.
      return [];
    }

    var endIndex = startIndex + itemsPerPage;

    if (endIndex > users.length) {
      endIndex = users.length;
    }

    return users.sublist(startIndex, endIndex);
  }

  void nextPage() {
    currentPage++;
  }
}
