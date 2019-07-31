import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:ui_practice/size_config.dart';

class StartUp extends StatefulWidget {
  @override
  _StartUpState createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {
  static const SCALE_FRACTION = 0.8;
  static const FULL_SCALE = 1.0;
  double page = 0.0;

  AutoScrollController controller = AutoScrollController();
  bool dragTargetVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 100.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 300.0,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification) {
                    setState(() {
                      page = controller.offset / (SizeConfig.screenWidth - 80);
                    });
                  }
                },
                child: ListView.builder(
                  itemCount: 10,
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final scale = max(SCALE_FRACTION,
                        (FULL_SCALE - (index - page).abs()) + 0.8);
                    return AutoScrollTag(
                        key: ValueKey(index),
                        index: index,
                        controller: controller,
                        child: dragWidget(scale, index));
                  },
                ),
              ),
            ),
            dragTarget(),
          ],
        ),
      ),
    );
  }

  Widget dragWidget(double scale, int index) {
    return Center(
      child: Draggable(
        affinity: Axis.vertical,
        child: containerWidget(scale, index),
        feedback: containerWidget(scale, index),
        data: index.toString(),
        childWhenDragging: Opacity(
          opacity: 0.0,
          child: containerWidget(scale, index),
        ),
        onDragStarted: () {
          setState(() {
            dragTargetVisible = true;
          });
        },
        onDragCompleted: () {
          setState(() {
            dragTargetVisible = false;
          });
        },
        onDragEnd: (d) {
          setState(() {
            dragTargetVisible = false;
          });
        },
        maxSimultaneousDrags: 1,
        axis: Axis.vertical,
        dragAnchor: DragAnchor.child,
      ),
    );
  }

  Widget dragTarget() {
    print("drag target indx");
    print(page.floor().toString());
    return Flexible(
      child: DragTarget(
        onAccept: (data) {
          print(data);
          print("accepted");
          setState(() {
            dragTargetVisible = false;
          });
        },
        onLeave: (data) {
          print("leave");
          setState(() {
            dragTargetVisible = false;
          });
        },
        onWillAccept: (data) {
          print("onWillAccept");
          return data.toString() == page.floor().toString() ? true : false;
        },
        builder: (BuildContext context, List<String> a, b) {
          return Visibility(
            visible: dragTargetVisible,
            child: Container(
              width: SizeConfig.screenWidth,
              child: Opacity(
                opacity: 0,
                child: Container(
                  height: 200.0,
                  width: SizeConfig.screenWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget containerWidget(double scale, int index) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        child: Container(
          height: 100.0 * scale,
          width: SizeConfig.screenWidth - 80,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Image.asset(
              'assets/vegeta.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        onTap: () {
          controller.scrollToIndex(index,
              preferPosition: AutoScrollPosition.middle,
              duration: Duration(milliseconds: 600));
        },
      ),
    );
  }
}