import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class NewJobForm extends StatefulWidget {
  const NewJobForm({Key? key}) : super(key: key);

  @override
  _NewJobFormState createState() => _NewJobFormState();
}

class _NewJobFormState extends State<NewJobForm> {
  // State
  String state = '0';
  String _selectedState = 'Select State';
  String district = '0';
  String _selectedDistrict = 'Select District';
  String landmark = '0';
  String _selectedLandmark = 'Select Landmark';

  String category = '0';
  String _selectCategory = 'Select Category';

  List<Tag> tags = [];
  final _selectedTags = StateProvider<List<String>>((ref) => []);
  List<String> ids = [];
  bool tagsValidator = false;

  String jobType = '0';
  String _selectJobType = 'Select Job Type';

  final HtmlEditorController _controller = HtmlEditorController();
  String _jobdescription = '';
  bool jobDescription = false;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _vacancies = TextEditingController();
  final TextEditingController _qualification = TextEditingController();
  final TextEditingController _salary = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _contactdetails = TextEditingController();
  final TextEditingController _shortDescription = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        AsyncValue<List<LocationModel>> location =
            ref.watch(fetchLocation); //Location
        AsyncValue<NewJobModel> job = ref.watch(jobData);
        ref.watch(_selectedTags);
        return Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left_rounded,
                color: Colors.black,
              ),
            ),
            title: Text(
              'Add Job',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 15,
                    ),
                    child: Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        wordSpacing: 1,
                      ),
                    ),
                  ),
                  location.when(
                    data: (locationData) {
                      // States
                      List<LocationModel> states = [];
                      states.add(
                        LocationModel(
                          id: '0',
                          english: 'Select State',
                        ),
                      );
                      locationData.map((e) => states.add(e)).toList();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                elevation: 0,
                                isExpanded: true,
                                focusColor: Colors.red,
                                value: _selectedState,
                                selectedItemBuilder: (BuildContext context) {
                                  return states
                                      .map<Widget>((LocationModel item) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                        // top: 15,
                                        left: 10,
                                        right: 10,
                                        // bottom: 5,
                                      ),
                                      child: Text(
                                        item.english!,
                                      ),
                                    );
                                  }).toList();
                                },
                                items: states.map((LocationModel value) {
                                  return DropdownMenuItem<String>(
                                    value: value.english!,
                                    onTap: () {
                                      if (value.english != "Select State") {
                                        setState(() {
                                          state = value.id!;
                                        });
                                        ref.read(getDistricts.notifier).state =
                                            [];
                                        ref
                                            .read(getDistricts.notifier)
                                            .state
                                            .add(District(
                                                id: '0',
                                                english: 'Select District'));
                                        value.districts!
                                            .map((e) => ref
                                                .read(getDistricts.notifier)
                                                .state
                                                .add(e))
                                            .toList();
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: value.english! == _selectedState
                                          ? Colors.red
                                          : Colors.white,
                                      padding: const EdgeInsets.all(10),
                                      child: new Text(
                                        value.english!,
                                        style: TextStyle(
                                          color:
                                              value.english! == _selectedState
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                validator: (v) {
                                  if (v == 'Select State') {
                                    return 'Select State';
                                  }
                                },
                                onChanged: (String? string) {
                                  setState(() {
                                    _selectedState = string!;

                                    _selectedDistrict = 'Select District';
                                    _selectedLandmark = 'Select Landmark';
                                  });
                                },
                                dropdownColor: Colors.white,
                              ),
                            ),

                            // District
                            _selectedState == 'Select State'
                                ? SizedBox.shrink()
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.5,
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      elevation: 0,
                                      isExpanded: true,
                                      focusColor: Colors.red,
                                      value: _selectedDistrict,
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return ref
                                            .watch(getDistricts.notifier)
                                            .state
                                            .map<Widget>((District item) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                              // top: 15,
                                              left: 10,
                                              right: 10,
                                              // bottom: 5,
                                            ),
                                            child: Text(
                                              item.english!,
                                            ),
                                          );
                                        }).toList();
                                      },
                                      items: ref
                                          .watch(getDistricts.notifier)
                                          .state
                                          .map((District value) {
                                        return DropdownMenuItem<String>(
                                          value: value.english!,
                                          onTap: () {
                                            if (value.english !=
                                                "Select District") {
                                              setState(() {
                                                district = value.id!;
                                              });

                                              ref
                                                  .read(getLandmarks.notifier)
                                                  .state = [];
                                              ref
                                                  .read(getLandmarks.notifier)
                                                  .state
                                                  .add(Landmark(
                                                      id: '0',
                                                      english:
                                                          'Select Landmark'));
                                              value.landmarks!
                                                  .map((e) => ref
                                                      .read(
                                                          getLandmarks.notifier)
                                                      .state
                                                      .add(e))
                                                  .toList();
                                            }
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: value.english! ==
                                                    _selectedDistrict
                                                ? Colors.red
                                                : Colors.white,
                                            padding: const EdgeInsets.all(10),
                                            child: new Text(
                                              value.english!,
                                              style: TextStyle(
                                                color: value.english! ==
                                                        _selectedDistrict
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      validator: (v) {
                                        if (v == 'Select District') {
                                          return 'Select District';
                                        }
                                      },
                                      onChanged: (String? string) {
                                        setState(() {
                                          _selectedDistrict = string!;
                                          _selectedLandmark = 'Select Landmark';
                                        });
                                      },
                                      dropdownColor: Colors.white,
                                    ),
                                  ),

                            // Landmark
                            _selectedState == 'Select State' ||
                                    _selectedDistrict == 'Select District'
                                ? SizedBox.shrink()
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.5,
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      elevation: 0,
                                      isExpanded: true,
                                      focusColor: Colors.red,
                                      value: _selectedLandmark,
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return ref
                                            .watch(getLandmarks.notifier)
                                            .state
                                            .map<Widget>((Landmark item) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                              // top: 15,
                                              left: 10,
                                              right: 10,
                                              // bottom: 5,
                                            ),
                                            child: Text(
                                              item.english!,
                                            ),
                                          );
                                        }).toList();
                                      },
                                      items: ref
                                          .watch(getLandmarks.notifier)
                                          .state
                                          .map((Landmark value) {
                                        return DropdownMenuItem<String>(
                                          value: value.english!,
                                          onTap: () {
                                            if (value.english !=
                                                'Select Landmark') {
                                              setState(() {
                                                landmark = value.id!;
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: value.english! ==
                                                    _selectedLandmark
                                                ? Colors.red
                                                : Colors.white,
                                            padding: const EdgeInsets.all(10),
                                            child: new Text(
                                              value.english!,
                                              style: TextStyle(
                                                color: value.english! ==
                                                        _selectedLandmark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      validator: (v) {
                                        if (v == 'Select Landmark') {
                                          return 'Select Landmark';
                                        }
                                      },
                                      onChanged: (String? string) {
                                        setState(() {
                                          _selectedLandmark = string!;
                                        });
                                      },
                                      dropdownColor: Colors.white,
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                    loading: () => Text(
                      "Fetching Topics...",
                      style: TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    error: (e, s) => Text(
                      "Error",
                      style: TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ),
                  // -----Category-----
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: job.when(
                      data: (jobContent) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                elevation: 0,
                                isExpanded: true,
                                focusColor: Colors.red,
                                value: _selectCategory,
                                selectedItemBuilder: (BuildContext context) {
                                  return jobContent.categories!
                                      .map<Widget>((Category item) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                        // top: 15,
                                        left: 10,
                                        right: 10,
                                        // bottom: 5,
                                      ),
                                      child: Text(
                                        item.category!,
                                      ),
                                    );
                                  }).toList();
                                },
                                items: jobContent.categories!
                                    .map((Category value) {
                                  return DropdownMenuItem<String>(
                                    value: value.category!,
                                    onTap: () {
                                      if (value.category != 'Select Category') {
                                        setState(() {
                                          category = value.id!;
                                          tags = [];
                                          ref
                                              .read(_selectedTags.notifier)
                                              .state = [];
                                        });
                                        value.tags!
                                            .map((e) => tags.add(e))
                                            .toList();
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: value.category! == _selectCategory
                                          ? Colors.red
                                          : Colors.white,
                                      padding: const EdgeInsets.all(10),
                                      child: new Text(
                                        value.category!,
                                        style: TextStyle(
                                          color:
                                              value.category == _selectCategory
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                validator: (v) {
                                  if (v == 'Select Category') {
                                    return 'Select Category';
                                  }
                                },
                                onChanged: (String? string) {
                                  setState(() {
                                    _selectCategory = string!;
                                  });
                                },
                                dropdownColor: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Skills',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            InkWell(
                              onTap: () {
                                for (int i = 0;
                                    i <
                                        ref
                                            .read(_selectedTags.notifier)
                                            .state
                                            .length;
                                    i++) {
                                  ids.add(ref
                                      .read(_selectedTags.notifier)
                                      .state[i]);
                                  setState(() {});
                                }
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          content: Wrap(
                                            children: tags.map((tag) {
                                              return Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: InkWell(
                                                  onTap: () {
                                                    if (ids.contains(tag.id)) {
                                                      setState(() {
                                                        ids.remove(tag.id!);
                                                      });
                                                    } else {
                                                      setState(() {
                                                        ids.add(tag.id!);
                                                      });
                                                    }
                                                  },
                                                  child: Chip(
                                                    backgroundColor: ids
                                                            .contains(tag.id!)
                                                        ? Colors.red
                                                        : Colors.grey
                                                            .withOpacity(0.1),
                                                    label: Text(
                                                      tag.name!,
                                                      style: TextStyle(
                                                        color: ids.contains(
                                                                tag.id!)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          scrollable: true,
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  ids = [];
                                                });
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              child: Text('cancle'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                        _selectedTags.notifier)
                                                    .state = ids;
                                                ids = [];
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              child: Text('Select'),
                                            ),
                                          ],
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          title: Text(
                                            'Select Skills',
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Select Skills',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            tagsValidator
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'Select Skills',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            Wrap(
                              children: tags.map((e) {
                                if (ref
                                    .read(_selectedTags.notifier)
                                    .state
                                    .contains(e.id)) {
                                  return GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(_selectedTags.notifier)
                                          .state
                                          .remove(e.id);

                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Chip(
                                        backgroundColor: Colors.red,
                                        label: Text(
                                          e.name!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                            wordSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }).toList(),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            // Salary
                            Text(
                              'Salary',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Salary',
                                  border: OutlineInputBorder(),
                                ),
                                validator: RequiredValidator(
                                  errorText: 'Enter Salary',
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                controller: _salary,
                              ),
                            ),

                            // Job Type
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Job Type',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                elevation: 0,
                                isExpanded: true,
                                focusColor: Colors.red,
                                value: _selectJobType,
                                validator: (v) => (v == "Select Job Type")
                                    ? 'Select Job Type'
                                    : null,

                                selectedItemBuilder: (BuildContext context) {
                                  return jobContent.types!
                                      .map<Widget>((Type item) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: Text(
                                        item.jobtype!,
                                      ),
                                    );
                                  }).toList();
                                },
                                items: jobContent.types!.map((Type value) {
                                  return DropdownMenuItem<String>(
                                    value: value.jobtype!,
                                    onTap: () {
                                      jobType = value.id!;
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: value.jobtype! == _selectJobType
                                          ? Colors.red
                                          : Colors.white,
                                      padding: const EdgeInsets.all(10),
                                      child: new Text(
                                        value.jobtype!,
                                        style: TextStyle(
                                          color: value.jobtype == _selectJobType
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? string) {
                                  setState(() {
                                    _selectJobType = string!;
                                  });
                                },
                                // underline: SizedBox(),
                                dropdownColor: Colors.white,
                              ),
                            ),

                            // Title
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Title',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Title',
                                  border: OutlineInputBorder(),
                                ),
                                validator: RequiredValidator(
                                  errorText: 'Enter Title',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                controller: _title,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            // Number of Hires
                            Text(
                              'No of Hires',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Vacancies',
                                  border: OutlineInputBorder(),
                                ),
                                validator: RequiredValidator(
                                  errorText: 'Enter Vacancies',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                controller: _vacancies,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            // Required Qualification
                            Text(
                              'Required Qualification',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Qualification',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: null,
                                validator: RequiredValidator(
                                  errorText: 'Enter Qualification',
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                controller: _qualification,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            // Location
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Location',
                                  border: OutlineInputBorder(),
                                ),
                                validator: RequiredValidator(
                                  errorText: 'Enter Location',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                controller: _location,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            // Contact
                            Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Contact Details',
                                  border: OutlineInputBorder(),
                                ),
                                validator: RequiredValidator(
                                  errorText: 'Enter Contact Details',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                controller: _contactdetails,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Contact
                            Text(
                              'Short Description',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter Short Description',
                                  border: OutlineInputBorder(),
                                ),
                                validator: RequiredValidator(
                                  errorText: 'Enter Short Description',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                controller: _shortDescription,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Job Description',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                wordSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            HtmlEditor(
                              controller: _controller,
                              htmlEditorOptions: HtmlEditorOptions(
                                initialText: _jobdescription,
                                hint: 'Enter Your Data....',
                              ),
                              htmlToolbarOptions: HtmlToolbarOptions(
                                toolbarType: ToolbarType.nativeGrid,
                              ),
                              otherOptions: OtherOptions(
                                height: 500,
                              ),
                            ),
                            jobDescription
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'Enter Job Description',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (ref
                                              .read(_selectedTags.notifier)
                                              .state
                                              .length ==
                                          0) {
                                        setState(() {
                                          tagsValidator = true;
                                        });
                                      } else {
                                        tagsValidator = false;
                                      }
                                      await _controller.getText().then((value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            jobDescription = true;
                                          });
                                        } else {
                                          setState(() {
                                            jobDescription = false;
                                          });

                                          ref
                                              .read(
                                                  jobsPaginationControllerProvider
                                                      .notifier)
                                              .addnewJob(
                                                state,
                                                district,
                                                landmark,
                                                category,
                                                ref
                                                    .read(
                                                        _selectedTags.notifier)
                                                    .state
                                                    .join(','),
                                                _salary.text,
                                                jobType,
                                                _title.text,
                                                _vacancies.text,
                                                _qualification.text,
                                                _location.text,
                                                _contactdetails.text,
                                                _shortDescription.text,
                                                value,
                                              )
                                              .then((value) {
                                            Navigator.of(context).pop();
                                          });
                                        }
                                      });
                                    }
                                  },
                                  child: const Text(
                                    'Add Job',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Text(
                        "Fetching Data...",
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                      error: (e, s) => Text(
                        "Error",
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
