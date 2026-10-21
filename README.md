# Consulta de Estados e Municípios do Brasil

Aplicativo desenvolvido em **Flutter** para consultar e exibir os estados brasileiros e seus respectivos municípios por meio da API de Localidades do IBGE.

Na tela inicial, os estados são apresentados em formato de grade. Ao tocar em um estado, o aplicativo abre uma nova tela contendo a lista de municípios pertencentes ao estado selecionado.

## Funcionalidades

- Consulta dos estados brasileiros na API do IBGE.
- Ordenação alfabética dos estados.
- Exibição dos estados em um `GridView` com duas colunas.
- Exibição da bandeira, do nome e da sigla de cada estado.
- Navegação entre a tela de estados e a tela de municípios.
- Consulta dos municípios conforme a sigla do estado selecionado.
- Ordenação alfabética dos municípios.
- Indicador visual durante o carregamento dos dados.

## Tecnologias utilizadas

- Flutter
- Dart
- Pacote `http`
- API de Localidades do IBGE
- `FutureBuilder`
- `GridView.builder`
- `ListView.builder`
- `Navigator`
- `MaterialPageRoute`

## Estrutura sugerida do projeto

```text
lib/
├── imagens/
│   ├── AC.png
│   ├── AL.png
│   ├── AP.png
│   ├── ...
│   └── TO.png
├── models/
│   ├── estado.dart
│   └── municipio.dart
├── services/
│   └── ibge_service.dart
├── views/
│   ├── estados_view.dart
│   └── municipios_view.dart
└── main.dart
```

## Dependências

Adicione o pacote `http` ao arquivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
```

Depois, instale as dependências:

```bash
flutter pub get
```

> Verifique no [pub.dev](https://pub.dev/packages/http) se existe uma versão mais atual do pacote `http` compatível com o seu projeto.

## Configuração das imagens

As imagens das bandeiras devem possuir como nome a sigla de cada estado, por exemplo:

```text
SP.png
RJ.png
MG.png
PR.png
```

No arquivo `pubspec.yaml`, registre a pasta de imagens:

```yaml
flutter:
  uses-material-design: true

  assets:
    - lib/imagens/
```

A imagem de cada estado é carregada utilizando sua sigla:

```dart
Image.asset(
  'lib/imagens/${lista[index].sigla}.png',
  width: 120,
)
```

## Model Estado

Arquivo sugerido: `lib/models/estado.dart`

```dart
class Estado {
  final int id;
  final String sigla;
  final String nome;
  final String regiao;

  Estado(this.id, this.sigla, this.nome, this.regiao);

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      json['id'],
      json['sigla'],
      json['nome'],
      json['regiao']['nome'],
    );
  }
}
```

## Model Município

Arquivo sugerido: `lib/models/municipio.dart`

```dart
class Municipio {
  final int id;
  final String nome;

  Municipio(this.id, this.nome);

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      json['id'],
      json['nome'],
    );
  }
}
```

## Serviço de consulta ao IBGE

Arquivo sugerido: `lib/services/ibge_service.dart`

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/estado.dart';
import '../models/municipio.dart';

class IbgeService {
  Future<List<Estado>> listarEstados() async {
    final resposta = await http.get(
      Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/?orderby=nome',
      ),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> lista = json.decode(resposta.body);

      return lista
          .map(
            (item) => Estado.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  Future<List<Municipio>> listarMunicipios(String sigla) async {
    final resposta = await http.get(
      Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$sigla/municipios?orderby=nome',
      ),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> lista = json.decode(resposta.body);

      return lista
          .map(
            (item) => Municipio.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }
}
```

## Tela de estados

Arquivo sugerido: `lib/views/estados_view.dart`

```dart
import 'package:flutter/material.dart';

import '../models/estado.dart';
import '../services/ibge_service.dart';
import 'municipios_view.dart';

class EstadosView extends StatefulWidget {
  const EstadosView({super.key});

  @override
  State<EstadosView> createState() => _EstadosViewState();
}

class _EstadosViewState extends State<EstadosView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estados brasileiros'),
      ),
      body: FutureBuilder<List<Estado>>(
        future: IbgeService().listarEstados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os estados.'),
            );
          }

          final lista = snapshot.data ?? [];

          if (lista.isEmpty) {
            return const Center(
              child: Text('Nenhum estado foi encontrado.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final estado = lista[index];

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MunicipiosView(estado),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'lib/imagens/${estado.sigla}.png',
                          width: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.flag_outlined,
                              size: 72,
                            );
                          },
                        ),
                        Text(
                          '${estado.nome} (${estado.sigla})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

O evento de clique é implementado no `onTap` do `InkWell`:

```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MunicipiosView(estado),
    ),
  );
},
```

## Tela de municípios

Arquivo sugerido: `lib/views/municipios_view.dart`

```dart
import 'package:flutter/material.dart';

import '../models/estado.dart';
import '../models/municipio.dart';
import '../services/ibge_service.dart';

class MunicipiosView extends StatefulWidget {
  final Estado estado;

  const MunicipiosView(this.estado, {super.key});

  @override
  State<MunicipiosView> createState() => _MunicipiosViewState();
}

class _MunicipiosViewState extends State<MunicipiosView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.estado.nome} (${widget.estado.sigla})',
        ),
      ),
      body: FutureBuilder<List<Municipio>>(
        future: IbgeService().listarMunicipios(widget.estado.sigla),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os municípios.'),
            );
          }

          final lista = snapshot.data ?? [];

          if (lista.isEmpty) {
            return const Center(
              child: Text('Nenhum município foi encontrado.'),
            );
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final municipio = lista[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(municipio.nome),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Arquivo principal

Arquivo: `lib/main.dart`

```dart
import 'package:flutter/material.dart';

import 'views/estados_view.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estados e Municípios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const EstadosView(),
    );
  }
}
```

## Como executar

### 1. Clone ou baixe o projeto

```bash
git clone URL_DO_REPOSITORIO
cd NOME_DO_PROJETO
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Verifique os dispositivos disponíveis

```bash
flutter devices
```

### 4. Execute o aplicativo

```bash
flutter run
```

## Permissão de internet no Android

Para acessar a API no Android, verifique se a permissão de internet está presente no arquivo `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

A permissão deve ser declarada dentro de `<manifest>` e antes de `<application>`.

## Endpoints utilizados

### Estados

```text
GET https://servicodados.ibge.gov.br/api/v1/localidades/estados/?orderby=nome
```

### Municípios por estado

```text
GET https://servicodados.ibge.gov.br/api/v1/localidades/estados/{UF}/municipios?orderby=nome
```

Exemplo para o estado de São Paulo:

```text
GET https://servicodados.ibge.gov.br/api/v1/localidades/estados/SP/municipios?orderby=nome
```

## Fluxo da aplicação

1. A tela inicial executa `listarEstados()`.
2. O `FutureBuilder` aguarda o retorno da API.
3. Os estados são mostrados em um `GridView`.
4. O usuário toca em um estado por meio do `InkWell`.
5. O `Navigator.push()` abre a `MunicipiosView`.
6. O objeto `Estado` selecionado é enviado para a nova tela.
7. A `MunicipiosView` executa `listarMunicipios(estado.sigla)`.
8. Os municípios são exibidos em uma `ListView`.

## Tratamento de estados da interface

A aplicação considera quatro situações durante as consultas:

- **Carregando:** exibe `CircularProgressIndicator`.
- **Sucesso:** exibe os estados ou municípios retornados.
- **Lista vazia:** informa que nenhum resultado foi encontrado.
- **Erro:** informa que os dados não puderam ser carregados.

## Possíveis melhorias

- Implementar pesquisa de municípios por nome.
- Aplicar cache para reduzir consultas repetidas.
- Exibir informações adicionais sobre cada município.
- Utilizar gerenciamento de estado com `Provider`, `Riverpod` ou `Bloc`.
- Criar uma camada de exceções para diferenciar falhas de rede e respostas inválidas.
- Adicionar testes unitários para os models e para o serviço.
- Adicionar testes de widgets para validar navegação e carregamento.
- Tornar o layout da grade responsivo para telas maiores.

## Fonte dos dados

Os dados são obtidos por meio da [API de Localidades do IBGE](https://servicodados.ibge.gov.br/api/docs/localidades).

## Licença

Este projeto pode ser utilizado para fins acadêmicos e educacionais. Caso seja publicado em um repositório, recomenda-se incluir um arquivo de licença, como a licença MIT.
