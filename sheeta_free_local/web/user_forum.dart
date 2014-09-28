library userforum; 

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:convert';

String host = 'localhost';
int port = 8084;

class Forum_Post extends Object with Observable{
  @observable int post_ID;
  @observable String content;
  @observable String post_user;
  @observable String post_time;
  int parent_thread; 
  Forum_Post(this.post_ID, this.content, this.post_time, this.post_user, this.parent_thread);
  dynamic toJson() => {"post_ID":this.post_ID, "content":this.content, 
    "post_user":this.post_user, "post_time":this.post_time, "parent_thread":this.parent_thread, "type":"post"}; 
}


class Forum_Thread extends Object with Observable{
  @observable int thread_ID;
//  String thread_db_id;   this.thread_db_id,   "thread_db_id":this.thread_db_id,
  @observable String title;
  @observable String init_content; 
  @observable String creation_user;
  @observable String creation_time;  
  @observable String modified_time; 
  @observable num num_of_post;  
  List <Forum_Post> post_in_thread = toObservable([]);  
  Forum_Thread(this.thread_ID,  this.title, this.init_content, this.creation_user, this.creation_time, this.modified_time, this.num_of_post, this.post_in_thread);
  dynamic toJson() => {"thread_ID":this.thread_ID,  "title":this.title, "init_content":this.init_content, 
    "creation_user":this.creation_user, "creation_time":this.creation_time, "modified_time":this.modified_time, "num_of_post":this.num_of_post, "type":"thread"  };
}





@CustomTag('user-forum')
class UserForumElement extends PolymerElement { 
  @observable bool forum_list_mode = true; 
  @observable bool thread_content_mode = false;
  @observable bool new_thread_mode = false; 
  @published String username = "iranyu";   
  int thread_count_total = 0; 
  WebSocket ws;
  
  List <Forum_Thread> forum_list = toObservable([]); 
  @observable Forum_Thread new_forum_thread; 
 // @observable Forum_Thread active_forum_thread; 
  @observable int current_thread = 0; 
  @observable String textarea_content = "xxxxxxxx"; 
    
  UserForumElement.created() : super.created() {
  //  active_forum_thread = null; 
    ws = new WebSocket("ws://"+host+":"+port.toString()+"/ws"); 
  //  this.refresh_forum(); 
    ws.onOpen.listen((event){
      forum_list.clear(); 
      ws.send(JSON.encode({"CMD":"check-forum-thread"}));   
    }); 
    
    ws.onMessage.listen((event){
      
      var data = JSON.decode(event.data);
            if(data["MSG"]=="forum-thread-check"){              
              var p = data["thread"];
              new_forum_thread = new Forum_Thread(p["thread_ID"], p["title"], p["init_content"], p["creation_user"], p["creation_time"], p["modified_time"], p["num_of_post"], toObservable([]));              
              forum_list.insert(0, new_forum_thread); 
              thread_count_total += 1; 
              forum_list.sort((x, y) => DateTime.parse(y.modified_time).compareTo(DateTime.parse(x.modified_time))); 
            }
            
            if(data["MSG"]=="forum-post-check"){
              var p = data["post"];
              forum_list[current_thread].post_in_thread.add(new Forum_Post(p["post_ID"], p["content"], p["post_user"], p["post_time"], p["parent_thread"])); 
              forum_list[current_thread].num_of_post += 1;                
            }           
    }); 
    
  }
  
  
  void new_thread(){
    new_thread_mode = true; 
    forum_list_mode = false;
    DateTime now = new DateTime.now();
    new_forum_thread = new Forum_Thread(0, "hello", "hello xxxxx",  username, now.toString(), now.toString(), 0, toObservable([]));

  }
  
  void new_thread_create(){
    new_forum_thread.thread_ID = thread_count_total; 
    thread_count_total += 1; 
    
    ws.send(JSON.encode({"CMD":"forum-new-thread", "thread":new_forum_thread}));      
    
    forum_list.insert(0, new_forum_thread); 
    new_thread_mode = false; 
    forum_list_mode = true; 
  }
  
  void new_thread_discard(){
    new_thread_mode = false; 
    forum_list_mode = true; 
  }
  
  void show_thread(Event e, var detail, Element target){
    current_thread = int.parse(target.attributes['data-msg']);
    
    forum_list[current_thread].post_in_thread.clear(); 
    forum_list[current_thread].num_of_post = 0; 
    ws.send(JSON.encode({"CMD":"check-forum-post", "parent_thread":forum_list[current_thread].thread_ID}));   

  //  active_forum_thread = forum_list[current_thread]; 
  //  print(current_thread); 
    forum_list_mode = false;
    thread_content_mode = true; 
  }
  
  void back_to_forum_list(){
    forum_list_mode = true;
    thread_content_mode = false; 
    forum_list.sort((x, y) => DateTime.parse(y.modified_time).compareTo(DateTime.parse(x.modified_time))); 
  }
  
  void post_response(){
  //  print(textarea_content);     
    DateTime now = new DateTime.now();
 //   active_forum_thread.post_in_thread.add(new Forum_Post(forum_list[current_thread].post_in_thread.length, textarea_content, now.toString(), this.username)); 
    forum_list[current_thread].post_in_thread.add(new Forum_Post(forum_list[current_thread].post_in_thread.length, 
        textarea_content, now.toString(), this.username, forum_list[current_thread].thread_ID)); 
    forum_list[current_thread].num_of_post += 1;   
    forum_list[current_thread].modified_time = now.toString();    
    
    ws.send(JSON.encode({"CMD":"forum-new-post", "post":forum_list[current_thread].post_in_thread.last}));   
    
  }
  
  void refresh_forum(){    
    forum_list.clear(); 
    ws.send(JSON.encode({"CMD":"check-forum-thread"}));     
  }
  
}


