library tableelement;


import './table-core.dart'; 
import 'package:polymer/polymer.dart';
import 'dart:async';
//import './Expression.dart';
import 'dart:convert';
//import './interval_decimal.dart';
import 'dart:html';
//import 'package:three/three.dart';
//import 'package:vector_math/vector_math.dart';
import './shared_functions.dart';
import 'dart:js';
import 'dart:math' as math;
//import 'dart:async';
//import './three-triangle.dart';
//import './three-parent.dart';
import './lagrange-interpolation.dart';
import './plot2d_element.dart';
import './import_data.dart';
import './layout.dart';
import './ui_filters.dart';
import 'package:polymer_expressions/filter.dart';
import './map_var.dart';


/**
 * A Polymer click counter element.
 */
@CustomTag('table-element')
class Table_Element extends PolymerElement {
  @published Table table;
  @published int table_right;
  @published int table_bottom;
  @published CTXmenu_show ctxmenu_show;
  
  @published Table_select table_select;
  @published List <Table_select_rec> table_select_history = [];
  
  @published Set_column_value set_col_value;
  @published Copy_Buffer copy_buffer_object;
//  @published Scene scene = new Scene();
//  @published ThreeD_Surface_Plot threed_surf_plt;
  @published Plot_Dialog plot_dialog;
  @published Batch_Plot_Dialog batch_plot_dialog;
  
  @published bool table_show_mode = true;
  @published bool show_lag_inter_diaglog =  false;
//  @published String template_col_inter = null; 
  @observable String template_col_inter = "A"; 
  //@published bool show_2d_plot_mode = false;
  @published bool import_txt_dialog_show = false;
  
  //@published String plot_type;
  //@published dynamic plot_data;
  
  @published Geography_Set_As geography_set_as;
  @published Grid_Insert grid_insert;
  
  @observable int active_page = 0; 
  @observable int num_of_page = 200; 
  
  @observable bool FIND_DIALOG_SHOW = false;
  @observable bool REPLACE_DIALOG_SHOW = false; 
  @observable String find_string = "";
  @observable String replace_string = "";
  int current_col=0, current_row=0;
  @observable int scroll_top = 0; 
  
  bool CTRL_KEY_DOWN = false; 
  bool SHIFT_KEY_DOWN = false; 
  @observable bool FFT_DIALOG_SHOW = false; 
  
  @observable String input_col;
  @observable String output_col; 
  @observable bool DROP_MENU_SHOW = false; 
  @observable bool DROPBOX_DIALOG = false; 
  bool dropbox_read_start = false; 
  @observable bool RESIZE_DIALOG_SHOW = false; 
  @observable int new_num_of_row = 0;
  @observable int new_num_of_col = 0; 
  @observable bool COL_PROPERTY_SHOW = false; 
  @observable int active_col = 0; 
  
  Table_Element.created() : super.created() { } //  this.Re_init();   }     && event.origin=='http://127.0.0.1:8080'
  
  
  void attached() {
    super.attached(); 
    
    
    window.onMessage.listen((event){
      if(dropbox_read_start==true && event.origin=="http://127.0.0.1:8080"){
         // window.alert(event.data);
         // dropbox_read_start = false; 
          //var sheet = new CsvSheet(event.data, headerRow: false);
          this.table.csv_reinit(event.data);
          
       //   print(event.origin); 
        //  print(event.data);
          this.dropbox_dialog_cancel(); 
      }
      //print(event.data);
    }); 
    
    
    
    Timer.run((){            
        document.onContextMenu.listen((event){
          int x = event.client.x + document.body.scrollLeft + document.documentElement.scrollLeft;// - svgElement.offset.left ;
          int y = event.client.y + document.body.scrollTop + document.documentElement.scrollTop;// - svgElement.offset.top ;     
          ctxmenu_show.y_pos = y+5;
          ctxmenu_show.x_pos = x-150;
          event.preventDefault(); 
        });          
        
        
      // $[].querySelectorAll("li").onClick((event){
      //    DROP_MENU_SHOW = true; 
      //  });       
        
        
        $["menu_nav"].querySelectorAll("li").onMouseOver.listen((event){
          DROP_MENU_SHOW = true; 
        });  
        
        
        document.onClick.listen((event){ 
          
          //$["menu_nav"]
         // shadowRoot.querySelector("#menu_nav").querySelector("li").querySelector("ul").style.visibility = "none"; 
          
          if(ctxmenu_show.contextmenu_show==true){            
            for(var _table_select in table_select_history){     
              for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
                for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
                  table.Table_data[i].Row_data[j].select = "white";
                }
              }
            }       
            table_select_history.clear();    
            ctxmenu_show.contextmenu_show = false;  
          }          
                           
        });
        
        document.onMouseUp.listen((event){ 
          table_select.select_begin = false; 
        });         
        
      //  var k = new KeyCode();
        
        document.onKeyDown.listen((event){
          if(event.keyCode==KeyCode.CTRL){
            CTRL_KEY_DOWN = true; 
          }
          if(event.keyCode==KeyCode.SHIFT){
            SHIFT_KEY_DOWN = true;
          }
        });
        
        document.onKeyUp.listen((event){
          CTRL_KEY_DOWN = false; 
          SHIFT_KEY_DOWN = false; 
        });
        
       // document.onKeyPress
        
    });
    
    
  }
  
  final Transformer asInteger = new StringToInt();
  final Transformer asDouble = new StringToDouble();
  
  
  Filter myfilter(int min, int max) => (list) => list.where((item) => (item.row==null ? false: item.row>=min && item.row<max ));
  
  /*
  Filter myfilter(int min, int max) {
    return (num n) {
      return n.toStringAsFixed(digits);
    };
  }*/
  
  
  void ctx_find_dialog(){
    DROP_MENU_SHOW = false; 
    FIND_DIALOG_SHOW = true; 
    current_col=0;
    current_row=0;
  }
  
  void find_dialog_cancel(){
    FIND_DIALOG_SHOW = false;
  }
  
  void find_next_apply(){    
    table.Table_data[current_row].Row_data[current_col].select = "white";    
    String id;
    for(int i=current_row; i<table.num_of_row; i++){
      for(int j=current_col; j<table.num_of_col; j++){
        if(table.Table_data[i].Row_data[j].Cell_data==find_string){
          if(current_row==i && current_col==j){
            continue;
          }
          current_row = i; 
          current_col = j;
          id="R"+i.toString()+"C"+j.toString();
          shadowRoot.querySelector("#"+id).scrollIntoView();
          scroll_top = document.body.scrollTop + document.documentElement.scrollTop;          
          table.Table_data[current_row].Row_data[current_col].select = "#0066FF";
          return;
        }
      }
    }
    
  }
  
  void ctx_replace_dialog(){
    DROP_MENU_SHOW = false; 
    REPLACE_DIALOG_SHOW = true; 
  }
  
  void replace_next_apply(){
    table.Table_data[current_row].Row_data[current_col].Cell_data=replace_string; 
  }
  
  void find_replace_all(){
    for(int i=0; i<table.num_of_row; i++){
      for(int j=0; j<table.num_of_col; j++){
        if(table.Table_data[i].Row_data[j].Cell_data==find_string){          
          table.Table_data[i].Row_data[j].Cell_data=replace_string; 
          table.Table_data[i].Row_data[j].select = "#0066FF";
        }
      }
    }
  }
  
  void replace_dialog_cancel(){
    REPLACE_DIALOG_SHOW = false; 
  }
  
  
  
  void ctx_next_page(){
    if(active_page < (table.num_of_row-1)/num_of_page-1){
      active_page += 1; 
    }
  }
  
  void ctx_prev_page(){
    if(active_page > 0){
      active_page -= 1; 
    }
  }
  
  void ctx_first_page(){
    active_page = 0;
  }
  
  void ctx_last_page(){
    active_page = ((table.num_of_row-1)/num_of_page).toInt();
  }
  
  /*
  
  void write_to_db(Event e, var detail, Element target){
    table.write_to_db();
  //  print(JSON.encode(table));
    }
  
  void read_from_db(Event e, var detail, Element target){
    table.read_from_db();
  }
 */
  
 void show_table() {
   
   table_show_mode=true;
   
   var base_div = shadowRoot.querySelector("#plot_sss");
   
   base_div.style.display = "none";
 } 
//  show_plot() => data_plot.plot_mode_show = true;
  
  
  void show_input(Event e, var detail, Element target){
    var p = JSON.decode(target.attributes['data-msg']);
    table.Table_data[p["row"]].Row_data[p["col"]].edit = true;
  }
  
  void hide_input(Event e, var detail, Element target){
      var p = JSON.decode(target.attributes['data-msg']);
      table.Table_data[p["row"]].Row_data[p["col"]].edit = false;
   }
  
  /*
  void enter_key_input(Event e, var detail, Element target){
    if(e.keyCode==KeyCode.ENTER){
          CTRL_KEY_DOWN = true; 
    }
  }*/
  
  
  void show_contextmenu(Event event, var detail, Element target){
    ctxmenu_show.contextmenu_show = true;
 //   print(target.attributes['data-msg']);
    var p = JSON.decode(target.attributes['data-msg']);
    ctxmenu_show.row = p["row"];
    ctxmenu_show.col = p["col"];
    bool inside = false; 
    
    for(var _table_select in table_select_history){   
      if(ctxmenu_show.row>=_table_select.row_start && ctxmenu_show.row<=_table_select.row_end 
          && ctxmenu_show.col>=_table_select.col_start && ctxmenu_show.col<=_table_select.col_end){
        inside = true; 
      }
    } 
    
    if(inside==false){
      ctxmenu_show.contextmenu_show = false; 
    }
    
    //ctxmenu_show.menu_type : "all", "column", "row", "ok-region", "region", "cell", "multi-column", "multi-row", "multi-ok-region", "unknown-select-type"
  if(inside==true){
    if(table_select_history.length==1){
      ctxmenu_show.menu_type = table_select_history[0].select_type;
      if(table_select_history[0].select_type=="region" && table_select_history[0].row_end>table_select_history[0].row_start){
        ctxmenu_show.menu_type = "ok-region"; 
      }
  /*    if(table_select_history[0].select_type=="column"){
        CTX_MENU_PLOT = true;
      }  */
      if(table_select_history[0].select_type=="region" && table_select_history[0].row_end==table_select_history[0].row_start && table_select_history[0].col_end==table_select_history[0].col_start){
        ctxmenu_show.menu_type = "cell";
      }
    }       
    
    if(table_select_history.length>1){
      List <String> type_dict = []; 
      for(var _table_select in table_select_history){     
        if(_table_select.select_type=="region" && _table_select.row_end==_table_select.row_start && _table_select.col_end==_table_select.col_start){
          _table_select.select_type = "cell";
        }
        if(_table_select.select_type=="region" && _table_select.row_end>_table_select.row_start){
          _table_select.select_type = "ok-region";
        }
        
        if(!type_dict.contains(_table_select.select_type)){
          type_dict.add(_table_select.select_type);
        }      
      }
      
    //  CTX_MENU_PLOT = false; 
      
      if(type_dict.length==1){
        if(type_dict[0]=="column"){
          ctxmenu_show.menu_type = "multi-column";  
      //    CTX_MENU_PLOT = true;
        }
        if(type_dict[0]=="row"){
          ctxmenu_show.menu_type = "multi-row";  
      //    CTX_MENU_PLOT = true;
        }
        if(type_dict[0]=="ok-region"){
          ctxmenu_show.menu_type = "multi-ok-region";  
     //     CTX_MENU_PLOT = true;
        }
      }
      if(type_dict.length>1){
        ctxmenu_show.menu_type = "unknown-select-type"; 
      }      
    }
  }  // end of if(inside==true){
    
 } 
  
  /*
  void cell_select(Event event, var detail, Element target){
    ctxmenu_show.menu_type = "cell";
  } */
  
  void all_select(Event event, var detail, Element target){
    table_select.row_start = 0;
    table_select.row_end = table.num_of_row-1;
    table_select.col_start = 0;
    table_select.col_end = table.num_of_col-1;  
    for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
      for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
        table.Table_data[i].Row_data[j].select = "#0066FF";
      }
    } //end of for loop 
   // ctxmenu_show.menu_type = "all";    
    
    table_select_history.clear();   
    table_select_history.add(new Table_select_rec(table_select.row_start, table_select.col_start, table_select.row_end, table_select.col_end, "all"));   
    
  }
  
  void col_select(Event event, var detail, Element target){        
    var p = JSON.decode(target.attributes['data-msg']);    
    if(CTRL_KEY_DOWN==false && SHIFT_KEY_DOWN==false){
      for(var _table_select in table_select_history){     
        for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
          for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
            if(i<table.num_of_row && j<table.num_of_col){
                table.Table_data[i].Row_data[j].select = "white";
            }
          }
        }
      }       
      table_select_history.clear();        
    }    

      if(p["col"]>=0 && p["col"]<table.num_of_col){
        table_select.row_start = 0;
        table_select.row_end = table.num_of_row-1;
        table_select.col_start = p["col"];
        table_select.col_end = p["col"];  
      }//end of if(p["col"]>0 && p["col"]<num_of_col){
      
      for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
        for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
          table.Table_data[i].Row_data[j].select = "#0066FF";
        }
      } //end of for loop 
 //     ctxmenu_show.menu_type = "column";

    if(SHIFT_KEY_DOWN==false){
      table_select_history.add(new Table_select_rec(table_select.row_start, table_select.col_start, table_select.row_end, table_select.col_end, "column"));         
    }    
    
    if(SHIFT_KEY_DOWN==true && table_select_history.length>0){      
      int last_row_start = table_select_history[table_select_history.length-1].row_start;
      int last_row_end = table_select_history[table_select_history.length-1].row_end;
      int last_col_start = table_select_history[table_select_history.length-1].col_start;
      int last_col_end = table_select_history[table_select_history.length-1].col_end;      
      for(var _table_select in table_select_history){   
        for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
          for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
            table.Table_data[i].Row_data[j].select = "white";
          }
        }
      }       
      table_select_history.clear();          
      int this_row_start = table_select.row_start<last_row_start ? table_select.row_start : last_row_start; 
      int this_row_end = table_select.row_end>last_row_end ? table_select.row_end : last_row_end;
      int this_col_start = table_select.col_start<last_col_start ? table_select.col_start : last_col_start;
      int this_col_end = table_select.col_end>last_col_end ? table_select.col_end : last_col_end; 
      table_select_history.add(new Table_select_rec(this_row_start, this_col_start,this_row_end, this_col_end, "region"));          
      for(num i=this_row_start; i<(this_row_end+1); i++){
        for(num j=this_col_start; j<(this_col_end+1); j++){       
          table.Table_data[i].Row_data[j].select = "#0066FF";
        }
      } //end of for loop       
    }    
    
    if(SHIFT_KEY_DOWN==true && table_select_history.length==0){
      table_select_history.add(new Table_select_rec(table_select.row_start, table_select.col_start, table_select.row_end, table_select.col_end, "column"));    
    }
    
  }

  
  void row_select(Event event, var detail, Element target){
    var p = JSON.decode(target.attributes['data-msg']);
    
    if(CTRL_KEY_DOWN==false && SHIFT_KEY_DOWN==false){
      for(var _table_select in table_select_history){     
        for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
          for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
            table.Table_data[i].Row_data[j].select = "white";
          }
        }
      }       
      table_select_history.clear();        
    }    

    if(p["row"]>=0 && p["row"]<table.num_of_row){
      table_select.row_start = p["row"];
      table_select.row_end = p["row"];
      table_select.col_start = 0;
      table_select.col_end = table.num_of_col-1;  
    }
      
      for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
        for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
          table.Table_data[i].Row_data[j].select = "#0066FF";
        }
      } //end of for loop 
 //     ctxmenu_show.menu_type = "row"; 

    if(SHIFT_KEY_DOWN==false){
      table_select_history.add(new Table_select_rec( table_select.row_start, table_select.col_start, table_select.row_end, table_select.col_end, "row"));         
    }    
    
    if(SHIFT_KEY_DOWN==true && table_select_history.length>0){      
      int last_row_start = table_select_history[table_select_history.length-1].row_start;
      int last_row_end = table_select_history[table_select_history.length-1].row_end;
      int last_col_start = table_select_history[table_select_history.length-1].col_start;
      int last_col_end = table_select_history[table_select_history.length-1].col_end;      
      for(var _table_select in table_select_history){   
        for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
          for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
            table.Table_data[i].Row_data[j].select = "white";
          }
        }
      }       
      table_select_history.clear();          
      int this_row_start = table_select.row_start<last_row_start ? table_select.row_start : last_row_start; 
      int this_row_end = table_select.row_end>last_row_end ? table_select.row_end : last_row_end;
      int this_col_start = table_select.col_start<last_col_start ? table_select.col_start : last_col_start;
      int this_col_end = table_select.col_end>last_col_end ? table_select.col_end : last_col_end; 
      table_select_history.add(new Table_select_rec(this_row_start, this_col_start, this_row_end, this_col_end, "region"));          
      for(num i=this_row_start; i<(this_row_end+1); i++){
        for(num j=this_col_start; j<(this_col_end+1); j++){       
          table.Table_data[i].Row_data[j].select = "#0066FF";
        }
      } //end of for loop       
    }    
    
    if(SHIFT_KEY_DOWN==true && table_select_history.length==0){
      table_select_history.add(new Table_select_rec(table_select.row_start, table_select.col_start,  table_select.row_end, table_select.col_end, "row"));    
    }
    
  }
    
  
  void mouse_down(Event event, var detail, Element target){
    if(event.button==0){
    var p = JSON.decode(target.attributes['data-msg']);
    
    if(CTRL_KEY_DOWN==false){
      for(var _table_select in table_select_history){     
        for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
          for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
            table.Table_data[i].Row_data[j].select = "white";
          }
        }
      }       
      table_select_history.clear();        
    }  
    
    table_select.row_start = p["row"];
    table_select.col_start = p["col"];
    table_select.row_temp = p["row"];
    table_select.col_temp = p["col"];
    table_select.row_end = p["row"];
    table_select.col_end = p["col"]; 
    table_select.select_begin = true;
    table.Table_data[p["row"]].Row_data[p["col"]].select = "#0066FF";
    
    table_select_history.add(new Table_select_rec(table_select.row_start, table_select.col_start, table_select.row_end, table_select.col_end, "region"));         
    }
  }
  
  void mouse_move(Event event, var detail, Element target){
    if(table_select.select_begin==true){
 //     ctxmenu_show.menu_type = "region";
      var p = JSON.decode(target.attributes['data-msg']);
      table_select.row_temp = p["row"];
      table_select.col_temp = p["col"];
      if(table_select.row_temp!=table_select.row_end || table_select.col_temp!= table_select.col_end){
        for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
          for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
            table.Table_data[i].Row_data[j].select = "white";
          }
        } //end of for loop
        table_select.row_end = table_select.row_temp;
        table_select.col_end = table_select.col_temp;
        for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
          for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
            table.Table_data[i].Row_data[j].select = "#0066FF";
          }
        } //end of for loop        
      }      //end of table_select.row_temp!=table_select.row_end || table_select.col_temp!= table_select.col_end
      
      table_select_history.last.row_end = table_select.row_end;
      table_select_history.last.col_end = table_select.col_end; 
      
     // if(CTRL_KEY_DOWN==true){
     //   table_select_history.add(new Table_select(null, table_select.row_start, table_select.col_start, null, null, table_select.row_end, table_select.col_end));         
     // }    
      
    } //end of table_select.select_begin==true
  }
  
  
  void ctx_copy(){
    copy_buffer_object.Buffer_content = [];
    //print("xxxxxxxxx");
    for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
      List <String> temp_buffer = [];
      for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
        temp_buffer.add(table.Table_data[i].Row_data[j].Cell_data);
      }
      copy_buffer_object.Buffer_content.add(temp_buffer);
    } //end of for loop 
    copy_buffer_object.col_length = table_select.col_end+1-table_select.col_start;
    copy_buffer_object.row_length = table_select.row_end+1-table_select.row_start;
  }
  
  void ctx_paste(){
    if(copy_buffer_object.col_length>0 && copy_buffer_object.row_length>0){
      if(ctxmenu_show.menu_type == "cell" || ctxmenu_show.menu_type == "region" || ctxmenu_show.menu_type == "ok-region"){
        for(num i=0; i<copy_buffer_object.row_length; i++){
          for(num j=0; j<copy_buffer_object.col_length; j++){
            if((table_select.row_start+i)<table.num_of_row && (table_select.col_start+j)<table.num_of_col){
              table.Table_data[table_select.row_start+i].Row_data[table_select.col_start+j].Cell_data = copy_buffer_object.Buffer_content[i][j];
            }
          }
        }
      }
      
      if(ctxmenu_show.menu_type == "column"){
        for(num i=0; i<copy_buffer_object.row_length; i++){          
            table.Table_data[i].Row_data[table_select.col_start].Cell_data = copy_buffer_object.Buffer_content[i][0];          
        }
      }
      
      if(ctxmenu_show.menu_type == "row"){
        for(num i=0; i<copy_buffer_object.col_length; i++){
          table.Table_data[table_select.row_start].Row_data[i].Cell_data = copy_buffer_object.Buffer_content[0][i];
        }
      }
      
    }
  } 
  
  void ctx_cut(){
    copy_buffer_object.Buffer_content = [];
    for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
      List <String> temp_buffer = [];
      for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
        temp_buffer.add(table.Table_data[i].Row_data[j].Cell_data);
        table.Table_data[i].Row_data[j].Cell_data = " ";
      }
      copy_buffer_object.Buffer_content.add(temp_buffer);
    } //end of for loop 
    copy_buffer_object.col_length = table_select.col_end+1-table_select.col_start;
    copy_buffer_object.row_length = table_select.row_end+1-table_select.row_start;
  }
  
  
  
  void ctx_clear(){
    for(num i=table_select.row_start; i<(table_select.row_end+1); i++){
      for(num j=table_select.col_start; j<(table_select.col_end+1); j++){       
        table.Table_data[i].Row_data[j].Cell_data = " ";
      }
    } //end of for loop 
  }
  
  void ctx_delete(){  //need to be modified
    if(ctxmenu_show.menu_type == "column"){
      for(num i=0; i<table.num_of_row; i++){
        table.Table_data[i].Row_data.removeAt(ctxmenu_show.col);
      }
      table.Table_head_data.removeAt(ctxmenu_show.col);
      table.num_of_col -= 1;   //end of element removal, decrease the num_of_col
    //  if(table.num_of_col==0){
    //    table.Table_data.clear(); 
    //  }      
      for(num i=0; i<table.num_of_row; i++){
        for(num j=ctxmenu_show.col; j<table.num_of_col; j++){
          table.Table_data[i].Row_data[j].col -= 1;
        }
      }
      for(num j=(ctxmenu_show.col); j<(table.num_of_col); j++){
        table.Table_head_data[j].col -= 1;
      }
    }
    if(ctxmenu_show.menu_type == "row"){
      table.Table_data.removeAt(ctxmenu_show.row);
      table.num_of_row -= 1;        //end of element removal, decrease the num_of_row
      for(num i=ctxmenu_show.row; i<table.num_of_row; i++){
        for(num j=0; j<table.num_of_col; j++){
          table.Table_data[i].Row_data[j].row -= 1;
        }
      }
      for(num j=ctxmenu_show.row; j<table.num_of_row; j++){
        table.Table_data[j].row -= 1;
        table.Table_data[j].label = table.Table_data[j].row.toString();
      }
    }
  }
  
  void ctx_insert_col(){    //need to be modified
    if(ctxmenu_show.menu_type == "column"){
      for(num i=0; i<table.num_of_row; i++){
        var cell = new Cell("", null, "black", i, ctxmenu_show.col, false, "white", table.username);
        table.Table_data[i].Row_data.insert(ctxmenu_show.col, cell);
      }
      table.Table_head_data.insert(ctxmenu_show.col, new Head("Y", table.next_head_label(), ctxmenu_show.col));
      table.num_of_col += 1;  // end of element insert, increase the num_of_col
      for(num i=0; i<table.num_of_row; i++){
        for(num j=(ctxmenu_show.col+1); j<table.num_of_col; j++){
          table.Table_data[i].Row_data[j].col += 1;
        }
      }
      for(num j=(ctxmenu_show.col+1); j<(table.num_of_col); j++){
        table.Table_head_data[j].col += 1;
      }
      for(num j=0; j<table.num_of_row; j++){       
        table.Table_data[j].Row_data[ctxmenu_show.col+1].select = "white";
      } 
    }
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0;      
  }
  
  void ctx_insert_row(){
    if(ctxmenu_show.menu_type == "row"){
      List <Cell> temp_row = toObservable([]);   
      for(int j=0; j<table.num_of_col; j++){
        var cell = new Cell("", null ,"black", ctxmenu_show.row, j, false, "white", table.username);
        temp_row.add(cell);
      }      
      table.Table_data.insert(ctxmenu_show.row, new Row(ctxmenu_show.row.toString(), ctxmenu_show.row, temp_row));
      table.num_of_row += 1;      //end of element insert, increase the num_of_row
      for(num i=(ctxmenu_show.row+1); i<table.num_of_row; i++){
        for(num j=0; j<table.num_of_col; j++){
          table.Table_data[i].Row_data[j].row += 1;
        }
      }
      for(num j=(ctxmenu_show.row+1); j<table.num_of_row; j++){
        table.Table_data[j].row += 1;
        table.Table_data[j].label = table.Table_data[j].row.toString();
      }
      for(num j=0; j<table.num_of_col; j++){       
        table.Table_data[ctxmenu_show.row+1].Row_data[j].select = "white";
      }
    }
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0;  
  }
  
  
  void ctx_insert_grid(Event event, var detail, Element target){
    $['dialog'].toggle();
    grid_insert.show_insert_grid_dialog = true;
    grid_insert.grid_type = target.attributes['data-msg'];
  }
  
  void grid_insert_apply(){
    if(grid_insert.grid_type=="Grid_1d"){
          double step_x = (grid_insert.x_max-grid_insert.x_min)/(grid_insert.num_x_point-1);       
          if(grid_insert.num_x_point<=table.num_of_row){
            for(num i=0; i<grid_insert.num_x_point; i++){
              var cell = new Cell((grid_insert.x_min+i*step_x).toStringAsPrecision(5), (grid_insert.x_min+i*step_x), "black", i, ctxmenu_show.col, false, "white", table.username);
              table.Table_data[i].Row_data.insert(ctxmenu_show.col, cell);
            }
            for(int i=grid_insert.num_x_point; i<table.num_of_row; i++){
              var cell = new Cell("", null, "black", i, ctxmenu_show.col, false, "white", table.username);
              table.Table_data[i].Row_data.insert(ctxmenu_show.col, cell);
            }
          }
          if(grid_insert.num_x_point>table.num_of_row){
            for(int i=table.num_of_row; i<grid_insert.num_x_point; i++){
              List <Cell> temp_row = toObservable([]);
              for(int j=0; j<table.num_of_col; j++){
                var cell = new Cell("", 0.0, "black", i, j, false, "white", table.username);
                temp_row.add(cell);
              }
              table.Table_data.add(new Row(i.toString(), i, temp_row));
            }            
            for(num i=0; i<grid_insert.num_x_point; i++){
              var cell = new Cell((grid_insert.x_min+i*step_x).toStringAsPrecision(5), (grid_insert.x_min+i*step_x), "black", i, ctxmenu_show.col, false, "white", table.username);
              table.Table_data[i].Row_data.insert(ctxmenu_show.col, cell);
            }          
            table.num_of_row = grid_insert.num_x_point; 
          }
            table.Table_head_data.insert(ctxmenu_show.col, new Head("X", table.next_head_label(), ctxmenu_show.col));
            table.num_of_col += 1;  // end of element insert, increase the num_of_col
            for(num i=0; i<table.num_of_row; i++){
              for(num j=(ctxmenu_show.col+1); j<table.num_of_col; j++){
                table.Table_data[i].Row_data[j].col += 1;
              }
            }
            for(num j=(ctxmenu_show.col+1); j<(table.num_of_col); j++){
              table.Table_head_data[j].col += 1;
            }
            for(num j=0; j<table.num_of_row; j++){       
                    table.Table_data[j].Row_data[ctxmenu_show.col+1].select = "white";
           } 
      
    }  // end if if(grid_insert.grid_type=="Grid_1d"){
    if(grid_insert.grid_type=="Grid_2d"){
      double step_x = (grid_insert.x_max-grid_insert.x_min)/(grid_insert.num_x_point-1);           
      double step_y = (grid_insert.y_max-grid_insert.y_min)/(grid_insert.num_y_point-1);   
    if(grid_insert.num_x_point*grid_insert.num_y_point<=table.num_of_row){
      for(num i=0; i<grid_insert.num_x_point; i++){          
          for(num j=0; j<grid_insert.num_y_point; j++){
            var cell_x = new Cell((grid_insert.x_min+i*step_x).toStringAsPrecision(5), (grid_insert.x_min+i*step_x), "black", i*grid_insert.num_y_point+j, ctxmenu_show.col, false, "white", table.username);
            table.Table_data[i*grid_insert.num_y_point+j].Row_data.insert(ctxmenu_show.col, cell_x);
           var cell_y = new Cell((grid_insert.y_min+j*step_y).toStringAsPrecision(5), (grid_insert.y_min+j*step_y), "black", i*grid_insert.num_y_point+j, ctxmenu_show.col+1, false, "white", table.username);
            table.Table_data[i*grid_insert.num_y_point+j].Row_data.insert(ctxmenu_show.col+1, cell_y);
          }
        }
      for(int i=grid_insert.num_x_point*grid_insert.num_y_point; i<table.num_of_row; i++){
        var cell_x = new Cell("", null,  "black", i, ctxmenu_show.col, false, "white", table.username);
        table.Table_data[i].Row_data.insert(ctxmenu_show.col, cell_x);
        var cell_y = new Cell("", null,  "black", i, ctxmenu_show.col+1, false, "white", table.username);
        table.Table_data[i].Row_data.insert(ctxmenu_show.col+1, cell_y);
      }
    }  // end of  if(grid_insert.num_x_point*grid_insert.num_y_point<=table.num_of_row){
    if(grid_insert.num_x_point*grid_insert.num_y_point>table.num_of_row){
      for(int i=table.num_of_row; i<grid_insert.num_x_point*grid_insert.num_y_point; i++){
        List <Cell> temp_row = toObservable([]);
        for(int j=0; j<table.num_of_col; j++){
          var cell = new Cell("", 0.0, "black", i, j, false, "white", table.username);
          temp_row.add(cell);
        }
        table.Table_data.add(new Row(i.toString(), i, temp_row));
      }         
      for(num i=0; i<grid_insert.num_x_point; i++){          
          for(num j=0; j<grid_insert.num_y_point; j++){
            var cell_x = new Cell((grid_insert.x_min+i*step_x).toStringAsPrecision(5), (grid_insert.x_min+i*step_x), "black", i*grid_insert.num_y_point+j, ctxmenu_show.col, false, "white", table.username);
            table.Table_data[i*grid_insert.num_y_point+j].Row_data.insert(ctxmenu_show.col, cell_x);
           var cell_y = new Cell((grid_insert.y_min+j*step_y).toStringAsPrecision(5), (grid_insert.y_min+j*step_y), "black", i*grid_insert.num_y_point+j, ctxmenu_show.col+1, false, "white", table.username);
            table.Table_data[i*grid_insert.num_y_point+j].Row_data.insert(ctxmenu_show.col+1, cell_y);
          }
        }
      table.num_of_row = grid_insert.num_x_point*grid_insert.num_y_point; 
    }    
        table.Table_head_data.insert(ctxmenu_show.col, new Head("X", table.next_head_label(), ctxmenu_show.col));
        table.Table_head_data.insert(ctxmenu_show.col+1, new Head("Y", table.next_head_label(), ctxmenu_show.col+1));
        table.num_of_col += 2;  // end of element insert, increase the num_of_col
        for(num i=0; i<table.num_of_row; i++){
          for(num j=(ctxmenu_show.col+2); j<table.num_of_col; j++){
       //     print(i);
       //     print(j);
            table.Table_data[i].Row_data[j].col += 2;            
          }
        }
        for(num j=(ctxmenu_show.col+2); j<(table.num_of_col); j++){
          table.Table_head_data[j].col += 2;
        }
        for(num j=0; j<table.num_of_row; j++){       
          table.Table_data[j].Row_data[ctxmenu_show.col+2].select = "white";
        } 
                
    }  //end of if(grid_insert.grid_type=="Grid_2d"){
    if(grid_insert.grid_type=="Grid_3d"){
      double step_x = (grid_insert.x_max-grid_insert.x_min)/(grid_insert.num_x_point-1);         
      double step_y = (grid_insert.y_max-grid_insert.y_min)/(grid_insert.num_y_point-1);           
      double step_z = (grid_insert.z_max-grid_insert.z_min)/(grid_insert.num_z_point-1);   
   if(grid_insert.num_x_point*grid_insert.num_y_point*grid_insert.num_z_point<=table.num_of_row){   
      for(num i=0; i<grid_insert.num_x_point; i++){          
          for(num j=0; j<grid_insert.num_y_point; j++){             
             for(num k=0; k<grid_insert.num_z_point; k++){
               int index = i*grid_insert.num_y_point*grid_insert.num_z_point+j*grid_insert.num_z_point+k;
               var cell_x = new Cell((grid_insert.x_min+i*step_x).toStringAsPrecision(5), (grid_insert.x_min+i*step_x),  "black", index, ctxmenu_show.col, false, "white", table.username);
               table.Table_data[index].Row_data.insert(ctxmenu_show.col, cell_x);
               var cell_y = new Cell((grid_insert.y_min+j*step_y).toStringAsPrecision(5), (grid_insert.y_min+j*step_y),  "black", index, ctxmenu_show.col+1, false, "white", table.username);
               table.Table_data[index].Row_data.insert(ctxmenu_show.col+1, cell_y);
               var cell_z = new Cell((grid_insert.z_min+k*step_z).toStringAsPrecision(5), (grid_insert.z_min+j*step_z), "black", index, ctxmenu_show.col+2, false, "white", table.username);
               table.Table_data[index].Row_data.insert(ctxmenu_show.col+2, cell_z);
             }
          }
        }
      for(int i=grid_insert.num_x_point*grid_insert.num_y_point*grid_insert.num_z_point; i<table.num_of_row; i++){
        var cell_x = new Cell("", null,  "black", i, ctxmenu_show.col, false, "white", table.username);
        table.Table_data[i].Row_data.insert(ctxmenu_show.col, cell_x);
        var cell_y = new Cell("", null, "black", i, ctxmenu_show.col+1, false, "white", table.username);
        table.Table_data[i].Row_data.insert(ctxmenu_show.col+1, cell_y);
        var cell_z = new Cell("", null, "black", i, ctxmenu_show.col+2, false, "white", table.username);
        table.Table_data[i].Row_data.insert(ctxmenu_show.col+2, cell_z);
      }
   }
   if(grid_insert.num_x_point*grid_insert.num_y_point*grid_insert.num_z_point>table.num_of_row){  
     for(int i=table.num_of_row; i<grid_insert.num_x_point*grid_insert.num_y_point*grid_insert.num_z_point; i++){
       List <Cell> temp_row = toObservable([]);
       for(int j=0; j<table.num_of_col; j++){
         var cell = new Cell("", 0.0, "black", i, j, false, "white", table.username);
         temp_row.add(cell);
       }
       table.Table_data.add(new Row(i.toString(), i, temp_row));
     }       
     for(num i=0; i<grid_insert.num_x_point; i++){          
         for(num j=0; j<grid_insert.num_y_point; j++){             
            for(num k=0; k<grid_insert.num_z_point; k++){
              int index = i*grid_insert.num_y_point*grid_insert.num_z_point+j*grid_insert.num_z_point+k;
              var cell_x = new Cell((grid_insert.x_min+i*step_x).toStringAsPrecision(5), (grid_insert.x_min+i*step_x),  "black", index, ctxmenu_show.col, false, "white", table.username);
              table.Table_data[index].Row_data.insert(ctxmenu_show.col, cell_x);
              var cell_y = new Cell((grid_insert.y_min+j*step_y).toStringAsPrecision(5), (grid_insert.y_min+j*step_y),  "black", index, ctxmenu_show.col+1, false, "white", table.username);
              table.Table_data[index].Row_data.insert(ctxmenu_show.col+1, cell_y);
              var cell_z = new Cell((grid_insert.z_min+k*step_z).toStringAsPrecision(5), (grid_insert.z_min+j*step_z), "black", index, ctxmenu_show.col+2, false, "white", table.username);
              table.Table_data[index].Row_data.insert(ctxmenu_show.col+2, cell_z);
            }
         }
       }
     table.num_of_row = grid_insert.num_x_point*grid_insert.num_y_point*grid_insert.num_z_point; 
   }      
        table.Table_head_data.insert(ctxmenu_show.col, new Head("X", table.next_head_label(), ctxmenu_show.col));
        table.Table_head_data.insert(ctxmenu_show.col+1, new Head("Y", table.next_head_label(), ctxmenu_show.col+1));
        table.Table_head_data.insert(ctxmenu_show.col+2, new Head("Z", table.next_head_label(), ctxmenu_show.col+2));
        table.num_of_col += 3;  // end of element insert, increase the num_of_col
        for(num i=0; i<table.num_of_row; i++){
          for(num j=(ctxmenu_show.col+3); j<table.num_of_col; j++){
            table.Table_data[i].Row_data[j].col += 3;
          }
        }
        for(num j=(ctxmenu_show.col+3); j<(table.num_of_col); j++){
          table.Table_head_data[j].col += 3;
        }
        for(num j=0; j<table.num_of_row; j++){       
                table.Table_data[j].Row_data[ctxmenu_show.col+3].select = "white";
       } 
          
    }   //end of if(grid_insert.grid_type=="Grid_3d"){

    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0;    
    grid_insert.show_insert_grid_dialog = false;
    $['dialog'].toggle();
  }
  
  
  void grid_insert_cancel(){
    $['dialog'].toggle();
    grid_insert.show_insert_grid_dialog = false;
  }
  
  
  
  void ctx_move_left(){
    if(ctxmenu_show.col>0){
    for(num i=0; i<table.num_of_row; i++){
      Cell temp_cell1 = table.Table_data[i].Row_data[ctxmenu_show.col];
      Cell temp_cell2 = table.Table_data[i].Row_data[ctxmenu_show.col-1];
      temp_cell1.col -= 1;
      temp_cell2.col += 1;
      table.Table_data[i].Row_data[ctxmenu_show.col] = temp_cell2;
      table.Table_data[i].Row_data[ctxmenu_show.col-1] = temp_cell1;
      
    }    
    Head temp_head1 = table.Table_head_data[ctxmenu_show.col];
    Head temp_head2 = table.Table_head_data[ctxmenu_show.col-1];
    temp_head1.col -= 1;
    temp_head2.col += 1;
    table.Table_head_data[ctxmenu_show.col] = temp_head2;
    table.Table_head_data[ctxmenu_show.col-1] = temp_head1;
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col-1].select = "white";
    } 
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0;  
    }
  }
  
  void ctx_move_right(){
    if(ctxmenu_show.col<(table.num_of_col-1)){
    for(num i=0; i<table.num_of_row; i++){
      Cell temp_cell1 = table.Table_data[i].Row_data[ctxmenu_show.col];
      Cell temp_cell2 = table.Table_data[i].Row_data[ctxmenu_show.col+1];
      temp_cell1.col += 1;
      temp_cell2.col -= 1;
      table.Table_data[i].Row_data[ctxmenu_show.col] = temp_cell2;
      table.Table_data[i].Row_data[ctxmenu_show.col+1] = temp_cell1;
    }    
    Head temp_head1 = table.Table_head_data[ctxmenu_show.col];
    Head temp_head2 = table.Table_head_data[ctxmenu_show.col+1];
    temp_head1.col += 1;
    temp_head2.col -= 1;
    table.Table_head_data[ctxmenu_show.col] = temp_head2;
    table.Table_head_data[ctxmenu_show.col+1] = temp_head1;
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col+1].select = "white";
    } 
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0;  
    }
  }
  
  void ctx_move_first(){    
    if(ctxmenu_show.col>0){
      for(num i=0; i<table.num_of_row; i++){
        Cell temp_cell1 = table.Table_data[i].Row_data[ctxmenu_show.col];
        temp_cell1.col = 0;
        table.Table_data[i].Row_data.removeAt(ctxmenu_show.col);
        table.Table_data[i].Row_data.insert(0, temp_cell1);
        for(num j=1; j<(ctxmenu_show.col+1); j++){
          table.Table_data[i].Row_data[j].col += 1;
        }
      }    
      Head temp_head1 = table.Table_head_data[ctxmenu_show.col];
      temp_head1.col = 0;
      table.Table_head_data.removeAt(ctxmenu_show.col);
      table.Table_head_data.insert(0, temp_head1);
      for(num j=1; j<(ctxmenu_show.col+1); j++){
        table.Table_head_data[j].col +=1;
      }
      for(num j=0; j<table.num_of_row; j++){       
        table.Table_data[j].Row_data[0].select = "white";
      } 
      table_select.row_start = 0;
      table_select.row_end = 0;
      table_select.col_start = 0;
      table_select.col_end = 0;  
    }
  }
  
  void ctx_move_last(){    
    if(ctxmenu_show.col<(table.num_of_col-1)){
      for(num i=0; i<table.num_of_row; i++){
        Cell temp_cell1 = table.Table_data[i].Row_data[ctxmenu_show.col];
        temp_cell1.col = table.num_of_col-1;
        table.Table_data[i].Row_data.removeAt(ctxmenu_show.col);
        table.Table_data[i].Row_data.insert(table.num_of_col-1, temp_cell1);
        for(num j=ctxmenu_show.col; j<(table.num_of_col-1); j++){
          table.Table_data[i].Row_data[j].col -= 1;
        }
      }    
      Head temp_head1 = table.Table_head_data[ctxmenu_show.col];
      temp_head1.col = table.num_of_col-1;
      table.Table_head_data.removeAt(ctxmenu_show.col);
      table.Table_head_data.insert(table.num_of_col-1, temp_head1);
      for(num j=ctxmenu_show.col; j<table.num_of_col-1; j++){
        table.Table_head_data[j].col -=1;
      }
      for(num j=0; j<table.num_of_row; j++){       
        table.Table_data[j].Row_data[table.num_of_col-1].select = "white";
      } 
      table_select.row_start = 0;
      table_select.row_end = 0;
      table_select.col_start = 0;
      table_select.col_end = 0;  
    }
  }
  
  void ctx_fill_row_num(){
    for(num i=0; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = i.toString();
    }
  }
  
  void ctx_fill_rand_num(){
    for(num i=0; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = (new math.Random(i).nextDouble()).toStringAsPrecision(5);
    }
  }
  
  
  void ctx_set_as(Event event, var detail, Element target){
    table.Table_head_data[ctxmenu_show.col].Head_property = target.attributes['data-msg'];  
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0; 
    
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
    } 
  }
  
  void ctx_set_as_geo(){
    geography_set_as.show_set_as_geo_dialog=true;
    $['dialog'].toggle();
  }
  
  void geography_set_as_cancel(){
    geography_set_as.show_set_as_geo_dialog=false;
    $['dialog'].toggle();
  }
  
  void geography_set_as_apply(){
    geography_set_as.show_set_as_geo_dialog=false;
    $['dialog'].toggle();
    
  //  List <String> state_list = ["Anhui", "Beijing", "Chongqing", "Fujian", "Guangdong", "Gansu", "Guangxi", "Guizhou", "Hainan", "Hebei", "Henan", "Hong", "Heilongjiang", "Hunan", "Hubei", "Jilin", "Jiangsu", "Jiangxi", "Liaoning", "Macau", "Nei", "Ningxia", "Quinghai", "Shaanxi", "Sichuan", "Shandong", "Shanghai", "Shanxi", "Tianjin", "Taiwan", "Xinjiang", "Xizang", "Yunnan", "Zhejiang"];
    List <String> state_list_ = state_list[geography_set_as.country_selected_value]; 
    
  //  if(geography_set_as.country_selected_value=="China"){
    if(state_list_.length<=table.num_of_row){
      for(int i=0; i<state_list_.length; i++){
        table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = state_list_[i];
      }  
      
      for(int i=state_list_.length; i<table.num_of_row; i++){
        table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = "";
      }      
    }
         
      
 //   }
    
    if(state_list_.length>table.num_of_row){
      
               for(int i=table.num_of_row; i<state_list_.length; i++){
                 List <Cell> temp_row = toObservable([]);
                 for(int j=0; j<table.num_of_col; j++){
                   var cell = new Cell("", 0.0, "black", i, j, false, "white", table.username);
                   temp_row.add(cell);
                 }
                 table.Table_data.add(new Row(i.toString(), i, temp_row));
               }            
               for(int i=0; i<state_list_.length; i++){
                 table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = state_list_[i];
               }          
               table.num_of_row = state_list_.length; 
               
       }
    
    
   // }    
    
    table.Table_head_data[ctxmenu_show.col].Head_property = "G";  
    table.Table_head_data[ctxmenu_show.col].Head_label = geography_set_as.country_selected_value;  
        table_select.row_start = 0;
        table_select.row_end = 0;
        table_select.col_start = 0;
        table_select.col_end = 0; 
        
        for(num j=0; j<table.num_of_row; j++){       
          table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
        } 
  }

  
  void ctx_asc_this_col(){
    num col = ctxmenu_show.col;    
    List <num> temp_list = [];
    for(int i=0; i<table.num_of_row; i++){
      temp_list.add(double.parse(table.Table_data[i].Row_data[col].Cell_data));
    }
    temp_list.sort((x, y) => x.compareTo(y));
    for(int i=0; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[col].Cell_data = temp_list[i].toString();
    }
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0; 
    
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
    } 
  }
  
  void ctx_desc_this_col(){
    num col = ctxmenu_show.col;    
    List <num> temp_list = [];
    for(int i=0; i<table.num_of_row; i++){
      temp_list.add(double.parse(table.Table_data[i].Row_data[col].Cell_data));
    }
    temp_list.sort((x, y) => y.compareTo(x));
    for(int i=0; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[col].Cell_data = temp_list[i].toString();
    }
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0; 
    
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
    } 
  }
  
  void ctx_asc_conj_col(){
    num col = ctxmenu_show.col;    
    table.Table_data.sort((x, y) => double.parse(x.Row_data[col].Cell_data).compareTo(double.parse(y.Row_data[col].Cell_data)));
    for(int i=0; i<table.num_of_row; i++){
      table.Table_data[i].row = i; 
      table.Table_data[i].label = i.toString(); 
    }    
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0; 
    
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
    } 
  }
  
  void ctx_desc_conj_col(){
    num col = ctxmenu_show.col;    
    table.Table_data.sort((x, y) => double.parse(y.Row_data[col].Cell_data).compareTo(double.parse(x.Row_data[col].Cell_data)));
    for(int i=0; i<table.num_of_row; i++){
      table.Table_data[i].row = i; 
      table.Table_data[i].label = i.toString(); 
    }     
    table_select.row_start = 0;
    table_select.row_end = 0;
    table_select.col_start = 0;
    table_select.col_end = 0; 
    
    for(num j=0; j<table.num_of_row; j++){       
      table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
    } 
  }
  
  void ctx_inte_num(){
    num Y_col = ctxmenu_show.col; 
    num X_col = 0;
    for(int i=Y_col; i>=0; i--){
      if(table.Table_head_data[i].Head_property == "X"){
        X_col=i;
        break;
      }
    }       
    
    ctxmenu_show.col = X_col;
    this.ctx_asc_conj_col(); 
    
    List temp_list = [];
    for(int i=0; i<table.num_of_row; i++){
          temp_list.add([double.parse(table.Table_data[i].Row_data[X_col].Cell_data), double.parse(table.Table_data[i].Row_data[Y_col].Cell_data)]);
    }
  //  temp_list.sort((x, y) => x[0].compareTo(y[0]));
    List <double> inte_list = [];
    double total = 0.0; 
    inte_list.add(total);  
    for(int i=1; i<table.num_of_row; i++){
      total += (temp_list[i][1]+temp_list[i-1][1])*(temp_list[i][0]-temp_list[i-1][0])/2.0;
      inte_list.add(total);
    }
    
   // print(inte_list); 
    
    ctxmenu_show.col = Y_col + 1;
    this.ctx_insert_col(); 
    table.Table_head_data[ctxmenu_show.col].Head_label = "Inte";
    
    for(int i=0; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = inte_list[i].toString(); 
    }
    
    
    /*
    table.Table_head_data.add(new Head("X", "Int", table.num_of_col));
    table.Table_head_data.add(new Head("Y", "Int", table.num_of_col+1));
    table.num_of_col +=2;
    for(int i=1; i<table.num_of_row; i++){
      table.Table_data[i].Row_data.add(new Cell(temp_list[i][0].toString(), temp_list[i][0] , "black", i, table.num_of_col, false, "white", table.username));
      table.Table_data[i].Row_data.add(new Cell(inte_list[i].toString(), inte_list[i], "black", i, table.num_of_col+1, false, "white", table.username));
    }  */
  }
  
  void ctx_diff_num(){
    num Y_col = ctxmenu_show.col; 
    num X_col = 0;
    for(int i=Y_col; i>=0; i--){
      if(table.Table_head_data[i].Head_property == "X"){
        X_col=i;
        break;
      }
    }        
    
    ctxmenu_show.col = X_col;
    this.ctx_asc_conj_col();     
    
    List temp_list = [];
    for(int i=0; i<table.num_of_row; i++){
          temp_list.add([double.parse(table.Table_data[i].Row_data[X_col].Cell_data), double.parse(table.Table_data[i].Row_data[Y_col].Cell_data)]);
    }
  //  temp_list.sort((x, y) => x[0].compareTo(y[0]));
    List <double> inte_list = [];
    inte_list.add(null);  
    for(int i=1; i<table.num_of_row; i++){
      double result = (temp_list[i][1]-temp_list[i-1][1])/(temp_list[i][0]-temp_list[i-1][0]+1.0e-12);
      inte_list.add(result);
    }
    
    ctxmenu_show.col = Y_col + 1;
    this.ctx_insert_col(); 
    table.Table_head_data[ctxmenu_show.col].Head_label = "Diff";
    
    table.Table_data[0].Row_data[ctxmenu_show.col].Cell_data = "";
    
    for(int i=1; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = inte_list[i].toStringAsPrecision(5); 
    }
    
    
    /*
    table.Table_head_data.add(new Head("X", "Int", table.num_of_col));
    table.Table_head_data.add(new Head("Y", "Diff", table.num_of_col+1));
    table.num_of_col +=2;
    for(int i=1; i<table.num_of_row; i++){
      table.Table_data[i].Row_data.add(new Cell(temp_list[i][0].toString(), temp_list[i][0],  "black", i, table.num_of_col, false, "white", table.username));
      table.Table_data[i].Row_data.add(new Cell(inte_list[i].toString(), inte_list[i], "black", i, table.num_of_col+1, false, "white", table.username));
    }  */
  }
  
  void ctx_interpol_num(){
    $['dialog'].toggle();
    show_lag_inter_diaglog = true;
  }
  
  void lag_inter_apply(){
    show_lag_inter_diaglog = false;
    $['dialog'].toggle();
    
    num Y_col = ctxmenu_show.col; 
    num X_col = 0;
    for(int i=Y_col; i>=0; i--){
          if(table.Table_head_data[i].Head_property == "X"){
            X_col=i;
            break;
          }
    }  

    num X_col_template = 0;
    
    for(int i=0; i<table.num_of_col; i++){
          if(table.Table_head_data[i].Head_label == template_col_inter){
            X_col_template = i;
            break;
       }
    }  
    
    ctxmenu_show.col = X_col_template + 1;
    this.ctx_insert_col(); 
    table.Table_head_data[ctxmenu_show.col].Head_label = "Interp";   
         
    List <double> x = [];
    List <double> fx = [];
    List <double> input = [];    
    for(int i=0; i<table.num_of_row; i++){
      x.add(double.parse(table.Table_data[i].Row_data[X_col].Cell_data));
      fx.add(double.parse(table.Table_data[i].Row_data[Y_col].Cell_data));
      input.add(double.parse(table.Table_data[i].Row_data[X_col_template].Cell_data));
    }    
    List <double> res = Lag_inter(x, fx, input);
    for(int i=0; i<table.num_of_row; i++){
      table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data = res[i].toStringAsPrecision(5); 
    }
    
  }
  
   void lag_inter_cancel(){
     show_lag_inter_diaglog = false;
     $['dialog'].toggle();
   }
 
   void ctx_fft_dialog(){     
     FFT_DIALOG_SHOW = true;    
     $['dialog'].toggle();
     input_col = table.Table_head_data[table_select.col_start].Head_label;   
     output_col = table.Table_head_data[table_select.col_start+1].Head_label;   
   }

   void ctx_fft_apply(){       
     int input_idx, output_idx;      
     for(int i=0; i<table.num_of_col; i++){
           if(table.Table_head_data[i].Head_label == input_col){
             input_idx = i;
           }
           if(table.Table_head_data[i].Head_label == output_col){
             output_idx = i;
           }
     }      
     int length = table.num_of_row~/2 ;     
     var p = new JsObject(context['FFT']["complex"], [length, false]);     
     List <double> inp = [];
     List <double> out = [];         
     for(int i=0; i<2*length; i++){
       inp.add(double.parse(table.Table_data[i].Row_data[input_idx].Cell_data));       
     }          
     var iii = new JsObject.jsify(inp);
     var ooo = new JsObject.jsify(out);     
     p.callMethod("process", [ooo, 0, 1, iii, 0,  1]);          
     for(int i=0; i<2*length; i++){
       table.Table_data[i].Row_data[output_idx].Cell_data = ooo[i].toString();   
    }      
     FFT_DIALOG_SHOW = false;   
     $['dialog'].toggle();
   }

   void ctx_fft_cancel(){
     FFT_DIALOG_SHOW = false;
     $['dialog'].toggle();
   }
   
  
  void ctx_plot_2d(Event event, var detail, Element target){
    
    String plot_type = target.attributes['data-msg'];  

    this.plot_2d_apply(plot_type); 
    
  }
  
  void plot_2d_apply(String _plot_type_){    
    List <Grouped_Data> grouped_data = [];    
    for(var _table_select in table_select_history){     
      for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){  
        if(table.Table_head_data[j].Head_property!="X"){
          num Y_col = j; 
          num X_col = 0;
          for(int i=Y_col; i>=0; i--){
              if(table.Table_head_data[i].Head_property == "X"){
                X_col=i;
                break;
              }
          }      
          List <x_y_num> temp_list = [];        
          for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
            temp_list.add(new x_y_num(double.parse(table.Table_data[i].Row_data[X_col].Cell_data), double.parse(table.Table_data[i].Row_data[Y_col].Cell_data)));       
          }
          grouped_data.add(new Grouped_Data(temp_list, " ", " ", _plot_type_));
        }   // end of if(table.Table_head_data[j].Head_property != "X"){
      }      // end of for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){  
    }   // end of for(var _table_select in table_select_history){      
    
    LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
    layout.new_plot_file_("overlay", grouped_data);    
  }
  
  
  
  /*void ctx_plot_linesym(Event event, var detail, Element target){
    
  } */
  
  void ctx_plot_geo(){
      //  table_show_mode = false;
      //  String plot_type = "geography";  
        
        num Y_col = ctxmenu_show.col; 
        num X_col = 0;
        for(int i=Y_col; i>=0; i--){
              if(table.Table_head_data[i].Head_property == "G"){
                X_col=i;
                break;
              }
        }      
        
        List <Map> geo =[];        
        Map plot_data = {}; 
        
        for(num i=0; i<table.num_of_row; i++){
          if(table.Table_data[i].Row_data[X_col].Cell_data!=""){
          geo.add({"state":table.Table_data[i].Row_data[X_col].Cell_data, "color":double.parse(table.Table_data[i].Row_data[Y_col].Cell_data)});
          }
        }
        
        plot_data["parent"] = table.Table_head_data[X_col].Head_label;
        plot_data["data"] = geo;         
        
        LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
        layout.new_plot_file_("geography", plot_data);       
        
         
        //plot_data = geo;
        //show_2d_plot_mode=true;
        
        //Timer.run((){
        //Plot2dElement p2d = shadowRoot.querySelector("plot2d-element");
        //p2d.Re_init();
        //});
        
      //  table_show_mode=false;
  }
  
  void ctx_plot_heat_map(){
      //  table_show_mode = false;
        String plot_type = "2d_heat_map";  
        
        num Z_index = ctxmenu_show.col;
        num X_index = 0;
        num Y_index = 0;
        
        for(num i=ctxmenu_show.col-1; i>0; i--){
          if(table.Table_head_data[i].Head_property=="Y"){  //check for the data with "X" property
            Y_index = i;
          }
          if(table.Table_head_data[i].Head_property=="X"){  //check for the data with "X" property
            X_index = i;
            break;
          }
        }   
          
        List <Map> test_heat_map = [];
        
        for(num i=0; i<table.num_of_row; i++){
          test_heat_map.add({"x":double.parse(table.Table_data[i].Row_data[X_index].Cell_data), "y":double.parse(table.Table_data[i].Row_data[Y_index].Cell_data), "color":double.parse(table.Table_data[i].Row_data[Z_index].Cell_data)});
             //     temp_list.add(new x_y_num(), double.parse(table.Table_data[i].Row_data[Y_col].Cell_data)));
        }
        
        LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
        layout.new_plot_file_(plot_type, test_heat_map);
    
  }
  
  
  
  void ctx_plot_heat_map_interpo(){
      String plot_type = "2d_heat_map_interpo";  
    
      num Z_index = ctxmenu_show.col;
      num X_index = 0;
      num Y_index = 0;
      
      for(num i=ctxmenu_show.col-1; i>0; i--){
        if(table.Table_head_data[i].Head_property=="Y"){  //check for the data with "X" property
          Y_index = i;
        }
        if(table.Table_head_data[i].Head_property=="X"){  //check for the data with "X" property
          X_index = i;
          break;
        }
      }   
        
      List <Map> test_heat_map = [];
      
      for(num i=0; i<table.num_of_row; i++){
        test_heat_map.add({"x":double.parse(table.Table_data[i].Row_data[X_index].Cell_data), "y":double.parse(table.Table_data[i].Row_data[Y_index].Cell_data), "color":double.parse(table.Table_data[i].Row_data[Z_index].Cell_data)});
           //     temp_list.add(new x_y_num(), double.parse(table.Table_data[i].Row_data[Y_col].Cell_data)));
      }
    
    LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
    layout.new_plot_file_(plot_type, test_heat_map);
  }
  
  
  
  
  void ctx_set_col_value(Event event, var detail, Element target){
    set_col_value.col_value = ctxmenu_show.col;
    set_col_value.show = true;
    
    $['dialog'].toggle();
  }
  
  set_col_value_use_func() => set_col_value.use_type = "use_function";  
  set_col_value_use_db() => set_col_value.use_type = "use_database";
  
  void set_col_value_apply(Event event, var detail, Element target){             // need to be improved for multiple variables, and multiple/single output.   // need to insert functions 
    
    var obj = new JsObject(context["mathjs"]);    
    int start = 0; 
    int end = 0;
    Map _scope = new Map();   
    List <int> x_col_ = [];
    List <String> name_ = [];    
    
    String set_col = set_col_value.expression; 
    
    while(set_col.indexOf(new RegExp(r'Col\('), end)>-1){
      start = set_col.indexOf(new RegExp(r'Col\('), end);
      end = set_col.indexOf(new RegExp(r'\)'), start);
      String tmp = set_col.substring(start+4, end);
      if(!name_.contains(tmp)){
        name_.add(tmp);      
      }      
    }    
    
    for(var n in name_){
      String out = '_'+n+'_';
      set_col = set_col.replaceAll(new RegExp(r'Col\('+n+r'\)'), out); 
    } 
    
    var s;
    
    try{
      s = obj.callMethod('compile', [set_col]);
    }catch(e){      }
    
    for(var n in name_){
      for(int j=0; j<table.num_of_col; j++){
         if(table.Table_head_data[j].Head_label==n){
           x_col_.add(j); 
         }
      }      
    }
    
    List <dynamic> output = [];
    
    for(num i=0; i<table.num_of_row; i++){      
      for(int j=0; j<name_.length; j++){
        _scope['_'+name_[j]+'_']= double.parse(table.Table_data[i].Row_data[x_col_[j]].Cell_data);        
      }
      var scope = new JsObject.jsify(_scope);  
      
      try{
        output.add(s.callMethod('eval', [scope]));
      }catch(e){      }
      
    }  // end of    for(num i=0; i<table.num_of_row; i++){
    
    if(!(output[0] is List)){
      for(num i=0; i<table.num_of_row; i++){     
        table.Table_data[i].Row_data[set_col_value.col_value].Cell_data = output[i]!=null ? output[i].toStringAsPrecision(5) : ""; 
      }
    }
    
    if(output[0] is List){
      int insert_len = output[0].length-1; 
      ctxmenu_show.col = set_col_value.col_value + 1;
      for(int j=0; j<insert_len; j++){
        this.ctx_insert_col(); 
      }
      for(num i=0; i<table.num_of_row; i++){   
        for(int j=0; j<insert_len+1; j++){
          table.Table_data[i].Row_data[set_col_value.col_value+j].Cell_data = output[i][j]!=null ? output[i][j].toStringAsPrecision(5) : ""; 
        }
      }      
    }
    
    set_col_value.show = false;  
    $['dialog'].toggle();
  }  
  
  /*
  int insert_len = '\n'.allMatches(set_col).length;    
  * 
  *       if(insert_len>0){
      for(num j=0; j<insert_len+1; j++){
     //   print(s.callMethod('eval', [scope])); 
        table.Table_data[i].Row_data[set_col_value.col_value+j].Cell_data = s.callMethod('eval', [scope])[j].toStringAsPrecision(5);      // if the output is a list or not? 
       }
    }
    else{
      table.Table_data[i].Row_data[set_col_value.col_value].Cell_data = .toStringAsPrecision(5);      // if the output is a list or not? 
    }
  */
  
    /*
    
  if(insert_len>0){
    for(num i=0; i<table.num_of_row; i++){
        for(num j=0; j<insert_len; j++){
          var cell = new Cell("", null, "black", i, set_col_value.col_value+1+j, false, "white", table.username);
          table.Table_data[i].Row_data.insert(set_col_value.col_value+j+1, cell);
        }
     }
    for(num j=0; j<insert_len; j++){
      table.Table_head_data.insert(set_col_value.col_value+j+1, new Head("Y", table.next_head_label(), set_col_value.col_value+j+1));
       // end of element insert, increase the num_of_col
    }
    
    table.num_of_col += insert_len; 

      for(num i=0; i<table.num_of_row; i++){
        for(num j=(set_col_value.col_value+insert_len+1); j<table.num_of_col; j++){
          table.Table_data[i].Row_data[j].col += insert_len;
        }
      }
      for(num j=(set_col_value.col_value+insert_len+1); j<(table.num_of_col); j++){
        table.Table_head_data[j].col += insert_len;
      }   
  }  // end of  if(insert_len>0){
    
    for(num i=0; i<table.num_of_row; i++){      
      for(int j=0; j<name_.length; j++){
        _scope['_'+name_[j]+'_']= double.parse(table.Table_data[i].Row_data[x_col_[j]].Cell_data);        
      }
      var scope = new JsObject.jsify(_scope);
      
      if(insert_len>0){
        for(num j=0; j<insert_len+1; j++){
       //   print(s.callMethod('eval', [scope])); 
          table.Table_data[i].Row_data[set_col_value.col_value+j].Cell_data = s.callMethod('eval', [scope])[j].toStringAsPrecision(5);      // if the output is a list or not? 
         }
      }
      else{
        table.Table_data[i].Row_data[set_col_value.col_value].Cell_data = s.callMethod('eval', [scope]).toStringAsPrecision(5);      // if the output is a list or not? 
      }
    }  // end of    for(num i=0; i<table.num_of_row; i++){   */
    

  
  set_col_value_cancel() {
    set_col_value.show = false;
    $['dialog'].toggle();
  }
  
  set_col_value_add_filter() => set_col_value.filter_list.add("s==9");
  
  
  void ctx_batch_plot_dialog(){
    batch_plot_dialog.filter_list.clear();
    batch_plot_dialog.group_list.clear();    
    batch_plot_dialog.plot_type = "linesymbol_2d";
    //batch_plot_dialog.present_mode = "spreading"; //"overlay";
    batch_plot_dialog.x_label = "A";
    batch_plot_dialog.y_label = "B";
    //batch_plot_dialog.filter_label = "C";
    //batch_plot_dialog.filter_operator = "==";
    //batch_plot_dialog.filter_value = "0";
    //batch_plot_dialog.group_label = "C";
    batch_plot_dialog.show = true;
    $['dialog'].toggle();
    batch_plot_dialog.filter_list.add(new Filter_Obj("C", "==", "0"));
    batch_plot_dialog.group_list.add(new Group_Obj("D", 0.0, "spreading"));
    batch_plot_dialog.group_list.add(new Group_Obj("C", 0.0, "overlay"));
    batch_plot_dialog.group_list.add(new Group_Obj("E", 0.0, "multifile"));
  }
  
  
  void batch_plot_add_filter(){
    batch_plot_dialog.filter_list.add(new Filter_Obj("C", "==", "0"));
  }
  
  void batch_plot_add_group(){
    batch_plot_dialog.group_list.add(new Group_Obj("D", 0.0, "spreading"));
  }
  
  void batch_plot_remove_group(Event event, var detail, Element target){ 
    var p = int.parse(target.attributes['data-msg']);
    batch_plot_dialog.group_list.removeAt(p);
  }
  
  
  batch_plot_dialog_cancel() {
    batch_plot_dialog.show = false;
    $['dialog'].toggle(); 
  }
  
  void batch_plot_dialog_apply(){
    batch_plot_dialog.show = false;
    $['dialog'].toggle();
  
  //  if(batch_plot_dialog.group_list.length>1){
      bool overlay_mode = false;
      bool spreading_mode = false;
      bool multifile_mode = false;
      String overlay_label;
      String spreading_label;
      String multifile_label;
      for(var grp in batch_plot_dialog.group_list){
        if(grp.present_mode=="overlay") {    
          overlay_mode = true;         
          overlay_label = grp.group_label;
        }
        if(grp.present_mode=="spreading")  {   
          spreading_mode = true;      
          spreading_label = grp.group_label;
        }    
        if(grp.present_mode=="multifile"){
          multifile_mode = true;
          multifile_label = grp.group_label;
        }
      }
      
      if(overlay_mode==true && spreading_mode==false && multifile_mode==false) {
               int x_col=0, y_col=0;
               int group_col_overlay;
                 for(int i=0; i<table.num_of_col; i++){
                     if(table.Table_head_data[i].Head_label == batch_plot_dialog.x_label){
                       x_col = i;
                     }
                     if(table.Table_head_data[i].Head_label == batch_plot_dialog.y_label){
                       y_col = i;
                     }
                     if(table.Table_head_data[i].Head_label == overlay_label){
                       group_col_overlay = i;
                     }
                 }          
                 
                   List <Grouped_Data> grouped_data = [];
                   List <String> group_list = [];
                   for(int i=0; i<table.num_of_row; i++){
                     if(!group_list.contains(table.Table_data[i].Row_data[group_col_overlay].Cell_data)){
                       group_list.add(table.Table_data[i].Row_data[group_col_overlay].Cell_data);
                     }
                   }          
                   List <x_y_num> temp_list = [];          
                   for(int j=0; j<group_list.length; j++){
                     temp_list = [];
                     for(int i=0; i<table.num_of_row; i++){
                       if(table.Table_data[i].Row_data[group_col_overlay].Cell_data==group_list[j]){
                         temp_list.add(new x_y_num(double.parse(table.Table_data[i].Row_data[x_col].Cell_data), double.parse(table.Table_data[i].Row_data[y_col].Cell_data)));
                       }
                     }
                     grouped_data.add(new Grouped_Data(temp_list, batch_plot_dialog.group_list[0].group_label, group_list[j], batch_plot_dialog.plot_type));
                   }                           
                     
                     LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
                     layout.new_plot_file_("overlay", grouped_data);
                     
      }  // enf of if(overlay_mode==true && spreading_mode==false && multifile_mode==false) {
      
      if(overlay_mode==true && spreading_mode==true && multifile_mode==false) {
        int x_col=0, y_col=0;
        //int filter_col;
        int group_col_overlay;
        int group_col_spreading;
        //List <int> filter_col = [];
        //List <int> group_col = [];    
          for(int i=0; i<table.num_of_col; i++){
              if(table.Table_head_data[i].Head_label == batch_plot_dialog.x_label){
                x_col = i;
              }
              if(table.Table_head_data[i].Head_label == batch_plot_dialog.y_label){
                y_col = i;
              }
              if(table.Table_head_data[i].Head_label == overlay_label){
                group_col_overlay = i;
              }
              if(table.Table_head_data[i].Head_label == spreading_label){
                group_col_spreading = i;
              }
          }          
              List <Grouped_Data_List> grouped_data_list = [];
              List <String> group_spreading_list = [];
              List <List <String>> group_overlay_list = [];
              
              for(int i=0; i<table.num_of_row; i++){
                if(!group_spreading_list.contains(table.Table_data[i].Row_data[group_col_spreading].Cell_data)){
                  group_spreading_list.add(table.Table_data[i].Row_data[group_col_spreading].Cell_data);
                }
              }     
             // print(group_spreading_list);
              
              for(int i=0; i<group_spreading_list.length; i++){
                group_overlay_list.add([]);
              }
              
              for(int i=0; i<table.num_of_row; i++){
                int index_spreading_list = group_spreading_list.indexOf(table.Table_data[i].Row_data[group_col_spreading].Cell_data);
                if(!group_overlay_list[index_spreading_list].contains(table.Table_data[i].Row_data[group_col_overlay].Cell_data)){
                  group_overlay_list[index_spreading_list].add(table.Table_data[i].Row_data[group_col_overlay].Cell_data);
                }
              }
             // print(group_overlay_list);                 
              
              for(int i=0; i<group_spreading_list.length; i++){
                List <Grouped_Data> _data_list = [];
                List <x_y_num> temp_list = [];       
                for(int j=0; j<group_overlay_list[i].length; j++){                 
                  temp_list = [];
                  for(int k=0; k<table.num_of_row; k++){
                    if(table.Table_data[k].Row_data[group_col_overlay].Cell_data==group_overlay_list[i][j]
                        && table.Table_data[k].Row_data[group_col_spreading].Cell_data==group_spreading_list[i]){
                      temp_list.add(new x_y_num(double.parse(table.Table_data[k].Row_data[x_col].Cell_data), double.parse(table.Table_data[k].Row_data[y_col].Cell_data)));
                    }
                  }
                  _data_list.add(new Grouped_Data(temp_list, overlay_label, group_overlay_list[i][j], batch_plot_dialog.plot_type));
               }                
                grouped_data_list.add(new Grouped_Data_List(_data_list, spreading_label, group_spreading_list[i], "overlay"));
              }  // end of for(int i=0; i<group_spreading_list.length; i++){
                          
        //      plot_data = grouped_data_list;
        //      plot_type = "spreading";
        //      show_2d_plot_mode=true;
              table_show_mode=false;  
              
              LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
              layout.new_plot_file_("spreading", grouped_data_list);
              
              //Timer.run((){
                //Plot2dElement p2d = shadowRoot.querySelector("plot2d-element");
                
                //p2d.Re_init();
              //});         
            
      }   // end of if(overlay_mode==true && spreading_mode==true) {
      
      if(overlay_mode==true && spreading_mode==true && multifile_mode==true) {
        int x_col=0, y_col=0;
         //int filter_col;
         int group_col_overlay;
         int group_col_spreading;
         int group_col_multifile; 
         //List <int> filter_col = [];
         //List <int> group_col = [];    
           for(int i=0; i<table.num_of_col; i++){
               if(table.Table_head_data[i].Head_label == batch_plot_dialog.x_label){
                 x_col = i;
               }
               if(table.Table_head_data[i].Head_label == batch_plot_dialog.y_label){
                 y_col = i;
               }
               if(table.Table_head_data[i].Head_label == overlay_label){
                 group_col_overlay = i;
               }
               if(table.Table_head_data[i].Head_label == spreading_label){
                 group_col_spreading = i;
               }
               if(table.Table_head_data[i].Head_label == multifile_label){
                 group_col_multifile = i;
               }
           }          
           
           
           List <String> group_multifile_list = [];
           
           for(int i=0; i<table.num_of_row; i++){
             if(!group_multifile_list.contains(table.Table_data[i].Row_data[group_col_multifile].Cell_data)){
               group_multifile_list.add(table.Table_data[i].Row_data[group_col_multifile].Cell_data);
             }
           }
           
       //    print(group_multifile_list);
           
           for(String multifile_ in group_multifile_list){  
            
          //     print(multifile_);
               
               List <Grouped_Data_List> grouped_data_list = [];
               List <String> group_spreading_list = [];
               List <List <String>> group_overlay_list = [];
               
               
               for(int i=0; i<table.num_of_row; i++){
                 if(table.Table_data[i].Row_data[group_col_multifile].Cell_data==multifile_){
                   if((!group_spreading_list.contains(table.Table_data[i].Row_data[group_col_spreading].Cell_data))){
                     group_spreading_list.add(table.Table_data[i].Row_data[group_col_spreading].Cell_data);
                   }
                 }
               }     
              // print(group_spreading_list);
               
               for(int i=0; i<group_spreading_list.length; i++){
                 group_overlay_list.add([]);
               }
               
               for(int i=0; i<table.num_of_row; i++){
                 if(table.Table_data[i].Row_data[group_col_multifile].Cell_data==multifile_){
                     int index_spreading_list = group_spreading_list.indexOf(table.Table_data[i].Row_data[group_col_spreading].Cell_data);
                     if((!group_overlay_list[index_spreading_list].contains(table.Table_data[i].Row_data[group_col_overlay].Cell_data))){
                        group_overlay_list[index_spreading_list].add(table.Table_data[i].Row_data[group_col_overlay].Cell_data);
                     }
                   }
                }
              // print(group_overlay_list);                 
               
               for(int i=0; i<group_spreading_list.length; i++){
                 List <Grouped_Data> _data_list = [];
                 List <x_y_num> temp_list = [];       
                 for(int j=0; j<group_overlay_list[i].length; j++){                 
                   temp_list = [];
                   for(int k=0; k<table.num_of_row; k++){
                     if(table.Table_data[k].Row_data[group_col_multifile].Cell_data==multifile_){     
                       
                         if(table.Table_data[k].Row_data[group_col_overlay].Cell_data==group_overlay_list[i][j]
                             && table.Table_data[k].Row_data[group_col_spreading].Cell_data==group_spreading_list[i]){
                            temp_list.add(new x_y_num(double.parse(table.Table_data[k].Row_data[x_col].Cell_data), double.parse(table.Table_data[k].Row_data[y_col].Cell_data)));
                         }
                      }
                     
                   }
                   _data_list.add(new Grouped_Data(temp_list, overlay_label, group_overlay_list[i][j], batch_plot_dialog.plot_type));
                }                
                 grouped_data_list.add(new Grouped_Data_List(_data_list, spreading_label, group_spreading_list[i], "overlay"));
               }  // end of for(int i=0; i<group_spreading_list.length; i++){
                           
          //     plot_data = grouped_data_list;
          //     plot_type = "spreading";
           //    show_2d_plot_mode=true;
               table_show_mode=false;  
               
               if(group_multifile_list.indexOf(multifile_)==0){               
                   LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
                   layout.new_plot_file_("spreading", grouped_data_list);                 
               }
               
               if(group_multifile_list.indexOf(multifile_)>0){               
                   LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");               
                   layout.push_plot_list("spreading", grouped_data_list);                 
               }
               
               
        
           }  // end of    for(String multifile_ in group_multifile_list){        
      }       // end of   if(overlay_mode==true && spreading_mode==true && multifile_mode==true) {
 //   }  // end of if(batch_plot_dialog.group_list.length>1){
 
  }

  
  
  void menu_import_txt_dialog(){
    import_txt_dialog_show = true;
    
    Timer.run((){
      ImportData p2d = shadowRoot.querySelector("import-data");
      p2d.Re_init();
    });
  }
  
  void menu_import_txt_apply(){
    import_txt_dialog_show = false;
    ImportData p2d = shadowRoot.querySelector("import-data");
    p2d.import_data_to_table(table.username);
  }
  
  void menu_import_txt_cancel(){
    import_txt_dialog_show = false;
  }
  
  
  void ctx_stat_max(){
    String id;
    int max_row = 0; //
    int max_col = 0; 
    double max = null; //double.parse(table.Table_data[0].Row_data[0].Cell_data); 
    
    if(table_select_history.length>0){
    for(var _table_select in table_select_history){     
      for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
        for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
          double temp = double.parse(table.Table_data[i].Row_data[j].Cell_data); 
          if(max==null){
            max = temp;
          }
          if(temp>max && max!=null ){
            max = temp;
            max_row = i;
            max_col = j; 
          }
        }
      }
    }  
    
    
    for(var _table_select in table_select_history){     
      for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
        for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
          table.Table_data[i].Row_data[j].select = "white";
        }
      }
    }       
    table_select_history.clear();   
    
    
    id="R"+max_row.toString()+"C"+max_col.toString();
    shadowRoot.querySelector("#"+id).scrollIntoView();      
    table.Table_data[max_row].Row_data[max_col].select = "#0066FF";    
    }
  }
  
  
  void ctx_stat_min(){
    String id;
    int max_row = 0; //
    int max_col = 0; 
    double max = null; //double.parse(table.Table_data[0].Row_data[0].Cell_data); 
    
    if(table_select_history.length>0){
    for(var _table_select in table_select_history){     
      for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
        for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
          double temp = double.parse(table.Table_data[i].Row_data[j].Cell_data); 
          if(max==null){
            max = temp;
          }
          if(temp<max && max!=null ){
            max = temp;
            max_row = i;
            max_col = j; 
          }
        }
      }
    }  
    
    
    for(var _table_select in table_select_history){     
      for(num i=_table_select.row_start; i<(_table_select.row_end+1); i++){
        for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
          table.Table_data[i].Row_data[j].select = "white";
        }
      }
    }       
    table_select_history.clear();       
    
    
    id="R"+max_row.toString()+"C"+max_col.toString();
    shadowRoot.querySelector("#"+id).scrollIntoView();      
    table.Table_data[max_row].Row_data[max_col].select = "#0066FF";    
    }
//  return;
  } 
 
  
  void menu_import_csv_dialog(){
    window.alert("To be implemented soon!");
  }
  
  /*
  void test_copy(MouseEvent event){
    event.dataTransfer.setData('text/html', "xxxxxxxxx555555555555555xxx"); 
  }
  
  void test_paste(MouseEvent event){
    print(event.dataTransfer.getData('text/html')); 
  }
  */
  
  void set_contextmenu_type(){
    
  //  print(table_select_history.length); 
    
    if(table_select_history.length==1){
        ctxmenu_show.menu_type = table_select_history[0].select_type;
        if(table_select_history[0].select_type=="region" && table_select_history[0].row_end>table_select_history[0].row_start){
          ctxmenu_show.menu_type = "ok-region"; 
        }
    /*    if(table_select_history[0].select_type=="column"){
          CTX_MENU_PLOT = true;
        }  */
        if(table_select_history[0].select_type=="region" && table_select_history[0].row_end==table_select_history[0].row_start && table_select_history[0].col_end==table_select_history[0].col_start){
          ctxmenu_show.menu_type = "cell";
        }
      }       
      
      if(table_select_history.length>1){
        List <String> type_dict = []; 
        for(var _table_select in table_select_history){     
          if(_table_select.select_type=="region" && _table_select.row_end==_table_select.row_start && _table_select.col_end==_table_select.col_start){
            _table_select.select_type = "cell";
          }
          if(_table_select.select_type=="region" && _table_select.row_end>_table_select.row_start){
            _table_select.select_type = "ok-region";
          }
          
          if(!type_dict.contains(_table_select.select_type)){
            type_dict.add(_table_select.select_type);
          }      
        }
        
      //  CTX_MENU_PLOT = false; 
        
        if(type_dict.length==1){
          if(type_dict[0]=="column"){
            ctxmenu_show.menu_type = "multi-column";  
        //    CTX_MENU_PLOT = true;
          }
          if(type_dict[0]=="row"){
            ctxmenu_show.menu_type = "multi-row";  
        //    CTX_MENU_PLOT = true;
          }
          if(type_dict[0]=="ok-region"){
            ctxmenu_show.menu_type = "multi-ok-region";  
       //     CTX_MENU_PLOT = true;
          }
        }
        if(type_dict.length>1){
          ctxmenu_show.menu_type = "unknown-select-type"; 
        }      
      }
  }
  
  void dropdown_copy(){
    DROP_MENU_SHOW = false; 
    //this.set_contextmenu_type();
    this.ctx_copy();     
  //  shadowRoot.querySelector("#menu_nav").querySelectorAll("ul").style.visibility = "hidden"; 
  }
  
  void dropdown_paste(){
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();    
 //   print(copy_buffer_object.col_length);
 //   print(copy_buffer_object.row_length);     
 //   print(ctxmenu_show.menu_type);     
    this.ctx_paste(); 
  //  shadowRoot.querySelector("#menu_nav").querySelectorAll("ul").style.visibility = "hidden"; 
  }
  
  
  void dropdown_cut(){
    DROP_MENU_SHOW = false; 
    this.ctx_cut(); 
  }
  
  void dropdown_clear(){
    DROP_MENU_SHOW = false; 
    this.ctx_clear(); 
  }
 
  
  void dropdown_delete(){
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();  
    
    if(ctxmenu_show.menu_type=="column"){
      ctxmenu_show.col = table_select.col_start;
      this.ctx_delete(); 
    }
    
    if(ctxmenu_show.menu_type=="row"){
      ctxmenu_show.row = table_select.row_start; 
      this.ctx_delete(); 
    }
    
  }
  
  
  void dropdown_insert_row(){
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();  
    if(ctxmenu_show.menu_type=="row"){
          ctxmenu_show.row = table_select.row_start; 
          this.ctx_insert_row(); 
    }
  }
  
  void dropdown_insert_col(){
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();  
    if(ctxmenu_show.menu_type=="column"){
      ctxmenu_show.col = table_select.col_start;
      this.ctx_insert_col(); 
    }    
  }
  
  void dropdown_insert_grid(Event event, var detail, Element target){    
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
      ctxmenu_show.col = table_select.col_start;
      $['dialog'].toggle();
      grid_insert.show_insert_grid_dialog = true;
      grid_insert.grid_type = target.attributes['data-msg'];
    }   
  }
  
  
  void dropdown_dropbox_dialog(){
    DROP_MENU_SHOW = false; 
    DROPBOX_DIALOG = true;     
    $['dialog'].toggle(); 
    dropbox_read_start = true;
  }
  
  void dropbox_dialog_cancel(){
    DROPBOX_DIALOG = false;     
    $['dialog'].toggle(); 
    dropbox_read_start = false;
  }
  
  void dropdown_resize_dialog(){
    DROP_MENU_SHOW = false; 
    RESIZE_DIALOG_SHOW = true; 
    $['dialog'].toggle(); 
  }
  
  void resize_table_apply(){      //test pass  
    RESIZE_DIALOG_SHOW = false; 
    $['dialog'].toggle();     
    this.table.resize(new_num_of_row, new_num_of_col);     
  }
  
  void dropdown_append_row(){
    DROP_MENU_SHOW = false; 
    this.table.resize(table.num_of_row+1, table.num_of_col);     
  }
  
  void dropdown_append_col(){
    DROP_MENU_SHOW = false; 
    this.table.resize(table.num_of_row, table.num_of_col+1);     
  }
  
  void resize_table_cancel(){
    RESIZE_DIALOG_SHOW = false; 
    $['dialog'].toggle(); 
  }
  
  void dropdown_set_col_value(){      //test pass
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
      set_col_value.col_value = table_select.col_start;
      set_col_value.show = true;      
      $['dialog'].toggle();      
    }   
  }
  
  void dropdown_fill_row_num(){    // test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
      ctxmenu_show.col = table_select.col_start;
      this.ctx_fill_row_num(); 
           
    } 
  }
  
  void dropdown_fill_rand_num(){      // test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
      ctxmenu_show.col = table_select.col_start;
      this.ctx_fill_rand_num(); 
           
    } 
  }
  
  void dropdown_asc_this_col(){        // test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_asc_this_col();               
        } 
  }
  
  void dropdown_desc_this_col(){       // test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_desc_this_col();               
        } 
  }
  
  void dropdown_asc_conj_col(){       // test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_asc_conj_col();               
        } 
  }
  
  void dropdown_desc_conj_col(){         //test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_desc_conj_col();               
        } 
  }
  
  void dropdown_move_first(){      //test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_move_first();        
        } 
    
  }
  
  void dropdown_move_last(){        //test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_move_last();               
        } 
  }
  
  void dropdown_move_left(){   //test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_move_left();             
        } 
  }
  
  void dropdown_move_right(){    //test pass 
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_move_right();             
        } 
  }
  
  void dropdown_plot_2d(Event event, var detail, Element target){      // test pass 
        DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column" || ctxmenu_show.menu_type=="ok-region" || ctxmenu_show.menu_type=="all" ||
            ctxmenu_show.menu_type=="multi-column" || ctxmenu_show.menu_type=="multi-row" || ctxmenu_show.menu_type=="multi-ok-region"){
            ctxmenu_show.col = table_select.col_start;
            String plot_type = target.attributes['data-msg'];  
            this.plot_2d_apply(plot_type);          
        } 
  }
  
  void dropdown_plot_geo(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_plot_geo();             
        } 
  }
  
  void dropdown_plot_heat_map(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_plot_heat_map();             
        } 
  }
  
  void dropdown_plot_heat_map_interpo(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          this.ctx_plot_heat_map_interpo();             
        } 
  }
  
  
  
  void dropdown_batch_plot_dialog(){       // test pass 
    DROP_MENU_SHOW = false; 
    this.ctx_batch_plot_dialog(); 
  }
  
  void dropdown_set_as(Event event, var detail, Element target){      // test pass 
        DROP_MENU_SHOW = false; 
           this.set_contextmenu_type();      
           if(ctxmenu_show.menu_type=="column"){             
              ctxmenu_show.col = table_select.col_start;
              table.Table_head_data[ctxmenu_show.col].Head_property = target.attributes['data-msg'];  
              table_select.row_start = 0;
              table_select.row_end = 0;
              table_select.col_start = 0;
              table_select.col_end = 0;     
              for(num j=0; j<table.num_of_row; j++){       
               table.Table_data[j].Row_data[ctxmenu_show.col].select = "white";
              }     
           }   
  }
  
  void dropdown_set_as_geo(){    // test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){   
          ctxmenu_show.col = table_select.col_start;
           geography_set_as.show_set_as_geo_dialog=true;
           $['dialog'].toggle();
        }
  }
  
  
  void dropdown_inte_num(){   // test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){    
           ctxmenu_show.col = table_select.col_start;
           this.ctx_inte_num();
        }
  }
  
  
  void dropdown_diff_num(){      // test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){    
           ctxmenu_show.col = table_select.col_start;
           this.ctx_diff_num();
     }
  }
  
  
  void dropdown_interpol_yfromx(){   //test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){    
           ctxmenu_show.col = table_select.col_start;
           this.ctx_interpol_num();
     }   
  }
  
  
  void dropdown_interpol_num(){
    DROP_MENU_SHOW = false; 
  }
  
  void dropdown_stat_max(){    //test pass
    DROP_MENU_SHOW = false; 
    this.ctx_stat_max();
  }
  
  void dropdown_stat_min(){     // test pass 
    DROP_MENU_SHOW = false; 
    this.ctx_stat_min();
  }
  
  void dropdown_stat_avg(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("mean", [jsx]);      
          window.alert("Average: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_std_dev(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("stdev", [jsx]);      
          window.alert("Standard Deviation: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_sum(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("sum", [jsx]);      
          window.alert("Sum: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_product(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("product", [jsx]);      
          window.alert("Product: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_var(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("variance", [jsx]);      
          window.alert("Variance: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_range(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("range", [jsx]);      
          window.alert("Range: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_median(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("median", [jsx]);      
          window.alert("Median: "+z.toString()); 
        } 
  }
  
  
  void dropdown_stat_sum_sqr(){
    DROP_MENU_SHOW = false; 
        this.set_contextmenu_type();      
        if(ctxmenu_show.menu_type=="column"){
          ctxmenu_show.col = table_select.col_start;
          List <double> x = [];  
          for(int i=0; i<table.num_of_row; i++){
            x.add(double.parse(table.Table_data[i].Row_data[ctxmenu_show.col].Cell_data));
          }   
          var jsx = new JsObject.jsify(x);          
          var z = context["jStat"].callMethod("sumsqrd", [jsx]);      
          window.alert("Sum Squared: "+z.toString()); 
        } 
  }
  

  
  void dropdown_stat_dist(){
    DROP_MENU_SHOW = false; 
  }
  
  void dropdown_stat_kmeans(){
    DROP_MENU_SHOW = false; 
  }
  
  void dropdown_stat_corre(){
    DROP_MENU_SHOW = false; 
  }
  
  void dropdown_stat_autocorre(){
    DROP_MENU_SHOW = false; 
  }
  
  void dropdown_linear_fit(){     //test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
        ctxmenu_show.col = table_select.col_start;
        String plot_type = "symbol_2d";  
        this.plot_2d_apply(plot_type);       
        Timer.run((){
          Plot2dElement p2d = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("plot2d-element");
          p2d.show_poly_fit_dialog(); 
        });
    } 
  }
  
  void dropdown_poly_fit(){       //test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
        ctxmenu_show.col = table_select.col_start;
        String plot_type = "symbol_2d";  
        this.plot_2d_apply(plot_type);       
        Timer.run((){
          Plot2dElement p2d = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("plot2d-element");
          p2d.show_poly_fit_dialog(); 
        });
    } 
  }
  
  void dropdown_curve_fit(){    //test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
        ctxmenu_show.col = table_select.col_start;
        String plot_type = "symbol_2d";  
        this.plot_2d_apply(plot_type);       
        Timer.run((){
          Plot2dElement p2d = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("plot2d-element");
          p2d.show_curve_fit(); 
        });
    } 
  }
  
  void dropdown_diff_eq_para_est(){        //test pass 
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
        ctxmenu_show.col = table_select.col_start;
        String plot_type = "symbol_2d";  
        this.plot_2d_apply(plot_type);       
        Timer.run((){
          Plot2dElement p2d = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("plot2d-element");
          p2d.show_diff_eq_para_est(); 
        });
    } 
  }
  
  void dropdown_fft_dialog(){     //test pass 
    DROP_MENU_SHOW = false;     
    FFT_DIALOG_SHOW = true;        
    input_col = table.Table_head_data[table_select.col_start].Head_label;   
    output_col = table.Table_head_data[table_select.col_start+1].Head_label;  
    $['dialog'].toggle();
  }
  
  void dropdown_hil_trans(){
    DROP_MENU_SHOW = false; 
  }
  
  
  void ctx_col_property(){         //test pass 
    COL_PROPERTY_SHOW = true;
    $['dialog'].toggle();
    active_col = ctxmenu_show.col; 
  }
  
  void change_active_col(Event event, var detail, Element target){
    active_col = int.parse(target.attributes['data-msg']);     
  }
  
  void col_property_close(){     
    COL_PROPERTY_SHOW = false;
    $['dialog'].toggle();
  }
  
  
  void dropdown_col_property(){       //test pass 
    DROP_MENU_SHOW = false; 
       this.set_contextmenu_type();      
       if(ctxmenu_show.menu_type=="column"){  
         this.ctx_col_property(); 
       }
  }
  
  void dropdown_preference_dialog(){
    DROP_MENU_SHOW = false; 
  }
  
  
  
  void dropdown_google_chart(Event event, var detail, Element target){    
    String plot_type = target.attributes['data-msg'];  
    this.google_chart_apply(plot_type);     
  }
  
  void google_chart_apply(String _plot_type_){    
    List <List <dynamic>> grouped_data = [];    
    List temp_list = [];
    
    for(var _table_select in table_select_history){     
       for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){  
         temp_list.add(table.Table_head_data[j].Head_label);
       }
    }   
    grouped_data.add(temp_list); 
    
    String x_value_type = "number"; 
    if(table.Table_head_data[table_select_history[0].col_start].Head_property=="S"){
      x_value_type = "string";
    }
    
  for(int i=table_select.row_start; i<table_select.row_end+1; i++){ 
    List temp_list = [];
    for(var _table_select in table_select_history){          
       for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){  
         temp_list.add(table.Table_data[i].Row_data[j].Cell_data); 
        //  grouped_data.add(new Grouped_Data(temp_list, " ", " ", _plot_type_));
        }   // end of if(table.Table_head_data[j].Head_property != "X"){
      }      // end of for(num j=_table_select.col_start; j<(_table_select.col_end+1); j++){      
     grouped_data.add(temp_list);
   }   // end of for(var _table_select in table_select_history){   
  
    for(int i=1; i<grouped_data.length; i++){      
      if(x_value_type=="number"){
        grouped_data[i][0] = double.parse(grouped_data[i][0]); 
      }
      for(int j=1; j<grouped_data[i].length; j++){
        grouped_data[i][j] = double.parse(grouped_data[i][j]); 
      }
      
    }
    
    
    LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
    layout.new_google_chart(_plot_type_, grouped_data);    
  }
  
  
  
  void dropdown_plot_3d_surface(){
    
  DROP_MENU_SHOW = false; 
  this.set_contextmenu_type();      
  if(ctxmenu_show.menu_type=="column"){
        ctxmenu_show.col = table_select.col_start;    

    num Z_index = ctxmenu_show.col;
    num X_index = 0;
    num Y_index = 0;
    
    for(num i=ctxmenu_show.col-1; i>0; i--){
      if(table.Table_head_data[i].Head_property=="Y"){  //check for the data with "X" property
        Y_index = i;
      }
      if(table.Table_head_data[i].Head_property=="X"){  //check for the data with "X" property
        X_index = i;
      }
    }    
    
    List <List <double>> p = []; //= [[0, 0], [0, 1], [1, 0], [1, 1], [2, 0], [2, 1], [0, 2], [1, 2], [2, 2]];   
    
    for(num i=0; i<table.num_of_row; i++){
      p.add([double.parse(table.Table_data[i].Row_data[X_index].Cell_data), double.parse(table.Table_data[i].Row_data[Y_index].Cell_data), double.parse(table.Table_data[i].Row_data[Z_index].Cell_data)]);
    }           
    
    LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
    layout.new_d3surface_plot("3dsurface", p);       
  }
    
 }
  
  
  
  
  void dropdown_plot_3d_iso(){    
    
    DROP_MENU_SHOW = false; 
    this.set_contextmenu_type();      
    if(ctxmenu_show.menu_type=="column"){
      
    ctxmenu_show.col = table_select.col_start;  
    num F_index = ctxmenu_show.col;
    num Z_index = 0;
    num X_index = 0;
    num Y_index = 0;
    
    for(num i=ctxmenu_show.col-1; i>0; i--){
      if(table.Table_head_data[i].Head_property=="Z"){  //check for the data with "Z" property
        Z_index = i;
      }
      if(table.Table_head_data[i].Head_property=="Y"){  //check for the data with "Y" property
        Y_index = i;
      }
      if(table.Table_head_data[i].Head_property=="X"){  //check for the data with "X" property
        X_index = i;
      }
    }    
    
    List <List <double>> p = []; //= [[0, 0], [0, 1], [1, 0], [1, 1], [2, 0], [2, 1], [0, 2], [1, 2], [2, 2]];   
    
    for(num i=0; i<table.num_of_row; i++){
      p.add([double.parse(table.Table_data[i].Row_data[X_index].Cell_data), double.parse(table.Table_data[i].Row_data[Y_index].Cell_data),
                 double.parse(table.Table_data[i].Row_data[Z_index].Cell_data), double.parse(table.Table_data[i].Row_data[F_index].Cell_data)]);
    }             
    
    LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");  
    layout.new_d3surface_plot("marchingcube", p);       
   } 
    
  }
  
  
  
  
}   //end of table_element 

    
 
