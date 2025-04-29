import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_response.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_list_item.dart';

class MovieListScreen extends StatefulWidget {
  final UserResponse user;

  const MovieListScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).loadMovies();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMorePages) {
        provider.loadMovies();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Movies - ${widget.user.firstName} ${widget.user.lastName??""}'),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final movies = provider.movies;

          if (movies.isEmpty && provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMovies(refresh: true),
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: movies.length + (provider.isLoading ? 2 : 0),
              itemBuilder: (context, index) {
                if (index < movies.length) {
                  return MovieListItem(movie: movies[index]);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
