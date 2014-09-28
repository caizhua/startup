var mathjs = require('./math.js'),
    math = mathjs();


console.log(math.eval("f(y)=y^3; \n f(x)+3 \n f(5) \n \n", {x:4}));


