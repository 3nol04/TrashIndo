import 'dart:async';
import 'package:flutter/material.dart';

class Corousel extends StatefulWidget {
  const Corousel({super.key});

  @override
  State<Corousel> createState() => _CorouselState();
}

class _CorouselState extends State<Corousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _curentIndex = 0;
  final List<String> _linksImage = [
    'https://cdn.thezebra.com/zfront/media/production/images/hero-sustainable-cities-new-york-city-skylin.format-jpeg.jpg',
    'https://mir-s3-cdn-cf.behance.net/project_modules/1400/64220114061041.5627c9fe24e00.jpg',
    'https://as1.ftcdn.net/v2/jpg/05/39/68/24/1000_F_539682434_tP6yFmNpXIdXM9tq8izpxloyvQXeEb3R.jpg',
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.addListener(() {
        setState(() {
          _curentIndex = _pageController.page!.round();
        });
      });
    });
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_curentIndex < _linksImage.length - 1) {
        _curentIndex++;
      } else {
        _curentIndex = 0;
      }
      _pageController.animateToPage(
        _curentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(() {});
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _linksImage.length,
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _linksImage[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 1,
          left: 10,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.87,
            height: MediaQuery.of(context).size.height * 0.04,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(_linksImage.length, (idex) {
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _curentIndex == idex ? 15 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(
                            _curentIndex == idex ? 0xFF90A105 : 0xFFBDBDBD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
