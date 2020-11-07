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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef NativePutf = Int32 Function(Pointer<Utf8>);
typedef Putf = int Function(Pointer<Utf8>);

typedef NativeCompar = Int32 Function(Pointer<Int32>, Pointer<Int32>);
typedef NativeQsort = Void Function(
    Pointer<Int32>, Uint64, Uint64, Pointer<NativeFunction<NativeCompar>>);
typedef Qsort = void Function(
    Pointer<Int32>, int, int, Pointer<NativeFunction<NativeCompar>>);

int compar(Pointer<Int32> rhs_ptr, Pointer<Int32> lhs_ptr) {
  final rhs = rhs_ptr.value;
  final lhs = lhs_ptr.value;
  if (rhs > lhs) {
    return 1;
  } else if (rhs < lhs) {
    return -1;
  } else {
    return 0;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var _data = [1, 5, -10, 3, 9, 8, 7, 13];

  void _putf(String string) {
    final libc = DynamicLibrary.open('libc.so.6');
    final putf =
        libc.lookup<NativeFunction<NativePutf>>('puts').asFunction<Putf>();
    putf(Utf8.toUtf8(string));

    // TODO: should fflush via ffi.
    print('flush stdout');
    return;
  }

  Pointer<Int32> _intListToArray(List<int> list) {
    final ptr = allocate<Int32>(count: list.length);
    for (var i = 0; i < list.length; i++) {
      ptr.elementAt(i).value = list[i];
    }
    return ptr;
  }

  List<int> _arrayToIntList(Pointer<Int32> ptr, int length) {
    List<int> list = [];
    for (var i = 0; i < length; i++) {
      list.add(ptr[i]);
    }
    free(ptr);
    return list;
  }

  List<int> _qsort(final List<int> data, _compar) {
    final libc = DynamicLibrary.open('libc.so.6');
    final qsort =
        libc.lookup<NativeFunction<NativeQsort>>('qsort').asFunction<Qsort>();
    final dataPtr = _intListToArray(data);
    Pointer<NativeFunction<NativeCompar>> pointer = Pointer.fromFunction(compar, 0);
    qsort(dataPtr, data.length, sizeOf<Int32>(), pointer);
    return _arrayToIntList(dataPtr, data.length);
  }

  void _onClick() {
    _putf('_onClick start: $_data');
    final data = _qsort(_data, compar);
    setState(() {
      _counter++;
      _data = data;
    });
    _putf('_onClick end: $data');
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
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter : $_data',
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
