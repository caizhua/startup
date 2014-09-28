
math = mathjs();
 
var LSQ = function() {

this.LeastSq = function(func_str, x_data, y_data, parameter) {
  
  leastsq = function(a) { 
    result = 0;
    for(i=0; i<x_data.length; i++){  
      var scope = {
        x: x_data[i],
        c: a,
      };  
      y = math.eval(func_str, scope);              // 12  
      result += (y-y_data[i])*(y-y_data[i]);  
      }  
      return result;
  }; 
    
  s = numeric.uncmin(leastsq,[parameter]).solution;
  
  return s;
   
};


};







