import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:res_reline/my_responsive.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       extendBody: true,
        body: RefreshIndicator(
          onRefresh: () async {

            return;
          },
          child:  CustomScrollView(
              scrollCacheExtent: ScrollCacheExtent.pixels(100),
              physics: const BouncingScrollPhysics(),
              slivers: [

                 SliverToBoxAdapter(child: SizedBox(height: 80.s)),
              ],
            ),
        ),
      ),
    );
  }
}
