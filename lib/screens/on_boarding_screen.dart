import 'package:flutter/material.dart';
import 'package:trashindo/screens/log_in_screen.dart';
import 'package:trashindo/wigedts/on_boarding_wigedts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  final List<String> _title = [
    'Seqeorkan dalam Sekejap',
    'Jadi Bagian dari Perubahan'
    'Aksi Kecil, Dampak Besar'
  ];

  final List<String> _subtitle = [
    'Aplikasi TrashIndo membantumu melaporkan kondisi kotak sampah di sekitarmu secara cepat dan mudah',
    'Ambil foto kotak sampah, pilih lokasi, dan kirim laporan ke pihak berwenang hanya dalam beberapa langkah.',
    'Melalui setiap laporan, kamu membantu menciptakan lingkungan yang lebih bersih dan nyaman. Aksi kecilmu hari ini, dampak besarnya untuk esok.'
  ];
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDEE5AB),
              Color(0xFFFFFEFE),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _subtitle.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) => Stack(
                  children: [
                    Onborading_wigwedts(
                      image: 'assets/images/eart.png',
                      title: _title[index],
                      subtitle: _subtitle[index],
                    ),
                  ],
                ),
              ),
            ),
            // Tombol Next (opsional)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 1,
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (currentIndex <= 3)
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        _pageController.jumpToPage(3);
                                      },
                                      child: Text(
                                        "Skip",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Poppins',
                                            color: Color(0xFF000000)),
                                      )),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: List.generate(
                                        3,
                                        (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              width: currentIndex == index
                                                  ? 30
                                                  : 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Color(
                                                    currentIndex == index
                                                        ? 0xFF2D3600
                                                        : 0xFFDCE4A7),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        },
                                      )),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (currentIndex < _subtitle.length - 1) {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreens(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 30,
                                  ),
                                )
                              ])),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
