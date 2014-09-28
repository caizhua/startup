import 'dart:html';
import 'dart:convert';
import 'dart:js';
import 'dart:math';


void main(){
  
//  var p = new JsObject(context["jStat"]);  
  
  List ymat = [1,2,3,4,5,6,7,8]; 
  
  var y = new JsObject.jsify(ymat);
  
  var z = context["jStat"].callMethod("product", [y]);  
  
  print(z);
  
}
  
  /*
  
  List <double> ymat = [];
  List <List<double>> xmat = [];
  List <double> cmat = [];
  
  List <double> temp_x = [];
  
  var rng = new Random();
  
  int k = 4, N=1000; 
  
  for(int i=0; i<N; i++){
    double xx = rng.nextDouble()*100.0;
    temp_x.add(xx);
    ymat.add((3.0+rng.nextDouble()*0.1)*xx*xx+20.0*xx-12.0+rng.nextDouble());     
  }
  

  
  for(int i=0; i<N; i++){
    List <double> t_xmat = [];
    
    for(int j=0; j<k; j++){
      t_xmat.add(pow(temp_x[i], j));       
    }
    xmat.add(t_xmat);
  }
  
//  print(ymat);
//  print(xmat);
  
  
  var y = new JsObject.jsify(ymat);
  var x = new JsObject.jsify(xmat);
 // var c = new JsObject.jsify(cmat);
  
  
  var p = new JsObject(context["mathjs"]);  
  var xt = p.callMethod("transpose", [x]);  
  var ymul = p.callMethod("multiply", [xt, y]);  
  var xmul = p.callMethod("multiply", [xt, x]);  
  var xmul_inv = p.callMethod("inv", [xmul]);  
  var out = p.callMethod("multiply", [xmul_inv, ymul]);  
  print(out); 
  
 // var p = context['numeric'];
  
 // print(p);
  
 // var out = p.callMethod("inv", [x]);
  
 // print(out);
  
  
}  */
  
//  var data = new JsObject(context['ComplexArray'], [128]);
 /* 
  var p = new JsObject(context['FFT']["complex"], [20, false]);
  var inv_p = new JsObject(context['FFT']["complex"], [20, true]);
  
 // var x = p.callMethod("complex", [256, false]);
  
  List <double> inp = [];
  List <double> out = [];
  List <double> inv = [];
  
 // inp = [0.5785012864412081, 0.0007835923093592045, 0.3632060151900366, 0.2869503842527329, 0.1948500886817257, 0.07431210910444619, 0.11040538936331912, 0.4321133570165381, 0.8300855722785572, 0.9915455543571802, 0.5382178215802987, 0.649819151117232, 0.0007402583388982364, 0.8194696878330099, 0.7751348865961579, 0.4198580610744267, 0.09409652462688534, 0.4991724472518603, 0.8633325701421244, 0.45004599517826693, 0.6303165527427468, 0.25690182584325616, 0.6885168662034087, 0.583794003739216, 0.6566343738794171, 0.6001393959818456, 0.7235830480618506, 0.13535460674332345, 0.8082820032403936, 0.07617006291221107, 0.0050380230712653296, 0.06307630175343026, 0.48469554089168365, 0.42478806637263056, 0.01113221787598817, 0.4892351688170893, 0.8653541961381787, 0.6925949866482223, 0.3909332442584681];
  
  var rng = new Random();
  
  
  for (var j = 0; j < 40; j++) {
    inp.add(rng.nextDouble());
    
   /* if(j<256/3 || j>512/3){
      inp.add(0.0);
    }
    if(j>256/3 && j<512/3){
      inp.add(1.0);
    }
    
    //inp.add(sin(j/20.0));
    //out.add(2.0); */
  }
  
  
  var iii = new JsObject.jsify(inp);
  var ooo = new JsObject.jsify(out);
  var inv_ = new JsObject.jsify(inv);
  
  p.callMethod("process", [ooo, 0, 1, iii, 0,  1]);
  
  inv_p.callMethod("process", [inv_, 0, 1, ooo, 0,  1]);
  
  print(inp);
  print(inv_);
  print(ooo);
  
//  print(ooo);
//  for (var j = 0; j < 256; j++) {
 //   print(inv_[j]/128-iii[j]);
//  }
  
  
//  print(p);
  
 
} */
  
  /*
  print("hello~");
   
  var point = new JsObject(context['Voronoi'], []);
  
  var bbox = new JsObject.jsify({"xl":0,"xr":750,"yt":0,"yb":550});
  
 /* List <Map> sites_ = [];
  
  for(int i=100; i<800; i+=100){
    for(int j=100; j<600; j+=100){
      sites_.add({"x":i.toString(), "y":j.toString()});
     }    
  }
  
  for(var p in sites_){
    print(p);
  } */
  
 // print(sites_);
  
//  var sites = new JsObject.jsify(sites_);
  var sites = new JsObject.jsify([{"x":200, "y":200}, {"x":50, "y":250}, {"x":400, "y":100}, {"x":250, "y":200}, {"x":150, "y":250}, {"x":300, "y":100},
                                  {"x":230, "y":230}, {"x":30, "y":230}, {"x":430, "y":100}, {"x":250, "y":230}, {"x":130, "y":250}, {"x":330, "y":130}]);
  
  var s = point.callMethod("compute", [sites, bbox]);
  
/*  for(var ss in s["vertices"]){
    print(ss["x"]);
    print(ss["y"]);
    print("   ");
  } */
  
  for(var ss in s["cells"]){
    print(ss["site"]["x"]);
    print(ss["site"]["y"]);
  //  print("\n");
    print("ssssssssssss");
    for(var sss in ss["halfedges"]){
       print(sss["edge"]["va"]["x"]);
       print(sss["edge"]["va"]["y"]);
       print(sss["edge"]["vb"]["x"]);
       print(sss["edge"]["vb"]["y"]);
    }    
    print("         ");
  }
  
//  print(s["cells"][0]["halfedges"][0]["site"]["x"]);
  
}
  */
  
 /* var x_data = new JsObject.jsify([ 0, 
                                        0.15789473684210525,
                                        0.3157894736842105,
                                        0.47368421052631576,
                                        0.631578947368421,
                                        0.7894736842105263,
                                        0.9473684210526315,
                                        1.105263157894737,
                                        1.263157894736842,
                                        1.4210526315789473,
                                        1.5789473684210527,
                                        1.736842105263158,
                                        1.894736842105263,
                                        2.0526315789473686,
                                        2.210526315789474,
                                        2.3684210526315788,
                                        2.526315789473684,
                                        2.6842105263157894,
                                        2.8421052631578947,
                                        3 ]);
  
  
  var y_data = new JsObject.jsify([ 1.0002985068550334,
                                        1.1991209649546175,
                                        1.374484912121682,
                                        1.6154745607356928,
                                        1.906596335724064,
                                        2.207162226871451,
                                        2.598972401623328,
                                        3.034699168961219,
                                        3.5530256843951924,
                                        4.147938920817996,
                                        4.8643443810916995,
                                        5.689041586947037,
                                        6.660060894465113,
                                        7.794753678869465,
                                        9.139864949875651,
                                        10.689472910245389,
                                        12.523331607034068,
                                        14.6658369817028,
                                        17.15930601985515,
                                        20.10561072637129 ]);


  var point = new JsObject(context['LSQ'], []);
  
  var p =  point.callMethod('LeastSq', ["exp(c*x)", x_data, y_data, 1.5]);
  
 print(p);
  */
//  var jsArray = new JsObject.jsify([[0, 0], [0, 1], [1, 0], [1, 1]]); 
  
 // var s = context["Delaunay"].callMethod('triangulate', [jsArray]);
  
 // print(s);
  
  
/*  var obj = new JsObject(context["mathjs"]);
  
  var scope = new JsObject.jsify({     'a': 3,    'b': 4   });
  
  print(obj.callMethod('eval', ['a=3; b=4; a + b \n a * b', scope])); 
  
  // These are correct codes !!!!!!!!!!!!!   */
  
  
 /* var obj = new JsObject(context["mathjs"]);
  
  var s = obj.callMethod('compile', ['_{a * b']);
  
  var scope = new JsObject.jsify({     '<a>': 3,    'b': 4   });
  
  print(s.callMethod('eval', [scope])); */
  
 // var code1 = new JsObject(context["mathjs"]);
  
//  print(code1.callMethod('eval', ['sqrt(3^2 + 4^2)']));
  
  
  //var s = obj.callMethod('eval', ['a=3; b=4; a + b \n a * b']);
  
//  var s = obj.callMethod('compile', ['a * b']);
  
//  print(obj.callMethod('eval', [s, scope]));
  
//  print(s);
  
 // print(obj.callMethod('eval', ['sin(pi / 4)']));
