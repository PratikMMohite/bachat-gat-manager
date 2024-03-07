import 'package:flutter/material.dart';

import '../../dao/dao_index.dart';
import '../../models/models_index.dart';
import '../pdf/excel/excel_example.dart';
import '../pdf/pdf_api.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport(this.group, this.members, this.intitalName, {super.key});
  final Group group;
  final List<GroupMember> members;
  final String intitalName;

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  late Group _group;
  late List<GroupMember> _members;
  late String selectedMemberId;
  late List<MemberTransactionDetails> memberData;
  late String selectedMemberName;
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now();

  String _formattDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _members = widget.members;
    selectedMemberId = _members.isEmpty ? "" : _members[0].id;
    selectedMemberName = _members.isEmpty ? " " : _members[0].name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yearly Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            // Date Pickers for Start and End Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        label: Text(_formattDate(_startDate)),
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime(_startDate.year, _startDate.month, 1),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _startDate) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _endDate) {
                            setState(() {
                              _endDate = picked;
                            });
                          }
                        },
                        label: Text(_formattDate(_endDate)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Download Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      ExcelExample.createAndSaveExcel(_group.id.toString(),
                          _formattDate(_startDate), _formattDate(_endDate));
                    },
                    label: const Text('Download Excel File'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      final dao = GroupsDao();
                      final data = await dao.getMemberDetailsByMemberId(
                          selectedMemberId,
                          _group.id,
                          _formattDate(_startDate),
                          _formattDate(_endDate));
                      if (data.isNotEmpty) {
                        var bytes = await PdfApi.generateTable(
                            data, selectedMemberName, _group.name.toString());
                        await PdfApi.previewPDF(bytes);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "There are no transaction between this period for the member please change the time period",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    label: const Text('Preview'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
