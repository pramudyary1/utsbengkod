import 'package:flutter/material.dart';
import 'package:uts_aplication_busettt/data/database.dart' as db;

final List<db.Todo> _allTodos = [];
final List<db.Todo> _filteredTodos = [];

class MyHomePage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const MyHomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db.MyDatabase database = db.MyDatabase();
  TextEditingController titleTEC = TextEditingController();
  TextEditingController detailTEC = TextEditingController();
  TextEditingController searchTEC = TextEditingController();

  List<db.Todo> _allTodos = [];
  List<db.Todo> _filteredTodos = [];

  Future insert(String title, String detail) async {
    await database
        .into(database.todos)
        .insert(db.TodosCompanion.insert(title: title, detail: detail));
    fetchTodos(); // Refresh data
  }

  Future fetchTodos() async {
    _allTodos = await database.select(database.todos).get();
    setState(() {
      _filteredTodos = _allTodos;
    });
  }

  Future update(db.Todo todo, String newTitle, String newDetail) async {
    await database
        .update(database.todos)
        .replace(db.Todo(id: todo.id, title: newTitle, detail: newDetail));
    fetchTodos(); // Refresh data
  }

  Future delete(db.Todo todo) async {
    await database.delete(database.todos).delete(todo);
    fetchTodos(); // Refresh data
  }

  Future deleteAll() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Semua Aktivitas"),
          content:
              const Text("Apakah Anda yakin ingin menghapus semua aktivitas?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await database.delete(database.todos).go();
                fetchTodos(); // Refresh data
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text(
                "Hapus Semua",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTodos();
    searchTEC.addListener(_searchTodos);
  }

  void _searchTodos() {
    final query = searchTEC.text.toLowerCase();
    setState(() {
      _filteredTodos = _allTodos
          .where((todo) =>
              todo.title.toLowerCase().contains(query) ||
              todo.detail.toLowerCase().contains(query))
          .toList();
    });
  }

  void todoDialog(db.Todo? todo, {bool isEditMode = false}) {
    if (todo == null) {
      titleTEC.clear();
      detailTEC.clear();
    } else {
      titleTEC.text = todo.title;
      detailTEC.text = todo.detail;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    (todo != null
                            ? (isEditMode ? "Edit" : "Detail")
                            : "Tambah") +
                        " Aktivitas",
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: titleTEC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Aktivitas",
                    ),
                    readOnly: todo != null && !isEditMode,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: detailTEC,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Deskripsi",
                    ),
                    readOnly: todo != null && !isEditMode,
                  ),
                  const SizedBox(height: 10),
                  if (todo == null || isEditMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                          child: const Text("Batal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (isEditMode && todo != null) {
                              update(todo, titleTEC.text, detailTEC.text);
                            } else {
                              insert(titleTEC.text, detailTEC.text);
                            }
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                            titleTEC.clear();
                            detailTEC.clear();
                          },
                          child: const Text("Simpan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'List Aktivitas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 2,
                shadowColor: Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
                child: TextField(
                  controller: searchTEC,
                  onChanged: (value) => _searchTodos(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        widget.isDarkMode ? Colors.grey[850] : Colors.white,
                    prefixIcon: Icon(Icons.search,
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.grey[700]),
                    hintText: 'Cari aktivitas...',
                    hintStyle: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.grey[700]),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _allTodos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Ayo Tambahkan Aktivitasmu!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/images/apayah.png',
                            height: 250,
                            width: 250,
                          ),
                        ],
                      ),
                    )
                  : _filteredTodos.isEmpty
                      ? const Center(
                          child: Text("Aktivitas Tidak Ditemukan"),
                        )
                      : ListView.builder(
                          itemCount: _filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = _filteredTodos[index];
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  todoDialog(todo);
                                },
                                title: Text(todo.title),
                                subtitle: Text(todo.detail),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.grey[900],
                                      onPressed: () {
                                        todoDialog(todo, isEditMode: true);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.grey[900],
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Hapus Aktivitas"),
                                              content: const Text(
                                                  "Apakah Anda yakin ingin menghapus aktivitas ini?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Batal"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    delete(todo);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          todoDialog(null);
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                widget.toggleTheme();
              },
              icon:
                  Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {
                deleteAll();
              },
              icon: const Icon(Icons.delete_forever),
            ),
          ],
        ),
      ),
    );
  }
}
