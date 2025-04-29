import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_list_item.dart';
import 'add_user_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'User List',
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final users = provider.users;

          if (users.isEmpty && provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadUsers(refresh: true),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return UserListItem(user: users[index]);
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: (!provider.isLoading && provider.hasMorePages)
                      ? () {
                          print('Load More button pressed');
                          provider.loadUsers();
                        }
                      : null,
                  // style: ElevatedButton.styleFrom(
                  //   padding: EdgeInsets.symmetric(vertical: 12),
                  //   backgroundColor: Colors.deepPurpleAccent
                  // ),
                  child: provider.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Loading...',
                              // style: TextStyle(color: Colors.white)
                            ),
                          ],
                        )
                      : Text(
                          provider.hasMorePages
                              ? 'Load More Users'
                              : 'No More Users',
                          // style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add User',
      ),
    );
  }
}
