library interval;

import 'package:decimal/decimal.dart';
//import './plot2d_element.dart';
import './shared_functions.dart';

/*
class Line_Set {
   double start_x;
   double start_y;
   double end_x;
   double end_y;
  Line_Set(this.start_x, this.start_y, this.end_x, this.end_y);
}
*/


List <double> find_interval(double max, double min, double step){
  List <double> result = [];
  if(max < min){
    return result;
  }
  var max_dec = Decimal.parse(max.toString());
  var min_dec = Decimal.parse(min.toString());
  var step_dec = Decimal.parse(step.toString());
  var round_d = (max_dec/step_dec).floor()*step_dec;
  var round_u = (min_dec/step_dec).ceil()*step_dec;
//  print(round_d);
//  print(round_u);
  
  for (var i=round_u; i<=round_d; i+=step_dec){
    result.add(i.toDouble());
  } 
  return result;  
}

bool inside_rect(double pt1_x, double pt1_y, double left, double top, double width, double height){
  double right = left + width;
  double bottom = top + height;
  if(pt1_x<=right && pt1_x>=left && pt1_y<=bottom && pt1_y>=top){
    return true;
  }
  else{
    return false;
  }
}


x_y_num cross_rect(x_y_num pt1, x_y_num pt2, double left, double top, double width, double height){
  double right = left + width;
  double bottom = top + height;  
  double _a = (pt2.y - pt1.y)/(pt2.x - pt1.x + 1.0e-12);
  double _b = pt2.y - _a*pt2.x;  
  double _inv_a = 1/(_a + 1.0e-12);
  double _inv_b = -_b/(_a + 1.0e-12);

//  print(_a);
//  print(_b);
//  print(_inv_a);
//  print(_inv_b);
  
  double cross_left = _a*left + _b;
  if(cross_left>=top && cross_left<=bottom && ((pt1.x>=left && pt2.x<=left)||(pt1.x<=left && pt2.x>=left))){
    return new x_y_num(left, cross_left);
  }
  
  double cross_right = _a*right + _b;
  if(cross_right>=top && cross_right<=bottom && ((pt1.x>=right && pt2.x<=right)||(pt1.x<=right && pt2.x>=right))){
    return new x_y_num(right, cross_right);
  }
  
  double cross_top = _inv_a*top + _inv_b;
  if(cross_top>=left && cross_top<=right && ((pt1.y>=top && pt2.y<=top)||(pt1.y<=top && pt2.y>=top))){
    return new x_y_num(cross_top, top);
  }
  
  double cross_bottom = _inv_a*bottom + _inv_b;
  if(cross_bottom>=left && cross_bottom<=right && ((pt1.y>=bottom && pt2.y<=bottom)||(pt1.y<=bottom && pt2.y>=bottom))){
    return new x_y_num(cross_bottom, bottom);
  }
  
  print(_a);
  print(_b);
  print(_inv_a);
  print(_inv_b);
  print(pt1.x);
  print(pt1.y);
  print(pt2.x);
  print(pt2.y);
  print(left);
  print(top);
  print(width);
  print(height);
}

/*
void main(){
  var p = cross_rect(new x_y_num(5.4, 0.5), new x_y_num(0.5, 0.5), 0.0, 0.0, 1.0, 1.0);
  print(p.x);
  print(p.y);
}
*/


/*void main(){
   var test = find_interval(1.40, 1.2, 0.2);
   print(test);
 // print((Decimal.parse('1.222')/Decimal.parse('0.2')).ceil());
 // print((Decimal.parse('1.222')/Decimal.parse('0.2')).floor());
}   */