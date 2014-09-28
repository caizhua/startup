library tableinstrument;
import 'package:polymer/polymer.dart';
import '../table_element.dart';
import 'dart:html';

@CustomTag('table-instrument')
class Table_Instrument extends Table_Element {
  
  
  Table_Instrument.created() : super.created() { }
  
  void menu_mpms_mtmh(){
    DROP_MENU_SHOW = false; 
  //  window.alert("to be implemented soon!");
  }
  
  void menu_ppms_rhot(){
    DROP_MENU_SHOW = false; 
   // window.alert("to be implemented soon!");
  }
  
  void menu_ppms_cpt(){
    DROP_MENU_SHOW = false; 
  //  window.alert("to be implemented soon!");
  }
  
}
