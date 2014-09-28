library tablecore;

import 'package:polymer/polymer.dart';
//import 'dart:async';
//import './Expression.dart';
import 'dart:convert';
//import './interval_decimal.dart';
import 'dart:html';
//import 'package:three/three.dart';
//import 'package:vector_math/vector_math.dart';
//import './shared_functions.dart';
//import 'dart:js';
//import 'dart:math' as math;
//import 'dart:async';
//import './three-triangle.dart';
//import './three-parent.dart';
//import './lagrange-interpolation.dart';
//import './plot2d_element.dart';
//import './import_data.dart';
//import './layout.dart';
//import './ui_filters.dart';
//import 'package:polymer_expressions/filter.dart' show Transformer;
import './map_var.dart';
import 'package:csv_sheet/csv_sheet.dart';

String host = 'localhost';
int port = 8084;

//var x = new DataTransfer(); 

class Head extends Object with Observable{   //定义每一个表格元素
  @observable String Head_property;   //there are choices like "X", "Y", "Z", "G", "C", "F", "E", "T", "N", "R" 
  @observable String Head_label;  
  @observable num col;
  Head(this.Head_property, this.Head_label, this.col);
  dynamic toJson() => {"property":Head_property, "label":Head_label, "col":col}; 
}


class Cell extends Object with Observable{   //定义每一个表格元素
  @observable String Cell_data;  
  num data_full_prec;
  @observable String color;
  @observable num col;
  @observable num row;
  @observable bool edit = false;  
  @observable String select;  //to define the color
  String author;
  Cell(this.Cell_data, this.data_full_prec, this.color, this.row, this.col, this.edit, this.select, this.author);
  dynamic toJson() => {"data":Cell_data, "author":this.author, "col":col}; 
}

class Row extends Object with Observable{   //定义每一行 
  @observable String label;
  @observable num row;
  List <Cell> Row_data = toObservable([]);  
  Row(this.label, this.row, this.Row_data);
  dynamic toJson(String parent_){
    return {"type":"document", "row":row, "data_set":Row_data, "parent":parent_};
}
}


class Table extends Object with Observable{        //定义整个表格
  String parent;
  String username;
  int num_of_col;
  int num_of_row;  
  @observable bool table_mode_show = true;
  List <Row> Table_data = toObservable([]);  
  List <Head> Table_head_data = toObservable([]);  
  int head_label_count;
  Table(this.num_of_col, this.num_of_row, this.table_mode_show, this.Table_data, this.Table_head_data, this.parent, this.username);
  dynamic toJson() => {"type":"doc-head", "num_of_col":num_of_col, "num_of_row":num_of_row, "parent":parent, "head_data":Table_head_data};
  
  
  /*
  Table.boring_init(int num_of_row_, int num_of_col_, String parent_, String username_){
    head_label_count = 0;
    this.num_of_col = num_of_col_;
    this.num_of_row = num_of_row_;
    this.parent = parent_;
    this.username = username_;
    
    for(int i=0; i<num_of_row; i++){
      List <Cell> temp_row = toObservable([]);
      for(int j=0; j<num_of_col; j++){
        var cell = new Cell(i.toString(), i.toDouble(),  "black", i, j, false, "#CCFFFF", this.username);
        temp_row.add(cell);
      }
      Table_data.add(new Row(i.toString(), i, temp_row));
    }
    
    for(int i=0; i<num_of_col; i++){
      String s = new String.fromCharCodes([65+i]);
      if(i==0){
        Table_head_data.add(new Head("X", s,  i));
      }
      if(i>0){
        Table_head_data.add(new Head("Y", s,  i));
      }
    }
  }*/
  
  Table.zero_init(int num_of_row_, int num_of_col_, String parent_, String username_){
    head_label_count = 0;
    this.num_of_col = num_of_col_;
    this.num_of_row = num_of_row_;
    this.parent = parent_;
    this.username = username_;
        
    for(int i=0; i<num_of_row; i++){
      List <Cell> temp_row = toObservable([]);
      for(int j=0; j<num_of_col; j++){
        var cell = new Cell("", 0.0, "black", i, j, false, "white", this.username);
        temp_row.add(cell);
      }
      Table_data.add(new Row(i.toString(), i, temp_row));
    }
    
    for(int i=0; i<num_of_col; i++){
      String s = new String.fromCharCodes([65+i]);
      if(i==0){
        Table_head_data.add(new Head("X", this.next_head_label(),  i));
      }
      if(i>0){
        Table_head_data.add(new Head("Y", this.next_head_label(),  i));
      }
    }    
  }
  /*
  Table.threed_init(int num_of_row, int num_of_col){
    head_label_count = 0;
    this.num_of_col = num_of_col;
    this.num_of_row = num_of_row;
    
    Table_head_data.add(new Head("X", this.next_head_label(),  0));
    Table_head_data.add(new Head("Y", this.next_head_label(),  1));
    Table_head_data.add(new Head("Z", this.next_head_label(),  2));
    
    for(int i=0; i<20; i++){
      for(int j=0; j<20; j++){
        List <Cell> temp_row = toObservable([]);
        temp_row.add(new Cell(i.toString(), "black", i*20+j, 0, false, "white", this.username));
        temp_row.add(new Cell(j.toString(), "black", i*20+j, 1, false, "white", this.username));       
        double s = 10.0*math.sin(math.sqrt((i-9.5)*(i-9.5)+(j-9.5)*(j-9.5))/5.0);
        temp_row.add(new Cell(s.toStringAsPrecision(5), "black", i*20+j, 2, false, "white", this.username));        
        Table_data.add(new Row((i*20+j).toString(), (i*20+j), temp_row));
      }
    }     
  }  // end of  Table.threed_init(int num_of_row, int num_of_col){
  */
  
  Table.db_init( String parent_, String username_){
        //head_label_count = 0;
        this.parent = parent_;
        this.username = username_;
        
        var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");   
           ws_read_db.onOpen.listen((event){
             ws_read_db.send(JSON.encode({"CMD":"read-table-head", "filter":{"parent":this.parent}}));
           });
           ws_read_db.onMessage.listen((event){
           //  print(event.data);
             var data = JSON.decode(event.data);
           //  num old_num_of_col = this.num_of_col;
           //  num old_num_of_row = this.num_of_row;
             
             if(data["type"]=="doc-head"){
               this.num_of_col = data["num_of_col"];
               this.num_of_row = data["num_of_row"];            
               this._empty_init(num_of_row, num_of_col);   
               this.head_label_count = data["num_of_col"]; 
               
               for(var h_d in data["head_data"]){
                 for(num i=0; i<this.num_of_col; i++){
                   if(h_d["col"]==i){
                     this.Table_head_data[i] = new Head(h_d["property"], h_d["label"], i);
                   }
                 }
               } //end of for(var h_d in data["head_data"]){
               ws_read_db.send(JSON.encode({"CMD":"read-table-body", "filter":{"parent":this.parent}}));        
             }  // end of if(data["type"]=="doc-head"){
             
             if(data["type"]=="document"){
               num row = data["row"];
               this.Table_data[row].row = row;
               this.Table_data[row].label = row.toString();
               for(var doc in data["data_set"]){
                 for(num i=0; i<this.num_of_col; i++){
                   if(doc["col"]==i){               
                     //num temp =   num.parse(doc["data"])
                     this.Table_data[row].Row_data[i] = new Cell(doc["data"], null, "black", row, i, false, "white", doc["author"]);
                  //   if(doc["author"]!=this.username) {
                    //   this.Table_data[row].Row_data[i].color = "blue";
                    // }
                   }
                 } //end of for(num i=0; i<this.num_of_col; i++){
               }  //end of for(var doc in data["data_set"]){
             }  // end of if(data["type"]=="document"){
             
           });  //end of ws_read_db.onMessage.listen((event){
    
  }   
  
  
  
  void _empty_init(int num_of_row, int num_of_col){
    Table_data.clear();
    for(int i=0; i<num_of_row; i++){
      List <Cell> temp_row = toObservable([]);
      for(int j=0; j<num_of_col; j++){
        var cell = new Cell(null, null, null, null, null, null, null, null);
        temp_row.add(cell);
      }
      Table_data.add(new Row(null, null, temp_row));
    } //end of     for(int i=0; i<num_of_row; i++){
    Table_head_data.clear();
    for(int i=0; i<num_of_col; i++){
        Table_head_data.add(new Head(null, null, null));
    }    
  } 
  
  void csv_reinit(String data){
    
   // print(data);
    
    var sheet = new CsvSheet(data, headerRow: false);    
      head_label_count = 0;
      this.num_of_col = sheet.numCols;
      this.num_of_row = sheet.numRows;
      Table_data.clear();
      Table_head_data.clear();
      
    //  print(sheet.numCols);
    //  print(sheet.numRows);
    //  this.parent = parent_;
   //   this.username = username_;      
   //   this._empty_init(sheet.numRows, sheet.numCols); 
          
      for(int i=0; i<this.num_of_row; i++){
        List <Cell> temp_row = toObservable([]);
        for(int j=0; j<this.num_of_col; j++){
          var cell = new Cell(sheet[j+1][i+1], double.parse(sheet[j+1][i+1]), "black", i, j, false, "white", this.username);
          temp_row.add(cell);
        }
        Table_data.add(new Row(i.toString(), i, temp_row));
      }
      
      for(int i=0; i<this.num_of_col; i++){
        String s = new String.fromCharCodes([65+i]);
        if(i==0){
          Table_head_data.add(new Head("X", this.next_head_label(),  i));
        }
        if(i>0){
          Table_head_data.add(new Head("Y", this.next_head_label(),  i));
        }
      }        
    
  }
  
  void resize(int new_num_of_row, int new_num_of_col){
    if(this.num_of_row<new_num_of_row && this.num_of_col<new_num_of_col){           
      for(int i=0; i<this.num_of_row; i++){
        for(int j=this.num_of_col; j<new_num_of_col; j++){
          this.Table_data[i].Row_data.add(new Cell("", 0.0, "black", i, j, false, "white", this.username));          
        }        
      }        
        for(int i=this.num_of_row; i<new_num_of_row; i++){
          List <Cell> temp_row = toObservable([]);
          for(int j=0; j<new_num_of_col; j++){
            var cell = new Cell("", 0.0, "black", i, j, false, "white", this.username);
            temp_row.add(cell);
          }
          this.Table_data.add(new Row(i.toString(), i, temp_row));
        }             
        for(int j=this.num_of_col; j<new_num_of_col; j++){
          this.Table_head_data.add(new Head("Y", this.next_head_label(), j));
        }
      this.num_of_col = new_num_of_col;
      this.num_of_row = new_num_of_row; 
    }
    
    if(this.num_of_row>=new_num_of_row && this.num_of_col>=new_num_of_col){   
      this.Table_data.removeRange(new_num_of_row, this.num_of_row);       
      for(int i=0; i<new_num_of_row; i++){
        this.Table_data[i].Row_data.removeRange(new_num_of_col, this.num_of_col);
      }   
      this.Table_head_data.removeRange(new_num_of_col, this.num_of_col);
      this.num_of_col = new_num_of_col;
      this.num_of_row = new_num_of_row; 
    }
    
    if(this.num_of_row>=new_num_of_row && this.num_of_col<new_num_of_col){   
      this.Table_data.removeRange(new_num_of_row, this.num_of_row);    
      for(int i=0; i<new_num_of_row; i++){
        for(int j=this.num_of_col; j<new_num_of_col; j++){
          this.Table_data[i].Row_data.add(new Cell("", 0.0, "black", i, j, false, "white", this.username));          
        }        
      } 
      for(int j=this.num_of_col; j<new_num_of_col; j++){
        this.Table_head_data.add(new Head("Y", this.next_head_label(), j));
      }
      this.num_of_col = new_num_of_col;
      this.num_of_row = new_num_of_row; 
    }
    
    if(this.num_of_row<new_num_of_row && this.num_of_col>=new_num_of_col){   
      for(int i=0; i<this.num_of_row; i++){
        this.Table_data[i].Row_data.removeRange(new_num_of_col, this.num_of_col);
      }        
      this.Table_head_data.removeRange(new_num_of_col, this.num_of_col);
      for(int i=this.num_of_row; i<new_num_of_row; i++){
        List <Cell> temp_row = toObservable([]);
        for(int j=0; j<new_num_of_col; j++){
          var cell = new Cell("", 0.0, "black", i, j, false, "white", this.username);
          temp_row.add(cell);
        }
        this.Table_data.add(new Row(i.toString(), i, temp_row));
      } 
      this.num_of_col = new_num_of_col;
      this.num_of_row = new_num_of_row; 
    }     
  }
  
  
  String next_head_label(){
    String s = new String.fromCharCodes([65+head_label_count]);
    head_label_count += 1;    
    return s;
  }
  
  void write_to_db(){
    var ws_write_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");      
    ws_write_db.onOpen.listen((event){
       //var s = {"type":"doc-head", "num_of_col":this.num_of_col, "num_of_row":this.num_of_row, "parent":"Table1", "head_data":Table_head_data};
      // var s=this.toJson();
       ws_write_db.send(JSON.encode({"CMD":"insert-table-head", "data":this.toJson()}));
       for(num i=0; i<this.num_of_row; i++){
         ws_write_db.send(JSON.encode({"CMD":"insert-table-body", "data":Table_data[i].toJson(this.parent)}));
       }
       
    }); // end of  ws_write_db.onOpen.listen((event){
  }
  
  
}
  /*
  void read_from_db(){
    var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");   
    ws_read_db.onOpen.listen((event){
      ws_read_db.send(JSON.encode({"CMD":"read-db-head", "filter":{"parent":this.parent, "username":this.username}}));
    });
    ws_read_db.onMessage.listen((event){
    //  print(event.data);
      var data = JSON.decode(event.data);
      num old_num_of_col = this.num_of_col;
      num old_num_of_row = this.num_of_row;
      
      if(data["type"]=="doc-head"){
        this.num_of_col = data["num_of_col"];
        this.num_of_row = data["num_of_row"];            
        this._empty_init(num_of_row, num_of_col);    
        
        for(var h_d in data["head_data"]){
          for(num i=0; i<this.num_of_col; i++){
            if(h_d["col"]==i){
              this.Table_head_data[i] = new Head(h_d["property"], h_d["label"], i);
            }
          }
        } //end of for(var h_d in data["head_data"]){
        ws_read_db.send(JSON.encode({"CMD":"read-db-doc", "filter":{"parent":this.parent, "username":this.username}}));        
      }  // end of if(data["type"]=="doc-head"){
      
      if(data["type"]=="document"){
        num row = data["row"];
        this.Table_data[row].row = row;
        this.Table_data[row].label = row.toString();
        for(var doc in data["data_set"]){
          for(num i=0; i<this.num_of_col; i++){
            if(doc["col"]==i){
              this.Table_data[row].Row_data[i] = new Cell(doc["data"], "black", row, i, false, "white", doc["author"]);
            }
          } //end of for(num i=0; i<this.num_of_col; i++){
        }  //end of for(var doc in data["data_set"]){
      }  // end of if(data["type"]=="document"){
      
    });  //end of ws_read_db.onMessage.listen((event){
  }  */
  
//}



class CTXmenu_show extends Object with Observable{
  @observable bool contextmenu_show;
  @observable String menu_type;  // four values to be used: "cell", "region", "column", "row" and "all"~~~~~~~~~~~~~ default value is "cell"
  @observable num x_pos;
  @observable num y_pos;
  @observable num row;
  @observable num col;
  CTXmenu_show(this.contextmenu_show, this.menu_type, this.x_pos, this.y_pos, this.row, this.col);
}

class Table_select{
  bool select_begin;
  num row_start;
  num col_start;
  num row_temp;
  num col_temp;
  num row_end;
  num col_end;
  Table_select(this.select_begin, this.row_start, this.col_start, this.row_temp, this.col_temp, this.row_end, this.col_end);
}

class Table_select_rec{
  String select_type; 
  num row_start;
  num col_start;
  num row_end;
  num col_end;
  Table_select_rec(this.row_start, this.col_start, this.row_end, this.col_end, this.select_type);
}


class Database extends Object with Observable{
  @observable String Database_name;
  @observable int key_selected = 1;
  @observable String key_selected_value;
  List <String> Key_list = toObservable([]);
  Database(this.Database_name, this.key_selected, this.key_selected_value, this.Key_list);
}

class Set_column_value extends Object with Observable{
  @observable bool show;
  @observable String use_type; // two values to be used: "use_function", "use_database"
  @observable int db_selected = 1;
  @observable String db_selected_value;
  List <Database> Database_list = toObservable([]);
  List <String> filter_list = toObservable([]);
  int col_value;
  @observable String expression;
  List <Map> variables;
  Set_column_value(this.show, this.use_type, this.db_selected, this.db_selected_value, this.Database_list, this.filter_list, this.col_value, this.expression, this.variables);
}

class Copy_Buffer{
  List <List <String>> Buffer_content;
  num row_length;
  num col_length;
  Copy_Buffer(this.Buffer_content, this.row_length, this.col_length);
}

/*

class ThreeD_Surface_Plot{
  @observable bool d3_surface_plot_mode = false;
  List <Vector3> threed_data_list =  toObservable([]);
  List <Triangle_Def> triangle_list = toObservable([]);
  ThreeD_Surface_Plot(this.d3_surface_plot_mode, this.threed_data_list, this.triangle_list);
}
 */ 

class Geography_Set_As extends Object with Observable{
  @observable bool show_set_as_geo_dialog = false;
  List <String> Country_list = toObservable([]);
  @observable int country_selected;
  @observable String country_selected_value;
  Geography_Set_As(this.show_set_as_geo_dialog, this.Country_list, this.country_selected);
}

class Grid_Insert extends Object with Observable{
  @observable bool show_insert_grid_dialog = false;
  @observable String grid_type;
  @observable double x_max;
  @observable double x_min;
  @observable int num_x_point;
  @observable double y_max;
  @observable double y_min;
  @observable int num_y_point;
  @observable double z_max;
  @observable double z_min;
  @observable int num_z_point;
  Grid_Insert(this.show_insert_grid_dialog, this.grid_type, this.x_min, this.x_max, this.num_x_point, this.y_min, this.y_max, this.num_y_point, this.z_min, this.z_max, this.num_z_point);
}


class Plot_Dialog extends Object with Observable{
  @observable String x_label;
  @observable String y_label;
  @observable String f_label;
  @observable Map filter;
  @observable bool show = false;
  Plot_Dialog(this.x_label, this.y_label, this.f_label, this.filter, this.show);
}


class Filter_Obj extends Object with Observable{
  @observable String filter_label;
  @observable String filter_operator;
  @observable String filter_value;
  Filter_Obj(this.filter_label, this.filter_operator, this.filter_value);
}

class Group_Obj extends Object with Observable{
  @observable String group_label;
  @observable double value_deviation;
  @observable String present_mode;    // there are four present modes:  interactive mode, overlay mode, spreading mode, discrete mode............
  Group_Obj(this.group_label, this.value_deviation, this.present_mode);
}

class Batch_Plot_Dialog extends Object with Observable{
  @observable String plot_type;
  @observable String x_label;
  @observable String y_label;
  @observable String f_label;
  List <Filter_Obj> filter_list = toObservable([]);
  List <Group_Obj> group_list = toObservable([]);
  @observable bool show = false;
  Batch_Plot_Dialog(this.plot_type, this.x_label, this.y_label, this.f_label, this.filter_list, this.group_list, this.show);  
}


class Table_Element_ extends Object with Observable{
/*  @published int num_of_col, num_of_row;  
  @published String parentID;
  @published String username;
  @published String init_type; */

  @observable Table table;
  @observable int table_right;
  @observable int table_bottom;
  @observable CTXmenu_show ctxmenu_show;
  @observable Table_select table_select;
  @observable List <Table_select_rec> table_select_history = [];
  
  @observable Set_column_value set_col_value;
  @observable Copy_Buffer copy_buffer_object;
//  @observable Data_Plot data_plot;
//  @observable Plot_Setting plot_setting; 
//  @observable Scene scene = new Scene();
//  @observable ThreeD_Surface_Plot threed_surf_plt;
  @observable Plot_Dialog plot_dialog;
  @observable Batch_Plot_Dialog batch_plot_dialog;
  
  @observable bool table_show_mode = true;
  @observable bool show_lag_inter_diaglog =  false;
  @observable String template_col_inter = null; 
 // @observable bool show_2d_plot_mode = false;
  @observable bool import_txt_dialog_show = false;
  
//  @observable String plot_type;
//  @observable dynamic plot_data;
  
  @observable Geography_Set_As geography_set_as;
  @observable Grid_Insert grid_insert;

  
  Table_Element_.init(int num_of_col, int num_of_row, String parentID, String username, String init_type){
    
    if(init_type=="DataBase"){
      table = new Table.db_init(parentID, username);
    }          
    if(init_type=="Empty"){
      table = new Table.zero_init(num_of_row, num_of_col, parentID, username);
    }    
    
    ctxmenu_show = new CTXmenu_show(false, "cell", 400, 400, 0, 0);
    table_select = new Table_select(false, 1, 1, 1, 1, 1, 1);
    copy_buffer_object = new Copy_Buffer([], 0, 0);
    
    List <String> temp_key_list = toObservable([]);
    List <String> temp_filter_list = toObservable([]);
    List <Database> temp_database_list = toObservable([]);
    Database temp_database = new Database("xxxxxxx", 1, "pppp", temp_key_list);
    temp_database.Key_list.add("sssss");
    temp_database.Key_list.add("pppp");
    temp_database.Key_list.add("qqqqqq");
    set_col_value = new Set_column_value(false, "use_function", 0, "xxxxxxx", temp_database_list, temp_filter_list, 0, "f(x)=cos(x);\nsqrt(Col(A)^2+4)\nf(Col(A))", null);
    set_col_value.Database_list.add(temp_database);
    set_col_value.filter_list.add("s==9");
    set_col_value.filter_list.add("q>999");
    
    temp_key_list = toObservable([]);
    temp_database = new Database("222222222222", 1, "33333333", temp_key_list);
    temp_database.Key_list.add("55555555555");
    temp_database.Key_list.add("33333333");
    temp_database.Key_list.add("111111111111");
    set_col_value.Database_list.add(temp_database);
    
    country_list.sort((x, y) => x.compareTo(y)); 
    //List <String> temp_country_list = toObservable([]);      
    geography_set_as = new Geography_Set_As(false, country_list, null);
    
    //for(var coun in )
    
    //geography_set_as.Country_list.add("China");
    grid_insert = new  Grid_Insert(false, null, 0.0, 10.0, 10, 0.0, 10.0, 3, 0.0, 10.0, 3);          
    
   // List <Triangle_Def> temp_triangle_list = toObservable([]);
 //   threed_surf_plt = new ThreeD_Surface_Plot(false, null, temp_triangle_list);  
    plot_dialog = new Plot_Dialog(null, null, null, new Map(), false);          
    batch_plot_dialog = new Batch_Plot_Dialog(null, null, null, null, null, null, false);
    batch_plot_dialog.filter_list = toObservable([]);     
    batch_plot_dialog.group_list = toObservable([]);     
    
  }
  
}


