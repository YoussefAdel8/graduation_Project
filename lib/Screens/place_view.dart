import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PlaceView extends StatefulWidget {
  final Map<String, dynamic> placeData;
  final Map<String, dynamic> venueData;

  const PlaceView({
    required this.placeData,
    required this.venueData,
    Key? key,
  }) : super(key: key);

  @override
  _PlaceViewState createState() => _PlaceViewState();
}

class _PlaceViewState extends State<PlaceView> {
  @override
  Widget build(BuildContext context) {
    final placeName = widget.placeData['name'];
    final description = widget.placeData['description'];
    final imageUrls = widget.placeData['images'] ?? [];
    final capacity = widget.placeData['capacity'].toString();
    print(imageUrls);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Information'),
        backgroundColor: const Color(0xFFEF8B39),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.all(8)),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: imageUrls.isNotEmpty
                    ? Image.network(imageUrls[0])
                    : Container(),
              ),

              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Text('place name :'),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      placeName ?? 'amr',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 17,
              ),

              const SizedBox(height: 8.0),
              // Place description
              Row(
                children: const [
                  Padding(padding: EdgeInsets.all(5)),
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '$description',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  SizedBox(width: 8.0),
                  Text(
                    'Capacity: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(capacity),
                  Icon(Icons.people),
                ],
              ),
              const SizedBox(height: 40.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor:Color(0xFFEF8B39)),
                  onPressed: () {},
                  child: const Text('Book Now',style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

