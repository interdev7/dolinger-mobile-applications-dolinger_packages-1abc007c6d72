import 'package:dolinger_packages/dolinger_packages.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        return null;
      },
      builder: (context, child) {
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) {
                return const _ScreenStories();
              },
            );
          },
        );
      },
    );
  }
}

class _ScreenStories extends StatelessWidget {
  const _ScreenStories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StoriesList(
          storyContentFit: BoxFit.contain,
          stories: [
            StoriesModel(
              title: 'headline6',
              image:
                  'https://images.pexels.com/photos/27853682/pexels-photo-27853682.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
              video:
                  'https://videos.pexels.com/video-files/28348396/12364359_1920_1080_25fps.mp4',
              innerBanners: [
                StoriesModel(
                  title: 'headline6',
                  image:
                      'https://images.pexels.com/photos/27853682/pexels-photo-27853682.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  // video:
                  // 'https://videos.pexels.com/video-files/28348396/12364359_1920_1080_25fps.mp4',
                  innerBanners: [],
                  isShown: false,
                  screenTime: 10000,
                  description: 'description',
                  imageType: 'imageType',
                  buttonText: 'asdas',
                ),
                StoriesModel(
                  title: 'headline6',
                  image:
                      'https://images.pexels.com/photos/27853682/pexels-photo-27853682.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  video:
                      'https://videos.pexels.com/video-files/28348396/12364359_1920_1080_25fps.mp4',
                  innerBanners: [],
                  isShown: false,
                  screenTime: 10000,
                  description: 'description',
                  imageType: 'imageType',
                  buttonText: 'asdasfa',
                ),
              ],
              isShown: false,
              screenTime: 10000,
              description: 'description',
              imageType: 'imageType',
              buttonText: null,
            ),
          ],
        ),
      ),
    );
  }
}
