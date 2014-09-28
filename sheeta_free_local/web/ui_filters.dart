library filters;

import 'package:polymer_expressions/filter.dart';

class StringToInt extends Transformer<String, int> {
  final int radix;
  StringToInt({this.radix: 10});
  String forward(int i) => '$i';
  int reverse(String s) => s == null ? null : int.parse(s, radix: radix, onError: (s) => null);
}



class StringToDouble extends Transformer<String, double> {
 // final int radix;
 // StringToDouble({this.radix: 10});
  String forward(double i) => '$i';
  double reverse(String s) => s == null ? null : double.parse(s);
}

/*
class StringToBoolean extends Transformer<String, double> {
 // final int radix;
 // StringToDouble({this.radix: 10});
  String forward(double i) => '$i';
  double reverse(String s) => s == null ? null : bool.fromEnvironment(s);
}
*/
