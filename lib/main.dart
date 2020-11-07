import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dart:ffi callback example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'dart:ffi callback example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef NativeCompar = Int32 Function(Pointer<Int32>, Pointer<Int32>);
typedef NativeQsort = Void Function(
    Pointer<Int32>, Uint64, Uint64, Pointer<NativeFunction<NativeCompar>>);
typedef Qsort = void Function(
    Pointer<Int32>, int, int, Pointer<NativeFunction<NativeCompar>>);

int compar(Pointer<Int32> rhsPtr, Pointer<Int32> lhsPtr) {
  final rhs = rhsPtr.value;
  final lhs = lhsPtr.value;
  if (rhs > lhs) {
    return 1;
  } else if (rhs < lhs) {
    return -1;
  } else {
    return 0;
  }
}

Pointer<Int32> intListToArray(List<int> list) {
  final ptr = allocate<Int32>(count: list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}

List<int> arrayToIntList(Pointer<Int32> ptr, int length) {
  List<int> list = [];
  for (var i = 0; i < length; i++) {
    list.add(ptr[i]);
  }
  free(ptr);
  return list;
}

List<int> qsort(final List<int> data, _compar) {
  final dataPtr = intListToArray(data);
  final libc = DynamicLibrary.open('libc.so.6');
  final qsort =
      libc.lookup<NativeFunction<NativeQsort>>('qsort').asFunction<Qsort>();
  Pointer<NativeFunction<NativeCompar>> pointer =
      Pointer.fromFunction(compar, 0);
  qsort(dataPtr, data.length, sizeOf<Int32>(), pointer);
  return arrayToIntList(dataPtr, data.length);
}

class _MyHomePageState extends State<MyHomePage> {
  var _text = 'Before qsort';
  var _data = [1, 5, -10, 3, 9, 8, 7, 13];

  void _onClick() {
    final data = qsort(_data, compar);
    setState(() {
      _text = 'After qsort';
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_text',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_data',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onClick,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
