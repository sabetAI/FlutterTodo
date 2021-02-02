import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/DummyData.dart';
import 'package:todo/CustomIcons.dart';
import 'package:todo/objects/TodoObject.dart';
import 'package:todo/pages/Details.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(tabs: todos);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ScrollController scrollController;
  Color backgroundColor;
  LinearGradient backgroundGradient;
  Tween<Color> colorTween;
  int currentPage = 0;
  Color constBackColor;

  List<TabData> tabs;

  _HomePageState({this.tabs});

  @override
  void initState() {
    super.initState();
    colorTween = ColorTween(begin: tabs[0].color, end: tabs[0].color);
    backgroundColor = tabs[0].color;
    backgroundGradient = tabs[0].gradient;
    scrollController = ScrollController();
    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
//      ScrollDirection direction = position.userScrollDirection;
      int page = position.pixels ~/
          (position.maxScrollExtent / (tabs.length.toDouble() - 1));
      double pageDo = (position.pixels /
          (position.maxScrollExtent / (tabs.length.toDouble() - 1)));
      double percent = pageDo - page;
      if (tabs.length - 1 < page + 1) {
        return;
      }
      colorTween.begin = tabs[page].color;
      colorTween.end = tabs[page + 1].color;
      setState(() {
        backgroundColor = colorTween.transform(percent);
        backgroundGradient =
            tabs[page].gradient.lerpTo(tabs[page + 1].gradient, percent);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void removeTab(TabData tab) {
    setState(() {
      tabs.where((e) => e.uuid != tab.uuid).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomNavBar(),
        appBar:
            PreferredSize(preferredSize: Size.fromHeight(60), child: TopBar()),
        body: GridView.builder(
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          scrollDirection: Axis.vertical,
          physics: _CustomScrollPhysics(),
          controller: scrollController,
          shrinkWrap: true,
          itemCount: 6,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
          itemBuilder: tabBuilder,
        ),
      ),
    );
  }

  Widget tabBuilder(context, index) {
    TabData tab = tabs[index];
    double percentComplete = tab.percentComplete();

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                DetailPage(todoObject: tab),
            transitionDuration: Duration(milliseconds: 1000),
          ),
        );
      },
      child: TabBox(
        tab: tab,
        percentComplete: percentComplete,
        removeTabCallback: removeTab,
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            child: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
          )),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
          ),
          child: BottomAppBar(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(CustomIcons.menu),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(CustomIcons.search),
                onPressed: () {},
              )
            ],
          )),
        ));
  }
}

class TabBox extends StatelessWidget {
  const TabBox({
    Key key,
    @required this.tab,
    @required this.percentComplete,
    @required this.removeTabCallback,
  }) : super(key: key);

  final TabData tab;
  final double percentComplete;
  final void Function(TabData) removeTabCallback;

  List<Widget> buildTabContent() {
    return <Widget>[
      TabContent(tab: tab, removeTabCallback: removeTabCallback),
      Hero(
        tag: tab.uuid + "_number_of_tasks",
        child: Material(
            color: Colors.transparent,
            child: Text(
              tab.taskAmount().toString() + " Tasks",
              style: TextStyle(),
              softWrap: false,
            )),
      ),
      Spacer(),
      Hero(
        tag: tab.uuid + "_title",
        child: Material(
          color: Colors.transparent,
          child: Text(
            tab.title,
            style: TextStyle(fontSize: 30.0),
            softWrap: false,
          ),
        ),
      ),
      Spacer(),
      Hero(
        tag: tab.uuid + "_progress_bar",
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: <Widget>[
              Expanded(
                child: LinearProgressIndicator(
                  value: percentComplete,
                  backgroundColor: Colors.grey.withAlpha(50),
                  valueColor: AlwaysStoppedAnimation<Color>(tab.color),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text((percentComplete * 100).round().toString() + "%"),
              )
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(70),
                  offset: Offset(3.0, 10.0),
                  blurRadius: 15.0)
            ]),
        height: 250.0,
        child: Stack(children: <Widget>[
          Hero(
            tag: tab.uuid + "_background",
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildTabContent(),
              ))
        ]));
  }
}

class TabContent extends StatelessWidget {
  const TabContent({
    Key key,
    @required this.tab,
    @required this.removeTabCallback,
  }) : super(key: key);

  final void Function(TabData) removeTabCallback;
  final TabData tab;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TabPage(todoObject: tab),
          Spacer(),
          Hero(
            tag: tab.uuid + "_more_vert",
            child: Material(
              color: Colors.transparent,
              type: MaterialType.transparency,
              child: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                itemBuilder: popUpMenuBuilder,
                onSelected: (setting) {
                  tabPopUpMenuOptions(setting, tab);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<TodoCardSettings>> popUpMenuBuilder(context) =>
      <PopupMenuEntry<TodoCardSettings>>[
        PopupMenuItem(
          child: Text("Edit Color"),
          value: TodoCardSettings.edit_color,
        ),
        PopupMenuItem(
          child: Text("Delete"),
          value: TodoCardSettings.delete,
        ),
      ];

  void tabPopUpMenuOptions(TodoCardSettings setting, tab) {
    switch (setting) {
      case TodoCardSettings.edit_color:
        print("edit color clicked");
        break;
      case TodoCardSettings.delete:
        print("delete clicked");
        removeTabCallback(tab.uuid);
        break;
    }
  }
}

class TabPage extends StatelessWidget {
  const TabPage({
    Key key,
    @required this.todoObject,
  }) : super(key: key);

  final TabData todoObject;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Hero(
          tag: todoObject.uuid + "_backIcon",
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              height: 10,
              width: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: null,
              ),
            ),
          ),
        ),
        Hero(
          tag: todoObject.uuid + "_icon",
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.grey.withAlpha(70),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(todoObject.icon, color: todoObject.color),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomScrollPhysics extends ScrollPhysics {
  _CustomScrollPhysics({
    ScrollPhysics parent,
  }) : super(parent: parent);

  @override
  _CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _CustomScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels /
        (position.maxScrollExtent / (todos.length.toDouble() - 1));
    // return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    // return page * position.viewportDimension;
    return page * (position.maxScrollExtent / (todos.length.toDouble() - 1));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }
}
