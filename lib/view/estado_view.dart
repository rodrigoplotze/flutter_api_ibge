import 'package:flutter/material.dart';

import '../model/estado_model.dart';
import '../service/ibge_service.dart';

class EstadoView extends StatefulWidget {
  const EstadoView({super.key});

  @override
  State<EstadoView> createState() => _EstadoViewState();
}

class _EstadoViewState extends State<EstadoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: IbgeService().listarEstados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var lista = snapshot.data as List<Estado>;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'assets/imagens/${lista[index].sigla}.png',
                            width: 120,
                          ),
                          Text(
                            '${lista[index].nome} (${lista[index].sigla})',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
