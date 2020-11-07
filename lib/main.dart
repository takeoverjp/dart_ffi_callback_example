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

typedef putf_func = Int32 Function(Pointer<Utf8>);
typedef Putf = int Function(Pointer<Utf8>);

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _putf(String string) {
    final libc = DynamicLibrary.open('libc.so.6');
    final putf = libc.lookup<NativeFunction<putf_func>>('puts').asFunction<Putf>();
    putf(Utf8.toUtf8(string));

    // TODO: should fflush via ffi.
    print('flush stdout');
    return;
  }

  void _callQsort() {
    _putf('_callQsort start');
    setState(() {
      _counter++;
    });
    _putf('_callQsort end');
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
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _callQsort,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
