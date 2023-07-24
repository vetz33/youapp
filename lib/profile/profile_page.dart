import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:youapptest/profile/profile_blocs.dart';
import 'package:youapptest/profile/profile_events.dart';
import 'package:youapptest/profile/profile_states.dart';

import '../interest/interest_page.dart';


class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isProfileLoaded = false;
  bool isFilled = false;


  TextEditingController _nameController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _zodiacController = TextEditingController();
  TextEditingController _horoscopeController = TextEditingController();
  String _selectedGender = 'Male';
  List<String> interests = [];

  File? _pickedImage;

  void _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  int _calculateAge(String birthday) {
    DateTime currentDate = DateTime.now();
    DateTime parsedBirthday = intl.DateFormat('dd/MM/yyyy').parse(birthday);
    int age = currentDate.year - parsedBirthday.year;
    if (currentDate.month < parsedBirthday.month ||
        (currentDate.month == parsedBirthday.month &&
            currentDate.day < parsedBirthday.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final accessToken = ModalRoute.of(context)!.settings.arguments as String?;
    if (accessToken != null) {
      BlocProvider.of<ProfileBloc>(context).add(FetchProfileData(accessToken: accessToken));
    }
    return Scaffold(
      backgroundColor: Color(0xff00211d),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Center(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return Text(state.username, style: TextStyle(color: Colors.white),);
              } else {
                return Text('Profile');
              }
            },
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileUI(state.username, state.email);
          } else if (state is ProfileFailure) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is ProfileUpdated) {

            return Center(child: Text('Profile updated successfully!'));
          } else if (state is ProfileCreated) {

            return Center(child: Text('Profile created successfully!'));
          } else {

            return Center(child: Text('Loading profile...'));
          }
        },
      ),
    );
  }

  Widget _buildProfileUI(String username, String email) {
    return  SingleChildScrollView(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
            height: 200,
            margin: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _pickedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                else
                 SizedBox(),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: isFilled
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${_nameController.text}, ${_calculateAge(_birthdayController.text)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _selectedGender,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                _horoscopeController.text,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black87,
                            ),
                            Chip(
                              label: Text(
                                _zodiacController.text,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black87,
                            ),
                          ],
                        ),
                      ],
                    )
                        : Text(
                      username,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          isEditing ? _buildEditForm() : _buildAboutSection(
            name: _nameController.text,
            birthday: _birthdayController.text,
            height: _heightController.text,
            weight: _weightController.text,
            zodiac: _zodiacController.text,
            horoscope: _horoscopeController.text,
            gender: _selectedGender,),
          SizedBox(height: 10,),
          _buildInterestSection(),
        ],
      ),
    );

  }

  Widget _buildAboutSection({
    required String name,
    required String birthday,
    required String height,
    required String weight,
    required String zodiac,
    required String horoscope,
    required String gender,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(left: 30, right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
         isFilled! ? ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildAboutField('Birthday', '$birthday (Age ${_calculateAge(birthday)})'),
              _buildAboutField('Height', height),
              _buildAboutField('Weight', weight),
              _buildAboutField('Zodiac', zodiac),
              _buildAboutField('Horoscope', horoscope),
            ],
          ) : Text("Add in your profile to help others know you better", style: TextStyle(color: Colors.grey),),
          SizedBox(height: 20,)
        ],
      ),
    );
  }

  Widget _buildAboutField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }


  Widget _buildInterestSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(left: 30, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Interest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    final accessToken = ModalRoute.of(context)!.settings.arguments as String?;
                    if (accessToken != null) {
                      _navigateToInterestPage(interests, accessToken);
                    }
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (interests.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Add in your interest to find a better match',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (interests.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    final interest = interests[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(interest),
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _navigateToInterestPage(List<String> interests, String accessToken) async {
    final updatedInterests = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => InterestPage(
          accessToken: accessToken,
          initialInterests: interests,
        ),
      ),
    );

    if (updatedInterests != null) {
      setState(() {
        interests = updatedInterests;
      });
    }
  }


  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _addImage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_pickedImage == null)
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _pickedImage == null ? Colors.white.withOpacity(0.5) : Colors.transparent,
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: _addImage,
                            child: Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addImage,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Add Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 175,
                  child: Text('Name:', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Birthday:', style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (selectedDate != null) {
                        String formattedDate = intl.DateFormat('dd/MM/yyyy').format(selectedDate);

                        setState(() {
                          _birthdayController.text = formattedDate;
                        });

                        int day = selectedDate.day;
                        int month = selectedDate.month;
                        int year = selectedDate.year;
                        String zodiac = _getZodiac(month, day);
                        String horoscope = _getHoroscope(year);

                        setState(() {
                          _zodiacController.text = zodiac;
                          _horoscopeController.text = horoscope;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _birthdayController,
                        onEditingComplete: () {
                          List<String> dateComponents = _birthdayController.text.split('/');
                          if (dateComponents.length == 3) {
                            int day = int.tryParse(dateComponents[0]) ?? 0;
                            int month = int.tryParse(dateComponents[1]) ?? 0;
                            int year = int.tryParse(dateComponents[2]) ?? 0;

                            String zodiac = _getZodiac(day, month);
                            String horoscope = _getHoroscope(year);

                            setState(() {
                              _zodiacController.text = zodiac;
                              _horoscopeController.text = horoscope;
                            });
                          }
                        },
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          hintText: 'dd/mm/yyyy',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Gender:', style: TextStyle(color: Colors.grey),),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        dropdownColor: Colors.white,
                        underline: SizedBox(),
                        icon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Zodiac:', style: TextStyle(color: Colors.grey),),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _zodiacController,
                      enabled: false,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        hintText: '--',
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Horoscope:', style: TextStyle(color: Colors.grey),),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _horoscopeController,
                      enabled: false,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        hintText: '--',
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Height:', style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _heightController,
                      onEditingComplete: () {
                        String heightValue = _heightController.text.trim();
                        if (heightValue.isNotEmpty) {
                          setState(() {
                            _heightController.text = '$heightValue cm';
                          });
                        }
                      },
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        hintText: 'Add height',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Weight:', style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _weightController,
                      onEditingComplete: () {
                        String weightValue = _weightController.text.trim();
                        if (weightValue.isNotEmpty) {
                          setState(() {
                            _weightController.text = '$weightValue kg';
                          });
                        }
                      },
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        hintText: 'Add weight',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (isProfileLoaded) {
                  final updatedProfileData = {
                    "name": _nameController.text,
                    "birthday": _birthdayController.text,
                    "height": int.parse(_heightController.text),
                    "weight": int.parse(_weightController.text),
                    "zodiac": _zodiacController.text,
                    "horoscope": _horoscopeController.text,
                    "gender": _selectedGender,
                  };
                  final accessToken = ModalRoute.of(context)!.settings.arguments as String?;
                  if (accessToken != null) {
                    BlocProvider.of<ProfileBloc>(context).add(UpdateProfile(
                      accessToken: accessToken,
                      updatedProfileData: updatedProfileData,
                    ));
                  }
                } else {
                  try {
                    final profileData = {
                      "name": _nameController.text,
                      "birthday": _birthdayController.text,
                      "height": int.parse(_heightController.text),
                      "weight": int.parse(_weightController.text),
                      "zodiac": _zodiacController.text,
                      "horoscope": _horoscopeController.text,
                      "gender": _selectedGender,
                    };
                    final accessToken = ModalRoute.of(context)!.settings.arguments as String?;
                    if (accessToken != null) {
                      BlocProvider.of<ProfileBloc>(context).add(CreateProfile(
                        accessToken: accessToken,
                        profileData: profileData,
                      ));
                    }
                  } catch(error) {
                    print('CreateProfile Error: $error');
                  }
                }
                setState(() {
                  isEditing = false;
                  isProfileLoaded = true;
                  isFilled = true;
                });
              },
              child: Text(isProfileLoaded ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

}

String _getZodiac(int day, int month) {
  String horoscope = '';

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
    horoscope = 'Aries';
  } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
    horoscope = 'Taurus';
  } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
    horoscope = 'Gemini';
  } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
    horoscope = 'Cancer';
  } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
    horoscope = 'Leo';
  } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
    horoscope = 'Virgo';
  } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
    horoscope = 'Libra';
  } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    horoscope = 'Scorpio';
  } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    horoscope = 'Sagittarius';
  } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    horoscope = 'Capricorn';
  } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    horoscope = 'Aquarius';
  } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
    horoscope = 'Pisces';
  }

  return horoscope;
}

String _getHoroscope(int year) {
  const zodiacSigns = [
    'Monkey', 'Rooster', 'Dog', 'Pig', 'Rat', 'Ox',
    'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Goat'
  ];

  int baseYear = 1900;

  int zodiacIndex = (year - baseYear) % zodiacSigns.length;
  return zodiacSigns[zodiacIndex];
}