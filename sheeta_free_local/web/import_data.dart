import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
//import 'dart:math';
//import 'dart:async';
//import 'table_element.dart';
import './table-core.dart';

@CustomTag('import-data')
class ImportData extends PolymerElement {
    @published Table table;
    FormElement _readForm;
    InputElement _fileInput;
    Element _dropZone;
    OutputElement _output;
    HtmlEscape sanitizer = new HtmlEscape();     
    List <File> files_list;
    //Element _progressBar;
    //WebSocket ws;
    @observable String start_line = "0";
    @observable Pattern split_pattern = new RegExp(r"(\s+)");
    @observable List data_sample = toObservable([]);
    @observable List key_list = toObservable([]);
    @observable List prop_list = toObservable([]);
    @observable int total_line = 0;
    @observable bool file_readed = false;
    //@published String parentID;
    @observable bool import_start=false;
    @observable int progress = 0;
    @observable bool whitespace_ = true;
    @observable bool comma_ = false;
    @observable bool semicolon_ = false;
    @observable bool others_ = false;
    @observable String other_split = "";
    @observable String ws_error = "";
    
  
  ImportData.created() : super.created() {  } 
  
  void Re_init(){
    
    data_sample = toObservable([]);
    
    //ws = new WebSocket('ws://localhost:8088');
    
    //_progressBar = shadowRoot.querySelector('#progress-bar');
    _output = shadowRoot.querySelector('#list');
    _readForm = shadowRoot.querySelector('#read');
    _fileInput = shadowRoot.querySelector('#files');
    _fileInput.onChange.listen((e) => _onFileInputChange());

     _dropZone = shadowRoot.querySelector('#drop-zone');
     _dropZone.onDragOver.listen(_onDragOver);
     _dropZone.onDragEnter.listen((e) => _dropZone.classes.add('hover'));
     _dropZone.onDragLeave.listen((e) => _dropZone.classes.remove('hover'));
     _dropZone.onDrop.listen(_onDrop);  
    
    
    
  }
  
  void _onDragOver(MouseEvent event) {
     event.stopPropagation();
     event.preventDefault();
     event.dataTransfer.dropEffect = 'copy';
   }

   void _onDrop(MouseEvent event) {
     event.stopPropagation();
     event.preventDefault();
     _dropZone.classes.remove('hover');
     _readForm.reset();
     _onFilesSelected(event.dataTransfer.files);
     files_list = event.dataTransfer.files;
   }

   void _onFileInputChange() {
     _onFilesSelected(_fileInput.files);
     files_list = _fileInput.files;
   }

   void _onFilesSelected(List<File> files) {
     _output.nodes.clear();
     for (var file in files) {             
       var reader = new FileReader();       
       reader.onLoad.listen((e) {
         String res = reader.result; 
         List <String> list_res = res.split('\n'); 
         total_line = list_res.length;         
         num start_l = int.parse(start_line);
         List <String> ttt = [];         
         for(int i=start_l;i<(start_l+10);i++){           
           ttt.add(i.toString());
           List <String> tmp = list_res[i].split(split_pattern);
           for(var s in tmp){  
             if(s.length>0){
               ttt.add(s); 
              }
            }
           data_sample.add(ttt);
           ttt = [];
         } // end of for(int i=start_l; i<(start_l+10); i++){
         
         int key_list_length = data_sample[0].length;
        // key_list.add("Label:");
         
         for(int i=0; i<key_list_length-1; i++){
           key_list.add(new String.fromCharCodes([65+i]));
           if(i==0)   prop_list.add("X");
           if(i==1)   prop_list.add("Y");
           if(i==2)   prop_list.add("Z");
           if(i>2)    prop_list.add("F");
         }
         
         file_readed = true;        
       });       
       reader.readAsText(file);
     }   
    }  
   
   
   void import_data_to_table(String author){         
     
     for (var file in files_list) {         
        var reader = new FileReader();         
        reader.onLoad.listen((e) {           
           String res = reader.result; 
           List <String> list_res = res.split('\n');          
           List <num> ttt = [];         

           num start_l = int.parse(start_line);           
           List <String> tmp = list_res[start_l].split(split_pattern);
                         for(var s in tmp){  
                               if(s.length>0){
                                 ttt.add(double.parse(s)); 
                               }
                          }    
           int num_of_col = ttt.length; 
           int num_of_row = list_res.length-start_l;
           //table.empty_init(num_of_row, num_of_col);     
           table.Table_data.clear();
           table.Table_head_data.clear();
           
           for(int j=0; j<ttt.length; j++){
             table.Table_head_data.add(new Head(prop_list[j], key_list[j], j));
           }   
           
           ttt = [];           
           for(int i=0;i<num_of_row;i++){              
               List <String> tmp = list_res[i].split(split_pattern);
               for(var s in tmp){  
                     if(s.length>0){
                       ttt.add(double.parse(s)); 
                     }
                }
               if(ttt.length>0){
                 List <Cell> temp_row = toObservable([]);
                  for(int j=0; j<ttt.length; j++){
                     var cell = new Cell(ttt[j].toString(), ttt[j], "black", i, j, false, "white", author);
                     temp_row.add(cell);
                  }                
                  table.Table_data.add(new Row(i.toString(), i, temp_row));   
               }            
            ttt = [];
          } 
           
          table.num_of_col = table.Table_data[0].Row_data.length;
          table.num_of_row = table.Table_data.length;
         //  return result;
          });      
        
       reader.readAsText(file);  
    }         

   }
    
   
   
   /*
   
   void import_data_to_server(){
     import_start=true;     
     _progressBar.classes.add('loading');
     int count=0;
     bool big_data_show = false;
     
     new Timer.periodic(const Duration(seconds:1), (_){  
       count += 10;
       if(count<=100){
         _setProgress(count);
         progress = count;
       }       
       if(big_data_show==false && progress==100){
         big_data_show=true;
         
         document.querySelector("#import-data").style.display = "none";
         document.querySelector("#big-data").style.display = "block";
         
         BigData_Element bigdata = document.querySelector("bigdata-element");
         bigdata.Re_init();  
       }
       });  
     
     /*
     
     for (var file in files_list) { 
       var reader = new FileReader(); 
       
       reader.onLoad.listen((e) {
          String res = reader.result; 
          List <String> list_res = res.split('\n');          
          List <num> ttt = [];         
          Map doc_map = {};
          Map doc_map_head = {};
          List <Map> head_data = [];
          Map head_data_temp = {};
          num start_l = int.parse(start_line);
          
          List <String> tmp = list_res[start_l].split(split_pattern);
                        for(var s in tmp){  
                              if(s.length>0){
                                ttt.add(double.parse(s)); 
                              }
                         }
          for(int j=0; j<ttt.length; j++){
            head_data_temp["col"] = j;
            head_data_temp["label"] = key_list[j];
            head_data_temp["property"] = prop_list[j];
            head_data.add(head_data_temp);
            head_data_temp = {};
          }              
          
          doc_map_head["parent"]=parentID;
          doc_map_head["type"]="big_data_head";
          doc_map_head["num_of_col"] = ttt.length;
          doc_map_head["num_of_row"] = list_res.length;
          doc_map_head["head_data"] = head_data;
          
         // print(JSON.encode({"CMD":"import_big_data", "data":doc_map_head}));
          ws.send(JSON.encode({"CMD":"import_big_data_head", "data":doc_map_head}));
          ttt = [];
          
          for(int i=start_l;i<list_res.length;i++){              
              List <String> tmp = list_res[i].split(split_pattern);
              for(var s in tmp){  
                    if(s.length>0){
                      ttt.add(double.parse(s)); 
                    }
               }
               for(int j=0; j<ttt.length; j++){
                 doc_map[key_list[j]]=ttt[j];
               }
               
           if(doc_map.length>0){
               doc_map["_row"]=i;
               doc_map["_parent"]=parentID;
               doc_map["_type"]="big_data_doc";
           //if(i<10){   print(JSON.encode(doc_map));  }
               ws.send(JSON.encode({"CMD":"import_big_data", "data":doc_map}));
           }
           //JSON.encode(doc_map);
       //    progress = (i.toDouble()/list_res.length.toDouble()*100.0).toInt()+1;
       //    _setProgress(progress);
           ttt = [];
           doc_map = {};
           } // end of for(int i=start_l; i<(start_l+10); i++){   
         });       
      reader.readAsText(file);   */
     //}     
   }
   
   
   void _setProgress(int value) {
       value = min(100, max(0, value));
       _progressBar.style.width = '${value}%';
     } 
  */
  
}