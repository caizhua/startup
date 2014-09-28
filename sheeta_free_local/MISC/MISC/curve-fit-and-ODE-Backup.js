var Module = require("./curve3.js");
var mathjs = require('./math.min.js');

math = mathjs();


var MonotonicCubicSpline;
MonotonicCubicSpline = function() {
  function MonotonicCubicSpline(x, y) {
    var alpha, beta, delta, dist, i, m, n, tau, to_fix, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4;
    n = x.length;
    delta = [];
    m = [];
    alpha = [];
    beta = [];
    dist = [];
    tau = [];
    for (i = 0, _ref = n - 1; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
      delta[i] = (y[i + 1] - y[i]) / (x[i + 1] - x[i]);
      if (i > 0) {
        m[i] = (delta[i - 1] + delta[i]) / 2;
      }
    }
    m[0] = delta[0];
    m[n - 1] = delta[n - 2];
    to_fix = [];
    for (i = 0, _ref2 = n - 1; (0 <= _ref2 ? i < _ref2 : i > _ref2); (0 <= _ref2 ? i += 1 : i -= 1)) {
      if (delta[i] === 0) {
        to_fix.push(i);
      }
    }
    for (_i = 0, _len = to_fix.length; _i < _len; _i++) {
      i = to_fix[_i];
      m[i] = m[i + 1] = 0;
    }
    for (i = 0, _ref3 = n - 1; (0 <= _ref3 ? i < _ref3 : i > _ref3); (0 <= _ref3 ? i += 1 : i -= 1)) {
      alpha[i] = m[i] / delta[i];
      beta[i] = m[i + 1] / delta[i];
      dist[i] = Math.pow(alpha[i], 2) + Math.pow(beta[i], 2);
      tau[i] = 3 / Math.sqrt(dist[i]);
    }
    to_fix = [];
    for (i = 0, _ref4 = n - 1; (0 <= _ref4 ? i < _ref4 : i > _ref4); (0 <= _ref4 ? i += 1 : i -= 1)) {
      if (dist[i] > 9) {
        to_fix.push(i);
      }
    }
    for (_j = 0, _len2 = to_fix.length; _j < _len2; _j++) {
      i = to_fix[_j];
      m[i] = tau[i] * alpha[i] * delta[i];
      m[i + 1] = tau[i] * beta[i] * delta[i];
    }
    this.x = x.slice(0, n);
    this.y = y.slice(0, n);
    this.m = m;
  }
  MonotonicCubicSpline.prototype.interpolate = function(x) {
    var h, h00, h01, h10, h11, i, t, t2, t3, y, _ref;
    for (i = _ref = this.x.length - 2; (_ref <= 0 ? i <= 0 : i >= 0); (_ref <= 0 ? i += 1 : i -= 1)) {
      if (this.x[i] <= x) {
        break;
      }
    }
    h = this.x[i + 1] - this.x[i];
    t = (x - this.x[i]) / h;
    t2 = Math.pow(t, 2);
    t3 = Math.pow(t, 3);
    h00 = 2 * t3 - 3 * t2 + 1;
    h10 = t3 - 2 * t2 + t;
    h01 = -2 * t3 + 3 * t2;
    h11 = t3 - t2;
    y = h00 * this.y[i] + h10 * h * this.m[i] + h01 * this.y[i + 1] + h11 * h * this.m[i + 1];
    return y;
  };
  return MonotonicCubicSpline;
}();



// Import function from Emscripten generated file
var LM_LSQ = function() {

this.LM_FIT = function(x_data, y_data, var_list, para_list, para_init, func_str) {

/*
	console.log(x_data);
	console.log(y_data);
	console.log(var_list);
	console.log(para_list);
	console.log(para_init);
	console.log(func_str);   */

        if(x_data.length!=y_data.length || para_list.length!=para_init.length){
	  console.log("input data error!");
	}

	lmfit = Module.cwrap(
	  'lmfit_out', 'number', ['number', 'number', 'number', 'number', 'number', 'number']
	);

	var fit_func = Module.Runtime.addFunction(function(t, p) {   
	  var par = new Float64Array([100.0]);
	  var len = par.BYTES_PER_ELEMENT;
          var params = [];
	  var scope = [];
	  for(var j=0; j<para_list.length; j++){
	    params[j] = Module.getValue(p+len*j, "double");
	    scope[para_list[j]] = params[j];
	  }
          scope[var_list[0]] = t;
	  y = math.eval(func_str, scope);   
	  return y;
	});

	var par = new Float64Array(para_init);
	var nDataBytes = par.length * par.BYTES_PER_ELEMENT;
	var dataPtr = Module._malloc(nDataBytes);
	var par_PTR = new Float64Array(Module.HEAPU8.buffer, dataPtr, nDataBytes);
	par_PTR.set(new Float64Array(par.buffer));
	var t = new Float64Array(x_data);
	var nDataBytes1 = t.length * t.BYTES_PER_ELEMENT;
	var dataPtr1 = Module._malloc(nDataBytes1);
	var t_PTR = new Float64Array(Module.HEAPU8.buffer, dataPtr1, nDataBytes1);
	t_PTR.set(new Float64Array(t.buffer));
	var y = new Float64Array(y_data);
	var nDataBytes2 = y.length * y.BYTES_PER_ELEMENT;
	var dataPtr2 = Module._malloc(nDataBytes2);
	var y_PTR = new Float64Array(Module.HEAPU8.buffer, dataPtr2, nDataBytes2);
	y_PTR.set(new Float64Array(y.buffer));
	// Call function and get result

	lmfit(para_init.length, par_PTR.byteOffset, x_data.length, t_PTR.byteOffset, y_PTR.byteOffset, fit_func);
	var result = new Float64Array(par_PTR.buffer, par_PTR.byteOffset, par.length);

	var return_res = [];

	for(i=0; i<result.length; i++){
	   return_res[i] = result[i]; 
	   //console.log(result[i]);
	}

	// Free memory
	Module._free(par_PTR.byteOffset);
	Module._free(t_PTR.byteOffset);
	Module._free(y_PTR.byteOffset);
	Module.Runtime.removeFunction(fit_func); // 
	return return_res; 
};


this.LM_DIFF = function(x_data, y_data, var_x_list, var_y_list, para_list, para_init, func_str){            
// func_str = "x*sqrt(c*y);"    // to be determined init_val_list and para_list
	lmdiff = Module.cwrap(
	  'lmdiff_out', 'number', ['number', 'number', 'number', 'number']
	);

	function rk4(dx, x, y, c){
	  var scope = [];
	  for(var s=0; s<para_list.length; s++){
	    scope[para_list[s]] = c[s]; 
	  }
	  scope[var_x_list[0]] = x;
	  scope[var_y_list[0]] = y;
//	  scope[para_list[0]] = c;
//	  console.log(scope);

          var k1 = dx*math.eval(func_str, scope );   
	  scope[var_x_list[0]] = (x+dx/2.0);
	  scope[var_y_list[0]] = (y+k1/2.0);
//	  scope[para_list[0]] = c;
	  var k2 = dx*math.eval(func_str, scope );  
	  scope[var_x_list[0]] = (x+dx/2.0);
	  scope[var_y_list[0]] = (y+k2/2.0);
//	  scope[para_list[0]] = c; 
	  var k3 = dx*math.eval(func_str, scope );   
	  scope[var_x_list[0]] = (x+dx);
	  scope[var_y_list[0]] = (y+k3);
//	  scope[para_list[0]] = c;
	  var k4 = dx*math.eval(func_str, scope );   
          return y+(k1+2*k2+2*k3+k4)/6.0;
	}

        function Lag_inter(x, fx, input_list){
	  result = [];
	  for (var ii=0; ii<input_list.length; ii++){
	    input = input_list[ii];
	    var L = [];
	    var P = 0.0;
	    for(var i=0; i < x.length ; i++){
	      var surat = 1;
	      var makhraj = 1;
	      for(var j=0 ; j < x.length ; j++){
		if( j != i){
			surat *=  input - x[j];
			makhraj *= x[i] -  x[j];
		}
	      }
	      L[i] = surat/makhraj;
	    }
	    for(var i=0; i < x.length ; i++){
	      P += fx[i] * L[i];
	    }
	    result[ii] = P; 
          }
	  return result;
	}

	function Linear_inter(x, fx, input_list){
	  var result = [];
	  for (var ii=0; ii<input_list.length; ii++){
	    input = input_list[ii];
	    for(var i=0; i < x.length ; i++){
	      if(input>=x[i] && input<=x[i+1]){
		result[ii] = fx[i] + input*(fx[i+1]-fx[i])/(x[i+1]-x[i]);
		break; 
	      }
	    }
	  }
	  return result;
	}

	var eval_func = Module.Runtime.addFunction(function(par, m_dat, data, fvec, userbreak) {   
	  var p = new Float64Array([100.0]);
	  var len = p.BYTES_PER_ELEMENT;

	  var c = [];
	  for(var s=0; s<para_init.length; s++){
	    c[s] = Module.getValue(par+(s+1)*len, "double");
	  }
	 // var c = Module.getValue(par+len, "double");
//	  console.log(c); 
	  var y0 = Module.getValue(par, "double");
//	  console.log(y0);
	  var x0 = x_data[0], x1 = x_data[x_data.length-1]; //, dx = 0.02;
	  var n = 100; //(x1-x0)/dx + 1;
	  var dx = (x1-x0)/(n-1); 
	  var x_calc = [];
	  var y_calc = [];
	  y_calc[0] = y0;
	  x_calc[0] = x0; 
//console.log("\n");
	  for(var i=1; i<n; i++){
	    x_calc[i] = x0+dx*i;
	    y_calc[i] = rk4(dx, x_calc[i-1], y_calc[i-1], c);	    
	 //   console.log(y_calc[i]+",");
	  }
//console.log("\n");
//for(var i=0; i<n; i++){
//    console.log(x_calc[i]+",");
//}
//console.log("\n");

	  var temp = new MonotonicCubicSpline(x_calc, y_calc);
	//  for(
	//  var y_new = temp.interpolate(x_data);

//console.log(i);

	  //var y_new = Linear_inter(x_calc, y_calc, x_data);
	  for(var j=0; j<y_data.length; j++){
	    var y_new = temp.interpolate(x_data[j]);
//	    console.log(y_data[j]-y_new);
	//    console.log(y_new[j]);
	    Module.setValue(fvec+j*len, y_data[j]-y_new, "double");
	  }
	});

/*
	var variable = []; 
        for(var s=0; s<para_list.length; s++){
	  variable[s] = para_list[s];
	}
	for(var t=0; t<init_val_list.length; t++){
	  variable[t+para_list.length] = init_val_list[t];
	}
*/
	var variable = [y_data[0]];    // , para_init[0]
        for(var s=0; s<para_init.length; s++){
	  variable[s+1] = para_init[s];
	}

//	console.log(variable);

	var par = new Float64Array(variable);
	var nDataBytes = par.length * par.BYTES_PER_ELEMENT;
	var dataPtr = Module._malloc(nDataBytes);
	var par_PTR = new Float64Array(Module.HEAPU8.buffer, dataPtr, nDataBytes);
	par_PTR.set(new Float64Array(par.buffer));

	lmdiff(variable.length, par_PTR.byteOffset, y_data.length, eval_func);

	var result = new Float64Array(par_PTR.buffer, par_PTR.byteOffset, par.length);
	var return_res = [];

	for(i=0; i<result.length; i++){
	   return_res[i] = result[i]; 
	//   console.log(result[i]);
	}

	// Free memory
	Module._free(par_PTR.byteOffset);
	Module.Runtime.removeFunction(eval_func); // 
	
	return return_res; 
};


	this.RK4 = function(dx, x, y, c, var_x_list, var_y_list, para_list, func_str){
	  var scope = [];
	  for(var s=0; s<para_list.length; s++){
	    scope[para_list[s]] = c[s]; 
	  }
	  scope[var_x_list[0]] = x;
	  scope[var_y_list[0]] = y;
//	  scope[para_list[0]] = c;
//	  console.log(scope);

          var k1 = dx*math.eval(func_str, scope );   
	  scope[var_x_list[0]] = (x+dx/2.0);
	  scope[var_y_list[0]] = (y+k1/2.0);
//	  scope[para_list[0]] = c;
	  var k2 = dx*math.eval(func_str, scope );  
	  scope[var_x_list[0]] = (x+dx/2.0);
	  scope[var_y_list[0]] = (y+k2/2.0);
//	  scope[para_list[0]] = c; 
	  var k3 = dx*math.eval(func_str, scope );   
	  scope[var_x_list[0]] = (x+dx);
	  scope[var_y_list[0]] = (y+k3);
//	  scope[para_list[0]] = c;
	  var k4 = dx*math.eval(func_str, scope );   
          return y+(k1+2*k2+2*k3+k4)/6.0;
	};
}; 


/*

var lm = new LM_LSQ(); 
para_list = ["c", "b", "a"];
para_init = [2.5, 3.0, 2.0];
var_x_list = ["x"];
var_y_list = ["y"]; 
func_str = "c*x*x+b*x+a";
x_data =[26.308677508,38.2805341856,38.355481642,40.8261602358,43.1450966975,43.2046211251,44.7467503102,57.2294757213,57.9842090126,58.3266406567,58.9622145197,70.356063096,76.154642895,78.8332675555];
y_data = [6.9214651222,14.6539929754,14.7114297199,16.667753596,18.6149936904,18.6663928656,20.0227166332,32.7521289134,33.6216849482,34.0199701029,34.7654274107,49.4997561437,57.9952963447,62.1468407347];

var z = lm.LM_DIFF(x_data, y_data, var_x_list, var_y_list, para_list, para_init, func_str); 

console.log(z);
*/



/*
func_str = "2*x";
para_list = [];
para_init = [];
var_x_list = ["x"];
var_y_list = ["y"]; 

	function rk4(dx, x, y, c){
	  var scope = [];
	  for(var s=0; s<para_list.length; s++){
	    scope[para_list[s]] = c[s]; 
	  }
	  scope[var_x_list[0]] = x;
	  scope[var_y_list[0]] = y;
//	  scope[para_list[0]] = c;
          var k1 = dx*math.eval(func_str, scope );   
	  scope[var_x_list[0]] = (x+dx/2.0);
	  scope[var_y_list[0]] = (y+k1/2.0);
//	  scope[para_list[0]] = c;
	  var k2 = dx*math.eval(func_str, scope );  
	  scope[var_x_list[0]] = (x+dx/2.0);
	  scope[var_y_list[0]] = (y+k2/2.0);
//	  scope[para_list[0]] = c; 
	  var k3 = dx*math.eval(func_str, scope );   
	  scope[var_x_list[0]] = (x+dx);
	  scope[var_y_list[0]] = (y+k3);
//	  scope[para_list[0]] = c;
	  var k4 = dx*math.eval(func_str, scope );   
          return y+(k1+2*k2+2*k3+k4)/6.0;
	}


x_data = [];
y_data = [];

for(var i=0; i<11; i++){
  x_data[i] = i;
  y_data[i] = i*i;
}


c = [2, 10];

	  var x0 = x_data[0], x1 = x_data[x_data.length-1]; //, dx = 0.02;
	  var n = 100; //(x1-x0)/dx + 1;
	  var dx = (x1-x0)/(n-1); 
	  var x_calc = [];
	  var y_calc = [];
	  y_calc[0] = y_data[0];
	  x_calc[0] = x0; 
	  for(var i=1; i<n; i++){
	    x_calc[i] = x0+dx*i;
	    y_calc[i] = rk4(dx, x_calc[i-1], y_calc[i-1], c);
	    console.log(x_calc[i]);
	    console.log(y_calc[i]); 
	  }



*/




/*
x_data = [];
y_data = [];

for(var i=0; i<11; i++){
  x_data[i] = i;
  y_data[i] = Math.pow(x_data[i]*x_data[i]/4+1,2);
}

//console.log(x_data);
//console.log(y_data);

LM_DIFF(x_data, y_data, ["x"], ["y"], ["c"], [3.2], "x*sqrt(c*y/2)");
*/

/*
func_str = "x*sqrt(c*y)";


	function rk4(dx, x, y, c){
	  var scope = [];
	//  scope[]
	  var _x = "x"; //var_x_list[0];
	  var _y = "y"; //var_y_list[0];
	  var _c = "c"; //para_list[0];
	  scope[_x] = x;
	  scope[_y] = y;
	  scope[_c] = c;
          var k1 = dx*math.eval(func_str, scope);   
	  var k2 = dx*math.eval(func_str, {"x":(x+dx/2.0), "y":(y+k1/2.0), "c":c} );   
	  var k3 = dx*math.eval(func_str, {"x":(x+dx/2.0), "y":(y+k2/2.0), "c":c} );   
	  var k4 = dx*math.eval(func_str, {"x":(x+dx), "y":(y+k3), "c":c} );   
          return y+(k1+2*k2+2*k3+k4)/6.0;
	}

var p = rk4(0.01, 1, 2, 1);
console.log(p);
*/

//LM_DIFF(x_data, y_data, var_x_list, var_y_list, y_init_list, para_list, para_init, func_str)

/*  this is to test the runge-kuta method
func_str = "x*sqrt(y)";

	function rk4(dx, x, y){
          var k1 = dx*math.eval(func_str, {"x":x, "y":y});   
	  var k2 = dx*math.eval(func_str, {"x":(x+dx/2.0), "y":(y+k1/2.0)});   
	  var k3 = dx*math.eval(func_str, {"x":(x+dx/2.0), "y":(y+k2/2.0)});   
	  var k4 = dx*math.eval(func_str, {"x":(x+dx), "y":(y+k3)});   
          return y+(k1+2*k2+2*k3+k4)/6.0;
	}


var x0 = 0, x1 = 10, dx = 0.001;
var n = (x1-x0)/dx + 1;
y = [];
y[0] = 1.0;
for(var i=1; i<n; i++){
  y[i] = rk4(dx, x0+dx*(i-1), y[i-1]);
}

for(var i=0; i<n; i+=100){
  x = x0+dx*i;
  y2 = Math.pow(x*x/4+1,2)
//  console.log(x);
//  console.log(y[i]);
//  console.log(y2);
  console.log(y[i]/y2-1);
//  console.log(" ");
}  

*/

/*  the code below is to test the curve fit function 

var lm = new LM_LSQ(); 
para_list = ["c", "b", "a"];
para_init = [1.2,1,1];
var_list = ["x"];
func_str = "c*x*x+b*x+a";
x_data =[26.308677508,38.2805341856,38.355481642,40.8261602358,43.1450966975,43.2046211251,44.7467503102,57.2294757213,57.9842090126,58.3266406567,58.9622145197,70.356063096,76.154642895,78.8332675555];
y_data = [6.9214651222,14.6539929754,14.7114297199,16.667753596,18.6149936904,18.6663928656,20.0227166332,32.7521289134,33.6216849482,34.0199701029,34.7654274107,49.4997561437,57.9952963447,62.1468407347];

var z = lm.LM_FIT(x_data, y_data, var_list, para_list, para_init, func_str); 

console.log(z);

*/


/*   The code below is to test the interpolation function 
        function Lag_inter(x_data, y_data, input_list){
	  result = [];
	  for (var ii=0; ii<input_list.length; ii++){
	    input = input_list[ii];
	    var L = [];
	    var P = 0.0;
	    for(var i=0; i < x_data.length ; i++){
	      var surat = 1;
	      var makhraj = 1;
	      for(var j=0 ; j < x_data.length ; j++){
		if( j != i){
			surat *=  input - x[j];
			makhraj *= x[i] -  x[j];
		}
	      }
	      L[i] = surat/makhraj;
	    }
	    for(var i=0; i < x.length ; i++){
	      P += fx[i] * L[i];
	    }
	    result[ii] = P; 
	    //console.log(P);
          }
	  return result;
	}


  var x = [0, 0.1, 0.3, 0.2];
  var fx = [0.0, 1.0, 3.0, 2.0];
  var input = [0.05, 0.15, 0.25, 0.35, 0.45];
  var res = Lag_inter(x, fx, input);
  console.log(res);
 // for(var i=0; i<res.length; i++){   console.log(res[i]);       }
*/ 


