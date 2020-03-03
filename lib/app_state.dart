import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  List<Item> items = [Item.emptyFull()];

  int now = -1;
  Item currentItem = Item.emptyFull();

  void refreshNow() {
    int newNow = Utility.timeOfDayToIndex(TimeOfDay.now());
    if (now != newNow) {
      now = newNow;
      refreshItem();
      notifyListeners();
    }
  }

  void refreshItem() {
    currentItem = itemAt(now);
    notifyListeners();
  }

  Item itemAt(int index) {
    for (var item in items) {
      if (index >= item.start && index < item.start + item.duration) {
        return item;
      }
    }
    return null;
  }

  void swapDown(int oldIndex, int newIndex) {
    items.insert(newIndex, items.removeAt(oldIndex));
    for (int i = oldIndex; i <= newIndex; i++) {
      items[i].start =
          (i - 1 >= 0) ? items[i - 1].start + items[i - 1].duration : 0;
    }
    notifyListeners();
  }

  void swapUp(int oldIndex, int newIndex) {
    items.insert(newIndex, items.removeAt(oldIndex));
    for (int i = oldIndex; i >= newIndex; i--) {
      items[i].start = (i + 1 != items.length)
          ? items[i + 1].start - items[i].duration
          : 144 - items[i].duration;
    }
    notifyListeners();
  }

  AppState() {
    properInsert(Item('Sleep', 0, 30, Colors.blueGrey[300]));
    properInsert(Item('Morning Chores', 30, 2, Colors.indigo[300]));
    properInsert(Item('Meditation', 32, 2, Colors.blue[100]));
    properInsert(Item('Morning Walk', 34, 2, Colors.amber[200]));
    properInsert(Item('Breakfast', 36, 2, Colors.green[300]));
    properInsert(Item('Work Preparation', 38, 4, Colors.deepPurple[100]));
    properInsert(Item('Commute to Work', 42, 10, Colors.pink[200]));
    properInsert(Item('Settle into Work', 52, 2, Colors.deepPurple[200]));
    properInsert(Item('Work', 54, 24, Colors.deepPurple[300]));
    properInsert(Item('Lunch', 78, 2, Colors.green[300]));
    properInsert(Item('Work', 80, 22, Colors.deepPurple[300]));
    properInsert(Item('Commute Back', 102, 10, Colors.indigo[200]));
    properInsert(Item('Evening Tea', 112, 2, Colors.green[300]));
    properInsert(Item('Family Time', 114, 8, Colors.red[200]));
    properInsert(Item('Dinner', 122, 2, Colors.green[300]));
    properInsert(Item('Evening Walk', 124, 2, Colors.amber[200]));
    properInsert(Item('Work Preparation', 126, 6, Colors.deepPurple[100]));
    properInsert(Item('Novel Reading', 132, 3, Colors.blue[100]));
    properInsert(Item('Sleep', 135, 9, Colors.blueGrey[300]));

    // properInsert(Item('Attend to Accident', 45, 2, Colors.red[300]));
    // properInsert(Item('Attend to Accident', 47, 2, Colors.red[300]));
  }

  void properInsert(Item item) {
    int first, last;
    bool inserted = false;
    for (int i = 0; i < items.length; i++) {
      if (item.start >= items[i].start) {
        first = i;
      }
      if (item.start + item.duration <= items[i].start + items[i].duration) {
        last = i;
        break;
      }
    }
    if (first == last) {
      if (items[first].start == item.start) {
        items[first].start = item.start + item.duration;
        items[first].duration = items[first].duration - item.duration;
        if (items[first].duration == 0) {
          items[first] = item;
        } else {
          items.insert(first, item);
        }
      } else {
        if (items[first].start + items[first].duration ==
            item.start + item.duration) {
          items[first].duration = items[first].duration - item.duration;
          items.insert(first + 1, item);
        } else {
          var oldItem = items[first].copy();
          oldItem.start = item.start + item.duration;
          oldItem.duration =
              ((first + 1 < items.length) ? items[first + 1].start : 144) -
                  (item.start + item.duration);
          items[first].duration = item.start - items[first].start;
          items.insert(first + 1, oldItem);
          items.insert(first + 1, item);
        }
      }
    } else {
      for (int i = first + 1; i < last; i++) {
        items.removeAt(first + 1);
      }
      last = first + 1;
      if (items[first].start == item.start) {
        items[first] = item;
        inserted = true;
      } else {
        items[first].duration = item.start - items[first].start;
      }
      if (item.start + item.duration ==
          items[last].start + items[last].duration) {
        items.removeAt(last);
      } else {
        items[last].start = item.start + item.duration;
      }
      if (!inserted) {
        items.insert(first + 1, item);
      }
    }
    notifyListeners();
  }

  void recombineAdjacentItems() {
    int i = 0;
    while (i < items.length - 1) {
      if (items[i] == items[i + 1]) {
        items[i].duration = items[i].duration + items[i + 1].duration;
        items.removeAt(i + 1);
      }
      i++;
    }
    notifyListeners();
  }
}

class Item {
  String name;
  int start, duration;
  Color color;

  Item(this.name, this.start, this.duration, this.color);

  Item.empty(this.start, this.duration) {
    this
      ..name = 'Empty'
      ..color = Colors.grey[300];
  }

  Item copy() {
    return Item(this.name, this.start, this.duration, this.color);
  }

  Item.emptyFull() {
    this
      ..name = 'Empty'
      ..start = 0
      ..duration = 144
      ..color = Colors.grey[300];
  }

  bool operator ==(other) {
    return this.name == other.name;
  }

  int get hashCode => this.name.hashCode;
}

class Utility {
  // static class of utility functions
  // seperate from AppState to save instantiation time of AppState()

  static TimeOfDay indexToTimeOfDay(int index) {
    return TimeOfDay(hour: index ~/ 6, minute: (index % 6) * 10);
  }

  static int timeOfDayToIndex(TimeOfDay tod) {
    return (tod.hour * 6) + (tod.minute ~/ 10);
  }

  static int timestampToIndex(String timestamp) {
    var tod = TimeOfDay.fromDateTime(DateTime.parse(timestamp));
    return (tod.hour * 6) + (tod.minute ~/ 10);
  }

  static Color lighterColor(Color color) {
    double factor = 1.8;
    Color newColor = color;
    newColor = newColor.withRed((color.red * factor).floor() <= 255
        ? (color.red * factor).floor()
        : 255);
    newColor = newColor.withGreen((color.green * factor).floor() <= 255
        ? (color.green * factor).floor()
        : 255);
    newColor = newColor.withBlue((color.blue * factor).floor() <= 255
        ? (color.blue * factor).floor()
        : 255);
    return newColor;
  }

  static Color deeperColor(Color color) {
    double factor = 0.8;
    Color newColor = color;
    newColor = newColor.withRed(
        (color.red * factor).floor() >= 0 ? (color.red * factor).floor() : 0);
    newColor = newColor.withGreen((color.green * factor).floor() >= 0
        ? (color.green * factor).floor()
        : 0);
    newColor = newColor.withBlue(
        (color.blue * factor).floor() >= 0 ? (color.blue * factor).floor() : 0);
    return newColor;
  }
}
