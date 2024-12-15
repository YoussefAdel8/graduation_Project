import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';
  String? selectedPlaceType;

  List<String> placeTypes = ['Indoor', 'Outdoor', 'Cafe'];
  List<Map<String, dynamic>> searchResults = [];

  Future<void> _performSearch() async {
    Query query = FirebaseFirestore.instance.collection('places');

    // Combine active filters dynamically
    if (searchText.isNotEmpty) {
      query = query.where('name', isEqualTo: searchText);
    }
    if (selectedPlaceType != null) {
      query = query.where('type', isEqualTo: selectedPlaceType);
    }

    try {
      final querySnapshot = await query.get();
      setState(() {
        searchResults = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });

      if (searchResults.isEmpty) {
        print('No results match the selected criteria.');
      }
    } catch (e) {
      print('Error performing search: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by Name',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedPlaceType,
                decoration: const InputDecoration(labelText: 'Place Type'),
                onChanged: (value) {
                  setState(() {
                    selectedPlaceType = value;
                  });
                },
                items: placeTypes.map((placeType) {
                  return DropdownMenuItem<String>(
                    value: placeType,
                    child: Text(placeType),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF8B39),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                onPressed: _performSearch,
                child: const Text('Search',style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 20),
              searchResults.isEmpty
                  ? const Text('No results found.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final place = searchResults[index];
                        return ListTile(
                          title: Text(place['name'] ?? 'Unknown Place'),
                          subtitle: Text(
                            'Type: ${place['type'] ?? 'Unknown'}',
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
