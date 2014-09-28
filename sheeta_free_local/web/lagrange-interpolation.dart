library lag_inter;

List <double> Lag_inter(List <double> x, List <double> fx, List <double> input_){

 List <double> result = [];

for (double input in input_){
  List <double> L = [];
  double P = 0.0;
// calculating Lagrange functions 
    for(int i=0; i < x.length ; i++){
      double surat = 1.0;
      double makhraj = 1.0;
      for(var j=0 ; j < x.length ; j++){
        if( j != i){
          surat *=  (input - x[j]);
          makhraj *= (x[i] -  x[j]);
        }
      }
  // make array of Lagrange function
     L.add(surat/makhraj);
    }

// calculating f(x) of input
    for(var i=0; i < x.length ; i++){
      P += fx[i] * L[i];
 }
    result.add(P);
}
return result;
}


/*
void main(){
  List x = [0, 0.1, 0.3, 0.2];
  List fx = [0.0, 1.0, 3.0, 2.0];
  List input = [0.05, 0.15, 0.25, 0.35, 0.45];
  var res = Lag_inter(x, fx, input);
  print(res);
}*/