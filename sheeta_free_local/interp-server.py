import tornado.httpserver
import tornado.websocket
import tornado.ioloop
import tornado.web
import motor
from tornado import gen
import tornado.escape
import numpy as np
import json
from bson import json_util
from pymongo import MongoClient
from tornado.ioloop import IOLoop
from gridfs import GridFS
import os
import shutil
from scipy.interpolate import griddata

class WSHandler(tornado.websocket.WebSocketHandler):
    @tornado.web.asynchronous
    @gen.engine
    def open(self):
        print 'new connection'	
      
    def on_message(self, message):
        print 'message received %s' % message
	p = json.loads(message)
	if p["CMD"]=="interpolation_marching_cube":
	    num_of_step = p["num_of_step"]
	    x_min = p["range"]["x_min"]
	    x_max = p["range"]["x_max"]
	    y_min = p["range"]["y_min"]
	    y_max = p["range"]["y_max"]
	    z_min = p["range"]["z_min"]
	    z_max = p["range"]["z_max"]
	    points = [] 
	    values = []
	    for d in p["input_data"]:
		points.append([d[0], d[1], d[2]])
		values.append(d[3])	  
	    num_step = complex(0,num_of_step)
	    grid_x, grid_y, grid_z = np.mgrid[x_min:x_max:num_step, y_min:y_max:num_step, z_min:z_max:num_step]
	    grid_z2 = griddata(np.array(points), np.array(values), (grid_x, grid_y, grid_z), method='linear')	
	    output = []
	    for i in range(num_of_step):
		for j in range(num_of_step):
		    for k in range(num_of_step):
			output.append(grid_z2[k, j, i])
	    #print output
	    document = {"MSG":"interpolation_marching_cube_output", "output":output}
	    self.write_message(json.dumps(document, default=json_util.default))

	if p["CMD"]=="interpolation_heat_map":
	    num_of_step = p["num_of_step"]
	    x_min = p["range"]["x_min"]
	    x_max = p["range"]["x_max"]
	    y_min = p["range"]["y_min"]
	    y_max = p["range"]["y_max"]
	    points = [] 
	    values = []
	    for d in p["input_data"]:
		points.append([d["x"], d["y"]])
		values.append(d["color"])	  
	    num_step = complex(0,num_of_step)
	    #print np.array(points), np.array(values)
	    grid_x, grid_y = np.mgrid[x_min:x_max:num_step, y_min:y_max:num_step]
	    #print grid_x, grid_y 
	    grid_z2 = griddata(np.array(points), np.array(values), (grid_x, grid_y), method='cubic')	
	    output = []
	    for i in range(num_of_step):
		for j in range(num_of_step):
		    output.append(grid_z2[i,j])
	    #print output
	    document = {"MSG":"interpolation_heat_map_output", "output":output}
	    self.write_message(json.dumps(document, default=json_util.default))


    def on_close(self):
      print 'connection closed'   


db = motor.MotorClient().dasheeta	

application = tornado.web.Application([
    (r'/ws', WSHandler)
], db=db)
 
 
if __name__ == "__main__":
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(8090)
    tornado.ioloop.IOLoop.instance().start()

