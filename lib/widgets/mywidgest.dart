import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Widget buildLoading() {
  return Center(
    child: LoadingAnimationWidget.flickr(
      size: 200,
      leftDotColor: Colors.purple.shade200,
      rightDotColor: Colors.blueAccent.shade200,
    ),
  );
}

Widget buildNoConnectionMessage() {
  return const Center(
    child: Text(
      'Oops, no internet connection!',
      style: TextStyle(
        fontSize: 24,
        color: Colors.red,
      ),
    ),
  );
}

class contt extends StatelessWidget {
  const contt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade200,
            Colors.blueAccent.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class mysvg extends StatelessWidget {
  const mysvg({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1, // Adjust the opacity to make the SVG less intrusive
        child: Center(
          child: SvgPicture.asset(
            "assets/images/Google Ai Gemini.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 400.0,
            width: 400,
          ),
        ),
      ),
    );
  }
}
