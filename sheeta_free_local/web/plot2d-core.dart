library plot2dcore;

import 'package:polymer/polymer.dart';
import 'dart:convert';
import './interval_decimal.dart';
import 'dart:html';
import './shared_functions.dart';
import 'dart:js';
//import 'dart:svg' as svg;
//import 'dart:async'; 
import 'dart:math';
//import './ui_filters.dart';
//import 'package:polymer_expressions/filter.dart' show Transformer;
//import 'package:color/color.dart';

String host = 'localhost';
int port = 8084;


class Frame extends Object with Observable{
  @observable int top;
  @observable int left;
  @observable int height;
  @observable int width;
  @observable bool show_control_point = false;
  int active_circle;
  bool IS_CIRCLE_MOVE = false;
  Frame(this.left, this.top, this.width, this.height, this.show_control_point, this.active_circle, this.IS_CIRCLE_MOVE);
  dynamic toJson() => {"top":this.top, "left":this.left, "height":this.height, "width":this.width}; 
}

class _marker extends Object with Observable{
  @observable String text;
  @observable int position;
  _marker(this.text, this.position);
  dynamic toJson() => {"text":this.text, "position":this.position}; 
}

class Marker extends Object with Observable{ 
  List <_marker> marker = toObservable([]);
  @observable int position;
  @observable int font_size; 
  @observable int tick_length;
  @observable int tick_stroke_width;
  @observable String tick_stroke;
  Marker(this.marker, this.position, this.font_size, this.tick_length, this.tick_stroke_width, this.tick_stroke);
  dynamic toJson() => {"marker":this.marker, "position":this.position, "font_size":this.font_size, "tick_length":this.tick_length, 
    "tick_stroke_width":this.tick_stroke_width, "tick_stroke":this.tick_stroke}; 
}

class Label extends Object with Observable{
  @observable String text;
  @observable int x;
  @observable int y;
  double unscaled_x;
  double unscaled_y; 
  @observable String color;
  @observable int font_size;
  @observable int rotation_degree; 
  @observable bool edit = false; 
  @observable String font_weight = "normal";
  @observable String text_decoration = "none";
  @observable String font_style = "normal"; 
  Label(this.text, this.x, this.y, this.unscaled_x, this.unscaled_y, this.font_size, this.rotation_degree, this.edit, this.color);
  dynamic toJson() => {"text":this.text, "x":this.x, "y":this.y, "unscaled_x":this.unscaled_x, 
    "unscaled_y":this.unscaled_y, "font_size":this.font_size, "rotation_degree":this.rotation_degree, "color":this.color}; 
}


class _data_set_scaled extends Object with Observable{
  @observable num x;
  @observable num y;
  _data_set_scaled(this.x, this.y);
  dynamic toJson() => {"x":this.x, "y":this.y}; 
}


class Data_Set extends Object with Observable{
  List <x_y_num> data_set_unscaled;
  List <_data_set_scaled> symbol_set = toObservable([]);
  @observable _symbol_style_general symbol_style;
  @observable String symbol_type;           // for symbol types, the option include "circle", "square", "rectangle", "triangle"    etc
  @observable String line_type;              // for line types, the option include "solid", "dash", "dotted", "dash-dot"  etc 
  List <x_line_set> line_set = toObservable([]);
  @observable _line_style line_style;
  @observable Label text_legend;
  @observable String plot_type;        //   here the plot_type is for "symbol_2d", "linesymbol_2d", "line_2d"
  List <x_line_set> fit_line_set = toObservable([]);
  
  Data_Set(this.data_set_unscaled, this.symbol_set, this.symbol_style, this.line_set, this.line_style, this.text_legend, this.symbol_type, this.line_type, this.plot_type, this.fit_line_set); 

  dynamic toJson() => {"data_set_unscaled":this.data_set_unscaled, "symbol_set":this.symbol_set, "symbol_style":this.symbol_style, "line_set":this.line_set, 
    "line_style":this.line_style, "text_legend":this.text_legend, "symbol_type":this.symbol_type, "line_type":this.line_type, "plot_type":this.plot_type, "fit_line_set":this.fit_line_set  };
}

class _line_style extends Object with Observable{
  @observable String stroke;
  @observable int stroke_width;
  @observable String fill;
  _line_style(this.stroke, this.stroke_width, this.fill);
  dynamic toJson() => {"stroke":this.stroke, "stroke_width":this.stroke_width, "fill":this.fill};
}

class _symbol_style_general extends Object with Observable{
  @observable int radius;
  String points;
  @observable String stroke;
  @observable int stroke_width;
  @observable String fill;
  _symbol_style_general(this.radius, this.points, this.stroke, this.stroke_width, this.fill);
  dynamic toJson() => {"radius":this.radius, "points":this.points, "stroke":this.stroke, "stroke_width":this.stroke_width, "fill":this.fill }; 
}


class x_line_set extends Object with Observable{
  @observable num start_x;
  @observable num start_y;
  @observable num end_x;
  @observable num end_y;
  x_line_set(this.start_x, this.start_y, this.end_x, this.end_y);
  dynamic toJson() => {"start_x":this.start_x, "start_y":this.start_y, "end_x":this.end_x, "end_y":this.end_y }; 
}


class Fit_Setting extends Object with Observable{
  @observable bool show_fit_dialog = false;
  @observable String fit_fuction;
  List <String> para_name = toObservable([]);
  List <double> para_value = toObservable([]);
  @observable double x_min, x_max;
  @observable int num_of_point_for_plot;    
  @observable double squared_error = 0.0;
  @observable double correlation_coefficient = 0.0; 
  Fit_Setting(this.show_fit_dialog, this.fit_fuction, this.para_name, this.para_value, this.x_min, this.x_max, this.num_of_point_for_plot, this.squared_error, this.correlation_coefficient);
}

class Poly_Fit_Setting extends Object with Observable{
  @observable int poly_order = 1;    
  @observable double x_min, x_max;
  @observable int num_of_point_for_plot;    
  @observable double squared_error = 0.0;
  @observable double correlation_coefficient = 0.0; 
  List <double> para_value = toObservable([]);
  Poly_Fit_Setting(this.poly_order, this.x_min, this.x_max, this.num_of_point_for_plot, this.squared_error, this.correlation_coefficient, this.para_value);
}


class _heat_map_element{
  int color;
  //String color; 
  String path;
  _heat_map_element(this.color, this.path);
}

class _heat_map_interpo{
  int color;
  int x;
  int y; 
  _heat_map_interpo(this.color, this.x, this.y);
}


class State extends Object with Observable{
  @observable String path;
  @observable String name;
  State(this.path, this.name);
}




class Data_Plot extends Object with Observable{
  String parent;
  @observable Frame frame;
  @observable Marker x_marker;
  @observable Marker y_marker;
  @observable bool plot_mode_show = false;
  List <Data_Set> data_set_list_overlay = toObservable([]);
  List <Map> heat_map_original_data;
  List <_heat_map_element> heat_map_data = toObservable([]);
  List <_heat_map_interpo> heat_map_interpo = toObservable([]);
  List <State> state_list = toObservable([]);
  Map color_map = toObservable({});  
  @observable num x_range_min, x_range_max, y_range_min, y_range_max;  //range for x and y axis
  @observable num x_step, y_step;
  List <double> interval_y;
  List <double> interval_x;
  List <Label> label_list = toObservable([]);    
  @observable double translate_x = 0.0;
  @observable double translate_y = 0.0;
  @observable double scale = 1.0;
  @observable String plot_type;    // here the plot type is for "overlay", "heat map", or "geography", "single_line"
  num serial_number = 0; 
  @observable int legend_box_trans_x = 0; 
  @observable int legend_box_trans_y = 0; 
//  var ws_write_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");      
  
  dynamic toJson() => {"parent":this.parent, "frame":this.frame, "x_marker":this.x_marker, "y_marker":this.y_marker, "data_set_list_overlay":this.data_set_list_overlay,
    "x_range_min":this.x_range_min, "x_range_max":this.x_range_max, "y_range_min":this.y_range_min, "y_range_max":this.y_range_max,
    "x_step":this.x_step, "y_step":this.y_step, "label_list":this.label_list, "plot_type":this.plot_type, "serial_number":this.serial_number}; 
  
  Data_Plot.overlay_init(List <Grouped_Data> grouped_data, String plot_type_, num serial_num, String plot_title_, String parent_){
          this.parent = parent_; 
          this.plot_type = plot_type_;
          this.serial_number = serial_num; 
          
          for(var g_data in grouped_data){              
            List <x_y_num> xy_data = g_data.data_list;
          //  String plot_type_ = g_data.plot_type;

            for(num i=0; i<xy_data.length; i++){
              double temp_x = xy_data[i].x; //double.parse(table.Table_data[i].Row_data[X_index].Cell_data); //x data
              double temp_y = xy_data[i].y;//double.parse(table.Table_data[i].Row_data[Y_index].Cell_data);  // y data
              if(x_range_min==null || x_range_max==null || y_range_min==null || y_range_max==null){
                x_range_min = temp_x;
                x_range_max = temp_x;
                y_range_min = temp_y;
                y_range_max = temp_y;
              }
              else{
                if(x_range_min > temp_x) x_range_min = temp_x;
                if(x_range_max < temp_x) x_range_max = temp_x;
                if(y_range_min > temp_y) y_range_min = temp_y;
                if(y_range_max < temp_y) y_range_max = temp_y;
              }
            }  //end of for(num i=0; i<num_of_row; i++){            
          }  // end of for(var g_data in grouped_data){         
            
            double y_range_length = y_range_max-y_range_min;   // y range length
            double x_range_length = x_range_max-x_range_min;   // x range length
            
            num temp_left = 100 + (serial_num%2)*600;
            num temp_top = 100 + (serial_num/2).toInt()*400;
            num temp_height = 300;
            num temp_width = 500;
            
            Frame temp_frame = new Frame(temp_left, temp_top, temp_width, temp_height, false, null, false);    // frame 
            
            for(var g_data in grouped_data){
              int index = grouped_data.indexOf(g_data);
              
              List <x_y_num> xy_data = g_data.data_list;
              String plot_type_ = g_data.plot_type;
              
             List <x_line_set> fit_line_set_temp = toObservable([]);
            
             Data_Set _data_set_plot = new Data_Set(xy_data, null, null, null, null, null, "circle", "solid_line", plot_type_, fit_line_set_temp);
                         
             _data_set_plot.text_legend = new Label(g_data.group_label+"="+g_data.group_value, temp_frame.left+10, temp_frame.top+index*30, null, null, 20, 0, false, "#000000");  
             
             var rng = new Random();
             String color = '#'+rng.nextDouble().toStringAsFixed(16).substring(2, 8);
    
            if(plot_type_=="symbol_2d"||plot_type_=="linesymbol_2d"){
              List <_data_set_scaled> temp_scaled_data_set = toObservable([]);             
              for(num i=0; i<xy_data.length; i++){
                temp_scaled_data_set.add( new _data_set_scaled((xy_data[i].x-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble(), (-xy_data[i].y+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble()));           
              }             
              _data_set_plot.symbol_set = temp_scaled_data_set;
              
              _data_set_plot.symbol_style = new _symbol_style_general(5, null, color, 1, color);

              /*
              if(_data_set_plot.symbol_type=="circle"){
                  _data_set_plot.symbol_style = new _symbol_style_general(5, null, color, 1, color);
              }
              if(_data_set_plot.symbol_type=="rectangle"){
                  _data_set_plot.symbol_style = new _symbol_style_general(5, "0,0 1,0 1,1 0,1", color, 1, color);
              }
              if(_data_set_plot.symbol_type=="cross"){
                  _data_set_plot.symbol_style = new _symbol_style_general(5, "5,5 5,0 5,10 5,5 0,5 10,5", color, 1, "white");
              } */
              
            }  //end of if(plot_type_=="symbol_2d"||plot_type_=="linesymbol_2d"){
            
            if(plot_type_=="line_2d"||plot_type_=="linesymbol_2d"){    
              List <x_line_set> temp_scaled_line_set = toObservable([]);                   
              _data_set_plot.data_set_unscaled.sort((x, y) => x.x.compareTo(y.x));
              double va_x, va_y, vb_x, vb_y;
              va_x = (_data_set_plot.data_set_unscaled[0].x-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble();
              va_y = (-_data_set_plot.data_set_unscaled[0].y+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble();
              for(num i=1; i<_data_set_plot.data_set_unscaled.length; i++){
                  vb_x = (_data_set_plot.data_set_unscaled[i].x-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble();
                  vb_y = (-_data_set_plot.data_set_unscaled[i].y+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble();
                  temp_scaled_line_set.add(new x_line_set(va_x, va_y, vb_x, vb_y));
                  va_x = vb_x;
                  va_y = vb_y;
              }    
              _data_set_plot.line_set = temp_scaled_line_set;
           //   var rng = new Random();
           //   String color = '#'+rng.nextDouble().toStringAsFixed(16).substring(2, 8);
              _data_set_plot.line_style = new _line_style(color, 2, color);
            }  // end of if(plot_type_=="line_2d"||plot_type_=="linesymbol_2d"){    
            
            this.data_set_list_overlay.add(_data_set_plot);
            
            } // end of for(var g_data in grouped_data){
                            
            num num_of_x_marker = 6;
            num num_of_y_marker = 6;

            double step_x = double.parse((x_range_length/(num_of_x_marker-1).toDouble()).toStringAsPrecision(1));   // step of y plot
            double step_y = double.parse((y_range_length/(num_of_y_marker-1).toDouble()).toStringAsPrecision(1));   // step of x plot 
            
            this.x_step = step_x;
            this.y_step = step_y;
            
            interval_y = find_interval(y_range_max, y_range_min, step_y);    //find the interval
            interval_x = find_interval(x_range_max, x_range_min, step_x);    // find the interval
            
            List <_marker> temp_y_marker = toObservable([]);     
            for(int i=0; i<interval_y.length; i++){
              temp_y_marker.add(new _marker(interval_y[i].toString(), ((-interval_y[i]+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble()).toInt()));          // still problematic, to be continued. 
            }
            Marker _y_marker = new Marker(temp_y_marker, temp_frame.left-40, 20, 20, 3, "#000000");         
                 
            List <_marker> temp_x_marker = toObservable([]);     
            for(int i=0; i<interval_x.length; i++){
              temp_x_marker.add(new _marker(interval_x[i].toString(), ((interval_x[i]-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble()).toInt()));          // still problematic, to be continued. 
            }
            Marker _x_marker = new Marker(temp_x_marker, temp_frame.top+temp_frame.height+20, 20, 20, 3, "#000000");          // still problematic, to be continued.  
            
            Label _y_label = new Label("y data", temp_frame.left-60, (temp_frame.top+(temp_frame.height/2)).toInt()+30, null, null, 30, 270, false, "#000000"); 
            Label _x_label = new Label("x data" , (temp_frame.left+(temp_frame.width/2)).toInt()-30, temp_frame.top+temp_frame.height+50, null, null, 30, 0, false, "#000000");             
            Label _plot_title = new Label(plot_title_, (temp_frame.left+(temp_frame.width/2)).toInt()-30, temp_frame.top-10, null, null, 30, 0, false, "#000000");  
            
            this.frame = temp_frame;
            this.label_list.add(_x_label); // x_label = ;
            this.label_list.add(_y_label);   //  this.y_label = ;
            this.x_marker = _x_marker;
            this.y_marker = _y_marker;
            this.label_list.add(_plot_title);     // this.plot_title = _plot_title;
          //   this.data_set = _data_set_plot;      
            this.plot_mode_show = true;     
          //  print(this.label_list.length);
            
            for(var label in this.label_list){
              label.unscaled_x = (label.x-temp_frame.left)/temp_frame.width;
              label.unscaled_y = (label.y-temp_frame.top)/temp_frame.height;              
            }
  } //*/
  
  
  Data_Plot.heat_map_init(List <Map> data){
    
    List <Map> sites_ = [];
    this.plot_type = "2d_heat_map"; 
    
    //print(data); 
    
    this.heat_map_original_data = data;
    
              for(num i=0; i<data.length; i++){
                 double temp_x = data[i]["x"].toDouble(); 
                 double temp_y = data[i]["y"].toDouble();
       //          sites_.add({"x":temp_x, "y":temp_y});
                 if(i==0){
                   x_range_min = temp_x;
                   x_range_max = temp_x;
                   y_range_min = temp_y;
                   y_range_max = temp_y;
                 }
                 if(i>0){
                   if(x_range_min > temp_x) x_range_min = temp_x;
                   if(x_range_max < temp_x) x_range_max = temp_x;
                   if(y_range_min > temp_y) y_range_min = temp_y;
                   if(y_range_max < temp_y) y_range_max = temp_y;
                 }
               }  //end of for(num i=0; i<num_of_row; i++){    
    
              double y_range_length = y_range_max-y_range_min;   // y range length
              double x_range_length = x_range_max-x_range_min;   // x range length                       
              Frame temp_frame = new Frame(200, 100, 600, 600, false, null, false);    // frame     
              
              double color_min, color_max;
              color_min = data[0]["color"];
              color_max = data[0]["color"];
              for(var d in data){
                if(color_min>d["color"]) color_min=d["color"];
                if(color_max<d["color"]) color_max=d["color"];
              }
              
              for(var d in data){
                d["color"] = ((d["color"]-color_min)/(color_max-color_min)*30).toInt();
                //print(d["color"].toDouble()); 
                //d["color"] = ((d["color"]-color_min)/(color_max-color_min)*256).toInt();
                //num h = ((d["color"]-color_min)/(color_max-color_min)*360);
                //var color =  new Color.hsl(h, 100, 50);
                //color.toHexString();
                //d["color"] = 
              }
              
              
              for(num i=0; i<data.length; i++){
                  sites_.add({"x":(data[i]["x"]-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble(), 
                    "y":(-data[i]["y"]+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble()});
              }
              
              var point = new JsObject(context['Voronoi'], []);
              var bbox = new JsObject.jsify({"xl":temp_frame.left,"xr":(temp_frame.left+temp_frame.width),"yt":temp_frame.top,"yb":(temp_frame.top+temp_frame.height)});
              var sites = new JsObject.jsify(sites_);                        
              var s = point.callMethod("compute", [sites, bbox]);
              
              
              List <_heat_map_element> temp_heat_map_data = toObservable([]);     
              
                   for(var ss in s["cells"]){
                        String pat = "M";                          
                          for(var sss in ss["halfedges"]){
                            var start = sss.callMethod("getStartpoint", []);          
                            pat += start["x"].toString();
                            pat += " ";
                            pat += (2*temp_frame.top+temp_frame.height-start["y"]).toString();
                            pat += " ";
                            pat += "L";
                          }
                          var start = ss["halfedges"][0].callMethod("getStartpoint", []);
                          pat += start["x"].toString();
                          pat += " ";
                          pat += (2*temp_frame.top+temp_frame.height-start["y"]).toString();
                          pat += " ";
                          pat += "Z ";                            
              //            print(pat);                          
                          int id = ss["site"]["voronoiId"];                          
                        //  print(data[id]["color"]);                           
                        //  var color =  new Color.hsl(data[id]["color"].toDouble(), 100.0, 50.0);   color.toHexString()                          
                          temp_heat_map_data.add(new _heat_map_element(data[id]["color"], pat));
                        }             
              
              
                       num num_of_x_marker = 6;
                        num num_of_y_marker = 6;
                        double step_x = double.parse((x_range_length/(num_of_x_marker-1)).toStringAsPrecision(2));   // step of y plot
                        double step_y = double.parse((y_range_length/(num_of_y_marker-1)).toStringAsPrecision(2));   // step of x plot                              
                        interval_y = find_interval(y_range_max, y_range_min, step_y);    //find the interval
                        interval_x = find_interval(x_range_max, x_range_min, step_x);    // find the interval                        
                        List <_marker> temp_y_marker = toObservable([]);     
                        for(int i=0; i<interval_y.length; i++){
                          temp_y_marker.add(new _marker(interval_y[i].toString(), ((-interval_y[i]+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble()).toInt()));          // still problematic, to be continued. 
                        }
                        Marker _y_marker = new Marker(temp_y_marker, temp_frame.left-50, 20, 20, 3, "red");                               
                        List <_marker> temp_x_marker = toObservable([]);     
                        for(int i=0; i<interval_x.length; i++){
                          temp_x_marker.add(new _marker(interval_x[i].toString(), ((interval_x[i]-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble()).toInt()));          // still problematic, to be continued. 
                        }
                        Marker _x_marker = new Marker(temp_x_marker, temp_frame.top+temp_frame.height+20, 20, 20, 3, "red");          // still problematic, to be continued.                        
                    //    Label _y_label = new Label("y data", temp_frame.left-70, (temp_frame.top+(temp_frame.height/2)).toInt(), 30);  
                    //    Label _x_label = new Label("x data" , (temp_frame.left+(temp_frame.width/2)).toInt(), temp_frame.top+temp_frame.height+50, 30);                          
                        Label _y_label = new Label("y data", temp_frame.left-60, (temp_frame.top+(temp_frame.height/2)).toInt()+30, null, null, 30, 270, false, "#000000"); 
                        Label _x_label = new Label("x data" , (temp_frame.left+(temp_frame.width/2)).toInt()-30, temp_frame.top+temp_frame.height+50, null, null, 30, 0, false, "#000000");             
                                
                        
                        this.frame = temp_frame;
                        this.label_list.add(_x_label); // x_label = ;
                        this.label_list.add(_y_label);   //  this.y_label = ;
                    //    this.x_label = _x_label;
                    //    this.y_label = _y_label;
                        this.x_marker = _x_marker;
                        this.y_marker = _y_marker;
                        this.plot_mode_show = true;       
                        this.heat_map_data = temp_heat_map_data;   
                        
                        for(var label in this.label_list){
                          label.unscaled_x = (label.x-temp_frame.left)/temp_frame.width;
                          label.unscaled_y = (label.y-temp_frame.top)/temp_frame.height;              
                        }
  }
  
  
  Data_Plot.heat_map_init_interpo(List <Map> data){
    
    this.plot_type = "2d_heat_map_interpo";
    
    Frame temp_frame = new Frame(200, 100, 600, 600, false, null, false);    // frame  
    this.frame = temp_frame;    
    this.heat_map_original_data = data;
        
                  for(num i=0; i<data.length; i++){
                     double temp_x = data[i]["x"].toDouble(); 
                     double temp_y = data[i]["y"].toDouble();
           //          sites_.add({"x":temp_x, "y":temp_y});
                     if(i==0){
                       x_range_min = temp_x;
                       x_range_max = temp_x;
                       y_range_min = temp_y;
                       y_range_max = temp_y;
                     }
                     if(i>0){
                       if(x_range_min > temp_x) x_range_min = temp_x;
                       if(x_range_max < temp_x) x_range_max = temp_x;
                       if(y_range_min > temp_y) y_range_min = temp_y;
                       if(y_range_max < temp_y) y_range_max = temp_y;
                     }
                   }  //end of for(num i=0; i<num_of_row; i++){    
                  
                  double color_min, color_max;
                  color_min = data[0]["color"];
                  color_max = data[0]["color"];
                  for(var d in data){
                    if(color_min>d["color"]) color_min=d["color"];
                    if(color_max<d["color"]) color_max=d["color"];
                  }
        
                  double y_range_length = y_range_max-y_range_min;   // y range length
                  double x_range_length = x_range_max-x_range_min;   // x range length  
                  
                  
                     num num_of_x_marker = 6;
                     num num_of_y_marker = 6;
                     double step_x = double.parse((x_range_length/(num_of_x_marker-1)).toStringAsPrecision(2));   // step of y plot
                     double step_y = double.parse((y_range_length/(num_of_y_marker-1)).toStringAsPrecision(2));   // step of x plot                              
                     interval_y = find_interval(y_range_max, y_range_min, step_y);    //find the interval
                     interval_x = find_interval(x_range_max, x_range_min, step_x);    // find the interval                        
                     List <_marker> temp_y_marker = toObservable([]);     
                     for(int i=0; i<interval_y.length; i++){
                       temp_y_marker.add(new _marker(interval_y[i].toString(), ((-interval_y[i]+y_range_max)/y_range_length*temp_frame.height.toDouble()+temp_frame.top.toDouble()).toInt()));          // still problematic, to be continued. 
                     }
                     Marker _y_marker = new Marker(temp_y_marker, temp_frame.left-50, 20, 20, 3, "red");                               
                     List <_marker> temp_x_marker = toObservable([]);     
                     for(int i=0; i<interval_x.length; i++){
                       temp_x_marker.add(new _marker(interval_x[i].toString(), ((interval_x[i]-x_range_min)/x_range_length*temp_frame.width.toDouble()+temp_frame.left.toDouble()).toInt()));          // still problematic, to be continued. 
                     }
                     Marker _x_marker = new Marker(temp_x_marker, temp_frame.top+temp_frame.height+20, 20, 20, 3, "red");          // still problematic, to be continued.                        
                 //    Label _y_label = new Label("y data", temp_frame.left-70, (temp_frame.top+(temp_frame.height/2)).toInt(), 30);  
                 //    Label _x_label = new Label("x data" , (temp_frame.left+(temp_frame.width/2)).toInt(), temp_frame.top+temp_frame.height+50, 30);                          
                     Label _y_label = new Label("y data", temp_frame.left-60, (temp_frame.top+(temp_frame.height/2)).toInt()+30, null, null, 30, 270, false, "#000000"); 
                     Label _x_label = new Label("x data" , (temp_frame.left+(temp_frame.width/2)).toInt()-30, temp_frame.top+temp_frame.height+50, null, null, 30, 0, false, "#000000");             
                             
                     
                     this.frame = temp_frame;
                     this.label_list.add(_x_label); // x_label = ;
                     this.label_list.add(_y_label);   //  this.y_label = ;
                 //    this.x_label = _x_label;
                 //    this.y_label = _y_label;
                     this.x_marker = _x_marker;
                     this.y_marker = _y_marker;
                     this.plot_mode_show = true;       
                 //    this.heat_map_data = temp_heat_map_data;   
                     
                     for(var label in this.label_list){
                       label.unscaled_x = (label.x-temp_frame.left)/temp_frame.width;
                       label.unscaled_y = (label.y-temp_frame.top)/temp_frame.height;              
                     }
                  
                  
                  var ws_read_db = new WebSocket("ws://"+host+":"+8090.toString()+"/ws");   
                  
                    ws_read_db.onOpen.listen((event){
                        ws_read_db.send(JSON.encode({"CMD":"interpolation_heat_map", "input_data":data, "num_of_step":100,
                          "range":{"x_min":this.x_range_min, "x_max":this.x_range_max, "y_min":this.y_range_min, "y_max":this.y_range_max}}));
                    });           
                    
                    ws_read_db.onMessage.listen((event){
                      var _data_ = JSON.decode(event.data);   
                    if(_data_["MSG"]=="interpolation_heat_map_output"){                              
                      for(int i=0; i<100; i++){
                        for(int j=0; j<100; j++){
                          int temp = ((_data_["output"][i*100+j]-color_min)/(color_max-color_min)*30).toInt(); //(_data_["output"][i*100+j]*30).toInt(); 
                          this.heat_map_interpo.add(new _heat_map_interpo(temp, i*6+temp_frame.left, (99-j)*6+temp_frame.top)); 
                        }
                      }   
                    }
                    });    
  }
  
  
  Data_Plot.geotraphy_init(dynamic inp_data, String plot_type_, num serial_num, String parent_){
    
    this.serial_number = serial_num;
    this.parent = parent_;
    this.plot_type = plot_type_; 
    
    this.plot_mode_show = true;    
    Frame temp_frame = new Frame(null, null, null, null, false, null, false);    // frame     
    this.frame = temp_frame;
    
    
    var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");   
    
      ws_read_db.onOpen.listen((event){
          ws_read_db.send(JSON.encode({"CMD":"check_map_path", "filter":{"parent":inp_data["parent"]}}));
      });     
      
      
      ws_read_db.onMessage.listen((event){
        var data = JSON.decode(event.data);
        state_list.add(new State(data["path"], data["name"]));
      });     
      
      double min=inp_data["data"][0]["color"];
      double max=inp_data["data"][0]["color"];
      
      for(var d in inp_data["data"]){
        if(min>d["color"]) min=d["color"];
        if(max<d["color"]) max=d["color"];
      }
    
      for(var d in inp_data["data"]){
     //   print(d["color"]);  rng.nextDouble()
        color_map[d["state"]]= '#'+ ((d["color"]-min)/(max-min)).toStringAsFixed(16).substring(2, 8);
      }
  }
  
  
  
  void update_frame_change(){
    
    double y_range_length = y_range_max-y_range_min;   // y range length
    double x_range_length = x_range_max-x_range_min;   // x range length
    
    for(var dset in this.data_set_list_overlay){
      
      for(num i=0; i<dset.symbol_set.length; i++){
        dset.symbol_set[i].x = (dset.data_set_unscaled[i].x-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble();
        dset.symbol_set[i].y = (-dset.data_set_unscaled[i].y+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble();             
      }

      dset.line_set.clear();
   //   List <_line_set> temp_scaled_line_set = toObservable([]);                   
      dset.data_set_unscaled.sort((x, y) => x.x.compareTo(y.x));
      double va_x, va_y, vb_x, vb_y;
      va_x = (dset.data_set_unscaled[0].x-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble();
      va_y = (-dset.data_set_unscaled[0].y+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble();
      for(num i=1; i<dset.data_set_unscaled.length; i++){
          vb_x = (dset.data_set_unscaled[i].x-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble();
          vb_y = (-dset.data_set_unscaled[i].y+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble();
          dset.line_set.add(new x_line_set(va_x, va_y, vb_x, vb_y));
          va_x = vb_x;
          va_y = vb_y;
      }    
   //   dset.line_set = temp_scaled_line_set;
      
    }
    
               interval_y = find_interval(this.y_range_max.toDouble(), this.y_range_min.toDouble(), this.y_step.toDouble());    //find the interval
               interval_x = find_interval(this.x_range_max.toDouble(), this.x_range_min.toDouble(), this.x_step.toDouble());    // find the interval
    
              for(int i=0; i<interval_y.length; i++){
                this.y_marker.marker[i].position = ((-interval_y[i]+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble()).toInt(); 
              }     
              this.y_marker.position = this.frame.left-40;
              
              for(int i=0; i<interval_x.length; i++){
                this.x_marker.marker[i].position = ((interval_x[i]-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble()).toInt();
              } 
              this.x_marker.position = this.frame.top+this.frame.height+20;
              
              for(var label in this.label_list){
                label.x = (label.unscaled_x*this.frame.width.toDouble() + this.frame.left.toDouble()).toInt(); // = (-temp_frame.left)/temp_frame.width;
                label.y = (label.unscaled_y*this.frame.height.toDouble() + this.frame.top.toDouble()).toInt();   //label.unscaled_y = (-temp_frame.top)/temp_frame.height;              
              }
    
  }
  
  
  void update_zoom_change(bool is_fixed_step){
    
       double y_range_length = y_range_max-y_range_min;   // y range length
       double x_range_length = x_range_max-x_range_min;   // x range length
       
       for(var dset in this.data_set_list_overlay){  
         
         dset.symbol_set.clear();
         for(num i=0; i<dset.data_set_unscaled.length; i++){
                    double temp_x = (dset.data_set_unscaled[i].x-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble();
                    double temp_y = (-dset.data_set_unscaled[i].y+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble();   
                    bool is_inside_rect = inside_rect(temp_x, temp_y, this.frame.left.toDouble(), this.frame.top.toDouble(), this.frame.width.toDouble(), this.frame.height.toDouble());
                    if(is_inside_rect==true){
                                 dset.symbol_set.add(new _data_set_scaled(temp_x, temp_y));
                    }
         }
         
         
         dset.line_set.clear();                  
         dset.data_set_unscaled.sort((x, y) => x.x.compareTo(y.x));
         double va_x, va_y, vb_x, vb_y;
         va_x = (dset.data_set_unscaled[0].x-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble();
         va_y = (-dset.data_set_unscaled[0].y+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble();
         for(num i=1; i<dset.data_set_unscaled.length; i++){
             vb_x = (dset.data_set_unscaled[i].x-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble();
             vb_y = (-dset.data_set_unscaled[i].y+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble();            
             
             bool is_inside_rect_va = inside_rect(va_x, va_y, this.frame.left.toDouble(), this.frame.top.toDouble(), this.frame.width.toDouble(), this.frame.height.toDouble());
             bool is_inside_rect_vb = inside_rect(vb_x, vb_y, this.frame.left.toDouble(), this.frame.top.toDouble(), this.frame.width.toDouble(), this.frame.height.toDouble());
             
             if(is_inside_rect_va==true && is_inside_rect_vb==true){
               dset.line_set.add(new x_line_set(va_x, va_y, vb_x, vb_y));               
             }
             if(is_inside_rect_va==false && is_inside_rect_vb==true){
               x_y_num va_sss = cross_rect(new x_y_num(va_x, va_y), new x_y_num(vb_x, vb_y), this.frame.left.toDouble(), this.frame.top.toDouble(), this.frame.width.toDouble(), this.frame.height.toDouble());
               dset.line_set.add(new x_line_set(va_sss.x, va_sss.y, vb_x, vb_y));   
             }            
             if(is_inside_rect_va==true && is_inside_rect_vb==false){
               x_y_num vb_sss = cross_rect(new x_y_num(va_x, va_y), new x_y_num(vb_x, vb_y), this.frame.left.toDouble(), this.frame.top.toDouble(), this.frame.width.toDouble(), this.frame.height.toDouble());
               dset.line_set.add(new x_line_set(va_x, va_y, vb_sss.x, vb_sss.y));   
             }    
             
             va_x = vb_x;
             va_y = vb_y;
         }      
         
       }  //end of for(var dset in this.data_set_list_overlay){       
       

       
       if(is_fixed_step==false){       
         if(this.interval_x!=null)     this.interval_x.clear();
         if(this.interval_y!=null)     this.interval_y.clear();
         this.y_marker.marker.clear();
         this.x_marker.marker.clear();         
         num num_of_x_marker = 6;
         num num_of_y_marker = 6;
         double step_x = double.parse((x_range_length/(num_of_x_marker-1)).toStringAsPrecision(1));   // step of y plot
         double step_y = double.parse((y_range_length/(num_of_y_marker-1)).toStringAsPrecision(1));   // step of x plot        
         this.x_step = step_x;
         this.y_step = step_y;             
         this.interval_y = find_interval(y_range_max, y_range_min, step_y);    //find the interval
         this.interval_x = find_interval(x_range_max, x_range_min, step_x);    // find the interval       
                for(int i=0; i<interval_y.length; i++){
                  this.y_marker.marker.add(new _marker(interval_y[i].toString(), ((-interval_y[i]+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble()).toInt()));          // still problematic, to be continued. 
                }    
                for(int i=0; i<interval_x.length; i++){
                  this.x_marker.marker.add(new _marker(interval_x[i].toString(), ((interval_x[i]-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble()).toInt()));          // still problematic, to be continued. 
                }
       }
       
       if(is_fixed_step==true){         
         this.y_marker.marker.clear();
         this.x_marker.marker.clear();              
         this.interval_y = find_interval(y_range_max, y_range_min, this.y_step);    //find the interval
         this.interval_x = find_interval(x_range_max, x_range_min, this.x_step);    // find the interval       
                for(int i=0; i<interval_y.length; i++){
                  this.y_marker.marker.add(new _marker(interval_y[i].toString(), ((-interval_y[i]+y_range_max)/y_range_length*this.frame.height.toDouble()+this.frame.top.toDouble()).toInt()));          // still problematic, to be continued. 
                }    
                for(int i=0; i<interval_x.length; i++){
                  this.x_marker.marker.add(new _marker(interval_x[i].toString(), ((interval_x[i]-x_range_min)/x_range_length*this.frame.width.toDouble()+this.frame.left.toDouble()).toInt()));          // still problematic, to be continued. 
                }         
       }
       
                 
  }
  
 
  
  Data_Plot.server_init(var data){  
 
      this.parent = data["parent"];
      this.x_range_min = data["x_range_min"].toDouble();
      this.x_range_max = data["x_range_max"].toDouble();
      this.y_range_min = data["y_range_min"].toDouble();
      this.y_range_max = data["y_range_max"].toDouble();
      this.x_step = data["x_step"].toDouble();
      this.y_step = data["y_step"].toDouble();
      this.plot_type = data["plot_type"];
      this.serial_number = data["serial_number"];      
      
      Frame temp_frame = new Frame(data["frame"]["left"], data["frame"]["top"], data["frame"]["width"], data["frame"]["height"], false, null, false);    // frame 
      this.frame = temp_frame;      
      
      for(var data_set in data["data_set_list_overlay"]){
        
       List <x_y_num> xy_data = []; 
       for(var ds_un in data_set["data_set_unscaled"]){
         xy_data.add(new x_y_num(ds_un["x"].toDouble(), ds_un["y"].toDouble()));          
       }
       
       List <_data_set_scaled> temp_scaled_data_set = toObservable([]);   
       for(var dss in data_set["symbol_set"]){
         temp_scaled_data_set.add(new _data_set_scaled(dss["x"], dss["y"]));  
       }
       
       List <x_line_set> fit_line_set_temp = toObservable([]);
       for(var fls in data_set["fit_line_set"]){
         fit_line_set_temp.add(new x_line_set(fls["start_x"], fls["start_y"], fls["end_x"], fls["end_y"])); 
       }
       
       List <x_line_set> temp_scaled_line_set = toObservable([]); 
       if(data_set["line_set"]!=null){
         for(var ls in data_set["line_set"]){
           temp_scaled_line_set.add(new x_line_set(ls["start_x"], ls["start_y"], ls["end_x"], ls["end_y"])); 
         }
       }
       
       
       Data_Set _data_set_plot = new Data_Set(xy_data, temp_scaled_data_set, null, temp_scaled_line_set, null, null, data_set["symbol_type"], data_set["line_type"], data_set["plot_type"], fit_line_set_temp);
             
       
       
       _data_set_plot.text_legend = new Label(data_set["text_legend"]["text"], data_set["text_legend"]["x"], data_set["text_legend"]["y"],
           data_set["text_legend"]["unscaled_x"], data_set["text_legend"]["unscaled_y"], data_set["text_legend"]["font_size"], data_set["text_legend"]["rotation_degree"], false, data_set["text_legend"]["color"]);  

       if(data_set["line_style"]!=null){
         _data_set_plot.line_style = new _line_style(data_set["line_style"]["stroke"], data_set["line_style"]["stroke_width"], data_set["line_style"]["fill"]);
       }
       
     //  print(data_set["symbol_style"]); 
       
       _data_set_plot.symbol_style = new _symbol_style_general(data_set["symbol_style"]["radius"], data_set["symbol_style"]["points"], data_set["symbol_style"]["stroke"], data_set["symbol_style"]["stroke_width"], data_set["symbol_style"]["fill"]);       
       
       this.data_set_list_overlay.add(_data_set_plot);
      }
      
      //{"marker":this.marker, "position":this.position, "font_size":this.font_size, "tick_length":this.tick_length, 
     // "tick_stroke_width":this.tick_stroke_width, "tick_stroke":this.tick_stroke}; 
      
      //{"text":this.text, "position":this.position}; 
      
      //{"parent":this.parent, "frame":this.frame, "x_marker":this.x_marker, "y_marker":this.y_marker, "data_set_list_overlay":this.data_set_list_overlay,
  //    "x_range_min":this.x_range_min, "x_range_max":this.x_range_max, "y_range_min":this.y_range_min, "y_range_max":this.y_range_max,
  //    "x_step":this.x_step, "y_step":this.y_step, "label_list":this.label_list, "plot_type":this.plot_type, "serial_number":this.serial_number}; 
      
      List <_marker> temp_y_marker = toObservable([]);     
      for(var tym in data["y_marker"]["marker"]){
        temp_y_marker.add(new _marker(tym["text"], tym["position"])); 
      }
      Marker _y_marker = new Marker(temp_y_marker, data["y_marker"]["position"], data["y_marker"]["font_size"],
          data["y_marker"]["tick_length"], data["y_marker"]["tick_stroke_width"], data["y_marker"]["tick_stroke"]);    
      
      List <_marker> temp_x_marker = toObservable([]);     
      for(var txm in data["x_marker"]["marker"]){
        temp_x_marker.add(new _marker(txm["text"], txm["position"])); 
      }
      Marker _x_marker = new Marker(temp_x_marker, data["x_marker"]["position"], data["x_marker"]["font_size"],
          data["x_marker"]["tick_length"], data["x_marker"]["tick_stroke_width"], data["x_marker"]["tick_stroke"]);    
      
      this.x_marker = _x_marker;
      this.y_marker = _y_marker;
      
      //{"text":this.text, "x":this.x, "y":this.y, "unscaled_x":this.unscaled_x, 
     // "unscaled_y":this.unscaled_y, "font_size":this.font_size, "rotation_degree":this.rotation_degree}; 
      
      for(var lbl in data["label_list"]){
        this.label_list.add(new Label(lbl["text"], lbl["x"], lbl["y"], lbl["unscaled_x"], lbl["unscaled_y"], lbl["font_size"], lbl["rotation_degree"], false, lbl["color"]));  
      }
     
      this.plot_mode_show = true;       
    
  }
  
  
  
  
  void write_to_db(WebSocket ws_write_db){
    
  //  ws_write_db.onOpen.listen((event){
       ws_write_db.send(JSON.encode({"CMD":"insert-data-plot", "data":this.toJson()}));
  //  }); // end of  ws_write_db.onOpen.listen((event){
    
  }
  
}


class x_line_set_plot extends Object with Observable{
  @observable double start_x;
  @observable double start_y;
  @observable double end_x;
  @observable double end_y;
  @observable int num_line;
  @observable String stroke = "green";
  @observable int stroke_width = 3; 
  x_line_set_plot(this.start_x, this.start_y, this.end_x, this.end_y, this.num_line, this.stroke, this.stroke_width);
}

class x_rect_set_plot extends Object with Observable{
  @observable double start_x;
  @observable double start_y;
  @observable double end_x;
  @observable double end_y;
  @observable int num_rect;
  @observable String stroke = "green";
  @observable int stroke_width = 3; 
  @observable String fill = "green";
  x_rect_set_plot(this.start_x, this.start_y, this.end_x, this.end_y, this.num_rect, this.stroke, this.stroke_width, this.fill);
}


  class Line_Plot extends Object with Observable{    
    bool IS_CIRCLE_START_MOVE = false;
    bool IS_CIRCLE_END_MOVE = false;
    bool IS_DRAW_LINE_ALLOWED = false;
    bool IS_DRAW_LINE_START = false;
    @observable bool show_control_point = false;
    @observable int active_line;  //active的直线
    List <x_line_set_plot> line_list = toObservable([]);  //直线列表 this.start_point, this.end_point, 
  //  @observable String 
    Line_Plot(this.IS_DRAW_LINE_ALLOWED, this.IS_DRAW_LINE_START, this.IS_CIRCLE_START_MOVE, this.IS_CIRCLE_END_MOVE, this.show_control_point, this.active_line, this.line_list);    
  }
  
  class Rect_Plot extends Object with Observable{    
    bool IS_CIRCLE_MOVE = false;
    bool IS_DRAW_RECT_ALLOWED = false;
    @observable int active_rect;  //active的直线
    @observable int active_circle; //active的控制点
    @observable bool show_control_point = false;
    List <x_rect_set_plot> rect_list = toObservable([]);   //直线列表
    bool IS_DRAW_RECT_START = false;    
    Rect_Plot(this.IS_DRAW_RECT_ALLOWED, this.IS_DRAW_RECT_START, this.IS_CIRCLE_MOVE, this.show_control_point, this.active_rect, this.active_circle, this.rect_list); 
  }
  
  
  class x_data_set_scaled extends Object with Observable{
    @observable num x;
    @observable num y;
    x_data_set_scaled(this.x, this.y);
    dynamic toJson() => {"x":this.x, "y":this.y}; 
  }
  
  class x_polyline_plot extends Object with Observable{    
    List <x_data_set_scaled> point_set = toObservable([]);
    @observable String points = ""; 
    @observable String stroke = "green";
    @observable int stroke_width = 3; 
    @observable String polyline_or_polygon = ""; 
    x_polyline_plot(this.point_set, this.points, this.stroke, this.stroke_width, this.polyline_or_polygon);
    void update_point_chage(){
         this.points = ""; 
         for(int i=0; i<point_set.length; i++){
           this.points += point_set[i].x.toString() + "," + point_set[i].y.toString() + " "; 
         }
      }
  }
  
  class Polyline_Plot extends Object with Observable{    
    bool IS_CIRCLE_MOVE = false;
    bool IS_DRAW_POLYLINE_ALLOWED = false;
    @observable int active_polyline = 0;  //active的直线
    @observable int active_circle = 0; //active的控制点
    @observable bool show_control_point = false;
    List <x_polyline_plot> polyline_list = toObservable([]);   //直线列表
    bool IS_DRAW_POLYLINE_START = false;   
    bool INTERMEDIATE_CLICK = true; 
    String temp_polyline_or_polygon = "polyline";
    Polyline_Plot(); 
  }

  
  class Func_Plot extends Object with Observable{
    @observable bool show_plotfunc_dialog = false;
    @observable String plot_fuction;
    @observable double x_min, x_max;
    @observable int num_of_point_for_plot;     
    List <x_line_set> plot_line_set = toObservable([]);
    Func_Plot(this.show_plotfunc_dialog, this.plot_fuction, this.x_min, this.x_max, this.num_of_point_for_plot, this.plot_line_set);
  }
  
  class Screen_Reader extends Object with Observable{
    @observable bool show = false;
    @observable String x_value;
    @observable String y_value;
    @observable num x_value_scaled = 0.0;
    @observable num y_value_scaled = 0.0;
    @observable bool data_reader_enable = false; 
    @observable bool data_clicked = false; 
    Screen_Reader(this.show, this.x_value, this.y_value, this.data_reader_enable, this.data_clicked, this.x_value_scaled, this.y_value_scaled);
  }
  
  class Zoom_Range{
    double x_range_min;
    double x_range_max; 
    double y_range_min; 
    double y_range_max;  //ra
    Zoom_Range(this.x_range_min, this.x_range_max, this.y_range_min, this.y_range_max);
  }
  
  class Zoom_Temp extends Object with Observable{
    @observable int start_x;
    @observable int start_y;
    @observable int end_x;
    @observable int end_y;
    Zoom_Temp(this.start_x, this.start_y, this.end_x, this.end_y);
  }
  
  class Zoom_Control extends Object with Observable{
    bool ZOOM_IN_ALLOWED = false;
    @observable bool ZOOM_IN_STARTED = false;
    Zoom_Temp temp_range;
    List <Zoom_Range> zoom_history = [];    
    Zoom_Control(this.ZOOM_IN_ALLOWED, this.ZOOM_IN_STARTED, this.zoom_history, this.temp_range);
  }
  
    
  class CTXmenu_Show extends Object with Observable{
    @observable bool contextmenu_show;
    @observable String menu_type;  // four values to be used: "cell", "region", "column", "row" and "all"~~~~~~~~~~~~~ default value is "cell"
    @observable num x_pos;
    @observable num y_pos;
  //  @observable int data_idx;
 //   @observable int plt_idx;
    CTXmenu_Show(this.contextmenu_show, this.menu_type, this.x_pos, this.y_pos); //, this.data_idx, this.plt_idx);
  }
  
/**
 * A Polymer click counter element.
 */
  
  class Plot2dElement_ extends Object with Observable{
    @observable Fit_Setting fit_setting;
    @observable Poly_Fit_Setting poly_fit_setting;
    @observable Line_Plot line_plot;
    @observable Rect_Plot rect_plot;
    @observable Polyline_Plot polyline_plot; 
    @observable Func_Plot func_plot;    
    @observable Screen_Reader screen_reader;
    @observable Zoom_Control zoom_control; 
    @observable CTXmenu_Show ctxmenu_show;
  //  @published String plot_type;
  //  @published dynamic plot_data;    
    List <Data_Plot> data_plot_list = toObservable([]);
    @observable num active_plot = 0;  // data_plot_list[active_plot]
    
    
    Plot2dElement_.dbinit(String parentID){
      
      //String parentID)
       
       var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");      
       ws_read_db.onOpen.listen((event){
          ws_read_db.send(JSON.encode({"CMD":"read-data-plot", "filter":{"parent":parentID}}));
       }); // end of  ws_write_db.onOpen.listen((event){
       
       ws_read_db.onMessage.listen((event){         
         var data = JSON.decode(event.data);      
         Data_Plot temp_data_plot = new Data_Plot.server_init(data);      
         data_plot_list.add(temp_data_plot);         
       }); 
       
       
       fit_setting = new Fit_Setting(false, "c*x*x+b*x+a", toObservable(["c", "b", "a"]), toObservable([1.2, 1.0, 1.0]), 20.0, 80.0, 40, null, null); 
       poly_fit_setting = new Poly_Fit_Setting(1, 20.0, 80.0, 40, null, null, toObservable([])); 
       
       List <x_line_set_plot> temp_line_list = toObservable([]);
       line_plot = new Line_Plot(false, false, false, false, false, 0, temp_line_list);   
      // line_plot.line_list.add(new _line_set_plot(100.0, 100.0, 400.0, 400.0, 0));
       
       List <x_rect_set_plot> temp_rect_list = toObservable([]);
       rect_plot = new Rect_Plot(false, false, false, false, null, null, temp_rect_list);
       
       List <x_line_set> temp_line_set = toObservable([]);
       func_plot = new Func_Plot(false, "x*x", 0.0, 3.0, 30, temp_line_set);
       
       polyline_plot = new Polyline_Plot(); 
       
       screen_reader = new Screen_Reader(false, null, null, false, false, null, null );
     
       zoom_control = new Zoom_Control(false, false, [], new Zoom_Temp(null, null, null, null));
       
       ctxmenu_show = new CTXmenu_Show(false, null, null, null); //, 0, 0);
       
      
    }
    
    
    Plot2dElement_.init(String plot_type, dynamic plot_data, String parentID){     // here the plot_type is for "spreading"
      /*
      // data_plot_list = toObservable([]);
       
       if(plot_type=="symbol_2d"||plot_type=="line_2d"||plot_type=="linesymbol_2d"||plot_type=="rectangular"){
      //      print(plot_type);
            data_plot = new Data_Plot.boring_init(plot_data, plot_type, 0); 
          }


        
        if(plot_type=="overlay"){
          data_plot = new Data_Plot.overlay_init(plot_data); 
        }
        
        if(plot_type=="interactive"){
          data_plot = new Data_Plot.interactive_init(plot_data);         
        }
        
        */
      
      if(plot_type=="geography"){
        Data_Plot temp_data_plot = new Data_Plot.geotraphy_init(plot_data, plot_type, 0, parentID); 
        data_plot_list.add(temp_data_plot);
      }
      
      
      if(plot_type=="2d_heat_map"){
        Data_Plot temp_data_plot = new Data_Plot.heat_map_init(plot_data); 
        data_plot_list.add(temp_data_plot);
      }      
      
      if(plot_type=="2d_heat_map_interpo"){
        Data_Plot temp_data_plot = new Data_Plot.heat_map_init_interpo(plot_data); 
        data_plot_list.add(temp_data_plot);
      }  
      
      
      if(plot_type=="overlay"){        
        Data_Plot temp_data_plot = new Data_Plot.overlay_init(plot_data, plot_type, 0, " ", parentID); 
        data_plot_list.add(temp_data_plot);
      }
      
      
         
        if(plot_type=="spreading"){  
          
          for(int i=0; i<plot_data.length; i++){
          //for(var g_data in plot_data){
            //Grouped_Data  g_data = plot_data[i];   // think about how to make them look consistent
            Grouped_Data_List g_data = plot_data[i];
            String _plot_type_ = g_data.plot_type;
            Data_Plot temp_data_plot; 
            
            // problem: the frame should be different for different plots, modify this latter 
            
     /*       if(_plot_type_=="symbol_2d"||_plot_type_=="line_2d"||_plot_type_=="linesymbol_2d"||_plot_type_=="rectangular"){
                 temp_data_plot = new Data_Plot.boring_init(g_data.data_list, _plot_type_, i); 
              }  */
            
            if(_plot_type_=="overlay"){
              temp_data_plot = new Data_Plot.overlay_init(g_data.data_list, _plot_type_, i, g_data.group_label+"="+g_data.group_value, parentID); 
            }
            
            /*
            
            if(_plot_type_=="geography"){
              temp_data_plot = new Data_Plot.geotraphy_init(plot_data); 
            }
            if(_plot_type_=="2d_heat_map"){
              temp_data_plot = new Data_Plot.heat_map_init(plot_data); 
            }      */       
            data_plot_list.add(temp_data_plot);
          }
            
        }   // end of if(plot_type=="spreading"){  
        
        //print(data_plot_list.length);
        //print(data_plot_list[active_plot].frame.left);
        
        /*
        if(plot_type=="distinct"){
          data_plot = new Data_Plot.distinct_init(plot_data);         
        }
        
        if(plot_type=="3d_stack"){
          data_plot = new Data_Plot.d3stack_init(plot_data);           
        }
        
        if(plot_type=="dynamic"){
          data_plot = new Data_Plot.dynamic_init(plot_data);           
        }
        */
        
        fit_setting = new Fit_Setting(false, "c*x*x+b*x+a", toObservable(["c", "b", "a"]), toObservable([1.2, 1.0, 1.0]), 20.0, 80.0, 40, null, null); 
        poly_fit_setting = new Poly_Fit_Setting(1, 20.0, 80.0, 40, null, null, toObservable([])); 
        
        List <x_line_set_plot> temp_line_list = toObservable([]);
        line_plot = new Line_Plot(false, false, false, false, false, 0, temp_line_list);   
       // line_plot.line_list.add(new _line_set_plot(100.0, 100.0, 400.0, 400.0, 0));
        polyline_plot = new Polyline_Plot(); 
        
        List <x_rect_set_plot> temp_rect_list = toObservable([]);
        rect_plot = new Rect_Plot(false, false, false, false, null, null, temp_rect_list);
        
        List <x_line_set> temp_line_set = toObservable([]);
        func_plot = new Func_Plot(false, "x*x", 0.0, 3.0, 30, temp_line_set);
        
        screen_reader = new Screen_Reader(false, null, null, false, false, null, null);
      
        zoom_control = new Zoom_Control(false, false, [], new Zoom_Temp(null, null, null, null));
        
        ctxmenu_show = new CTXmenu_Show(false, null, null, null); //, 0, 0);
    }
    
  } 