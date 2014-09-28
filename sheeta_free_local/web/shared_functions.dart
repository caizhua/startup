library sharedfunctions;

//import 'package:three/three.dart';
//import 'package:vector_math/vector_math.dart';

/*
class Number3{
  Vector3 x;
  Vector3 y;
  Vector3 z;
  Number3(this.x, this.y, this.z);
}

class Triangle_Def{
  Number3 pos;
  double color_;
  Triangle_Def(this.pos, this.color_);
}*/

class x_y_num{
  double x;
  double y;
  x_y_num(this.x, this.y);
  dynamic toJson() => {"x":this.x, "y":this.y}; 
}

class str_num{
  String geo;
  double val;
  str_num(this.geo, this.val);
}

class Grouped_Data{
  List <x_y_num> data_list;
  String group_label;
  String group_value;
  String plot_type;
  Grouped_Data(this.data_list, this.group_label, this.group_value, this.plot_type);
}


class Grouped_Data_List{
  List <Grouped_Data> data_list;
  String group_label;
  String group_value;
  String plot_type;
 Grouped_Data_List(this.data_list, this.group_label, this.group_value, this.plot_type);
  
}
