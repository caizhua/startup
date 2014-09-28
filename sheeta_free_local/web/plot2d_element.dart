library plot2d;

import './plot2d-core.dart'; 
import 'package:polymer/polymer.dart';
import 'dart:convert';
//import './interval_decimal.dart';
import 'dart:html';
//import './shared_functions.dart';
import 'dart:js';
//import 'dart:svg' as svg;
//import 'dart:async'; 
import 'dart:math';
import './ui_filters.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;
  
  
@CustomTag('plot2d-element')
class Plot2dElement extends PolymerElement {
//  @published String parentID; 
 // @observable Data_Plot data_plot;  
  @published Fit_Setting fit_setting;
  @published Poly_Fit_Setting poly_fit_setting;  
  @published Line_Plot line_plot;
  @published Rect_Plot rect_plot;
  @published Polyline_Plot polyline_plot; 
  @published Func_Plot func_plot;
  @published Screen_Reader screen_reader;
  @published Zoom_Control zoom_control; 
  @published CTXmenu_Show ctxmenu_show;
/*  
  @published String plot_type;
  @published dynamic plot_data;
*/  
  @published List <Data_Plot> data_plot_list = toObservable([]);
  @published num active_plot = 0;  // data_plot_list[active_plot]
  @observable num active_data = 0; 
  @observable num active_label = 0;   
  Data_Plot temp_data_plot;    
  bool DRAW_TEXT_ALLOWED = false; 
  bool DRAW_TEXT_STARTED = false;   
  @observable bool PLOT_SETTING_FRAME = false;
  @observable bool PLOT_SETTING_AXIS = false; 
  @observable bool PLOT_SETTING_DATA_MANAGE = false;
  @observable bool PLOT_SETTING_DATA_STYLE = false;
  @observable bool PLOT_SETTING_SHOW = false;  
  @observable bool FIT_SETTING_SHOW = false; 
  @observable bool POLY_FIT_SET_SHOW = false;   
  @observable bool DIFF_EQ_PARA_EST = false; 
  @observable bool PLOT_SETTING_LABEL_STYLE = false;
  @observable bool PLOT_SETTING_LEGEND_BOX = false; 
  @observable bool EMBED_SHARED_DIALOG = false;
  @observable bool EMAIL_FIGURE_DIALOG = false; 
  @observable String email_content = "";
  @observable String share_link = "";   
  @observable bool RIBBON_FIGURE = true;
  @observable bool RIBBON_EDIT = false;
  @observable bool RIBBON_DRAW = false;
  @observable bool RIBBON_TEXT = false;
  @observable bool RIBBON_FIGURE_STYLE = false;
  @observable bool RIBBON_ANALYSIS = false; 
  @observable String active_draw_object = "nothing";  // possible opiton include line, rect, polyline, polygon, curve
  @observable String stroke_color_predefined = "#009900"; 
  @observable int stroke_width_color_predefined = 3; 
  @observable num text_select_rect_left = 0; 
  @observable num text_select_rect_top = 0; 
  @observable num text_select_rect_width = 0; 
  @observable num text_select_rect_height = 0;   
 // @observable bool text_select_rect_show = false;   
//  @observable bool PLOT_SETTING_LABEL = false;
  Map symbol_style_map = {
    "circle":null,
    "square":"0,0 1,0 1,1 0,1",
    "rectangle":"0,0 1,0 1,2 0,2" , 
    "triangle":"0,0 2,0 1,1.732" , 
    "cross":"5,5 5,0 5,10 5,5 0,5 10,5"
  }; 
  
  Map dash_array_map = {
     "solid":null,                   
     "long-dash": "10, 5",
     "short-dash": "5, 5",
     "dotted": "1, 5",
     "dash-dot": "5, 5, 1, 5"
  };   
  
  List color_map = [  "#000000",   "#000F05",  "#001F0A",  "#002E0F", "#003D14",  "#004C1A", "#005C1F",  "#006B24",  "#007A29",
                      "#008A2E",  "#009933",  "#19A347",  "#33AD5C",  "#4DB870",  "#66C285", "#80CC99", "#99D6AD",  "#B2E0C2",
                  "#CCEBD6",      "#E6F5EB",     "#FFFFFF", 
                  "#FFE6E6", "#FFCCCC", "#FFB2B2", "#FF9999", "#FF8080",  "#FF6666",  "#FF4D4D", "#FF3333",  "#FF1919", "#FF0000"  ];
  //String temp_polyline_or_polygon; // = "polyline"; 
  //String xxx; 
  

Plot2dElement.created() : super.created() { }//this.Re_init();  }

final Transformer asInteger = new StringToInt();
final Transformer asDouble = new StringToDouble();

void zoom_in_start(){
  zoom_control.ZOOM_IN_ALLOWED = true;
}

void zoom_out_start(){
  
  if(zoom_control.zoom_history.length>0){
    int last_index = zoom_control.zoom_history.length-1;
    data_plot_list[active_plot].x_range_min = zoom_control.zoom_history[last_index].x_range_min ;
    data_plot_list[active_plot].x_range_max = zoom_control.zoom_history[last_index].x_range_max ;
    data_plot_list[active_plot].y_range_min = zoom_control.zoom_history[last_index].y_range_min ;
    data_plot_list[active_plot].y_range_max = zoom_control.zoom_history[last_index].y_range_max ;
    data_plot_list[active_plot].update_zoom_change(false);     
    zoom_control.zoom_history.removeAt(last_index);
  }
  
}

void show_screen_reader(){
  screen_reader.show = true;
}

void show_data_reader(){
  screen_reader.show = true;
  screen_reader.data_reader_enable = true; 
}

void data_reader_value(Event event, var detail, Element target){
  if(screen_reader.data_reader_enable==true){
    screen_reader.data_clicked = true; 
    int index = int.parse(target.attributes['data-msg']);  
    screen_reader.x_value = data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled[index].x.toString(); 
    screen_reader.y_value = data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled[index].y.toString(); 
    screen_reader.x_value_scaled = data_plot_list[active_plot].data_set_list_overlay[active_data].symbol_set[index].x; 
    screen_reader.y_value_scaled = data_plot_list[active_plot].data_set_list_overlay[active_data].symbol_set[index].y; 
  }
}



void hide_screen_reader(){
  screen_reader.show = false;
  screen_reader.data_reader_enable = false; 
  screen_reader.data_clicked = false; 
}

void draw_text_start(){
  DRAW_TEXT_ALLOWED = true;
}
  

  void show_curve_fit(){
    FIT_SETTING_SHOW = true; 
//    $['dialog'].toggle();     
  }
  
  void fit_set_add_para(){
    fit_setting.para_name.add("c");
    fit_setting.para_value.add(1.0);
  }
  
  void fit_set_del_para(Event event, var detail, Element target){
    int idx = int.parse(JSON.decode(target.attributes['data-msg']));
    fit_setting.para_name.removeAt(idx);
    fit_setting.para_value.removeAt(idx);
  }
  
  void show_curve_fit_cancel(){
    FIT_SETTING_SHOW = false; 
  //  $['dialog'].toggle();     
  }

  void do_curve_fit(){
 //   $['dialog'].toggle();     
 //   FIT_SETTING_SHOW = false; 
  //  fit_setting.show_fit_dialog = false;
  //  data_plot_list[active_plot].plot_mode_show=true;
    List <double > _x_data = [];
    List <double > _y_data = [];
    
    for(var d in data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled){
      if(d.x<fit_setting.x_max && d.x>fit_setting.x_min){
        _x_data.add(d.x);
        _y_data.add(d.y);
      }      
    }    
    
    var x_data = new JsObject.jsify(_x_data);
    var y_data = new JsObject.jsify(_y_data);    
    List <String> _var_list = ["x"];
    var var_list = new JsObject.jsify(_var_list);
    var para_list = new JsObject.jsify(fit_setting.para_name);
    var para_init = new JsObject.jsify(fit_setting.para_value);      
        
    var fit = new JsObject(context['LM_LSQ'], []);    
    var para =  fit.callMethod('LM_FIT', [x_data, y_data, var_list, para_list, para_init, fit_setting.fit_fuction]);
    
  //  print(para);
    for(int i=0; i<para_list.length; i++){
      fit_setting.para_value[i] = double.parse( para[i].toStringAsPrecision(5)); 
    }   
    
    double x_min = fit_setting.x_min; 
    double x_max = fit_setting.x_max; 
    double step = (x_max-x_min)/fit_setting.num_of_point_for_plot;
    
    var obj = new JsObject(context["mathjs"]);    
    var s = obj.callMethod('compile', [fit_setting.fit_fuction]);    
    
    fit_setting.squared_error = 0.0;
    fit_setting.correlation_coefficient = 0.0; 
    double y_var = obj.callMethod('var', [y_data]);
  //  dboule y_squared_error = 0; 
    
    var temp_scope = new Map();
    for(int i=0; i<para_list.length; i++){
      temp_scope[para_list[i]] = para[i];
    }  
    
    for(var d in data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled){        
      temp_scope[_var_list[0]] = d.x;
      var scope = new JsObject.jsify(temp_scope);      
      double y_cal = s.callMethod('eval', [scope]).toDouble(); 
      fit_setting.squared_error += (y_cal-d.y)*(y_cal-d.y); 
    }
    
    fit_setting.correlation_coefficient = sqrt(1.0-fit_setting.squared_error/y_var); 
    
    
   // var obj = new JsObject(context["mathjs"]);
    
    double _s_x, _s_y, _e_x, _e_y;
    double start_x, end_x, start_y, end_y;
    double x_range_length = data_plot_list[active_plot].x_range_max - data_plot_list[active_plot].x_range_min;
    double y_range_length = data_plot_list[active_plot].y_range_max - data_plot_list[active_plot].y_range_min;     
    
    for(int i=0; i<fit_setting.num_of_point_for_plot; i++){
      
      start_x = x_min+i*step;
      end_x = x_min+(i+1)*step;      
    //  var temp_scope = new Map();
    //  for(int i=0; i<para_list.length; i++){
    //    temp_scope[para_list[i]] = para[i];
    //  }          
      temp_scope[_var_list[0]] = start_x;
      var scope = new JsObject.jsify(temp_scope);      
      start_y =  s.callMethod('eval', [scope]).toDouble(); 
      temp_scope[_var_list[0]] = end_x;
      var scope2 = new JsObject.jsify(temp_scope);     
      end_y = s.callMethod('eval', [scope2]).toDouble();     
 
      _s_x = (start_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
      _s_y = (-start_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();          
      _e_x = (end_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
      _e_y = (-end_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();
      
      data_plot_list[active_plot].data_set_list_overlay[active_data].fit_line_set.add(new x_line_set(_s_x, _s_y, _e_x, _e_y));       
      
    }  // end of for(int i=0; i<199; i++){    
  }  //end of void do_curve_fit(){
  
  
  void show_poly_fit_dialog(){
    POLY_FIT_SET_SHOW = true; 
  //  $['dialog'].toggle();     
  }
  
  void show_poly_fit_cancel(){
    POLY_FIT_SET_SHOW = false; 
  //  $['dialog'].toggle();      
  }
  
  
  void do_polynomial_fit(){
   //   $['dialog'].toggle();     
   //   POLY_FIT_SET_SHOW = false; 
      List <double > _x_data = [];
      List <double > _y_data = [];
      
      for(var d in data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled){
        if(d.x<fit_setting.x_max && d.x>fit_setting.x_min){
          _x_data.add(d.x);
          _y_data.add(d.y);
        }      
      }    
      
      int N = _x_data.length;
      int k = poly_fit_setting.poly_order+1; 
      
      List <List<double>> xmat = [];
      
      for(int i=0; i<N; i++){
        List <double> t_xmat = [];        
        for(int j=0; j<k; j++){
          t_xmat.add(pow(_x_data[i], j));       
        }
        xmat.add(t_xmat);
      }
      
      var y = new JsObject.jsify(_y_data);
      var x = new JsObject.jsify(xmat);
      
      var p = new JsObject(context["mathjs"]);  
      var xt = p.callMethod("transpose", [x]);  
      var ymul = p.callMethod("multiply", [xt, y]);  
      var xmul = p.callMethod("multiply", [xt, x]);  
      var xmul_inv = p.callMethod("inv", [xmul]);  
      var fit_out = p.callMethod("multiply", [xmul_inv, ymul]);  
      
      
      var obj = new JsObject(context["mathjs"]);    
      var s = obj.callMethod('compile', [fit_setting.fit_fuction]);    
      
      poly_fit_setting.squared_error = 0.0;
      poly_fit_setting.correlation_coefficient = 0.0; 
      double y_var = obj.callMethod('var', [y]);
      
      for(int j=0; j<k; j++){
        poly_fit_setting.para_value.add(double.parse( fit_out[j].toStringAsPrecision(5))); 
      }
      
      for(var d in data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled){
        double y_cal = 0.0; 
        for(int j=0; j<k; j++){
          y_cal += fit_out[j]*pow(d.x, j);      
        }
        poly_fit_setting.squared_error += (y_cal-d.y)*(y_cal-d.y);        
      }
      
      poly_fit_setting.correlation_coefficient = sqrt(1.0-poly_fit_setting.squared_error/y_var);       
      
      double x_min = poly_fit_setting.x_min; 
      double x_max = poly_fit_setting.x_max; 
      double step = (x_max-x_min)/poly_fit_setting.num_of_point_for_plot;
      
      
      
      double _s_x, _s_y, _e_x, _e_y;
      double start_x, end_x, start_y, end_y;
      double x_range_length = data_plot_list[active_plot].x_range_max - data_plot_list[active_plot].x_range_min;
      double y_range_length = data_plot_list[active_plot].y_range_max - data_plot_list[active_plot].y_range_min;     
      
      for(int i=0; i<poly_fit_setting.num_of_point_for_plot; i++){
        
        start_x = x_min+i*step;
        end_x = x_min+(i+1)*step;  
        start_y = 0.0;   
        end_y = 0.0;     
        
        for(int j=0; j<k; j++){
          start_y += fit_out[j]*pow(start_x, j);    
          end_y += fit_out[j]*pow(end_x, j);    
        }
   
        _s_x = (start_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
        _s_y = (-start_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();          
        _e_x = (end_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
        _e_y = (-end_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();
        
        data_plot_list[active_plot].data_set_list_overlay[active_data].fit_line_set.add(new x_line_set(_s_x, _s_y, _e_x, _e_y));       
        
      }  // end of for(int i=0; i<199; i++){    
    }  //end of void do_curve_fit(){
  
  
  
  
  void show_diff_eq_para_est(){
  //  $['dialog'].toggle();     
    DIFF_EQ_PARA_EST = true;    
//    fit_setting = new Fit_Setting(false, "b*x+a", toObservable(["b", "a"]), toObservable([1.0, 1.0]), 20.0, 80.0, 40); 
  }
  
  void diff_eq_para_est_cancel(){
    DIFF_EQ_PARA_EST = false;
  //  $['dialog'].toggle();     
  }
  
  void do_diff_eq_para_est(){
  //  $['dialog'].toggle();     
    DIFF_EQ_PARA_EST = false;
  //  fit_setting.show_fit_dialog = false;
  //  data_plot_list[active_plot].plot_mode_show=true;
    List <double > _x_data = [];
    List <double > _y_data = [];
    
    for(var d in data_plot_list[active_plot].data_set_list_overlay[active_data].data_set_unscaled){
      if(d.x<fit_setting.x_max && d.x>fit_setting.x_min){
        _x_data.add(d.x);
        _y_data.add(d.y);
      }      
    }    
    
    var x_data = new JsObject.jsify(_x_data);
    var y_data = new JsObject.jsify(_y_data);    
    List <String> _var_x_list = ["x"];
    var var_x_list = new JsObject.jsify(_var_x_list);
    List <String> _var_y_list = ["y"];
    var var_y_list = new JsObject.jsify(_var_y_list);
    var para_list = new JsObject.jsify(fit_setting.para_name);
    var para_init = new JsObject.jsify(fit_setting.para_value);      
        
    var fit = new JsObject(context['LM_LSQ'], []);    
    var para =  fit.callMethod('LM_DIFF', [x_data, y_data, var_x_list, var_y_list, para_list, para_init, fit_setting.fit_fuction]);
    
   // print(para);   // x_data, y_data, var_x_list, var_y_list, para_list, para_init, func_str
    
 //   print(para["x_out"]);
 //   print(para["y_out"]);
    double _s_x, _s_y, _e_x, _e_y;
    double start_x, end_x, start_y, end_y;
    
    start_x = para["x_out"][0];
    start_y = para["y_out"][0];
    
    double x_range_length = data_plot_list[active_plot].x_range_max - data_plot_list[active_plot].x_range_min;
    double y_range_length = data_plot_list[active_plot].y_range_max - data_plot_list[active_plot].y_range_min;    
    
    for(int i=1; i<para["x_out"].length; i++){
      end_x = para["x_out"][i];
      end_y = para["y_out"][i];
      
      _s_x = (start_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
      _s_y = (-start_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();          
      _e_x = (end_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
      _e_y = (-end_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();
      
      data_plot_list[active_plot].data_set_list_overlay[active_data].fit_line_set.add(new x_line_set(_s_x, _s_y, _e_x, _e_y));  
      
      start_x = end_x;
      start_y = end_y; 
    }
    
    
  }
  
  void ribbon_figure_show(){
    RIBBON_FIGURE = true;
    RIBBON_DRAW = false;
    RIBBON_TEXT = false;
    RIBBON_FIGURE_STYLE = false;
    RIBBON_ANALYSIS = false; 
    RIBBON_EDIT = false;
  }
  
  void ribbon_draw_show(){
    RIBBON_FIGURE = false; 
    RIBBON_DRAW = true;
    RIBBON_TEXT = false;
    RIBBON_FIGURE_STYLE = false;
    RIBBON_ANALYSIS = false; 
    RIBBON_EDIT = false;
  }
  
  void ribbon_text_show(){
    RIBBON_FIGURE = false; 
    RIBBON_DRAW = false;
    RIBBON_TEXT = true;
    RIBBON_FIGURE_STYLE = false;
    RIBBON_ANALYSIS = false; 
    RIBBON_EDIT = false;
  }
  
  void ribbon_figure_style_show(){
    RIBBON_FIGURE = false; 
    RIBBON_DRAW = false;
    RIBBON_TEXT = false;
    RIBBON_FIGURE_STYLE = true;
    RIBBON_ANALYSIS = false; 
    RIBBON_EDIT = false;
  }
  
  void ribbon_edit_show(){
    RIBBON_EDIT = true;
    RIBBON_FIGURE = false; 
    RIBBON_DRAW = false;
    RIBBON_TEXT = false;
    RIBBON_FIGURE_STYLE = false;
    RIBBON_ANALYSIS = false; 
  }
  
  /*
  
  void ribbon_frame_style(){
    
  }
  
  void ribbon_axis_style(){
    
  }
  
  void ribbon_data_set_style(){
    
  }
  
  void ribbon_legend_box_style(){
    
  }
  
  void ribbon_label_style(){
    
  }
  * 
  * */
  
  void ribbon_analysis_show(){
    RIBBON_FIGURE = false; 
    RIBBON_DRAW = false;
    RIBBON_TEXT = false;
    RIBBON_FIGURE_STYLE = false;
    RIBBON_ANALYSIS = true; 
    RIBBON_EDIT = false;
  }
    

  
   void plt_show_setting(Event event, var detail, Element target){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_FRAME = true;
     $['dialog'].toggle(); 
  
   }
   
   void plt_setting_apply(Event event, var detail, Element target){
     PLOT_SETTING_SHOW = false;
     $['dialog'].toggle();      
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = false;     
     PLOT_SETTING_LEGEND_BOX = false; 
   }
   
   
   void plt_setting_cancel(Event event, var detail, Element target){
     PLOT_SETTING_SHOW = false;
     $['dialog'].toggle();    
     
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = false;
     PLOT_SETTING_LEGEND_BOX = false; 
   //  data_plot_list[active_plot].plot_setting.plot_setting_show = false;
   }
   
   void plt_setting_frame(){
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = true;
     PLOT_SETTING_LABEL_STYLE = false;
     PLOT_SETTING_LEGEND_BOX = false; 
   }
   
   void plt_setting_axis(){
     PLOT_SETTING_AXIS = true;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = false;
     PLOT_SETTING_LEGEND_BOX = false; 
   }
   
   void plt_setting_data_manage(){
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = true;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = false;
     PLOT_SETTING_LEGEND_BOX = false; 
   }
   
   void plt_setting_data_style(){
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = true;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = false;
     PLOT_SETTING_LEGEND_BOX = false; 
   }
   
   void plt_setting_label_style(){
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = true;
     PLOT_SETTING_LEGEND_BOX = false; 
   }
   
   void plt_setting_legend_box(){
     PLOT_SETTING_AXIS = false;
     PLOT_SETTING_DATA_MANAGE = false;
     PLOT_SETTING_DATA_STYLE = false;
     PLOT_SETTING_FRAME = false;
     PLOT_SETTING_LABEL_STYLE = false;
     PLOT_SETTING_LEGEND_BOX = true; 
   }
   
   void data_set_mod_sty(){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_DATA_STYLE = true;
     $['dialog'].toggle(); 
   //  ctxmenu_show.contextmenu_show = false;   
   }
   
   void lenged_box_style(){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_LEGEND_BOX = true; 
     $['dialog'].toggle(); 
   }
   
   void data_set_manage(){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_DATA_MANAGE = true;
     $['dialog'].toggle(); 
   }
   
   void label_modify_style(){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_LABEL_STYLE = true;
     $['dialog'].toggle(); 
   }
   
   void frame_modify_style(){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_FRAME = true;
     $['dialog'].toggle(); 
   }
   
   
   void axis_modify_style(){
     PLOT_SETTING_SHOW = true;
     PLOT_SETTING_AXIS = true;
     $['dialog'].toggle();      
   }
   
   void adjust_frame_change(){
     data_plot_list[active_plot].update_frame_change(); 
   }
   
   void adjust_axis_change(){
     data_plot_list[active_plot].update_zoom_change(true); 
   }
   
   
   void change_data_set(Event event, var detail, Element target){
     active_data = int.parse(target.attributes['data-msg']);     
   }
   
   void change_label_(Event event, var detail, Element target){
     active_label = int.parse(target.attributes['data-msg']);  
   }
   
   void delete_label_(Event event, var detail, Element target){
     int index = int.parse(target.attributes['data-msg']);  
     data_plot_list[active_plot].label_list.removeAt(index); 
   }
   
   
   void show_ctrl_pt_line(Event event, var detail, Element target){
     active_draw_object = "line"; 
     line_plot.active_line = int.parse(target.attributes['data-msg']);
     line_plot.show_control_point=true;
   }
   
   
 circle_start_move() => line_plot.IS_CIRCLE_START_MOVE = true;   
 circle_end_move() => line_plot.IS_CIRCLE_END_MOVE = true;
 
 
 void draw_line_start(){     
   line_plot.IS_DRAW_LINE_ALLOWED = true;
   zoom_control.temp_range.start_x = null;
   zoom_control.temp_range.start_y = null;
   zoom_control.temp_range.end_x = null;
   zoom_control.temp_range.end_y = null;
 }
    
   
   void show_ctrl_pt_rect(Event event, var detail, Element target){
     active_draw_object = "rectangle"; 
  //   rect_plot.IS_CIRCLE_MOVE = true;
     rect_plot.show_control_point = true;
     rect_plot.active_rect = int.parse(target.attributes['data-msg']);
   }
   
   void circle_rect_move(Event event, var detail, Element target){
     rect_plot.IS_CIRCLE_MOVE = true;
     rect_plot.active_circle = int.parse(target.attributes['data-msg']);
   }
   
   void circle_frame_move(Event event, var detail, Element target){
     data_plot_list[active_plot].frame.active_circle = int.parse(target.attributes['data-msg']);
     data_plot_list[active_plot].frame.IS_CIRCLE_MOVE = true;
   }
   

   void draw_rect_start(){
         rect_plot.IS_DRAW_RECT_ALLOWED = true;
   }
   
   void draw_polyline_start(){
     polyline_plot.IS_DRAW_POLYLINE_ALLOWED = true; 
     polyline_plot.temp_polyline_or_polygon = "polyline"; 
     active_draw_object = "polyline"; 
   }
   
   void show_ctrl_pt_polyline(Event event, var detail, Element target){
     active_draw_object = "polyline"; 
  //   rect_plot.IS_CIRCLE_MOVE = true;
     polyline_plot.show_control_point = true;
     polyline_plot.active_polyline = int.parse(target.attributes['data-msg']);
   }
   
   
   void circle_polyline_move(Event event, var detail, Element target){
     polyline_plot.IS_CIRCLE_MOVE = true; 
     polyline_plot.active_circle = int.parse(target.attributes['data-msg']);
   }
   
   void draw_polygon_start(){
     polyline_plot.IS_DRAW_POLYLINE_ALLOWED = true; 
     polyline_plot.temp_polyline_or_polygon = "polygon"; 
     active_draw_object = "polyline"; 
    // print("ccc");
   //  print(this.temp_polyline_or_polygon); 
    // xxx = "polygon"; 
   }
   
   void predefined_stroke_update(Event event, var detail, Element target){
     stroke_color_predefined = target.attributes['data-msg']; 
   }
   
   void predefined_stroke_with_update(Event event, var detail, Element target){
     stroke_width_color_predefined = int.parse(target.attributes['data-msg']);
   }
   
   
   void draw_func_dialog_show(){
     $['dialog'].toggle(); 
     func_plot.show_plotfunc_dialog = true;
   //  data_plot_list[active_plot].plot_mode_show=false;
   }
   
   void plot_function_cancel(){
     $['dialog'].toggle(); 
     func_plot.show_plotfunc_dialog = false;
   //  data_plot_list[active_plot].plot_mode_show=true;
   }
   
   void do_plot_function(){
     $['dialog'].toggle(); 
     func_plot.show_plotfunc_dialog = false;
  //   data_plot_list[active_plot].plot_mode_show=true;
     
         double x_min =func_plot.x_min; 
         double x_max =func_plot.x_max; 
         double step = (x_max-x_min)/func_plot.num_of_point_for_plot;
         
         var obj = new JsObject(context["mathjs"]);    
         var s = obj.callMethod('compile', [func_plot.plot_fuction]);
         
        // var obj = new JsObject(context["mathjs"]);
         
         double _s_x, _s_y, _e_x, _e_y;
         double start_x, end_x, start_y, end_y;
         
         for(int i=0; i<func_plot.num_of_point_for_plot; i++){           
           start_x = x_min+i*step;
           end_x = x_min+(i+1)*step;      
           var scope = new JsObject.jsify({    'x': start_x   });      
           start_y = double.parse( s.callMethod('eval', [scope]).toStringAsPrecision(5)); 
           var scope2 = new JsObject.jsify({   'x': end_x   });     
           end_y = double.parse(s.callMethod('eval', [scope2]).toStringAsPrecision(5)); 
           
           double x_range_length = data_plot_list[active_plot].x_range_max - data_plot_list[active_plot].x_range_min;
           double y_range_length = data_plot_list[active_plot].y_range_max - data_plot_list[active_plot].y_range_min;      
           _s_x = (start_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
           _s_y = (-start_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();          
           _e_x = (end_x-data_plot_list[active_plot].x_range_min)/x_range_length*data_plot_list[active_plot].frame.width.toDouble()+data_plot_list[active_plot].frame.left.toDouble();      
           _e_y = (-end_y+data_plot_list[active_plot].y_range_max)/y_range_length*data_plot_list[active_plot].frame.height.toDouble()+data_plot_list[active_plot].frame.top.toDouble();
           
           func_plot.plot_line_set.add(new x_line_set(_s_x, _s_y, _e_x, _e_y));       
           
         }  // end of for(int i=0; i<199; i++){
         
     
   }
   
   void show_frame_ctrl_pt(Event event, var detail, Element target){
     var p = JSON.decode(target.attributes['data-msg']);
     active_plot = p["plt_idx"];
     data_plot_list[active_plot].frame.show_control_point=true;
   }
   
   
   void hide_label_edit(Event event, var detail, Element target){
     var p = JSON.decode(target.attributes['data-msg']);
     data_plot_list[p["plt_idx"]].label_list[p["line_idx"]].edit = false;
   }
   
   
   void show_label_edit(Event event, var detail, Element target){
     //print(target.attributes['data-msg']);
     var p = JSON.decode(target.attributes['data-msg']);
     data_plot_list[p["plt_idx"]].label_list[p["line_idx"]].edit = true;
   }
   
   
   void label_click(Event event, var detail, Element target){     
     active_draw_object = "text";
     this.text_select_rect_left = target.getBoundingClientRect().left-160;
     this.text_select_rect_top = target.getBoundingClientRect().top;
     this.text_select_rect_width = target.getBoundingClientRect().width;
     this.text_select_rect_height = target.getBoundingClientRect().height;
     RIBBON_FIGURE = false; 
     RIBBON_DRAW = false;
     RIBBON_TEXT = true;
     RIBBON_FIGURE_STYLE = false;
     RIBBON_ANALYSIS = false; 
     RIBBON_EDIT = false;
     var p = JSON.decode(target.attributes['data-msg']);
     active_label = p["label_idx"]; 
   //  print("label clicked");
   //  print(target.getBBox().x);
    // print(target.getBoundingClientRect().left);
   }
   
   void ribbon_text_larger(){
     data_plot_list[active_plot].label_list[active_label].font_size += 5; 
   }
   
   void ribbon_text_smaller(){
     data_plot_list[active_plot].label_list[active_label].font_size -= 5; 
   }
   
   void ribbon_text_bold(){
  //   print(data_plot_list[active_plot].label_list[active_label].font_weight);
     if(data_plot_list[active_plot].label_list[active_label].font_weight=="normal"){
         data_plot_list[active_plot].label_list[active_label].font_weight = "bold";
         return; 
     }
     if(data_plot_list[active_plot].label_list[active_label].font_weight=="bold"){
         data_plot_list[active_plot].label_list[active_label].font_weight = "normal";
         return; 
     }
   }
   
   void ribbon_text_italic(){
     if(data_plot_list[active_plot].label_list[active_label].font_style=="normal"){
       data_plot_list[active_plot].label_list[active_label].font_style = "italic";
       return;
     }
     if(data_plot_list[active_plot].label_list[active_label].font_style=="italic"){
       data_plot_list[active_plot].label_list[active_label].font_style = "normal";
       return;
     }
   }
   
   void ribbon_text_underline(){
     if(data_plot_list[active_plot].label_list[active_label].text_decoration=="none"){
       data_plot_list[active_plot].label_list[active_label].text_decoration = "underline";
       return;
     }
     if(data_plot_list[active_plot].label_list[active_label].text_decoration=="underline"){
       data_plot_list[active_plot].label_list[active_label].text_decoration = "none";
       return; 
     } 
   }
   
   
   
   void show_contextmenu(Event event, var detail, Element target){         
     var p = JSON.decode(target.attributes['data-msg']);
  //   print(p);     
     ctxmenu_show.menu_type = p["obj_type"];     
     active_plot = p["plt_idx"];   
     
     if(p["obj_type"]=="data_set"){
       active_data = p["data_idx"];
     }
     if(p["obj_type"]=="label"){
       active_label = p["label_idx"]; 
     }
     if(p["obj_type"]=="frame"){
       
     }
     if(p["obj_type"]=="range"){
       
     }     
     ctxmenu_show.contextmenu_show = true;
   }
   
   
   void delete_data_set(Event event, var detail, Element target){      
     var p = JSON.decode(target.attributes['data-msg']);
     data_plot_list[p["plt_idx"]].data_set_list_overlay.removeAt(p["data_idx"]); 
   }
   
   
   void delete_data_fitting(Event event, var detail, Element target){ 
     var p = JSON.decode(target.attributes['data-msg']);
     data_plot_list[p["plt_idx"]].data_set_list_overlay[p["data_idx"]].fit_line_set.clear(); 
   }
   
   
   void embed_share_dialog(){
     this.EMBED_SHARED_DIALOG = true; 
     $['dialog'].toggle(); 
   }
   
   void embed_share_cancel(){
     this.EMBED_SHARED_DIALOG = false; 
     $['dialog'].toggle(); 
   }
   
   void generate_static_link(){
     String temp = shadowRoot.querySelector("#container").innerHtml; 
     String content = '<svg height="100%" width="100%">'+temp+"</svg>";     
     var rng = new Random();
     String color = rng.nextDouble().toStringAsFixed(16).substring(2, 8);     
     DateTime now = new DateTime.now();
     // now.toString();  
     String llllink = now.toString()+color+".html"; 
     print(llllink); 
     this.share_link = "www.sheetacloud.com/static_figure_link/"+llllink;     
     var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");      
     ws_read_db.onOpen.listen((event){
         ws_read_db.send(JSON.encode({"CMD":"write-static-figure", "figure":content, "filename":llllink}));
     }); // end of  ws_write_db.onOpen.listen((event){
     //ws_read_db.onMessage.listen((event){
         
     //}); 
     
   }
   
   void generate_editable_link(){
     
   }
   
   void generate_embed_link(){
     
   }
   
   void email_figure_dialog(){
     this.EMAIL_FIGURE_DIALOG = true; 
    // String temp = shadowRoot.querySelector("#container").innerHtml; 
   //  this.email_content = "mailto:name1@rapidtables.com?cc=name2@rapidtables.com&bcc=name3@rapidtables.com&subject=The%20subject%20of%20the%20email&body="
       //  +'<svg height="100%" width="100%">'+temp+"</svg>";
     
   //  print(email_content);
     
     
     $['dialog'].toggle(); 
   }
   
   void email_figure_cancel(){
     this.EMAIL_FIGURE_DIALOG = false; 
     $['dialog'].toggle(); 
   }
   
   
   void ribbon_copy(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_cut(){
     window.alert("To be implemented soon!");
   }

   void ribbon_paste(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_delete(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_duplicate_figure(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_insert_inset(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_rescale_show_all(){
     window.alert("To be implemented soon!");
   }
   
   void draw_point_start(){
     window.alert("To be implemented soon!");
   }
   
   /*
   void draw_polygon_start(){
     window.alert("To be implemented soon!");
   }
   
   void draw_polyline_start(){
     window.alert("To be implemented soon!");
   } */
   
   void ribbon_draw_fill(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_draw_stroke(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_draw_stroke_width(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_draw_line_type(){
     window.alert("To be implemented soon!");
   }
   

   /*
   void ribbon_text_larger(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_text_smaller(){
     window.alert("To be implemented soon!");
   }
   * */
   
   void ribbon_text_color(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_text_fontsize(){
     window.alert("To be implemented soon!");
   }
   
   void ribbon_text_font(){
     window.alert("To be implemented soon!");
   }
   
//   void 
  // void 
   
   
      
   void attached() {
     super.attached();      
     var svgElement = shadowRoot.querySelector('#container');        
     document.onClick.listen((event){       
       if(DRAW_TEXT_STARTED==true){         
         Label draw_label = new Label("text" , event.client.x-139, event.client.y, null, null, 30, 0, true, "#000000");  
         draw_label.unscaled_x = (draw_label.x-data_plot_list[active_plot].frame.left)/data_plot_list[active_plot].frame.width;
         draw_label.unscaled_y = (draw_label.y-data_plot_list[active_plot].frame.top)/data_plot_list[active_plot].frame.height;  
         data_plot_list[active_plot].label_list.add(draw_label);
         DRAW_TEXT_STARTED = false;
       }       
       if(DRAW_TEXT_ALLOWED==true){
         DRAW_TEXT_STARTED = true;
         DRAW_TEXT_ALLOWED = false;
       }              
       ctxmenu_show.contextmenu_show = false;           
       num x = event.client.x - svgElement.offset.left - 139;
       num y = event.client.y - svgElement.offset.top - 0;        
    //   print("clicked!"); 
    //   print(event.target);
       /*
       if(data_plot_list[active_plot].frame.show_control_point==true){
         data_plot_list[active_plot].frame.show_control_point = false; 
       } */
       
     });   
     
     
     
     $["container"].onClick.listen((event){
       if(event.target.id=="container"){
         data_plot_list[active_plot].frame.show_control_point = false; 
       }
      // print(event.target);
      // print(event.target.id);
     });  
     
     
     //document.body.scrollLeft + document.documentElement.scrollLeft;//  + document.body.scrollTop + document.documentElement.scrollTop;//
     
     document.onContextMenu.listen((event){
       int x = event.client.x  - svgElement.offset.left ;
       int y = event.client.y  - svgElement.offset.top ;   
       
    //   print(event.client.x);
    //   print(event.client.y); 
       
       ctxmenu_show.y_pos = y;
       ctxmenu_show.x_pos = x-139;
       event.preventDefault(); 
     });  
              
        document.onMouseDown.listen((event){  //鼠标按下去的时候，画出起始控制点
          num x = event.client.x-svgElement.offset.left-139;
          num y = event.client.y-svgElement.offset.top;
          
          if(zoom_control.ZOOM_IN_ALLOWED==true){             
             //zoom_control.temp_range = new Zoom_Temp(x, y, null, null);    
            zoom_control.temp_range.start_x = x;
            zoom_control.temp_range.start_y = y;
            zoom_control.ZOOM_IN_STARTED = true;
          }
          
          
          if(line_plot.IS_DRAW_LINE_ALLOWED){
            if(!line_plot.IS_DRAW_LINE_START)  line_plot.IS_DRAW_LINE_START = true;
            line_plot.show_control_point = true;
            line_plot.active_line = line_plot.line_list.length;   //active的直线
            line_plot.line_list.add(new x_line_set_plot(x.toDouble(), y.toDouble(), x.toDouble(), y.toDouble(), line_plot.active_line, stroke_color_predefined, stroke_width_color_predefined));
            active_draw_object = "line"; 
            //  print(line_plot.line_list.length);
          }
          
          if(rect_plot.IS_DRAW_RECT_ALLOWED){
                  if(!rect_plot.IS_DRAW_RECT_START) rect_plot.IS_DRAW_RECT_START = true;
                  rect_plot.show_control_point = true;
                  rect_plot.active_rect = rect_plot.rect_list.length;   //active的直线
                  rect_plot.rect_list.add(new x_rect_set_plot(x.toDouble(), y.toDouble(), null, null, rect_plot.active_rect, stroke_color_predefined, stroke_width_color_predefined, "none"));
                  active_draw_object = "rectangle"; 
          }    
          
          
          if(polyline_plot.IS_DRAW_POLYLINE_ALLOWED){            
            if(polyline_plot.IS_DRAW_POLYLINE_START){ 
              polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.removeLast(); 
              polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.add(new x_data_set_scaled(x, y));               
              polyline_plot.polyline_list[polyline_plot.active_polyline].update_point_chage(); 
              polyline_plot.INTERMEDIATE_CLICK = true;               
            }           
           // print("clicked");             
            if(!polyline_plot.IS_DRAW_POLYLINE_START){
              polyline_plot.IS_DRAW_POLYLINE_START = true ;
              polyline_plot.show_control_point = true;
              polyline_plot.active_polyline = polyline_plot.polyline_list.length;               
              polyline_plot.polyline_list.add(new x_polyline_plot(toObservable([]), "", stroke_color_predefined, stroke_width_color_predefined, polyline_plot.temp_polyline_or_polygon));
              polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.add(new x_data_set_scaled(x, y)); 
             // this.active_draw_object = "polyline"; 
              polyline_plot.INTERMEDIATE_CLICK = true;               
            }
          }          
        });  //onMouseDown结束
            
                
        document.onMouseMove.listen((event){  //鼠标移动的时候，结束控制点随着鼠标移动而移动
          num x = event.client.x - svgElement.offset.left - 139;
          num y = event.client.y - svgElement.offset.top - 0; 
          
          if(screen_reader.show==true && screen_reader.data_reader_enable==false){
            screen_reader.x_value = (data_plot_list[active_plot].x_range_min +(data_plot_list[active_plot].x_range_max-data_plot_list[active_plot].x_range_min)*(x-data_plot_list[active_plot].frame.left)/data_plot_list[active_plot].frame.width).toStringAsPrecision(5);
            screen_reader.y_value = (data_plot_list[active_plot].y_range_min +(data_plot_list[active_plot].y_range_max-data_plot_list[active_plot].y_range_min)*(-y+data_plot_list[active_plot].frame.top+data_plot_list[active_plot].frame.height)/data_plot_list[active_plot].frame.height).toStringAsPrecision(5);  
          }          
          
          if(zoom_control.ZOOM_IN_ALLOWED==true){     
            zoom_control.temp_range.end_x = x;
            zoom_control.temp_range.end_y = y;
          }
          
          
          if(line_plot.IS_DRAW_LINE_START){
       //     print(line_plot.active_line);
            line_plot.line_list[line_plot.active_line].end_x = x.toDouble();
            line_plot.line_list[line_plot.active_line].end_y = y.toDouble();            
          }
          
          if(line_plot.IS_CIRCLE_START_MOVE){   //移动起始控制点  
            line_plot.line_list[line_plot.active_line].start_x = x.toDouble();
            line_plot.line_list[line_plot.active_line].start_y = y.toDouble();
          }
          if(line_plot.IS_CIRCLE_END_MOVE){   //启动结束控制点
            line_plot.line_list[line_plot.active_line].end_x = x.toDouble();
            line_plot.line_list[line_plot.active_line].end_y = y.toDouble();
          }
          
          if(rect_plot.IS_DRAW_RECT_ALLOWED && rect_plot.IS_DRAW_RECT_START){
            rect_plot.rect_list[rect_plot.active_rect].end_x = x.toDouble();
            rect_plot.rect_list[rect_plot.active_rect].end_y = y.toDouble();
        
                }       
          
          if(polyline_plot.IS_DRAW_POLYLINE_ALLOWED && polyline_plot.IS_DRAW_POLYLINE_START){            
            if(polyline_plot.INTERMEDIATE_CLICK==false){
              polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.removeLast(); 
            }            
            polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.add(new x_data_set_scaled(x, y)); 
            polyline_plot.polyline_list[polyline_plot.active_polyline].update_point_chage(); 
            polyline_plot.INTERMEDIATE_CLICK = false; 
          }
          
          if(rect_plot.IS_CIRCLE_MOVE){   //移动起始控制点             
            
                if(rect_plot.active_circle==0){
                  rect_plot.rect_list[rect_plot.active_rect].start_x = x.toDouble();
                  rect_plot.rect_list[rect_plot.active_rect].start_y = y.toDouble();                  
                }
                if(rect_plot.active_circle==1){
                  rect_plot.rect_list[rect_plot.active_rect].start_x = x.toDouble();               
                }
                if(rect_plot.active_circle==2){
                  rect_plot.rect_list[rect_plot.active_rect].start_x = x.toDouble();
                  rect_plot.rect_list[rect_plot.active_rect].end_y = y.toDouble();                  
                }
                if(rect_plot.active_circle==3){
                  rect_plot.rect_list[rect_plot.active_rect].end_y = y.toDouble();                 
                }
                if(rect_plot.active_circle==4){
                  rect_plot.rect_list[rect_plot.active_rect].end_x = x.toDouble();
                  rect_plot.rect_list[rect_plot.active_rect].end_y = y.toDouble();                  
                }
                if(rect_plot.active_circle==5){
                  rect_plot.rect_list[rect_plot.active_rect].end_x = x.toDouble();                  
                }
                if(rect_plot.active_circle==6){
                  rect_plot.rect_list[rect_plot.active_rect].end_x = x.toDouble();
                  rect_plot.rect_list[rect_plot.active_rect].start_y = y.toDouble();                  
                }
                if(rect_plot.active_circle==7){
                  rect_plot.rect_list[rect_plot.active_rect].start_y = y.toDouble();                 
                }
          }
          
          
          if(polyline_plot.IS_CIRCLE_MOVE){
            polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.removeAt(polyline_plot.active_circle);                     
            polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.insert(polyline_plot.active_circle, new x_data_set_scaled(x, y)); 
            polyline_plot.polyline_list[polyline_plot.active_polyline].update_point_chage(); 
          }
          
          
          if(data_plot_list.length > 0) {
          
          if(data_plot_list[active_plot].frame.IS_CIRCLE_MOVE){   //移动起始控制点    
            int right = data_plot_list[active_plot].frame.width + data_plot_list[active_plot].frame.left;
            int bottom = data_plot_list[active_plot].frame.height + data_plot_list[active_plot].frame.top;
                                           
                          if(data_plot_list[active_plot].frame.active_circle==0){
                            data_plot_list[active_plot].frame.left = x;
                            data_plot_list[active_plot].frame.top = y;
                            data_plot_list[active_plot].frame.width = right - x;
                            data_plot_list[active_plot].frame.height = bottom - y;                
                          }
                          if(data_plot_list[active_plot].frame.active_circle==1){
                            data_plot_list[active_plot].frame.left = x;
                            data_plot_list[active_plot].frame.width = right - x;
                          }
                          if(data_plot_list[active_plot].frame.active_circle==2){
                            data_plot_list[active_plot].frame.left = x;
                            data_plot_list[active_plot].frame.width = right - x;     
                            data_plot_list[active_plot].frame.height = y-data_plot_list[active_plot].frame.top;    
                          }
                          if(data_plot_list[active_plot].frame.active_circle==3){
                            data_plot_list[active_plot].frame.height = y-data_plot_list[active_plot].frame.top;            
                          }
                          if(data_plot_list[active_plot].frame.active_circle==4){
                            data_plot_list[active_plot].frame.width = x-data_plot_list[active_plot].frame.left;
                            data_plot_list[active_plot].frame.height = y-data_plot_list[active_plot].frame.top;
                          }
                          if(data_plot_list[active_plot].frame.active_circle==5){
                            data_plot_list[active_plot].frame.width = x-data_plot_list[active_plot].frame.left;                  
                          }
                          if(data_plot_list[active_plot].frame.active_circle==6){
                            data_plot_list[active_plot].frame.top = y;
                            data_plot_list[active_plot].frame.height = bottom - y;       
                            data_plot_list[active_plot].frame.width = x-data_plot_list[active_plot].frame.left;
                          }
                          if(data_plot_list[active_plot].frame.active_circle==7){
                            data_plot_list[active_plot].frame.top = y;
                            data_plot_list[active_plot].frame.height = bottom - y;                 
                          }
                          
                         data_plot_list[active_plot].update_frame_change(); 
                    }  // end of if(data_plot.frame.IS_CIRCLE_MOVE){   //移动起始控制点  
          
          }
          
        });
        
        
        document.onDoubleClick.listen((event){  
          num x = event.client.x - svgElement.offset.left - 139;
          num y = event.client.y - svgElement.offset.top - 0; 
          
          if(polyline_plot.IS_DRAW_POLYLINE_ALLOWED && polyline_plot.IS_DRAW_POLYLINE_START){
                      polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.removeLast(); 
                      polyline_plot.polyline_list[polyline_plot.active_polyline].point_set.add(new x_data_set_scaled(x, y)); 
                      polyline_plot.polyline_list[polyline_plot.active_polyline].update_point_chage(); 
                      polyline_plot.IS_DRAW_POLYLINE_ALLOWED = false;
                      polyline_plot.IS_DRAW_POLYLINE_START = false;                       
           }
        }); 
        
        
        document.onMouseUp.listen((event){    //鼠标键弹起，画线结束  
        //  num x = event.client.x - svgElement.offset.left - 139;
        //  num y = event.client.y - svgElement.offset.top - 0; 
          
          if(line_plot.IS_CIRCLE_START_MOVE) line_plot.IS_CIRCLE_START_MOVE = false;
          if(line_plot.IS_CIRCLE_END_MOVE) line_plot.IS_CIRCLE_END_MOVE = false;            
          if(line_plot.IS_DRAW_LINE_ALLOWED){    line_plot.IS_DRAW_LINE_ALLOWED = false;  }
          if(line_plot.IS_DRAW_LINE_START){    line_plot.IS_DRAW_LINE_START = false;  }          
          if(rect_plot.IS_DRAW_RECT_ALLOWED) rect_plot.IS_DRAW_RECT_ALLOWED = false;          
          if(rect_plot.IS_CIRCLE_MOVE) rect_plot.IS_CIRCLE_MOVE = false;          
          if(polyline_plot.IS_CIRCLE_MOVE) polyline_plot.IS_CIRCLE_MOVE = false; 
          if(rect_plot.IS_DRAW_RECT_START){   rect_plot.IS_DRAW_RECT_START = false;   }  
          
          if(zoom_control.ZOOM_IN_STARTED==true){
            zoom_control.ZOOM_IN_STARTED = false;
            zoom_control.ZOOM_IN_ALLOWED = false;        
            
            double y_range_length = data_plot_list[active_plot].y_range_max - data_plot_list[active_plot].y_range_min;   // y range length
            double x_range_length = data_plot_list[active_plot].x_range_max - data_plot_list[active_plot].x_range_min;   // x range length
            
            double x_range_min_new, x_range_max_new, y_range_min_new, y_range_max_new;  //range f
            
            zoom_control.zoom_history.add(new Zoom_Range(data_plot_list[active_plot].x_range_min, data_plot_list[active_plot].x_range_max, data_plot_list[active_plot].y_range_min, data_plot_list[active_plot].y_range_max));
            
            x_range_min_new = (zoom_control.temp_range.start_x.toDouble() - data_plot_list[active_plot].frame.left.toDouble())/data_plot_list[active_plot].frame.width.toDouble()*x_range_length +  data_plot_list[active_plot].x_range_min;
            x_range_max_new = (zoom_control.temp_range.end_x.toDouble() - data_plot_list[active_plot].frame.left.toDouble())/data_plot_list[active_plot].frame.width.toDouble()*x_range_length +   data_plot_list[active_plot].x_range_min;
            y_range_max_new = (-zoom_control.temp_range.start_y.toDouble() + data_plot_list[active_plot].frame.top.toDouble() + data_plot_list[active_plot].frame.height.toDouble())/data_plot_list[active_plot].frame.height.toDouble()*y_range_length +  data_plot_list[active_plot].y_range_min;
            y_range_min_new = (-zoom_control.temp_range.end_y.toDouble() + data_plot_list[active_plot].frame.top.toDouble() + data_plot_list[active_plot].frame.height.toDouble())/data_plot_list[active_plot].frame.height.toDouble()*y_range_length +   data_plot_list[active_plot].y_range_min;
                        
            data_plot_list[active_plot].x_range_min = x_range_min_new ;
            data_plot_list[active_plot].x_range_max = x_range_max_new ;
            data_plot_list[active_plot].y_range_min = y_range_min_new ;
            data_plot_list[active_plot].y_range_max = y_range_max_new ;           
            
            data_plot_list[active_plot].update_zoom_change(false); 
          }
          
          if(data_plot_list[active_plot].frame.IS_CIRCLE_MOVE){ data_plot_list[active_plot].frame.IS_CIRCLE_MOVE = false;}
        }); 
        
        
        
      } 
      
}