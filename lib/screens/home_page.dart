import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  int _page = 0;

  final int _limit = 20;

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;

  bool _isLoadMoreRunning = false;

  List _posts = [];

  List filteredPosts = [];

  var searchedValue = '';

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });

      _page += 1; // Increase _page by 1

      try {
        final res =
            await http.get(Uri.parse("$_baseUrl?_page=$_page&_limit=$_limit"));

        final List fetchedPosts = json.decode(res.body);
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _posts.addAll(fetchedPosts);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  Future<void> firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      final res =
          await http.get(Uri.parse("$_baseUrl?_page=$_page&_limit=$_limit"));
      setState(() {
        _posts = filteredPosts = json.decode(res.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void filterPosts(String value) {
    setState(() {
      filteredPosts = _posts.where((element) {
        return element['title'].toString().contains(value);
      }).toList();
    });

    // filteredPosts =
    //     _posts.where((element) => element['title'] == value).toList();
    // setState(() {
    //   _posts = filteredPosts;
    // });
  }

  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  Widget build(BuildContext context) {
    print('filter-posts: $filteredPosts');
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your news',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _isFirstLoadRunning
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  firstLoad();
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextField(
                        onChanged: (value) {
                          searchedValue = value;
                          filterPosts(searchedValue);
                          print(searchedValue);
                        },
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredPosts.length,
                        controller: _controller,
                        itemBuilder: (_, index) => Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          child: ListTile(
                            title: Text(filteredPosts[index]['title']),
                            subtitle: Text(filteredPosts[index]['body']),
                          ),
                        ),
                      ),
                    ),
                    if (_isLoadMoreRunning == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (_hasNextPage == false)
                      Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 40),
                        color: Colors.amber,
                        child: const Center(
                          child: Text('You have fetched all of the content'),
                        ),
                      ),
                  ],
                ),
              ));
  }
}
