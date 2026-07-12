import 'package:flutter/material.dart';
import 'package:poketstore/controllers/search_producer_controller.dart';
import 'package:provider/provider.dart';

class SearchProducer extends StatelessWidget {
  const SearchProducer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/addproduct.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 120,
                child: Text(
                  "Search Producer",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Consumer<SearchProducerProvider>(
                builder:
                    (context, provider, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Find Producers",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 7, 3, 201),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Select State",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          value: provider.selectedState,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          hint: const Text("Select Your State"),
                          items:
                              provider.states.map((state) {
                                return DropdownMenuItem(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                          onChanged:
                              (value) => provider.updateSelectedState(value),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Producer List",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 7, 3, 201),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.separated(
                            itemCount: provider.producers.length,
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  "Producer Name: ${provider.producers[index]['name']}",
                                ),
                                subtitle: Text(
                                  "Category: ${provider.producers[index]['category']}",
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      7,
                                      3,
                                      201,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "View Detail",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
