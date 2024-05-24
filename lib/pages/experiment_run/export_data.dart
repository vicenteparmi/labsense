import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExportData extends StatelessWidget {
  final List<List<double>> data;
  final String procedureName;

  const ExportData(
      {super.key, required this.data, required this.procedureName});

  void saveAs(String fileType) {
    // Define MIME type based on file type
    MimeType mimeType = fileType == 'txt' ? MimeType.text : MimeType.csv;

    // Parse bytes according to file type
    Uint8List bytes;

    switch (fileType) {
      case 'txt':
        bytes = Uint8List.fromList(data
            .map((e) => '${e[0]}\t${e[1]}\n'.codeUnits)
            .expand((e) => e)
            .toList());
        break;
      case 'csv':
        bytes = Uint8List.fromList(data
            .map((e) => '${e[0]},${e[1]}\n'.codeUnits)
            .expand((e) => e)
            .toList());
        break;
      default:
        bytes = Uint8List(0);
    }

    // Save data as the specified file type
    FileSaver.instance.saveAs(
        name: '${DateTime.now()} - $procedureName',
        ext: fileType,
        mimeType: mimeType,
        bytes: bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            color: Colors.transparent,
            child: PaginatedDataTable(
              header: Text(AppLocalizations.of(context)!.exportData),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save_rounded),
                  onPressed: () {
                    // Open modal to select file type
                    showModalBottomSheet(
                      showDragHandle: true,
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(AppLocalizations.of(context)!.saveAs,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const SizedBox(height: 12.0),
                            ListTile(
                              title: const Text('TXT'),
                              leading: Icon(Icons.text_snippet_rounded,
                                  color: Theme.of(context).colorScheme.primary),
                              onTap: () {
                                // Save data as PDF
                                saveAs('txt');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('CSV'),
                              leading: Icon(Icons.file_copy_rounded,
                                  color: Theme.of(context).colorScheme.primary),
                              onTap: () {
                                // Save data as CSV
                                saveAs('csv');
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 12.0),
                          ],
                        );
                      },
                    );
                  },
                ),
                // Close button
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ],
              sortAscending: false,
              showCheckboxColumn: false,
              showFirstLastButtons: true,
              columns: [
                DataColumn(
                    label:
                        Text('${AppLocalizations.of(context)!.potential} (V)')),
                DataColumn(
                    label:
                        Text('${AppLocalizations.of(context)!.current} (A)')),
              ],
              source: _DataSource(context, data),
              // Calculate rows per page based on available size
              rowsPerPage: (MediaQuery.of(context).size.height / 70).floor(),
            ),
          );
        },
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final List<List<double>> data;

  _DataSource(this.context, this.data);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      return const DataRow(cells: []); // Return empty row (no data)
    }
    final row = data[index];
    return DataRow(cells: [
      DataCell(Text(row[0].toString())),
      DataCell(Text(row[1].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
