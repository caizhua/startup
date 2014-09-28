import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import './ThreeShow.dart';
import './marching_cube_data.dart';
import 'dart:js'; 
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async'; 
import 'layout.dart'; 
import 'dart:math';


String host = 'localhost';
int port = 8090;
int port2 = 8084;


class D3SurfaceElement_ extends Object with Observable{
  @observable String plot_type = "3dsurface";   // it can be "marchingcube" or "3dsurface"
 // @observable dynamic d3_object_save; 
  @observable dynamic plot_data; 
  @observable String parentID;
  
  D3SurfaceElement_.init(String _plot_type_, dynamic _plot_data_, String parent){
     this.plot_type = _plot_type_;
     this.plot_data = _plot_data_; 
     this.parentID = parent; 
     /*
     if(plot_type=="marchingcube"){     
       this.plot_data = _plot_data_; 
     }
     
     if(plot_type=="3dsurface"){
       this.plot_data = new MarchingCube_Setting(_plot_data_); 
     }     */
  }
  
  dynamic toJson() => {"plot_data":this.plot_data, "plot_type":this.plot_type, "parent":this.parentID}; 
  
  
  void write_to_db(){
    var ws_write_db = new WebSocket("ws://"+host+":"+port2.toString()+"/ws");       
    ws_write_db.onOpen.listen((event){
        ws_write_db.send(JSON.encode({"CMD":"insert-3dsurface-plot", "data":this.toJson()}));
    //    ws_write_db.close(); 
    });    
  }

  D3SurfaceElement_.db_init(String _parentID_){
    var ws_read_db = new WebSocket("ws://"+host+":"+port2.toString()+"/ws");   
         
         ws_read_db.onOpen.listen((event){
            ws_read_db.send(JSON.encode({"CMD":"read-3dsurface-plot", "filter":{"parent":_parentID_}}));  
         }); 
         
         ws_read_db.onMessage.listen((event){
           var data = JSON.decode(event.data);           
           this.parentID = data["parent"];
           var temp_plot_data = data["plot_data"];
           this.plot_type = data["plot_type"];
          
           if(plot_type=="marchingcube"){
             
             MarchingCube_Setting marchingcube_setting = new MarchingCube_Setting.empty();
             marchingcube_setting
             ..x_min = temp_plot_data["range"]['x_min']
             ..x_max = temp_plot_data["range"]['x_max']
             ..y_min = temp_plot_data["range"]['y_min']
             ..y_max = temp_plot_data["range"]['y_max']
             ..z_min = temp_plot_data["range"]['z_min']
             ..z_max = temp_plot_data["range"]['z_max']
             ..num_of_step = temp_plot_data['num_of_step']
             ..value_list = temp_plot_data['value_list']
             ..value_list_calculated = true
             ..isovalue = temp_plot_data['isovalue'];      
             this.plot_data = marchingcube_setting;              
           }
           
           
           Timer.run((){
             D3SurfaceElement d3surface = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("d3surface-element");
             d3surface.Re_init(); 
           });  
           
           
         });     
  }
  
}


@CustomTag('d3surface-element')
class D3SurfaceElement extends PolymerElement {
   THREEX     THREEx; // = new THREEX();
   ThreeShow  threeShow; // = new ThreeShow();
  @published String plot_type = "marchingcube";   // it can be "marchingcube" or "3dsurface"
  @published dynamic plot_data; 
  //@published dynamic d3_object_save; 
  @published bool output_mode = false; 
  @published String output_string = ''; 
  @published String parentID;
  @observable bool EMBED_SHARED_DIALOG = false; 
  @observable String share_link = "";   
  @observable String email_content = "";
  
  D3SurfaceElement.created() : super.created() { 
    if(output_mode==true){
      this.plot_data = new MarchingCube_Setting.json_init(output_string); 
      this.Re_init();
    }    
  }
  
  
  void Re_init(){    
    THREEx = new THREEX();
    threeShow  = new ThreeShow();        
    
    if(plot_type=="marchingcube"){
      MarchingCube marchingCube = new MarchingCube(plot_data);
      //Timer.run((){
        //threeShow.addObject(marchingCube);
      //}); 
      
     // d3_object_save = marchingCube; 
    }
    if(plot_type=="3dsurface"){
      ThreeDSurface threeDSurface = new ThreeDSurface(plot_data);
      threeShow.addObject(threeDSurface);
      //d3_object_save = threeDSurface; //.geometry; //.clone(); // new ThreeDSurface(); //
    }
    
    //threeShow.addObject(d3_object_save);    
    THREEx.WindowResize(threeShow.renderer, threeShow.camera);
    threeShow.run();      
  }  
  
  void embed_share_plot(){
    this.EMBED_SHARED_DIALOG = true; 
    $['dialog'].toggle(); 
  }
  
  
  void generate_embed_link(){
    
    String content = this.plot_data; 
    
    var rng = new Random();
    String color = rng.nextDouble().toStringAsFixed(16).substring(2, 8);     
    DateTime now = new DateTime.now();
    // now.toString();  
    String llllink = now.toString()+color+".html";     
    this.share_link = "http://0.0.0.0:8000/d3surface-plot/"+llllink;     
    this.email_content = "mailto:name1@rapidtables.com?subject=The%20subject%20of%20the%20email&body=" + this.share_link ; 
    var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");      
    ws_read_db.onOpen.listen((event){
        ws_read_db.send(JSON.encode({"CMD":"write-d3surface-plot", "figure":content, "filename":llllink}));
      //  ws_read_db.close(); 
    }); // end of  ws_write_db.onOpen.listen((event){
    //ws_read_db.onMessage.listen((event){
       
    //}); 
  }
  
  void embed_share_cancel(){
    this.EMBED_SHARED_DIALOG = false; 
    $['dialog'].toggle(); 
  }
  
  
  
}



class MarchingCube_Setting extends Object with Observable{
  List <List <double>> inpout_data;
  @observable num x_min, x_max, y_min, y_max, z_min, z_max;
  @observable int num_of_step = 25;
  @observable num isovalue = 0.0;
  @observable List <double> value_list;
  @observable bool value_list_calculated = false; 
  
  MarchingCube_Setting.init(dynamic _plot_data_){
    this.inpout_data = _plot_data_;     
  }
  
  MarchingCube_Setting.empty(){   }  
  
  dynamic toJson() => { "value_list":this.value_list, "num_of_step":this.num_of_step, "isovalue":this.isovalue, 
      "range":{"x_min":this.x_min, "x_max":this.x_max, "y_min":this.y_min, "y_max":this.y_max,
        "z_min":this.z_min, "z_max":this.z_max}};
  
  MarchingCube_Setting.json_init(String input){
    var inp = JSON.decode(input);
    this.x_min = inp["range"]['x_min'];
    this.x_max = inp["range"]["x_max"];
    this.y_min = inp["range"]["y_min"];
    this.y_max = inp["range"]["y_max"];
    this.z_min = inp["range"]["z_min"];
    this.z_max = inp["range"]["z_max"];
    this.num_of_step = inp['num_of_step'];
    this.value_list = inp['value_list'];
    this.isovalue = inp['isovalue'];    
    this.value_list_calculated = true; 
  }
  
}



class MarchingCube{
  // objects will be added into scene
  List<Object3D> objects = new List<Object3D>();
  // Light
  Light light;
  // mesh
  Mesh mesh;
  // data about
  List<Vector3> points = [];
  List<double> values = [];
  int size;  
  List <List <double>> inpout_data;
  num x_min, x_max, y_min, y_max, z_min, z_max;
  int num_of_step = 25;
  num isovalue = 0.0;
  List <double> value_list;  

  Vector3 selfVectorLerp(Vector3 x1, Vector3 x2, double alpha){
    var r = x1.clone();
    r.x += ( x2.x - r.x ) * alpha;
    r.y += ( x2.y - r.y ) * alpha;
    r.z += ( x2.z - r.z ) * alpha;
    return r;
  }
  
  
  
  void render_marching_cube(){
// Light
 light = new PointLight(0xffffff);
 light.position.setValues(0.0, 10.0, 100.0);

 objects.add(new MyAxisHelper());

 // number of cubes along a side
 size = this.num_of_step;
 
 double scale = 10.0;
 values = this.value_list; 
 
 //print(values[0]); 
 
 for (var k = 0; k < size; k++)
   for (var j = 0; j < size; j++)
     for (var i = 0; i < size; i++)
     {
       double x = scale*(this.x_min + (this.x_max-this.x_min) * i / (size - 1));
       double y = scale*(this.y_min + (this.y_max-this.y_min) * j / (size - 1));
       double z = scale*(this.z_min + (this.z_max-this.z_min) * k / (size - 1));
       points.add( new Vector3(x,y,z) );          
     }  

 // Marching Cubes Algorithm
 var size2 = size * size;
 // Vertices may occur along edges of cube, when the values at the edge's endpoints
 // straddle the isolevel value.
 // Actual position along edge weighted according to function values.
 var vlist = new List(12);

 var geometry = new Geometry();
 var vertexIndex = 0;

 for (var z = 0; z < size - 1; z++)
   for (var y = 0; y < size - 1; y++)
     for (var x = 0; x < size - 1; x++)
     {
       // index of base point, and also adjacent points on cube
       var p    = x + size * y + size2 * z,
           px   = p   + 1,
           py   = p   + size,
           pxy  = py  + 1,
           pz   = p   + size2,
           pxz  = px  + size2,
           pyz  = py  + size2,
           pxyz = pxy + size2;

       // store scalar values corresponding to vertices
       var value0 = values[ p    ],
           value1 = values[ px   ],
           value2 = values[ py   ],
           value3 = values[ pxy  ],
           value4 = values[ pz   ],
           value5 = values[ pxz  ],
           value6 = values[ pyz  ],
           value7 = values[ pxyz ];

       // place a "1" in bit positions corresponding to vertices whose
       //   isovalue is less than given constant.

       num isolevel = this.isovalue;

       int cubeindex = 0;
       if ( value0 < isolevel ) cubeindex |= 1;
       if ( value1 < isolevel ) cubeindex |= 2;
       if ( value2 < isolevel ) cubeindex |= 8;
       if ( value3 < isolevel ) cubeindex |= 4;
       if ( value4 < isolevel ) cubeindex |= 16;
       if ( value5 < isolevel ) cubeindex |= 32;
       if ( value6 < isolevel ) cubeindex |= 128;
       if ( value7 < isolevel ) cubeindex |= 64;

       // bits = 12 bit number, indicates which edges are crossed by the isosurface
       int bits = edgeTable[ cubeindex ];

       // if none are crossed, proceed to next iteration
       if ( bits == 0 ) continue;

       // check which edges are crossed, and estimate the point location
       //    using a weighted average of scalar values at edge endpoints.
       // store the vertex in an array for use later.
       double mu = 0.5;

       // bottom of the cube
       if ( bits & 1 != 0 )
       {
         mu = ( isolevel - value0 ) / ( value1 - value0 );
         vlist[0] = selfVectorLerp( points[p], points[px], mu );
       }
       if ( bits & 2 != 0 )
       {
         mu = ( isolevel - value1 ) / ( value3 - value1 );
         vlist[1] = selfVectorLerp( points[px], points[pxy], mu );
       }
       if ( bits & 4 != 0 )
       {
         mu = ( isolevel - value2 ) / ( value3 - value2 );
         vlist[2] = selfVectorLerp( points[py], points[pxy], mu );
       }
       if ( bits & 8 != 0 )
       {
         mu = ( isolevel - value0 ) / ( value2 - value0 );
         vlist[3] = selfVectorLerp( points[p], points[py], mu );
       }
       // top of the cube
       if ( bits & 16 != 0)
       {
         mu = ( isolevel - value4 ) / ( value5 - value4 );
         vlist[4] = selfVectorLerp( points[pz], points[pxz], mu );
       }
       if ( bits & 32 != 0 )
       {
         mu = ( isolevel - value5 ) / ( value7 - value5 );
         vlist[5] = selfVectorLerp( points[pxz], points[pxyz], mu );
       }
       if ( bits & 64 != 0 )
       {
         mu = ( isolevel - value6 ) / ( value7 - value6 );
         vlist[6] = selfVectorLerp( points[pyz], points[pxyz], mu );
       }
       if ( bits & 128 != 0 )
       {
         mu = ( isolevel - value4 ) / ( value6 - value4 );
         vlist[7] = selfVectorLerp( points[pz], points[pyz], mu );
       }
       // vertical lines of the cube
       if ( bits & 256 != 0 )
       {
         mu = ( isolevel - value0 ) / ( value4 - value0 );
         vlist[8] = selfVectorLerp( points[p], points[pz], mu );
       }
       if ( bits & 512 != 0 )
       {
         mu = ( isolevel - value1 ) / ( value5 - value1 );
         vlist[9] = selfVectorLerp( points[px], points[pxz], mu );
       }
       if ( bits & 1024 != 0 )
       {
         mu = ( isolevel - value3 ) / ( value7 - value3 );
         vlist[10] = selfVectorLerp( points[pxy], points[pxyz], mu );
       }
       if ( bits & 2048 != 0 )
       {
         mu = ( isolevel - value2 ) / ( value6 - value2 );
         vlist[11] = selfVectorLerp( points[py], points[pyz], mu );
       }

       // construct triangles -- get correct vertices from triTable.
       var i = 0;
       cubeindex <<= 4;  // multiply by 16...
       // "Re-purpose cubeindex into an offset into triTable."
       //  since each row really isn't a row.

       // the while loop should run at most 5 times,
       //   since the 16th entry in each row is a -1.
       while ( triTable[ cubeindex + i ] != -1 )
       {
         var index1 = triTable[cubeindex + i];
         var index2 = triTable[cubeindex + i + 1];
         var index3 = triTable[cubeindex + i + 2];

         geometry.vertices.add( vlist[index1].clone());
         geometry.vertices.add( vlist[index2].clone());
         geometry.vertices.add( vlist[index3].clone());

         var face = new Face3(vertexIndex, vertexIndex+1, vertexIndex+2);
         geometry.faces.add( face );

         geometry.faceVertexUvs[ 0 ].add( [ new Vector2(0.0, 0.0),
                                            new Vector2(0.0, 1.0),
                                            new Vector2(1.0, 1.0) ] );

         vertexIndex += 3;
         i += 3;
       }
     }           // end of for   for (var x = 0; x < size - 1; x++)

 geometry.computeCentroids();
 geometry.computeFaceNormals();
 geometry.computeVertexNormals();

 var colorMaterial = new MeshPhongMaterial(color: 0x00ff00, shininess:100, side: DoubleSide); // new MeshLambertMaterial( color: 0x0000ff, side: DoubleSide );
 mesh = new Mesh( geometry, colorMaterial );

 objects.add( light );
 objects.add( mesh );
 
 var ambientLight = new AmbientLight(0x0000ff);
 objects.add(ambientLight);
 
 //querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.
 
 D3SurfaceElement d3surface = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("d3surface-element");
 d3surface.threeShow.addObject2(objects); 
  }
  
  /*
  List<Object3D> clone(){
    
  }*/

  MarchingCube(dynamic _plot_data_){    
    if(!(_plot_data_ is MarchingCube_Setting)){    
    this.inpout_data = _plot_data_; 
    //MarchingCube_Setting plot_data = new MarchingCube_Setting(_plot_data_);     
    for(num i=0; i<_plot_data_.length; i++){
           double temp_x = _plot_data_[i][0]; //.toDouble(); 
           double temp_y = _plot_data_[i][1]; //.toDouble(); 
           double temp_z = _plot_data_[i][2]; //.toDouble(); 
//          sites_.add({"x":temp_x, "y":temp_y});
           if(i==0){
             this.x_min = temp_x;
             this.x_max = temp_x;
             this.y_min = temp_y;
             this.y_max = temp_y;
             this.z_min = temp_z;
             this.z_max = temp_z;
           }
           if(i>0){
             if(this.x_min > temp_x) this.x_min = temp_x;
             if(this.x_max < temp_x) this.x_max = temp_x;
             if(this.y_min > temp_y) this.y_min = temp_y;
             if(this.y_max < temp_y) this.y_max = temp_y;
             if(this.z_min > temp_z) this.z_min = temp_z;
             if(this.z_max < temp_z) this.z_max = temp_z;
           }
         }  //end of for(num i=0; i<num_of_row; i++){         
        //print(this.x_min); print(this.x_max); print(this.y_min); print(this.y_max); print(this.z_min); print(this.z_max);         
        var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");           
          ws_read_db.onOpen.listen((event){
              ws_read_db.send(JSON.encode({"CMD":"interpolation_marching_cube", "input_data":this.inpout_data, "num_of_step":this.num_of_step,
                "range":{"x_min":this.x_min, "x_max":this.x_max, "y_min":this.y_min, "y_max":this.y_max, "z_min":this.z_min, "z_max":this.z_max}}));
          });                     
          ws_read_db.onMessage.listen((event){
            var data = JSON.decode(event.data);   
            if(data["MSG"]=="interpolation_marching_cube_output"){
              this.value_list = data["output"]; 
              //print(this.value_list[0]);                      
           //print(this.value_list.length);     
    this.render_marching_cube();     
    print("init A"); 
    LayoutElement layout = document.querySelector("folder-element").shadowRoot.querySelector("layout-element");    
    MarchingCube_Setting marchingcube_setting = new MarchingCube_Setting.empty();
    marchingcube_setting
    ..x_min = this.x_min
    ..x_max = this.x_max
    ..y_min = this.y_min
    ..y_max = this.y_max
    ..z_min = this.z_min
    ..z_max = this.z_max
    ..num_of_step = this.num_of_step
    ..value_list = this.value_list
    ..value_list_calculated = true
    ..isovalue = this.isovalue
    ..inpout_data = this.inpout_data;        
    layout.d3surface_temp.plot_data = marchingcube_setting; 
                } // end of if(data["MSG"]=="interpolation_marching_cube_output"){    
          });      // end of   ws_read_db.onMessage.listen((event){    
    }  //end of if(!(_plot_data_ is MarchingCube_Setting)){
    
   
    if(_plot_data_ is MarchingCube_Setting){
      if(_plot_data_.value_list_calculated==true){        
        this.x_min = _plot_data_.x_min;
        this.x_max = _plot_data_.x_max;
        this.y_min = _plot_data_.y_min;
        this.y_max = _plot_data_.y_max;
        this.z_min = _plot_data_.z_min;
        this.z_max = _plot_data_.z_max;
        this.num_of_step = _plot_data_.num_of_step;
        this.value_list = _plot_data_.value_list;
        this.isovalue = _plot_data_.isovalue;        
        this.render_marching_cube();     
        print("init B");         
      }      
    }    
  }   // end of  MarchingCube(dynamic _plot_data_){ 
  
}


class ThreeDSurface_Setting extends Object with Observable{  
  
}


class ThreeDSurface{
  // objects will be added into scene
  List<Object3D> objects = new List<Object3D>();
  // Light
  Light light;
 // Light light2;
  // mesh
  Mesh mesh;  
  var geometry = new Geometry();    
  
  ThreeDSurface(dynamic plot_data){
    
    light = new PointLight(0xffffff);
    light.position.setValues(1000.0, 1000.0, 1000.0);
  //  light2 = new PointLight(0xffffff);
  //  light2.position.setValues(0.0, 00.0, -1000.0);       
    objects.add(new MyAxisHelper());        
    
        List <List <double>> p = []; //= [[0, 0], [0, 1], [1, 0], [1, 1], [2, 0], [2, 1], [0, 2], [1, 2], [2, 2]];   
        List <List <double>> q = []; 
     /*   
        int size = 20;         
        for(int i=0; i<size; i++){
          for(int j=0; j<size; j++){
            p.add([(i-10).toDouble()*20.0, (j-10).toDouble()*20.0, (i-10).toDouble()*(i-10).toDouble()+(j-10).toDouble()*(j-10).toDouble()]); 
            q.add([(i-10).toDouble()*20.0, (j-10).toDouble()*20.0]); 
          }
        }   */
        
        for(var data in plot_data){
          p.add([data[0], data[1], data[2]]);
          q.add([data[0], data[1]]); 
        }       
        
        var jsArray = new JsObject.jsify(q); 
        var s = context["Delaunay"].callMethod('triangulate', [jsArray]);
        double scale_x = 10.0;
        double scale_y = 10.0;
        double scale_z = 1.0;

        var vertexIndex = 0;        
        for(int i=0; i<(s.length)/3; i++){
           Vector3 v1 = new Vector3(p[s[3*i]][0]*scale_x, p[s[3*i]][1]*scale_y, p[s[3*i]][2]*scale_z);
           Vector3 v2 = new Vector3(p[s[3*i+1]][0]*scale_x, p[s[3*i+1]][1]*scale_y, p[s[3*i+1]][2]*scale_z);
           Vector3 v3 = new Vector3(p[s[3*i+2]][0]*scale_x, p[s[3*i+2]][1]*scale_y, p[s[3*i+2]][2]*scale_z);                            
        //   double _color_ = (p[s[3*i]][2]*scale + p[s[3*i+1]][2]*scale + p[s[3*i+2]][2]*scale);
      //     print(_color_);
      //     threed_surf_plt.triangle_list.add(new Triangle_Def(new Number3(v1, v2, v3), _color_));
           geometry.vertices.add(v1);
           geometry.vertices.add(v2);
           geometry.vertices.add(v3);
           var face = new Face3(vertexIndex, vertexIndex+1, vertexIndex+2);
           geometry.faces.add( face );
           vertexIndex += 3;                       
        }          
        
        geometry.computeCentroids();
        geometry.computeFaceNormals();
        geometry.computeVertexNormals();
        
        var colorMaterial = new MeshPhongMaterial(color: 0x00ff00, shininess:100, side: DoubleSide); // new MeshLambertMaterial( color: 0x0000ff, side: DoubleSide );
        mesh = new Mesh( geometry, colorMaterial );
        objects.add( light );
     //   objects.add( light2 );
        objects.add( mesh );
        
        var ambientLight = new AmbientLight(0x0000ff);
        objects.add(ambientLight);
        
      }     
}



class MyAxisHelper extends Object3D {
  MyAxisHelper() {
    var lineGeometry = new Geometry();
    lineGeometry.vertices.add( new Vector3.zero() );
    lineGeometry.vertices.add( new Vector3( 0.0, 100.0, 0.0 ) );

    var coneGeometry = new CylinderGeometry( 0.0, 0.5, 5.0, 4, 1, false);

    var line, cone;

    // x

    line = new Line( lineGeometry, new LineBasicMaterial( color: 0xff0000 ) );
    line.rotation.z = - 3.14159265358 / 2.0;
    this.add( line );

    cone = new Mesh( coneGeometry, new MeshBasicMaterial( color: 0xff0000 ) );
    cone.position.x = 100.0;
    cone.rotation.z = - 3.14159265358 / 2.0;
    this.add( cone );

    // y

    line = new Line( lineGeometry, new LineBasicMaterial( color: 0x00ff00 ) );
    this.add( line );

    cone = new Mesh( coneGeometry, new MeshBasicMaterial( color: 0x00ff00 ) );
    cone.position.y = 100.0;
    this.add( cone );

    // z

    line = new Line( lineGeometry, new LineBasicMaterial( color: 0x0000ff ) );
    line.rotation.x =   3.14159265358 / 2.0;
    this.add( line );

    cone = new Mesh( coneGeometry, new MeshBasicMaterial( color: 0x0000ff ) );
    cone.position.z = 100.0;
    cone.rotation.x =   3.14159265358 / 2.0;
    this.add( cone );
  }
}




 /*
 MarchingCube_Setting(dynamic _plot_data_){
   
   this.inpout_data = _plot_data_; 
   
   for(num i=0; i<_plot_data_.length; i++){
      double temp_x = _plot_data_[i][0]; //.toDouble(); 
      double temp_y = _plot_data_[i][1]; //.toDouble(); 
      double temp_z = _plot_data_[i][2]; //.toDouble(); 
//          sites_.add({"x":temp_x, "y":temp_y});
      if(i==0){
        this.x_min = temp_x;
        this.x_max = temp_x;
        this.y_min = temp_y;
        this.y_max = temp_y;
        this.z_min = temp_z;
        this.z_max = temp_z;
      }
      if(i>0){
        if(this.x_min > temp_x) this.x_min = temp_x;
        if(this.x_max < temp_x) this.x_max = temp_x;
        if(this.y_min > temp_y) this.y_min = temp_y;
        if(this.y_max < temp_y) this.y_max = temp_y;
        if(this.z_min > temp_z) this.z_min = temp_z;
        if(this.z_max < temp_z) this.z_max = temp_z;
      }
    }  //end of for(num i=0; i<num_of_row; i++){ 
   
   print(this.x_min); print(this.x_max); print(this.y_min); print(this.y_max); print(this.z_min); print(this.z_max); 
   
   var ws_read_db = new WebSocket("ws://"+host+":"+port.toString()+"/ws");   
   
     ws_read_db.onOpen.listen((event){
         ws_read_db.send(JSON.encode({"CMD":"interpolation_marching_cube", "input_data":this.inpout_data, "num_of_step":this.num_of_step,
           "range":{"x_min":this.x_min, "x_max":this.x_max, "y_min":this.y_min, "y_max":this.y_max, "z_min":this.z_min, "z_max":this.z_max}}));
     });           
     
     ws_read_db.onMessage.listen((event){
       var data = JSON.decode(event.data);   
       if(data["MSG"]=="interpolation_marching_cube_output"){
         this.value_list = data["output"]; 
         print(this.value_list);          
       }
     });    
   
 }*/



