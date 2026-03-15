import 'package:flutter/material.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';

class SnakeGalleryScreen extends StatelessWidget {
  const SnakeGalleryScreen({super.key});

  final List<Map<String, String>> _snakes = const [
    {
      "name": "Cobra",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Naja_naja_01.jpg/640px-Naja_naja_01.jpg",
      "type": "Neurotoxic",
    },
    {
      "name": "Krait",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Bungarus_caeruleus_01.jpg/640px-Bungarus_caeruleus_01.jpg",
      "type": "Neurotoxic",
    },
    {
      "name": "Russell's Viper",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Daboia_russelii.jpg/640px-Daboia_russelii.jpg",
      "type": "Haemotoxic",
    },
    {
      "name": "Saw-scaled Viper",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Echis_carinatus.jpg/640px-Echis_carinatus.jpg",
      "type": "Haemotoxic",
    },
    {
      "name": "Malayan Pit Viper",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Calloselasma_rhodostoma_01.jpg/640px-Calloselasma_rhodostoma_01.jpg",
      "type": "Haemotoxic",
    },
    {
      "name": "Sea Snake",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Laticauda_colubrina.jpg/640px-Laticauda_colubrina.jpg",
      "type": "Myotoxic",
    },
    {
      "name": "Python",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Python_molurus_molurus.jpg/640px-Python_molurus_molurus.jpg",
      "type": "Non-Venomous",
    },
    {
      "name": "Rat Snake",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Ptyas_mucosa.jpg/640px-Ptyas_mucosa.jpg",
      "type": "Non-Venomous",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blueGrey.shade900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Identify Species",
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _snakes.length,
          itemBuilder: (context, index) {
            final snake = _snakes[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, snake["name"]);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          snake["image"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.blueGrey.shade300,
                                ),
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snake["name"]!,
                            style: TextStyle(
                              color: Colors.blueGrey.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                snake["type"] ?? "",
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getTypeColor(
                                  snake["type"] ?? "",
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              snake["type"]!,
                              style: TextStyle(
                                color: _getTypeColor(snake["type"] ?? ""),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type == "Neurotoxic") return Colors.purple.shade600;
    if (type == "Haemotoxic") return Colors.red.shade600;
    if (type == "Myotoxic") return Colors.orange.shade600;
    return Colors.green.shade600;
  }
}
