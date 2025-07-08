import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_guru_all/src/models/requirementsModel.dart';
import '../src.dart';
import '../utils/colors.dart';

class RequirementsScreen extends StatefulWidget {
  final String? name;
  const RequirementsScreen({
    this.name,
    Key? key,
  }) : super(key: key);

  @override
  _RequirementsScreenState createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        AsyncValue<List<RequirementsModel>> requirementsData =
            ref.watch(fetchRequirementsData);
        return SafeArea(
          child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.white,
                title: Text(
                  widget.name!,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
              body: requirementsData.when(data: (data) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    if (data[index].name == widget.name) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Html(
                          data: data[index].data!,
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                );
              }, error: (e, s) {
                return Text(s.toString());
              }, loading: () {
                return Text('Fetching');
              })),
        );
      },
    );
  }
}
