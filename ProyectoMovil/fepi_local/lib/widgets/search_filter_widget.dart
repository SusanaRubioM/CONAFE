import 'package:fepi_local/widgets/dynamic_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchFilterWidget extends StatefulWidget {
  final List<Map<String, String>> data;

  const SearchFilterWidget({Key? key, required this.data}) : super(key: key);

  @override
  _SearchFilterWidgetState createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  String query = '';
  String filterStatus = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  decoration: InputDecoration(
                    
                    hintText: 'Buscar por nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () async {
                  final selectedFilter = await _showFilterDialog();
                  if (selectedFilter != null) {
                    setState(() {
                      filterStatus = selectedFilter;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        // Eliminamos Expanded y usamos un ListView sin contenedor Expandido
        Flexible(
          child: ListView.builder(
            itemCount: widget.data
                .where((item) => item['Nombre']!.contains(query) && 
                                  (filterStatus == 'Todos' || item['Estatus'] == filterStatus))
                .toList()
                .length,
            itemBuilder: (context, index) {
              final filteredData = widget.data
                  .where((item) => item['Nombre']!.contains(query) && 
                                    (filterStatus == 'Todos' || item['Estatus'] == filterStatus))
                  .toList();
              return DynamicTableWidget(data: [filteredData[index]]);
            },
          ),
        ),
      ],
    );
  }

  Future<String?> _showFilterDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrar por Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Todos', 'Activo', 'Inactivo']
                .map((status) => RadioListTile<String>(
                      title: Text(status),
                      value: status,
                      groupValue: filterStatus,
                      onChanged: (value) {
                        Navigator.pop(context, value);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
