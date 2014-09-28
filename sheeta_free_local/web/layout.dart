library layout_element; 

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
//import 'table_element.dart';
//import 'plot2d_element.dart';
import 'dart:async';
import './folder_element.dart';
import './shared_functions.dart';
import 'table-core.dart';
import 'plot2d-core.dart'; 
import 'googlechart.dart';
import 'martching_cube.dart'; 

String host = 'localhost';
int port = 8084;


class Num2 <T> {
  T x;
  T y;
  Num2(this.x, this.y);
}

class Col_Name extends Object with Observable{
  @observable int index; 
  @observable String name;
  Col_Name(this.index, this.name); 
}

class Table_Name extends Object with Observable{
  List <Col_Name> col_list = toObservable([]); 
  @observable int index; 
  @observable String name;
  Table_Name(this.index, this.name, this.col_list); 
}

class PlotDataSet extends Object with Observable{
  @observable int table_index ;
  @observable int col_index ; 
  @observable String plot_type ;   
  @observable String name; 
  PlotDataSet(this.table_index, this.col_index, this.plot_type, this.name);   
}


class FileX extends Object with Observable{
  @observable String object_id;
  @observable String object_name;
  String creater;
  String created_time;
  String modified_time;
  String type;
  @observable Num2 <int> translate;
  String parent;
//  @observable String obj_visible = "none";
//  @observable double obj_opacity = 0.0;
  FileX(this.object_id, this.object_name, this.parent, this.creater, this.created_time, this.modified_time, this.type, this.translate); //, this.obj_opacity);

  dynamic toJson() => {"file_id":this.object_id, "file_name":this.object_name, "parent":this.parent, "creater":this.creater,
    "created_time":this.created_time, "modified_time":this.modified_time, "type":this.type }; 
}



@CustomTag('layout-element')
class LayoutElement extends PolymerElement { 
  @published String username = "sherchy";
  @published String parentID = "sherchyDataPro3";
  @published bool readonly = false; 
  @published String custom_tag;   
  
  @observable num filecount = 0;
  List <FileX> file_list = toObservable([]);
  @observable Table_Element_ table_temp;
  @observable Plot2dElement_ plot_temp;
  @observable GchartElement_ gchart_temp;  
  @observable D3SurfaceElement_ d3surface_temp; 
  @observable bool table_show = false;
  @observable bool plot_show = false;
  @observable bool gchart_show = false; 
  @observable bool d3surface_show = false; 
  List <dynamic> obj_list = toObservable([]);  //toObservable([3]);
  int current_index = 0;
  List <String> plot_type_list = [];
  List <dynamic> plot_data_list = [];
  List <bool> plot_init_list = [];
  WebSocket ws;
  List <Table_Name> table_name_list = toObservable([]); 
  @observable int choosed_table_index = 0;
  @observable int choosed_col_index = 0; 
  @observable bool PLOT_DIALOG_SHOW = false; 
  @observable String user_plot_type = "linesymbol_2d"; 
  List <PlotDataSet> dataset_list = toObservable([]); 
  @observable bool SHOW_FILE_MANAGE = false; 
  @observable int active_subfile = 0; 
  
  LayoutElement.created() : super.created() {
    

    
    ws = new WebSocket("ws://"+host+":"+port.toString()+"/ws"); 
    
    ws.onOpen.listen((event){
      ws.send(JSON.encode({"CMD":"check-sub-file", "filter":{"parent":parentID}}));
    });

    
    ws.onMessage.listen((event){      
      var data = JSON.decode(event.data);      
      if(data["MSG"]=="subfile_list"){
        var p = data["data"];
        FileX temp_file = new FileX(p["file_id"],p["file_name"], p["parent"], p["creater"], p["created_time"], p["modified_time"], p["type"], null); //, 1.0);
        
        filecount += 1;
        temp_file.translate = new Num2<int>(0, filecount*40+240);    
        file_list.add(temp_file);   
        
        if(temp_file.type=="table_file"){
          table_temp = new Table_Element_.init(null, null, temp_file.object_id, username, "DataBase");      
            if(table_temp!=null){
              obj_list.add(table_temp);
            } 
          current_index = obj_list.length-1;      
          table_show = true;            
          plot_show = false;      
          gchart_show = false; 
          d3surface_show = false; 
          plot_type_list.add(null);
          plot_data_list.add(null);
          plot_init_list.add(true);          
        }  
                
        
        if(temp_file.type=="plot_file"){
          plot_temp = new Plot2dElement_.dbinit(temp_file.object_id);    
            if(plot_temp!=null){
              obj_list.add(plot_temp);
            } 
          current_index = obj_list.length-1;      
          table_show = false;
          plot_show = true;    
          gchart_show = false; 
          d3surface_show = false;   
          plot_type_list.add(null);
          plot_data_list.add(null);
          plot_init_list.add(true);          
        }
        
        if(temp_file.type=="gchart_file"){
          gchart_temp = new GchartElement_.db_init(temp_file.object_id);    
            if(gchart_temp!=null){
              obj_list.add(gchart_temp);
            } 
          current_index = obj_list.length-1;      
          table_show = false;
          plot_show = false;  
          gchart_show = true; 
          d3surface_show = false;   
      /*    Timer.run((){
            GchartElement gchart = shadowRoot.querySelector("gchart-element");  
            gchart.refresh_plot(); 
          });   */
          
          plot_type_list.add(null);
          plot_data_list.add(null);
          plot_init_list.add(true);          
        }
        
      
        if(temp_file.type=="d3surface_file"){          
          table_show = false;
          plot_show = false;  
          gchart_show = false; 
          d3surface_show = true;           
          Timer.run((){            
            d3surface_temp = new D3SurfaceElement_.db_init(temp_file.object_id);    
              if(d3surface_temp!=null){
                obj_list.add(d3surface_temp);
              } 
              current_index = obj_list.length-1;      
          });
          
          plot_type_list.add(null);
          plot_data_list.add(null);
          plot_init_list.add(true);          
        }
        
        
      }     
      
    });
    
    
    
  }
  
  
  void subfile_manage_dialog(){
    SHOW_FILE_MANAGE = true; 
    $['dialog'].toggle();    
  }
  
  void delete_sub_file(Event e, var detail, Element target){    
    int index = int.parse(target.attributes['data-msg']);
    ws.send(JSON.encode({"CMD":"delete-sub-file", "username":username, "subfile":file_list[index]}));    
    file_list.removeAt(index); 
    active_subfile = 0; 
  }
  
  
  void switch_sub_file(Event e, var detail, Element target){
    active_subfile = int.parse(target.attributes['data-msg']);     
  }
  
  void file_manage_close(){
    SHOW_FILE_MANAGE = false; 
    $['dialog'].toggle();
  }
  
  
  
  void new_table_file_(){
    
    FileX temp_file = new FileX(null, null, parentID, username, null, null, "table_file", null); //, 1.0);
    DateTime now = new DateTime.now();
    temp_file.created_time = now.toString();
    temp_file.modified_time = now.toString();
    String temp_id = parentID + "Table" + filecount.toString();
    temp_file.object_id = temp_id;
    temp_file.object_name = "Table" + filecount.toString();
    filecount += 1;
    temp_file.translate = new Num2<int>(0, filecount*40+240);    
    file_list.add(temp_file);   
    
  //  ws.send(JSON.encode({"CMD":"insert-sub-file", "data":temp_file}));
    
    plot_show = false;  
    gchart_show = false; 
    d3surface_show = false; 
    table_temp = new Table_Element_.init(3, 40, temp_id, username, "Empty");      
      if(table_temp!=null){
        obj_list.add(table_temp);
      } 
      current_index = obj_list.length-1;      
      table_show = true;
      
      
      plot_type_list.add(null);
      plot_data_list.add(null);
      plot_init_list.add(true);
    
  }
  
  void new_plot_file_(String _plot_type_, dynamic _plot_data_){
    
    FileX temp_file = new FileX(null, null, parentID, username, null, null, "plot_file", null); //, 1.0);
    DateTime now = new DateTime.now();
    temp_file.created_time = now.toString();
    temp_file.modified_time = now.toString();
    temp_file.object_id = parentID + "Plot" + filecount.toString();
    temp_file.object_name = "Plot" + filecount.toString();
    filecount += 1;
    temp_file.translate = new Num2<int>(0, filecount*40+240);    
    file_list.add(temp_file);  
    
  //  ws.send(JSON.encode({"CMD":"insert-sub-file", "data":temp_file}));
    
    table_show = false;  
    gchart_show = false; 
    d3surface_show = false; 
    plot_temp = new Plot2dElement_.init(_plot_type_, _plot_data_, temp_file.object_id);
      
      if(plot_temp!=null){
        obj_list.add(plot_temp);
      }  
      
      current_index = obj_list.length-1;       
      plot_show = true;
      
      plot_type_list.add(null);
      plot_data_list.add(null);
      plot_init_list.add(true);
  }
  
  
  void new_google_chart(String _plot_type_, List _plot_data_){
    
    FileX temp_file = new FileX(null, null, parentID, username, null, null, "gchart_file", null); //, 1.0);
    DateTime now = new DateTime.now();
    temp_file.created_time = now.toString();
    temp_file.modified_time = now.toString();
    temp_file.object_id = parentID + "GChart" + filecount.toString();
    temp_file.object_name = "GChart" + filecount.toString();
    filecount += 1;
    temp_file.translate = new Num2<int>(0, filecount*40+240);    
    file_list.add(temp_file);  
    
  //  ws.send(JSON.encode({"CMD":"insert-sub-file", "data":temp_file}));
    
    table_show = false;  
    plot_show = false;
    d3surface_show = false; 
   // print(_plot_data_); 
    
    gchart_temp = new GchartElement_.init(_plot_type_, _plot_data_, temp_file.object_id);
      
      if(gchart_temp!=null){
        obj_list.add(gchart_temp);
      }  
      
      gchart_show = true; 
      current_index = obj_list.length-1;      
      
      Timer.run((){
        GchartElement gchart = shadowRoot.querySelector("gchart-element");  
        gchart.refresh_plot(); 
      });       
      
      plot_type_list.add(null);
      plot_data_list.add(null);
      plot_init_list.add(true);
    
  }
  
  void new_d3surface_plot(String _plot_type_, dynamic _plot_data_){
    FileX temp_file = new FileX(null, null, parentID, username, null, null, "d3surface_file", null); //, 1.0);
    DateTime now = new DateTime.now();
    temp_file.created_time = now.toString();
    temp_file.modified_time = now.toString();
    temp_file.object_id = parentID + "D3Surface" + filecount.toString();
    temp_file.object_name = "Three" + filecount.toString();
    filecount += 1;
    temp_file.translate = new Num2<int>(0, filecount*40+240);    
    file_list.add(temp_file);  
    
    table_show = false;  
    plot_show = false;
    gchart_show = false; 
   // print(_plot_data_); 
    d3surface_show = true;       
      //d3surface_show = true;        
    //  Timer.run((){        
        d3surface_temp = new D3SurfaceElement_.init(_plot_type_, _plot_data_, temp_file.object_id);          
          if(d3surface_temp!=null){
            obj_list.add(d3surface_temp);
          }                 
          d3surface_show = true;                 
          Timer.run((){
            D3SurfaceElement d3surface = shadowRoot.querySelector("d3surface-element");  
            d3surface.Re_init(); 
          }); 
    //  });             
      current_index = obj_list.length-1;        
      plot_type_list.add(null);
      plot_data_list.add(null);
      plot_init_list.add(true);    
  }
  
  
  void new_plot_file_dialog(){
    table_name_list.clear(); 
    
    for(var obj in obj_list){
         int index = obj_list.indexOf(obj);
         if(file_list[index].type=="table_file"){
           List <Col_Name> temp_col_list = toObservable([]);                    
           for(var col in obj.table.Table_head_data){
             if(col.Head_property!="X" && col.Head_property!="G"){
                  temp_col_list.add(new Col_Name(col.col, col.Head_label)); 
             }
           }
           table_name_list.add(new Table_Name(index, file_list[index].object_name, temp_col_list));   
         }              
     }    
    
    PLOT_DIALOG_SHOW = true; 
    $['dialog'].toggle();
  }
  
  void add_data_set(){
    int table_index = table_name_list[choosed_table_index].index; 
    num Y_col = table_name_list[choosed_table_index].col_list[choosed_col_index].index; 
    String name = table_name_list[choosed_table_index].name + "_" + table_name_list[choosed_table_index].col_list[choosed_col_index].name;
    
    dataset_list.add(new PlotDataSet(table_index, Y_col, user_plot_type, name));
    
  }
  
  
  void delete_data_set(Event e, var detail, Element target){
    var p = JSON.decode(target.attributes['data-msg']);    
    dataset_list.removeAt(p); 
  }
  
  void plot_apply(){    
   // print(choosed_table_index);
   // print(choosed_col_index);     
    List <Grouped_Data> grouped_data = [];      
    
  for(int jjj=0; jjj<dataset_list.length; jjj++){    
    int table_index = dataset_list[jjj].table_index;     
    String plot_type = dataset_list[jjj].plot_type;
    num Y_col = dataset_list[jjj].col_index;
    num X_col = 0;    
    //num col = obj_list[choosed_table_index].table.    
    for(int i=Y_col; i>=0; i--){
        if(obj_list[table_index].table.Table_head_data[i].Head_property == "X"){
              X_col=i;
              break;
         }
     }      
    List <x_y_num> temp_list = [];      
    for(num i=0; i<obj_list[table_index].table.num_of_row; i++){
      temp_list.add(new x_y_num(double.parse(obj_list[table_index].table.Table_data[i].Row_data[X_col].Cell_data),
          double.parse(obj_list[table_index].table.Table_data[i].Row_data[Y_col].Cell_data)));       
    }
    grouped_data.add(new Grouped_Data(temp_list, " ", " ", plot_type));    
  }    // end of for(int i=0; i=dataset_list.length; i++){    
  
 //   LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
    this.new_plot_file_("overlay", grouped_data);    
    PLOT_DIALOG_SHOW = false; 
    $['dialog'].toggle();
  }
  
  
  void plot_cancel(){
    PLOT_DIALOG_SHOW = false; 
    $['dialog'].toggle();
  }
  
  
  
  void show_selected_file(Event e, var detail, Element target){
    
   // print(target.attributes['data-msg']);
    
    var p = JSON.decode(target.attributes['data-msg']);    
    int index = p["idx"];
    
    if(index!=current_index){
      if(p["type"]=="table_file"){
        table_show = true;
        plot_show = false;
        gchart_show = false; 
        d3surface_show = false; 
        table_temp = obj_list[index];   
        
       // shadowRoot.querySelector("d3surface-element").shadowRoot.querySelector('#ThreeJS').style.opacity = "0.0"; 

      }      
      
      if(p["type"]=="gchart_file"){
        table_show = false;
        plot_show = false;
        gchart_show = true; 
        d3surface_show = false; 
        gchart_temp = obj_list[index];           
        Timer.run((){
          GchartElement gchart = shadowRoot.querySelector("gchart-element");
          gchart.refresh_plot();          
        });        
      }  
      
      
      if(p["type"]=="d3surface_file"){        
       // shadowRoot.querySelector("d3surface-element").shadowRoot.querySelector('#ThreeJS').style.opacity = "1.0"; 
       // table_show = false;       
      d3surface_show = false;    
      Timer.run((){  
        table_show = false;
        plot_show = false;
        gchart_show = false;         
      //  Timer.run((){        
          //d3surface_temp = new D3SurfaceElement_.init();    
          d3surface_temp = obj_list[index];          
        //d3surface_temp = new D3SurfaceElement_.init();           
          d3surface_show = true;             
            Timer.run((){
              D3SurfaceElement d3surface = shadowRoot.querySelector("d3surface-element");  
              d3surface.Re_init(); 
            });      
         });
      }            
      
      if(p["type"]=="plot_file" && plot_init_list[index]==true){
        table_show = false;
        plot_show = true;
        gchart_show = false; 
        d3surface_show = false; 
        plot_temp = obj_list[index];      
      }
      
      if(p["type"]=="plot_file" && plot_init_list[index]==false){
        plot_temp = new Plot2dElement_.init(plot_type_list[index], plot_data_list[index], file_list[index].object_id);          
          if(plot_temp!=null){
            obj_list[index] = plot_temp;
          }            
      //    ws.send(JSON.encode({"CMD":"insert-sub-file", "data":plot_temp}));          
     //     current_index = index;       
        table_show = false;
        gchart_show = false; 
        plot_show = true;
        d3surface_show = false;         
        plot_init_list[index] = true; 
    //    plot_temp = obj_list[index];      
      }
      
    }    
    
    current_index = index;
    
  }
  
  
  void push_plot_list(String _plot_type_, dynamic _plot_data_){
    plot_type_list.add(_plot_type_);
    plot_data_list.add(_plot_data_);
    plot_init_list.add(false);
    
    FileX temp_file = new FileX(null, null, parentID, username, null, null, "plot_file", null); //, 1.0);
    DateTime now = new DateTime.now();
    temp_file.created_time = now.toString();
    temp_file.modified_time = now.toString();
    temp_file.object_id = parentID + "Plot" + filecount.toString();
    temp_file.object_name = "Plot" + filecount.toString();
    filecount += 1;
    temp_file.translate = new Num2<int>(0, filecount*40+240);    
    file_list.add(temp_file);  
    
   // ws.send(JSON.encode({"CMD":"insert-sub-file", "data":temp_file}));  
    
    obj_list.add(null);
    
  }  
  
  
  
  void save_and_exit(){
  if(readonly==false){
    
  //  for(var file in file_list){
  //    ws.send(JSON.encode({"CMD":"insert-sub-file", "data":file}));  
  //  }
    
    for(var obj in obj_list){
      int index = obj_list.indexOf(obj);
      if(file_list[index].type=="table_file"){
        obj.table.write_to_db();  
        DateTime now = new DateTime.now();
        file_list[index].modified_time = now.toString();
        ws.send(JSON.encode({"CMD":"insert-sub-file", "data":file_list[index]}));
     //   ws.send(JSON.encode());  
      }  
      if(file_list[index].type=="plot_file"){
        for(var ooo in obj.data_plot_list){
          ooo.write_to_db(ws);
          DateTime now = new DateTime.now();
          file_list[index].modified_time = now.toString();
          ws.send(JSON.encode({"CMD":"insert-sub-file", "data":file_list[index]}));
        }        
      }  
      if(file_list[index].type=="gchart_file"){
        obj.write_to_db();                                  // GchartElement_    write_to_db() method. 
        DateTime now = new DateTime.now();
        file_list[index].modified_time = now.toString();
        ws.send(JSON.encode({"CMD":"insert-sub-file", "data":file_list[index]}));      
    }
      if(file_list[index].type=="d3surface_file"){
        obj.write_to_db();                                  // GchartElement_    write_to_db() method. 
        DateTime now = new DateTime.now();
        file_list[index].modified_time = now.toString();
        ws.send(JSON.encode({"CMD":"insert-sub-file", "data":file_list[index]}));      
    }
      
    }
    
    DataProjElement p2d = document.querySelector("folder-element");    
    p2d.show_selected_dataproj=false;    
  }
    
  }
  
  void save_not_exit(){
    
    DataProjElement p2d = document.querySelector("folder-element");    
    p2d.show_selected_dataproj=false;    
    
  }
  
  void exit_buttton_exec(){
    if(readonly==true){
      this.save_not_exit();
    }
    if(readonly==false){
      this.save_and_exit(); 
    }
  }
  
  
  @override
  attached() {
    super.attached();
    
    if(readonly==true){
      window.alert("You are in ReadOnly mode!"); 
    }
    
    
    DataProjElement p2d = document.querySelector("folder-element");
    p2d.update_edit_status(parentID, true);
    
    void timeout(){
      $['save_exit'].style.display = "none";
      $['save_no_exit'].style.display = "none";
    }
    
    $['save_and_exit'].onMouseOver.listen((event){
      $['save_exit'].style.display = "block";
      $['save_no_exit'].style.display = "block";
      new Timer(const Duration(seconds:5), timeout);
    }); 
     
    
  }  //end of enteredView 
  
  
  @override
  detached() {
    super.detached();
    DataProjElement p2d = document.querySelector("folder-element");   
    p2d.update_edit_status(parentID, false);
  }  //end of enteredView 
  
}








