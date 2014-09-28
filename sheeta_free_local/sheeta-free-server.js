var MongoClient = require('mongodb').MongoClient;
var WebSocketServer = require('ws').Server, wss = new WebSocketServer({port: 8084});
var async = require('async');
var fs = require('fs');
//var replace = require("replace");


MongoClient.connect("mongodb://localhost:27017/sheeta_free", function(err, db) {  

var file_list = db.collection('file_list'); 
var user_list = db.collection('user_list'); 
var msg_list = db.collection('msg_center');
var table_head = db.collection('table_head');
var table_body = db.collection('table_body');
var data_plot = db.collection('data_plot');
var google_chart = db.collection('google_chart');
var d3surface_plot = db.collection('d3surface_plot');
var solid_lattice = db.collection('solid_lattice');
var user_forum = db.collection('user_forum');
var maps_svg = db.collection('maps_svg');  

    wss.on('connection', function(ws) {
        console.log("new collection");

        ws.on('message', function(message) {
            console.log('received: %s', message);
	    var CMD = JSON.parse(message);


	    if(CMD["CMD"]=="login-auth"){
	        var cursor = user_list.find(CMD["data"]);
		cursor.count(function(err, count){
		    console.log("Total matches: "+count);
		    if(count==0){
			ws.send(JSON.stringify({"MSG":"login_failed"}));  
		    }
		    if(count>0){
			user_list.findOne(CMD["data"], function(err, document) {
 			    ws.send(JSON.stringify({"MSG":"login_success", "dataproj_count":document["dataproj_count"]}));  				
			});
			var cursor1 = file_list.find({"creater":CMD["data"]["username"], "type":CMD["proj_type"]}); 
			cursor1.each(function(err, doc){
			    if(doc!=null){
		    	        ws.send(JSON.stringify({"MSG":"dataproj_list", "data":doc})); 
			    }
			}); 			
			var cursor2 = file_list.find({"type":CMD["proj_type"], "share_list":{"$elemMatch":{"share_author":CMD["data"]["username"]}}});
			cursor2.each(function(err, doc){
			    if(doc!=null){
			        ws.send(JSON.stringify({"MSG":"dataproj_list", "data":doc})); 
			    }
			}); 
		    }
		});    	    	    
	    }

	    if(CMD["CMD"]=="register-auth"){
	        var cursor = user_list.find({"username":CMD["data"]["username"]});
		cursor.count(function(err, count){
		    console.log("Total matches: "+count);
		    if(count==0){
			user_list.insert({"username":CMD["data"]["username"], "password":CMD["data"]["password"], "dataproj_count":0}, function(err, doc){	    
			    //ws.send(JSON.stringify({"MSG":"new_user_success"}));  
			    ws.send(JSON.stringify({"MSG":"login_success", "dataproj_count":0}));  
			});
		    }
		    if(count>0){
	           	ws.send(JSON.stringify({"MSG":"user_already_existed"}));
		    }
		});	    
	    }


	    if(CMD["CMD"]=="login-auth-passport"){
		user_list.findOne(CMD["data"], function(err, document) {
 		    ws.send(JSON.stringify({"MSG":"login_success", "dataproj_count":document["dataproj_count"]}));  				
		});
		var cursor1 = file_list.find({"creater":CMD["data"]["username"], "type":CMD["proj_type"]}); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"dataproj_list", "data":doc})); 
		    }
		}); 			
		var cursor2 = file_list.find({"type":CMD["proj_type"], "share_list":{"$elemMatch":{"share_author":CMD["data"]["username"]}}});
		cursor2.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"dataproj_list", "data":doc})); 
		    }
		});   	    	    
	    }



	    if(CMD["CMD"]=="insert-file"){
		file_list.insert(CMD["data"], function(err, doc){	    });
		user_list.update({"username":CMD["username"]}, { "$inc":{"dataproj_count":1}}, function(err, doc){	    });
	    }


	    if(CMD["CMD"]=="delete-file"){
    		async.waterfall([
		    function(callback){
			var cursor1 = file_list.find({"parent":CMD["filter"]["file_id"]}); 
			cursor1.each(function(err, doc){
			    console.log(doc);
			    if(doc!=null){
			        table_head.remove({"parent":doc["file_id"]}, function(err, doc){	    });
	  	                table_body.remove({"parent":doc["file_id"]}, function(err, doc){	    });
	    	                data_plot.remove({"parent":doc["file_id"]}, function(err, doc){	   callback(null);     });
			    }
			}); 
		    },
		    function(callback){
		        file_list.remove({"parent":CMD["filter"]["file_id"]}, function(err, doc){	    });
		        file_list.remove(CMD["filter"], function(err, doc){	    });
		        user_list.update({"username":CMD["username"]}, { "$dec":{"dataproj_count":1}}, function(err, doc){	    });			
		    }
		], function(err, result) { }     ); 
	    }


	    if(CMD["CMD"]=="delete-sub-file"){
	        table_head.remove({"parent":CMD["subfile"]["file_id"]}, function(err, doc){	    });
	        table_body.remove({"parent":CMD["subfile"]["file_id"]}, function(err, doc){	    });
	        data_plot.remove({"parent":CMD["subfile"]["file_id"]}, function(err, doc){	    });
		file_list.remove(CMD["subfile"], function(err, doc){	    });
	    }


	    if(CMD["CMD"]=="insert-sub-file"){
		//file_list.insert(CMD["data"], function(err, doc){	    });
		var cursor = file_list.find({"file_id":CMD["data"]["file_id"]});
		cursor.count(function(err, count){
		    if(count==0){
			file_list.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			file_list.update({"file_id":CMD["data"]["file_id"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 
	    }


	    if(CMD["CMD"]=="check-sub-file"){
		var cursor1 = file_list.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"subfile_list", "data":doc})); 
		    }
		}); 
	    }


	    if(CMD["CMD"]=="update-edit-status"){
		file_list.update(CMD["file"], { "$set":CMD["update"]}, function(err, doc){	    });
	    }


	    if(CMD["CMD"]=="check-edit-status"){
		var cursor1 = file_list.find({"creater":CMD["username"], "type":"data_proj"}); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"dataproj_edit_status", "file_id":doc["file_id"], "edit_status":doc["edit_status"], "current_editor":doc["current_editor"]})); 
		    }
		}); 			
		var cursor2 = file_list.find({"type":"data_proj", "share_list":{"$elemMatch":{"share_author":CMD["username"]}}});
		cursor2.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"dataproj_edit_status", "file_id":doc["file_id"], "edit_status":doc["edit_status"], "current_editor":doc["current_editor"]})); 
		    }
		}); 
	    }

	    if(CMD["CMD"]=="user-message"){
		msg_list.insert(CMD["MSG"], function(err, doc){	    });
	    }

	    if(CMD["CMD"]=="check-user-message"){
		var cursor1 = msg_list.find({"receiver":CMD["username"]}); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"user-message-push", "data":doc})); 
			msg_list.remove(doc, function(err, docx){	    });
		    }
		}); 
	    }

	    if(CMD["CMD"]=="insert-table-head"){
		var cursor = table_head.find({"parent":CMD["data"]["parent"]});
		cursor.count(function(err, count){
		    if(count==0){
			table_head.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			table_head.update({"parent":CMD["data"]["parent"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 
	    }



	    if(CMD["CMD"]=="insert-table-body"){
		var cursor = table_body.find({"parent":CMD["data"]["parent"], "row":CMD["data"]["row"]});
		cursor.count(function(err, count){
		    if(count==0){
			table_body.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			table_body.update({"parent":CMD["data"]["parent"], "row":CMD["data"]["row"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 
	    }

	    if(CMD["CMD"]=="insert-data-plot"){
		var cursor = data_plot.find({"parent":CMD["data"]["parent"], "serial_number":CMD["data"]["serial_number"]});
		cursor.count(function(err, count){
		    if(count==0){
			data_plot.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			data_plot.update({"parent":CMD["data"]["parent"], "serial_number":CMD["data"]["serial_number"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 
	    }

	    if(CMD["CMD"]=="insert-google-chart"){
		var cursor = google_chart.find({"parent":CMD["data"]["parent"]});
		cursor.count(function(err, count){
		    if(count==0){
			google_chart.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			google_chart.update({"parent":CMD["data"]["parent"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 		
	    }

	    if(CMD["CMD"]=="read-google-chart"){
		var cursor1 = google_chart.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }

	    if(CMD["CMD"]=="insert-3dsurface-plot"){
		var cursor = d3surface_plot.find({"parent":CMD["data"]["parent"]});
		cursor.count(function(err, count){
		    if(count==0){
			d3surface_plot.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			d3surface_plot.update({"parent":CMD["data"]["parent"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 		
	    }


	    if(CMD["CMD"]=="read-3dsurface-plot"){
		var cursor1 = d3surface_plot.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }


	    if(CMD["CMD"]=="read-data-plot"){
		var cursor1 = data_plot.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }

	    if(CMD["CMD"]=="insert-solid-lattice"){
		var cursor = solid_lattice.find({"parent":CMD["data"]["parent"]});
		cursor.count(function(err, count){
		    if(count==0){
			solid_lattice.insert(CMD["data"], function(err, doc){	    });
		    }
		    if(count>0){
			solid_lattice.update({"parent":CMD["data"]["parent"]}, CMD["data"], function(err, doc){	    });
		    }
		}); 		
	    }


	    if(CMD["CMD"]=="read-solid-lattice"){
		var cursor1 = solid_lattice.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }


	    if(CMD["CMD"]=="read-table-head"){
		var cursor1 = table_head.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }

	    if(CMD["CMD"]=="read-table-body"){
		var cursor1 = table_body.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }	   

	    if(CMD["CMD"]=="check_map_path"){
		var cursor1 = maps_svg.find(CMD["filter"]); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify(doc)); 
		    }
	        });
	    }




	    if(CMD["CMD"]=="forum-new-thread"){
		user_forum.insert(CMD["thread"], function(err, doc){	    });
	    }

	    if(CMD["CMD"]=="forum-new-post"){
		user_forum.insert(CMD["post"], function(err, doc){	    });
		user_forum.update({"type":"thread", "thread_ID":CMD["post"]["parent_thread"]}, { "$inc":{"num_of_post":1}}, function(err, doc){	    });
	    }

	    if(CMD["CMD"]=="check-forum-thread"){
		var cursor1 = user_forum.find({"type":"thread"}); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"forum-thread-check", "thread":doc})); 
		    }
	        });
	    }	

	    if(CMD["CMD"]=="check-forum-post"){
		var cursor1 = user_forum.find({"parent_thread":CMD["parent_thread"], "type":"post"}); 
		cursor1.each(function(err, doc){
		    if(doc!=null){
		        ws.send(JSON.stringify({"MSG":"forum-post-check", "post":doc})); 
		    }
	        });
	    }	


	    if(CMD["CMD"]=="write-static-figure"){
		fs.writeFile("./public/static_figure_link/"+CMD["filename"], CMD["figure"], function(err) {
		    if(err) {
		        console.log(err);
		    } else {
		        console.log("The file was saved!");
			//ws.send(JSON.stringify({"MSG":"forum-post-check", "post":doc})); 
		    }
		}); 
	    }


	    if(CMD["CMD"]=="write-google-chart"){
		var body1 = '<!doctype html> <html> <head>  <meta name="viewport" content="width=device-width, minimum-scale=1.0, initial-scale=1.0, user-scalable=yes">   <title>google-chart Demo</title>    <script src="../platform/platform.js"></script>    <link rel="import" href="google-chart/google-chart.html">  <style>      code { color: #007000; }    </style>  </head>  <body unresolved>'; 
		var body2 = '</body>  </html>' ; 
		fs.writeFile("./public/google-chart/"+CMD["filename"], body1+CMD["figure"]+body2, function(err) {
		    if(err) {
		        console.log(err);
		    } else {
		        console.log("The file was saved!");
			//ws.send(JSON.stringify({"MSG":"forum-post-check", "post":doc})); 
		    }
		}); 
	    }

	    if(CMD["CMD"]=="write-d3surface-plot"){		
		fs.readFile("./public/d3surface-plot/marching_cube_output.html", 'utf8', function (err,data) {
		  if (err) {
		    return console.log(err);
		  }
		  var result = data.replace("INSERT-DATA-HERE", CMD["figure"]);
		  fs.writeFile("./public/d3surface-plot/"+CMD["filename"], result, 'utf8', function (err) {
		     if (err) return console.log(err);
		  });
		});
	    }

	
        

        });   //end of connect        
    });   //end of onmessage    
});   // end of server
