import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../profile/profile_blocs.dart';
import '../profile/profile_events.dart';
import '../profile/profile_states.dart';

class InterestPage extends StatefulWidget {
  final String accessToken;
  final List<String> initialInterests; // Add this line

  InterestPage({
    required this.accessToken,
    required this.initialInterests, // Add this line
  });

  @override
  _InterestPageState createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  TextEditingController _interestController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00211d),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () async {

              // Get the accessToken from the widget's property
              final accessToken = widget.accessToken;
              final updatedProfileData = {
                "interests": widget.initialInterests,
              };

              // Dispatch the UpdateProfile event to the ProfileBloc
              BlocProvider.of<ProfileBloc>(context).add(UpdateProfile(
                accessToken: accessToken,
                updatedProfileData: updatedProfileData,
              ));


              await BlocProvider.of<ProfileBloc>(context)
                  .stream
                  .firstWhere((state) => state is ProfileUpdated); // Add this line


              // Go back to the previous page (ProfilePage)
              Navigator.pop(context, widget.initialInterests);

            },
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds);
        },
        child: Text(
          'Save',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 10),
              child: RichText(
                text: TextSpan(
                  text: 'Tell everyone about yourself',
                  // Apply the gradient color to the text
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold).copyWith(
                    foreground: Paint()..shader = LinearGradient(
                      colors: [Colors.white, Color(0xFFDAA520)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            Container(
              padding: EdgeInsets.only(left: 10),
              child: RichText(
                text: TextSpan(
                  text: 'What interest you?',
                  // Apply the gradient color to the text
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
       TextField(
          controller: _interestController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
              onSubmitted: (value) {
                setState(() {
                  widget.initialInterests.add(value);
                  _interestController.clear();
                });
              },
        ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.initialInterests.map((interest) {
                return Chip(
                  label: Text(interest),
                  onDeleted: () {
                    setState(() {
                      widget.initialInterests.remove(interest);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}