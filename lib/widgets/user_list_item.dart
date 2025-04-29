import 'package:flutter/material.dart';
import '../models/user_response.dart';
import '../screens/movie_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserListItem extends StatelessWidget {
  final UserResponse user;

  const UserListItem({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: user.avatar != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatar!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.person),
                ),
              )
            : CircleAvatar(child: Icon(Icons.person)),
        title: Text('${user.firstName} ${user.lastName ?? ""}'),
        subtitle: user.email != null ? Text(user.email!) : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieListScreen(user: user),
            ),
          );
        },
      ),
    );
  }
}
