import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_firebase_project/image_saver.dart';
import 'package:flutter/material.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final List<Movie> movieList = [];
  // @override
  // void initState() {
  //   super.initState();
  //   _getMovieList();
  // }
  // void _getMovieList() {
  //   _firebaseFirestore.collection('movies').get().then((value){
  //     movieList.clear();
  //     for(QueryDocumentSnapshot doc in value.docs){
  //       print(doc.data());
  //       movieList.add(Movie.fromJson(doc.id, doc.data() as Map<String, dynamic>),);
  //     }
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie List'),
      ),
      body: StreamBuilder(
        stream: _firebaseFirestore.collection('movies').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }
          movieList.clear();
          for(QueryDocumentSnapshot doc in (snapshot.data?.docs ?? [])){
            //print(doc.data());
            movieList.add(Movie.fromJson(doc.id, doc.data() as Map<String, dynamic>),);
          }
          return ListView.separated(
            itemCount: movieList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(movieList[index].name, style: const TextStyle(fontSize: 24, color: Colors.red),),
                subtitle: Text(movieList[index].languages),
                leading: Text(movieList[index].rating),
                trailing: Text(movieList[index].year),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: (){
              Map<String, dynamic> newMovie = {
                'name' : 'Catch Me If You Can',
                'year' : '2007',
                'languages' : 'English, Hindi',
                'rating' : '4.5',
              };
              _firebaseFirestore.collection('movies').doc('new-movie').set(newMovie);
              //_firebaseFirestore.collection('movies').doc('new-movie').update(newMovie);
            },child: const Icon(Icons.add),
              ),
          const SizedBox(width: 16,),
          FloatingActionButton(
            onPressed: (){
              _firebaseFirestore.collection('movies').doc('new-movie').delete();
            },child: const Icon(Icons.delete),
          ),
          const SizedBox(width: 16,),
          FloatingActionButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const ImageSaveFromGallaryToDatabase(),),);
          },child: const Center(child: Icon(Icons.picture_in_picture_alt)),),
        ],
      ),
    );
  }
}

class Movie {
  final String id, name, languages, year, rating;

  Movie({required this.id, required this.name, required this.languages, required this.year, required this.rating});

  factory Movie.fromJson(String id,Map<String, dynamic> json) {
    return Movie(id: id, name: json['name'], languages: json['languages'], year: json['year'], rating: json['rating'] ?? 'Unknown');
  }

}
