library ThreeShow;

import 'dart:html';
import 'package:three/three.dart';
import 'package:three/extras/controls/trackball_controls.dart';
//import 'package:three/extras/scene_utils.dart';
//import 'package:polymer/polymer.dart';
//import 'dart:html';

class THREEX{
  WindowResize(Renderer renderer, PerspectiveCamera camera) {
    callback(Event e){
      // notify the renderer of th size change
      renderer.setSize( window.innerWidth, window.innerHeight);
      // update the camera
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
    }

    window.onResize.listen(callback);
  }
}


class ThreeShow{
  // standard variables
  Element  container;
  PerspectiveCamera   camera;
  Scene    scene;
  Renderer renderer;
  var controls;    

  // custom variables
  double VIEW_ANGLE, ASPECT, NEAR, FAR;

  ThreeShow(){
    VIEW_ANGLE = 45.0;
    ASPECT = window.innerWidth / window.innerHeight;
    NEAR = 0.1;
    FAR = 20000.0;
    // specify the container
    //container = document.querySelector("d3surface-element").shadowRoot.querySelector('#ThreeJS');
    //print(document.querySelector("folder-element").shadowRoot.querySelector("layout-element"));
   // print(document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("d3surface-element"));
    
    this.container = document.querySelector("folder-element").shadowRoot.querySelector("layout-element").shadowRoot.querySelector("d3surface-element").shadowRoot.querySelector('#ThreeJS');  
    // create the renderer
    renderer = new WebGLRenderer(antialias: true);
    renderer.setSize( window.innerWidth, window.innerHeight );
    container.append(renderer.domElement);

    // create the scene
    scene = new Scene();

    // put a camera in the scene
    camera = new PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR );
    camera.position.setValues(200.0, 200.0, 600.0);
    camera.lookAt(scene.position);
    scene.add(camera);

    // create a camera contol
    controls  = new TrackballControls( camera, renderer.domElement ); 
  }

  void addObject(var object){  //  
    if( object.objects != null )
    {
      for(Object3D ob in object.objects){
        scene.add(ob);   // cloneObject(
      }
    }
  }
  
  
  void addObject2(var objects){  //  
    if( objects != null )
    {
      for(Object3D ob in objects){
        scene.add(ob);   // cloneObject(
      }
    }
  }
  
  

  void run()
  {
    animate(30);
  }

  void update(){
    controls.update();
  }

  void render(){
    renderer.render(scene, camera);
  }

  void animate(time) {
    window.requestAnimationFrame( animate );
    render();
    update();
  }
}
