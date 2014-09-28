library folder;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import './layout.dart';

String host = 'localhost';
int port = 8084;


class share_doc extends Object with Observable{
  @observable String share_author;
  @observable String previllage;
  @observable String color;
  share_doc(this.share_author, this.previllage, this.color);
  dynamic toJson() => {"share_author":this.share_author, "privilege": this.previllage, "color":this.color}; 
}

class Num2 <T> {
  T x;
  T y;
  Num2(this.x, this.y);
}

class DataProj extends Object with Observable{
  String parent = null;
  @observable String object_id;
  @observable String object_name;
  String creater;
  String created_time;
  String modified_time;
  String type;
  List <share_doc> share_list = toObservable([]);
  @observable bool edit_status = false;
  @observable String current_editor; 
  @observable Num2 <int> translate;
  @observable bool read_only = false; 
  
  DataProj(this.parent, this.object_id, this.object_name, this.creater, this.created_time,
      this.modified_time, this.type, this.share_list, this.translate, this.edit_status, this.current_editor, this.read_only);
  dynamic toJson() => {"parent":this.parent, "file_id":this.object_id, "file_name":this.object_name, "creater":this.creater, "created_time":this.created_time, 
    "modified_time":this.modified_time, "type":this.type, "share_list":this.share_list, "edit_status":this.edit_status, "current_editor":this.current_editor};
}

class Show_Menu extends Object with Observable{
  @observable bool click_menu_show = false;
  @observable Num2 <int> menu_pos;
  @observable String target_id;
  Show_Menu(this.click_menu_show, this.menu_pos, this.target_id);
}


class Send_Message extends Object with Observable{
  @observable String sender;
  @observable String receiver;
  @observable String msg_type;
  @observable String addition_msg;
  @observable bool SHOW_MSG_DIALOG = false; 
  Send_Message(this.SHOW_MSG_DIALOG, this.sender, this.receiver, this.msg_type, this.addition_msg);
}



@CustomTag('folder-element')
class DataProjElement extends PolymerElement {
  List <DataProj> dataproj_list = toObservable([]);    
  @published bool login = false;
  @observable bool show_register = false;
  @published String username;
  @published bool is_username_fixed = false; 
  @published String custom_tag;   
  
  @observable String password;
  @observable String File_content;
  @observable String user_existed;
  @observable String login_failed;   
  @observable bool show_new_dataproj = false;
  @observable bool show_selected_dataproj = false;
  @observable int dataproj_count;  
  @observable DataProj new_dataproj;  
  WebSocket ws;
  @observable Show_Menu menu_show;
  @observable int active_dataproj = 0; 
  @observable Send_Message send_msg;
  @observable List <Send_Message> receiv_msg = toObservable([]);    
  
//  @observable String addition_msg; 
  @observable bool SHOW_MSG_RECEIVED = false; 
  @observable bool SHOW_USER_FORUM = false; 
  @observable bool SHOW_FILE_MANAGE = false; 
  @observable int active_dp = 0; 
  @observable int active_subfile = 0; 
  List <FileX> sub_file_list = toObservable([]);
 // @observable bool selected_proj_readonly = false; 
  

  DataProjElement.created() : super.created() {
    
 //   dataproj_list = toObservable([]);    
    
    
    ws = new WebSocket("ws://"+host+":"+port.toString()+"/ws"); 
    menu_show = new Show_Menu(false, null, null);
    send_msg = new Send_Message(false, username, null, null, "");
  //  receiv_msg = new Send_Message(false, username, null, null, "");
    
    if(login==true){
      ws.onOpen.listen((event){
        ws.send(JSON.encode({"CMD":"login-auth-passport", "data":{"username":username}, "proj_type":"data_proj"}));   
      }); 
    }
    
        
   ws.onMessage.listen((event){
     
   //   print(event.data);
      var data = JSON.decode(event.data);
      if(data["MSG"]=="user_already_existed"){
        user_existed = "User name already existed, please choose another one!";
      }
      if(data["MSG"]=="login_failed"){
        login_failed = "Login failed, check your username and password!";
      }
      if(data["MSG"]=="login_success"){
        dataproj_count = data["dataproj_count"];
        login = true;
    //    print(dataproj_count);
        /*
        Timer.run((){
          $["container"].onClick.listen((event){ 
            print(event.target.id);
            print(event.target); 
          }); 
        }); */


      }
      
      if(data["MSG"]=="new_user_success"){    
        
      }
      
      
      if(data["MSG"]=="subfile_list"){
              var p = data["data"];
              FileX temp_file = new FileX(p["file_id"],p["file_name"], p["parent"], p["creater"], p["created_time"], p["modified_time"], p["type"], null); //, 1.0);
              
           //   filecount += 1;
            //  temp_file.translate = new Num2<int>(0, filecount*40+240);    
              sub_file_list.add(temp_file);   
      }

      
      if(data["MSG"]=="dataproj_list"){
        if(data["data"]!=null){
          var temp = data["data"];
          //var temp = JSON.decode(data["data"]);
          int len_file = (dataproj_list.length);
          int x_len = (len_file+1)%8;
          int y_len = (len_file+1)~/8;
          List <share_doc> temp_list = toObservable([]);        
// (this.parent, this.object_id, this.object_name, this.creater, this.created_time, this.modified_time, this.type, this.share_list, this.translate);
          new_dataproj = new DataProj(temp["parent"],  temp["file_id"], temp["file_name"], temp["creater"], temp["created_time"], 
              temp["modified_time"],  temp["type"], temp_list, null, temp["edit_status"], temp["current_editor"], false);  
          new_dataproj.translate = new Num2<int>(x_len*150+20, y_len*150+20);
          for(var s in temp["share_list"]){
            new_dataproj.share_list.add(new share_doc(s["share_author"], s["privilege"], s["color"]));
          }
          if(new_dataproj.creater!=username){
            for(var s in new_dataproj.share_list){
              if(s.share_author==username && s.previllage=="read_only"){
                new_dataproj.read_only = true;
              }
            }
          }          
          
        dataproj_list.add(new_dataproj);     
    //    print(dataproj_list[0].toJson());
      }
      }
      
      if(data["MSG"]=="dataproj_edit_status"){
        for(var dp in dataproj_list){
          if(dp.object_id==data["file_id"]){
            dp.edit_status = data["edit_status"];
            dp.current_editor = data["current_editor"];
            if(dp.current_editor!=username){
              dp.read_only = true; 
            }
          }
        }        
      }
      
      if(data["MSG"]=="user-message-push"){
        receiv_msg.add(new Send_Message(true, data["data"]["sender"], data["data"]["receiver"], data["data"]["msg-type"], data["data"]["addition"]));  
        if(receiv_msg.length>0){
          SHOW_MSG_RECEIVED = true; 
        }
      }
      
    }); 
    
  }
  
  
  
  @override
  attached() {
    super.attached();
    
    
    new Timer.periodic(const Duration(seconds:10), (_){  
     ws.send(JSON.encode({"CMD":"check-edit-status", "username":username}));  
     ws.send(JSON.encode({"CMD":"check-user-message", "username":username}));  
     });     
    

    
    /*
    $['menu_class'].onClick.listen((event){ 
      menu_show.click_menu_show = false;
    }); 
    */
    
    
  //  document.onClick.listen((event){ 
      

    //  if(event.target.id=="group_menu"){
   //     menu_show.click_menu_show = true;
   //   }
      
      
   //   print(event.fromElement.nodeName); 
   //   print(event.target.toString()); 
   //   if(event.target.id!="group_menu" && event.target.id!="menu_class" && menu_show.click_menu_show==true){
   //     menu_show.click_menu_show = false;
   //   }

   // });    
  }  //end of enteredView 
  
  
  void login_auth(Event e, var detail, Element target){
    ws.send(JSON.encode({"CMD":"login-auth", "data":{"username":username, "password":password}, "proj_type":"data_proj"}));    
  }
  
  void show_register_(){
    show_register = true;
  }
  
  void clear_user_existed(){
    user_existed = " ";
  }
  
  void register_auth(Event e, var detail, Element target){
    ws.send(JSON.encode({"CMD":"register-auth", "data":{"username":username, "password":password}}));       
    show_register=false;
  }
  
  
  
  void add_shared_user(Event e, var detail, Element target){
    new_dataproj.share_list.add(new share_doc("iranyu", "read_only", "#de0dca"));
   }
   
  
   void delete_shared_user(Event e, var detail, Element target){
     int idx = JSON.decode(target.attributes['data-msg']);
     new_dataproj.share_list.removeAt(idx);   
   }
   
   
   
   void new_data_proj_(Event e, var detail, Element target){
 //    print("clicked");
     $['dialog'].toggle();
     show_new_dataproj = true;
     
     List <share_doc> temp_list = toObservable([]);
     String name = "File" + dataproj_count.toString();
     new_dataproj = new DataProj(null, null, name, username, null, null, "data_proj", temp_list, null, false, username, false);  
   }
   
   void new_dataproj_create(Event e, var detail, Element target){
     $['dialog'].toggle();    
     show_new_dataproj = false;
     
     DateTime now = new DateTime.now();
     new_dataproj.created_time = now.toString();
     new_dataproj.modified_time = now.toString();    

     new_dataproj.object_id = username + "File" + dataproj_count.toString();
     
     int len_file = (dataproj_list.length);
     int x_len = (len_file+1)%8;
     int y_len = (len_file+1)~/8;
     new_dataproj.translate = new Num2<int>(x_len*150+20, y_len*150+20);
     dataproj_list.add(new_dataproj);
     dataproj_count += 1;
     ws.send(JSON.encode({"CMD":"insert-file", "username":username, "data":new_dataproj}));

     active_dataproj = dataproj_count-1;      
     show_selected_dataproj=true;
     
   }
   
   void show_selected_dataproj_(Event e, var detail, Element target){
     show_selected_dataproj=true;       
     active_dataproj = JSON.decode(target.attributes['data-msg']);
     
     
   }
   
   
   void show_menu(Event e, var detail, Element target){
  //   click_menu_show= true;
     int idx = JSON.decode(target.attributes['data-msg']);
     menu_show.menu_pos = dataproj_list[idx].translate;     
     active_dataproj = idx;
     
 //    print(idx);
     menu_show.click_menu_show = true;
     
     new Timer(const Duration(seconds:2), hide_menu);
  //   menu_show.target_id = p["id"];
   }
   
   void hide_menu(){
     menu_show.click_menu_show = false; 
   }
   
   
   void new_dataproj_cancel(Event e, var detail, Element target){
     show_new_dataproj = false;
     $['dialog'].toggle();
   }
  
   
   void update_edit_status(String object_id, bool status){
     ws.send(JSON.encode({"CMD":"update-edit-status", "file":{"file_id":object_id}, "update":{"edit_status":status, "current_editor":username}}));     
   }
  
  /* 
  void check_edit_status(){
    
  }
  */
   
   void request_to_edit_dialog(){
     send_msg.SHOW_MSG_DIALOG = true;
     send_msg.sender = username;
     send_msg.receiver = dataproj_list[active_dataproj].current_editor;
     send_msg.msg_type = "MSG-request_to_edit";
     send_msg.addition_msg = "Can you exit editing " + dataproj_list[active_dataproj].object_name + " and let "+ send_msg.sender + " edit ? Thanks!";
   }
   
   void send_message_apply(){
     
     ws.send(JSON.encode({"CMD":"user-message", "MSG":{"sender":send_msg.sender, "receiver":send_msg.receiver,
       "msg-type":send_msg.msg_type, "addition":send_msg.addition_msg}}));     
     
     send_msg.SHOW_MSG_DIALOG = false; 
     $['dialog'].toggle();
   }
   
   void send_message_cancel(){
     $['dialog'].toggle();
     send_msg.SHOW_MSG_DIALOG = false; 
   }
   
   void receiv_message_accept(){  
     $['dialog'].toggle();
     if(receiv_msg.length==1){
       SHOW_MSG_RECEIVED = false; 
     }
     
     Timer.run((){
       receiv_msg.removeAt(0);     
     });     

   }
   
   void receiv_message_ignore(){
     $['dialog'].toggle();
     if(receiv_msg.length==1){
       SHOW_MSG_RECEIVED = false; 
     }
     
     Timer.run((){
       receiv_msg.removeAt(0);     
     });

   }
   
   void show_user_forum(){
     $['dialog'].toggle();
     SHOW_USER_FORUM = true; 
   }
   
   
   void hide_user_forum(){
     SHOW_USER_FORUM = false; 
     show_new_dataproj = false;
     send_msg.SHOW_MSG_DIALOG = false; 
     
   }
   
   
   void show_share_manage(){
     window.alert("To be implemented soon!");
   }
   
   void show_link_manage(){
     window.alert("To be implemented soon!");
   }
   
   void show_msg_center(){
     window.alert("To be implemented soon!");
   }
   
   void show_setting(){
     window.alert("To be implemented soon!");
   }
   
   void show_contact_us(){
     window.alert("To be implemented soon!");
   }
   
   void show_about(){
     window.alert("To be implemented soon!");
   }
   
   
   void show_file_manage(){
     SHOW_FILE_MANAGE = true; 
     active_dp = 0;
     $['dialog'].toggle();
     
     sub_file_list.clear();
     ws.send(JSON.encode({"CMD":"check-sub-file", "filter":{"parent":dataproj_list[active_dp].object_id}}));
     
   }
   
   void switch_data_proj(Event e, var detail, Element target){
     active_subfile = 0; 
     
     if(int.parse(target.attributes['data-msg'])!=active_dp){
       active_dp = int.parse(target.attributes['data-msg']);
       sub_file_list.clear();
       ws.send(JSON.encode({"CMD":"check-sub-file", "filter":{"parent":dataproj_list[active_dp].object_id}}));
     }       

   }
   
   void switch_sub_file(Event e, var detail, Element target){
     active_subfile = int.parse(target.attributes['data-msg']);     
   }
   
   
   void delete_data_proj(){     
     ws.send(JSON.encode({"CMD":"delete-file", "username":username, "filter":{"file_id":dataproj_list[active_dp].object_id}}));
     dataproj_list.removeAt(active_dp); 
     sub_file_list.clear();
     active_dp = 0; 
     active_subfile = 0; 
   }
   
   
   void delete_sub_file(Event e, var detail, Element target){
     
     int index = int.parse(target.attributes['data-msg']);
     ws.send(JSON.encode({"CMD":"delete-sub-file", "username":username, "subfile":sub_file_list[index]}));
     
     sub_file_list.removeAt(index); 
     active_subfile = 0; 
   }
   
   
   
   void file_manage_close(){
     SHOW_FILE_MANAGE = false; 
     $['dialog'].toggle();
   }
   
   
   
   
   
   /*
   
   ready() {
      $['confirmation'].target = this;
   }
   */
   

     
    // print($['confirmation']); 
    // print($['logo3']); 
  //   $['confirmation'].target = this;
     
   //  $['confirmation'].toggle();
     //shadowRoot.querySelector("#user-forum").toggle();    $['user-forum'].toggle();
     //
  // }
  
   /*
   inputHandler(e) {
     if (e.target.value == 'something') {
       $['confirmation'].toggle();
     }
   }

   tapHandler() {
     $['dialog'].toggle();
   }
  
   
  
   void hide_user_forum(){
     SHOW_USER_FORUM = false; 
   }
  */
  
}  