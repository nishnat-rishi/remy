import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:proto_1/app_state.dart';
import 'package:proto_1/modified_defaults/my_reorderable_list.dart';
import 'package:proto_1/modified_defaults/my_dismissible.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.white,
        textTheme: TextTheme(
            body1: TextStyle(color: Colors.white),
            body2: TextStyle(color: Colors.white),
            headline: TextStyle(color: Colors.white),
            title: TextStyle(color: Colors.white)),
      ),
      home: ChangeNotifierProvider(
        create: (_) => AppState(),
        child: Scaffold(
          body: PageView(
              controller: PageController(
                  initialPage:
                      1), // instantiate this  outside build to save instantiation time
              children: [
                InputPage(),
                OutputPage(),
              ]),
        ),
      ),
    );
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _inputController = TextEditingController();

  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: BottomSheet(
        onClosing: () {},
        builder: (_) => Container(
          color: Colors.grey[400],
          child: ListTile(
            // backgroundColor: Colors.grey[400],
            title: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[400],
                contentPadding: EdgeInsets.all(5.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.white),
                ),
              ),
              cursorColor: Colors.white,
              controller: _inputController,
            ),
            trailing: FlatButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Input Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {},
          )
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFixedExtentList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  title: Text(Provider.of<AppState>(context).items[index].name),
                  trailing: IconButton(
                    icon: Icon(
                      !_editMode ? Icons.favorite_border : Icons.delete,
                    ),
                    onPressed: () {},
                  ),
                ),
                childCount: Provider.of<AppState>(context).items.length,
              ),
              itemExtent: 60),
        ],
      ),
    );
  }
}

class OutputPage extends StatefulWidget {
  const OutputPage({Key key}) : super(key: key);

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  var _scrollController = ScrollController();

  double _timeLineFactor = 0.2;
  double _leftMargin = 6;
  double _rightMargin = 6;

  int alphaVal = 127;

  int i = 0;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 50), () {
      Provider.of<AppState>(context).refreshNow();
      Timer.periodic(Duration(seconds: 30), (Timer timer) {
        Provider.of<AppState>(context).refreshNow();
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<AppState>(context).currentItem.color,
        title: Text(Provider.of<AppState>(context).currentItem.name),
      ),
      body: Container(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * _timeLineFactor,
                child: Column(
                  children: List.generate(
                      144,
                      (index) => Row(
                            children: <Widget>[
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: index <
                                            Provider.of<AppState>(context).now
                                        ? Colors.amber
                                        : (index ==
                                                Provider.of<AppState>(context)
                                                    .now
                                            ? Colors.red
                                            : Colors.blue),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.zero,
                                      bottomLeft: Radius.zero,
                                      topRight: Radius.circular(2),
                                      bottomRight: Radius.circular(2),
                                    ),
                                  ),
                                  child: Text(
                                      Utility.indexToTimeOfDay(index)
                                          .format(context),
                                      textScaleFactor: 0.75,
                                      textAlign: TextAlign.end),
                                  padding: EdgeInsets.only(right: 5),
                                  margin: EdgeInsets.only(top: 2, bottom: 2),
                                  height: 12,
                                ),
                              ),
                            ],
                          )),
                ),
              ),
              Container(
                height: 144 * 16.0, // + ((16 * 8) - 4.0),
                margin: EdgeInsets.only(left: _leftMargin, right: _rightMargin),
                width:
                    MediaQuery.of(context).size.width * (1 - _timeLineFactor) -
                        (_leftMargin + _rightMargin),
                child: MyReorderableListView(
                  onDragEnd: () {
                    Provider.of<AppState>(context).recombineAdjacentItems();
                  },
                  physics: NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex--;
                      Provider.of<AppState>(context)
                          .swapDown(oldIndex, newIndex);
                      Provider.of<AppState>(context).refreshItem();
                    } else if (newIndex < oldIndex) {
                      Provider.of<AppState>(context).swapUp(oldIndex, newIndex);
                      Provider.of<AppState>(context).refreshItem();
                    }
                  },
                  children: List.generate(
                          Provider.of<AppState>(context).items.length,
                          (index) => index)
                      .map((i) => MyDismissible(
                            key: Key(
                                '${Provider.of<AppState>(context).items[i].start}:${Provider.of<AppState>(context).items[i].name}'),
                            onDismissed: (direction) {
                              setState(() {
                                Provider.of<AppState>(context).items[i]
                                  ..name = 'Empty'
                                  ..color = Colors.grey[300];
                              });
                              Provider.of<AppState>(context)
                                  .recombineAdjacentItems();
                            },
                            child: AnimatedContainer(
                              // TODO (quevigil): make sure hero is applied to each part of item
                                duration: Duration(milliseconds: 200),
                                child: Center(
                                  child: Text(
                                    Provider.of<AppState>(context)
                                        .items[i]
                                        .name,
                                    style: TextStyle(
                                        color: Utility.lighterColor(
                                            Provider.of<AppState>(context)
                                                .items[i]
                                                .color),
                                        fontSize: Provider.of<AppState>(context)
                                                    .items[i]
                                                    .duration <
                                                2
                                            ? 12
                                            : 20,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 2,
                                              color: Utility.lighterColor(
                                                  Provider.of<AppState>(context)
                                                      .items[i]
                                                      .color))
                                        ]),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Provider.of<AppState>(context)
                                        .items[i]
                                        .color,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey[500],
                                          blurRadius: 2)
                                    ]),
                                margin: EdgeInsets.only(top: 2, bottom: 2),
                                height: 16.0 *
                                        Provider.of<AppState>(context)
                                            .items[i]
                                            .duration -
                                    4, // TODO: start from 1 pixel and make it this big.
                                width: MediaQuery.of(context).size.width *
                                        (1 - _timeLineFactor) -
                                    (_leftMargin + _rightMargin)),
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
