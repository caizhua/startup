

void main(){

    int start = 0; 
    int end = 0;
    
    String set_col = ";sqrt;(Col(A)^2+ \n Col;(B)^2 \n );"; 

    List <int> x_col_ = [];
    List <String> name_ = [];    
    
 // print(set_col.indexOf(new RegExp(r'Col\('), 20)); 
    print('\n'.allMatches(set_col).length); 
    
    while(set_col.indexOf(new RegExp(r'Col\('), end)>-1){
      start = set_col.indexOf(new RegExp(r'Col\('), end);
      end = set_col.indexOf(new RegExp(r'\)'), start);
      String tmp = set_col.substring(start+4, end);
      if(!name_.contains(tmp)){
        name_.add(tmp);      
      }      
    }
    
    
    for(var n in name_){
      String out = '_'+n+'_';
      set_col = set_col.replaceAll(new RegExp(r'Col\('+n+r'\)'), out); 
    } 
    
    print(set_col);
    

   


}