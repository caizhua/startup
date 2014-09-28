library googlechart;

import 'dart:html';
//import 'package:js/js.dart' as js;
import 'dart:js'; 
import 'package:polymer/polymer.dart';
import './ui_filters.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;
import 'dart:math';
import 'dart:async';
import 'dart:convert'; 

String host = 'localhost';
int port = 8084;

class Text_Style extends Object with Observable{
    @observable String color = "#000000"; //: <string>,
    @observable String fontName = 'Times-Roman';  //: <string>,
    @observable int fontSize = 15; // : <number>,
    @observable bool bold = false; //: <boolean>,
    @observable bool italic = false; // : <boolean> 
    Text_Style();
    Text_Style.set_value(Map input){
      this.color = input["color"];
      this.fontName = input["fontName"];
      this.fontSize = input["fontSize"];
      this.bold = input["bold"];
      this.italic = input["italic"];
    }
    dynamic toJson() => { "color":this.color, "fontName":this.fontName, "fontSize":this.fontSize, "bold":this.bold, "italic":this.italic } ;
}

class Tool_Tip extends Object with Observable{
  @observable bool isHtml = false;
  @observable bool showColorCode = true;
  @observable Text_Style textStyle;
  @observable String trigger = 'focus';
  Tool_Tip(this.textStyle);
  void set_value(Map input){
    this.trigger = input["trigger"];
    this.textStyle = new Text_Style.set_value(input["textStyle"]); 
  }
  dynamic toJson() => {"trigger":this.trigger, "textStyle":this.textStyle.toJson()}; 
}

class hAxes extends Object with Observable{
  @observable num baseline;
  @observable String baselineColor = "black";
  @observable int direction = 1;
  @observable String format = "auto";
  @observable dynamic gridlines; 
  @observable dynamic minorGridlines; 
  @observable bool logScale = false;
  @observable String textPosition = 'out';
  @observable Text_Style textStyle;
  @observable List ticks; 
  @observable String title;
  @observable Text_Style titleTextStyle;
  @observable num maxValue;
  @observable num minValue; 
  hAxes(); 
  void set_value(Map input){
    this.title = input["title"];
    this.minValue = input["minValue"];
    this.maxValue = input["maxValue"];
  }
  dynamic toJson() => { "title":this.title, "minValue":this.minValue, "maxValue":this.maxValue }; 
}

class vAxes extends Object with Observable{
  @observable num baseline;
  @observable String baselineColor = "black";
  @observable int direction = 1;
  @observable String format = "auto";
  @observable dynamic gridlines; 
  @observable dynamic minorGridlines; 
  @observable bool logScale = false;
  @observable String textPosition = 'out';
  @observable Text_Style textStyle;
  @observable List ticks; 
  @observable String title;
  @observable Text_Style titleTextStyle;
  @observable num maxValue;
  @observable num minValue; 
  vAxes(); 
  void set_value(Map input){
    this.title = input["title"];
    this.minValue = input["minValue"];
    this.maxValue = input["maxValue"];
  }
  dynamic toJson() => { "title":this.title, "minValue":this.minValue, "maxValue":this.maxValue }; 
}

class Background extends Object with Observable{
  @observable String stroke;
  @observable String fill = "#a5efe7";
  @observable num strokeWidth;
  Background();
  void set_value(Map input){
    this.fill = input["fill"];
    this.stroke = input["stroke"];
    this.strokeWidth = input["strokeWidth"];
  }
  dynamic toJson() => { "fill":this.fill, "stroke":this.stroke, "strokeWidth":this.strokeWidth }; 
}

class Cross_Hair extends Object with Observable{
  @observable String color;
  @observable dynamic focused;
  @observable num opacity;
  @observable String orientiation; 
  @observable dynamic selected;
  @observable String trigger = null;
  Cross_Hair();
  void set_value(Map input){
    this.trigger = input["trigger"];
    this.color = input["color"]; 
  }
  
  dynamic toJson() => {  "color":this.color, "trigger":this.trigger }; 
}

class Legend extends Object with Observable{
  @observable String alignment;
  @observable int maxLines = 1;
  @observable String position = 'right';
  @observable Text_Style textStyle;
  Legend(this.textStyle);     
  void set_value(Map input){
    this.position = input["position"];
    this.alignment = input["alignment"]; 
    this.maxLines = input["maxLines"];
    this.textStyle = new Text_Style.set_value(input["textStyle"]); 
  }  
  dynamic toJson() => { "position":this.position, "alignment":this.alignment, "maxLines":this.maxLines, "textStyle":this.textStyle.toJson() } ;
}

class Title extends Object with Observable{
  @observable String title = 'Company Performance';
  @observable Text_Style titleTextStyle;
  @observable String titlePosition = "out";
  Title(this.titleTextStyle);
}

class Explorer extends Object with Observable{
  @observable List <String> actions = [];
  @observable String axis;
  @observable bool keepInBounds = false;
  @observable num maxZoomIn = 0.25;
  @observable num maxZoomOut = 4.0;
  @observable num zoomDelta = 1.5;
  @observable bool IS_dragToPan = false; 
  @observable bool IS_dragToZoom = true; 
  @observable bool IS_rightClickToReset = true; 
  Explorer(); 
  dynamic toJson() => {"actions":this.actions }; 
  
  void set_value(Map input){
    actions = input["actions"];
    if(actions.contains("dragToPan")){
      IS_dragToPan = true; 
    }
    if(actions.contains("dragToZoom")){
      IS_dragToZoom = true; 
    }
    if(actions.contains("rightClickToReset")){
      IS_rightClickToReset = true; 
    }
  }
  
  void update(){
    actions.clear();
    Timer.run((){
      if(IS_dragToPan){
        actions.add("dragToPan");       
      }
      if(IS_dragToZoom){
        actions.add("dragToZoom");       
      }
      if(IS_rightClickToReset){
        actions.add("rightClickToReset");    
      }
    });   

   // print(actions); 
   // print(IS_dragToZoom); 
  }
}

class data_series extends Object with Observable{
  @observable dynamic annotations;
  @observable String color; // = "#FF0000";
  @observable String curveType = 'none';
  @observable int lineWidth = 2;
  @observable String pointShape;
  @observable int pointSize = 10;
  @observable int targetAxisIndex;
  @observable bool visibleInLegend = true;
  data_series.init(){
    var rng = new Random();
    this.color = '#'+rng.nextDouble().toStringAsFixed(16).substring(2, 8);
  }
  
  data_series.set_value(Map input){
    this.color = input["color"];
    this.visibleInLegend = input["visibleInLegend"]; 
    this.curveType = input["curveType"];
    this.lineWidth = input["lineWidth"]; 
    this.pointShape = input["pointShape"];
    this.pointSize = input["pointSize"]; 
  }  
  
  dynamic toJson() => { "color":this.color, "visibleInLegend":this.visibleInLegend, "curveType":this.curveType, "lineWidth":this.lineWidth, "pointShape":this.pointShape, "pointSize":this.pointSize  }; 
}

class Data_Series_List extends Object with Observable{
  List <data_series> data_style_list = toObservable([]); 
  Data_Series_List();
  List toJson(){
    List result = []; 
    for(var data in data_style_list){
      result.add(data.toJson()); 
    }
    return result; 
  }
}

class Frame extends Object with Observable{
  @observable int left = 0;
  @observable int top = 100;
  @observable int height = 400;
  @observable int width = 600;
  Frame(); 
  dynamic toJson() => { "left":this.left, "top":this.top, "height":this.height, "width":this.width };
}


class Plot_Options extends Object with Observable{
  @observable Frame frame;
  @observable Title title;
  @observable Background background;
  @observable Legend legend; 
  @observable hAxes haxis; 
  @observable vAxes vaxis; 
  //@observable List <data_series> data_style_list = toObservable([]); 
  @observable Data_Series_List data_series_list;
  @observable Tool_Tip tool_tip; 
  @observable Cross_Hair cross_hair; 
  @observable Explorer explorer; 
  
  Plot_Options.init(int data_length){
   this.frame = new Frame();  
   this.title = new Title(new Text_Style());
  // this.title.titleTextStyle = new Text_Style(); 
   this.background = new Background(); 
   this.legend = new Legend(new Text_Style()); 
   this.haxis = new hAxes(); 
   this.vaxis = new vAxes(); 
   this.data_series_list = new Data_Series_List();   
   for(int i=0; i<data_length; i++){
     this.data_series_list.data_style_list.add(new data_series.init()); 
   }
   this.tool_tip = new Tool_Tip(new Text_Style()); 
   this.cross_hair = new Cross_Hair(); 
   this.explorer = new Explorer(); 
   this.explorer.update(); 
   //int data_length = 
   
   //this.data_style_list = toObservable([]); 
  }
  
  //Plot_Options.empty(); 
  
  dynamic toJson(String plot_type){    
    if(plot_type == "pie"){
      return { "title":title.title, "titlePosition":title.titlePosition, "titleTextStyle":title.titleTextStyle.toJson(), 
        "backgroundColor":background.toJson(), "legend":legend.toJson(), "hAxis":haxis.toJson(), "vAxis":vaxis.toJson(), 
        "series":data_series_list.toJson(), "tooltip":tool_tip.toJson(), "crosshair":cross_hair.toJson()};       
    }
    
    if(plot_type != "pie"){
          return { "title":title.title, "titlePosition":title.titlePosition, "titleTextStyle":title.titleTextStyle.toJson(), 
            "backgroundColor":background.toJson(), "legend":legend.toJson(), "hAxis":haxis.toJson(), "vAxis":vaxis.toJson(), 
            "series":data_series_list.toJson(), "tooltip":tool_tip.toJson(), "crosshair":cross_hair.toJson(), "explorer":explorer.toJson()};       
        }   
    return null; 
 } 
//, "explorer":explorer.toJson(), 
  
}


class GchartElement_ extends Object with Observable{
  @observable Plot_Options plot_option; 
  @observable String plot_type = ""; 
  @observable List plotdata; 
  @observable String parentID;
  
  GchartElement_.init(String _plot_type_, List _plot_data_, String parent){
    this.plotdata = _plot_data_;
 //   print(this.plotdata);
    this.plot_type = _plot_type_; 
    this.parentID = parent; 
    int data_length = plotdata[0].length-1; 
    plot_option = new Plot_Options.init(data_length); 
  }
  
  dynamic toJson() => { "plot_data":this.plotdata, "plot_type":this.plot_type, "parent":this.parentID, "plot_option":this.plot_option, "frame":this.plot_option.frame}; 
  
   void write_to_db(){
     var ws_write_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");   
     
     ws_write_db.onOpen.listen((event){
         ws_write_db.send(JSON.encode({"CMD":"insert-google-chart", "data":this.toJson()}));
     //    ws_write_db.close(); 
     });
     
   }

   GchartElement_.db_init(String _parentID_){
     var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");   
     
     ws_read_db.onOpen.listen((event){
        ws_read_db.send(JSON.encode({"CMD":"read-google-chart", "filter":{"parent":_parentID_}}));  
     }); 
     
     ws_read_db.onMessage.listen((event){
       var data = JSON.decode(event.data);
       this.parentID = data["parent"];
       this.plotdata = data["plot_data"];
       this.plot_type = data["plot_type"];
       
       int data_length = this.plotdata.length-1;        
       this.plot_option = new Plot_Options.init(data_length);
       
       this.plot_option.frame.left = data["frame"]["left"];
       this.plot_option.frame.top = data["frame"]["top"];
       this.plot_option.frame.width = data["frame"]["width"];
       this.plot_option.frame.height = data["frame"]["height"];
       
       this.plot_option.title.title = data["plot_option"]["title"];
       this.plot_option.title.titlePosition = data["plot_option"]["titlePosition"];
       this.plot_option.title.titleTextStyle = new Text_Style.set_value(data["plot_option"]["titleTextStyle"]); 
       
       this.plot_option.background.set_value(data["plot_option"]["backgroundColor"]); 
       this.plot_option.legend.set_value(data["plot_option"]["legend"]);
       this.plot_option.haxis.set_value(data["plot_option"]["hAxis"]);
       this.plot_option.vaxis.set_value(data["plot_option"]["vAxis"]);
       this.plot_option.tool_tip.set_value(data["plot_option"]["tooltip"]);
       this.plot_option.cross_hair.set_value(data["plot_option"]["crosshair"]);
       this.plot_option.explorer.set_value(data["plot_option"]["explorer"]);
       
       this.plot_option.data_series_list.data_style_list.clear();
       for(var ds in data["plot_option"]["series"]){
         this.plot_option.data_series_list.data_style_list.add(new data_series.set_value(ds)); 
       }
       
        Timer.run((){
          GchartElement gchart = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("gchart-element");  
          gchart.refresh_plot(); 
        });  
       
       
     }); 
  
   }
  
}



@CustomTag('gchart-element')
class GchartElement extends PolymerElement {
  @published Plot_Options plot_option; 
  @published String plot_type = ""; 
  @published List plotdata; 
  @published String parentID;
  
  @observable bool RIBBON_GENERAL = true; 
  @observable bool RIBBON_AXIS = false; 
  @observable bool RIBBON_DATA = false; 
  @observable bool RIBBON_ADVANCED = false; 
  @observable bool EMBED_SHARED_DIALOG = false; 
  @observable String share_link = "";   
  @observable String email_content = "";
  @observable String x_value_type = "number"; 
  
  /* = [
          ['Year', 'Sales', 'Expenses'],
          [2004,  1000,      400],
          [2005,  1170,      460],
          [2006,  660,       1120],
          [2007,  1030,      540]
                       ];  */
  //@published dynamic plotoption = {};
  /*
  = { "title": 'Company Performance' , 
    "series": {0:{"color": 'black', "visibleInLegend": true},
               1:{"color": 'red', "visibleInLegend": true}},
               "hAxis": {"title": 'Hello',  "titleTextStyle": {"color": '#FF0000'}},
               "tooltip": {"textStyle": {"color": '#00FF00'}, "showColorCode": true, "trigger":'selection'},
               "explorer": { "actions": ['dragToZoom', 'rightClickToReset'] },
               "backgroundColor":'white', "crosshair": { "trigger": 'both',  "focused": { "color": '#3bc', "opacity": 0.8 } }, 
               "legend":{"position": 'top', "textStyle": {"color": 'blue', "fontSize": 16}}
  }; 
  * */
  
  GchartElement.created() : super.created() {  }              //  this.Re_init();    //  this.refresh_plot();      }//this.Re_init();  
  
  final Transformer asInteger = new StringToInt();
  final Transformer asDouble = new StringToDouble();
  
  /*
  void Re_init(){
    int data_length = plotdata[0].length-1; 
    plot_option = new Plot_Options.init(data_length); 
    
    if(plotdata[1][0] is num){
      x_value_type = "number"; 
    }
    
    if(plotdata[1][0] is String){
      x_value_type = "string"; 
    }
    
    print(x_value_type); 
    
  }*/
  
  
  void drawVisualization() {
    var gviz = context['google']['visualization'];    //final vis = context["google"]["visualization"];
    var listData = plotdata; 
    var arrayData = new JsObject.jsify(listData); //;js.array();
    var tableData = gviz.callMethod('arrayToDataTable', [arrayData]); //gviz.arrayToDataTable(arrayData);
    var options = new JsObject.jsify(plot_option.toJson(plot_type));
    // Create and draw the visualization.  
    
    dynamic chart_type;
    
    if(plot_type=="scatter"){              //  x value: number
      chart_type = gviz['ScatterChart'];
    }
    
    if(plot_type=="line"){      // x value: string (discrete)      number, date, datetime or   timeofday (continuous)
      chart_type = gviz['LineChart'];
    }
    
    if(plot_type=="area"){        // x value:  string (discrete)      number, date, datetime or   timeofday (continuous)
      chart_type = gviz['AreaChart'];
    }
    
    if(plot_type=="bar"){        // x value:  string (discrete)      number, date, datetime or   timeofday (continuous)
      chart_type = gviz['BarChart'];
    }
    
    if(plot_type=="pie"){   // x value : string    only two column is allowed. 
      chart_type = gviz['PieChart'];
    }
    
    if(plot_type=="bubble"){   // ID: string   X: number  Y: number  color:  string or number  size: number
      chart_type = gviz['BubbleChart'];
    }
    
    if(plot_type=="candlestick"){  //  String (discrete) used as a group label on the X axis, or number, date, datetime or timeofday (continuous) used as a va
      chart_type = gviz['CandlestickChart'];
    }
    
    if(plot_type=="column"){  // x value: string (discrete)      number, date, datetime or   timeofday (continuous)
      chart_type = gviz['ColumnChart'];
    }
    
    if(plot_type=="combo"){   //   x value:  string (discrete)      number, date, datetime or   timeofday (continuous)
      chart_type = gviz['ComboChart'];
    }
    
    if(plot_type=="histogram"){  // x value : string 
      chart_type = gviz['Histogram'];
    }
    
    if(plot_type=="stepped-area"){   // x value: string 
      chart_type = gviz['SteppedAreaChart'];
    }
    
    if(plot_type=="geo"){   //x value: Region location [String,   Y value: Region color [Number, Optional] - An
      chart_type = gviz['GeoChart'];
    }   
    
    var jsChart = new JsObject(chart_type, [shadowRoot.querySelector('#visualization')]);
    jsChart.callMethod('draw', [tableData, options]);
    //new JsObject(context["google"]["visualization"]["Gauge"], [element]);
    
    //var chart = new js.Proxy(chart_type, shadowRoot.querySelector('#visualization'));    
    //jsChart.draw(tableData, options);
  }
  
  
  
  //document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("gchart-element").
  
  void refresh_plot(){    
    context["google"].callMethod('load',
       ['visualization', '1', new JsObject.jsify({
         'packages': ['corechart'],
         'callback': drawVisualization,
       })]);  
  }
  
  
  
  void refresh_explorer(){
    plot_option.explorer.update();
    Timer.run((){
       this.refresh_plot(); 
    }); 
  }

  
  
  void general_show(){
    RIBBON_GENERAL = true; 
    RIBBON_AXIS = false; 
    RIBBON_DATA = false; 
    RIBBON_ADVANCED = false; 
  }
  
  void axis_show(){
    RIBBON_GENERAL = false; 
    RIBBON_AXIS = true; 
    RIBBON_DATA = false; 
    RIBBON_ADVANCED = false; 
  }
  
  void data_show(){
    RIBBON_GENERAL = false; 
    RIBBON_AXIS = false; 
    RIBBON_DATA = true; 
    RIBBON_ADVANCED = false; 
  }
  
  void advance_show(){
    RIBBON_GENERAL = false; 
    RIBBON_AXIS = false; 
    RIBBON_DATA = false; 
    RIBBON_ADVANCED = true; 
  }
  
  void embed_share_plot(){
    this.EMBED_SHARED_DIALOG = true; 
    $['dialog'].toggle(); 
  }
  
  void download_plot(){
    
    String contents = shadowRoot.querySelector("#visualization").innerHtml; 

    Blob blob = new Blob([contents]);
    AnchorElement downloadLink = new AnchorElement(href: Url.createObjectUrlFromBlob(blob));
    downloadLink.text = 'Download me';
    downloadLink.download = 'svg_contents.html';

    Element body = shadowRoot.querySelector('#download_plotxxx');
    body.append(downloadLink);
    
    //print(JSON.encode({"xxxxxxxxx":plotdata}));
  }
  
  void generate_static_link(){
    
    String temp = shadowRoot.querySelector("#visualization").innerHtml; 
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
  
  void generate_embed_link(){
    
    String content = "<google-chart  " + "type=" + "\'" + this.plot_type +"\'";
    content += " height=" + "\'" + this.plot_option.frame.height.toString()  + "px" + "\'";
    content += " width=" + "\'" +  this.plot_option.frame.width.toString() +  "px"+ "\'" ;
    content += " options=" + "\'" +  JSON.encode(this.plot_option.toJson(plot_type)) + "\'" ;
    content += " data=" + "\'" + JSON.encode(this.plotdata)+ "\'"; 
    content +=  " </google-chart>"; 
    
    var rng = new Random();
    String color = rng.nextDouble().toStringAsFixed(16).substring(2, 8);     
    DateTime now = new DateTime.now();
    // now.toString();  
    String llllink = now.toString()+color+".html";     
    this.share_link = "http://0.0.0.0:8000/google-chart/"+llllink;     
    this.email_content = "mailto:name1@rapidtables.com?subject=The%20subject%20of%20the%20email&body=" + this.share_link ; 
    var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");      
    ws_read_db.onOpen.listen((event){
        ws_read_db.send(JSON.encode({"CMD":"write-google-chart", "figure":content, "filename":llllink}));
      //  ws_read_db.close(); 
    }); // end of  ws_write_db.onOpen.listen((event){
    //ws_read_db.onMessage.listen((event){
       
    //}); 
  }
  
  void embed_share_cancel(){
    this.EMBED_SHARED_DIALOG = false; 
    $['dialog'].toggle(); 
  }
  
/*
  @override
  attached() {
  //  print(this.plotdata);
    Timer.run((){
      this.refresh_plot(); 
    }); 
*/
    
 // }
  
  
  
  
}