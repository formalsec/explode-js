Test that timeout works:
  $ explode-js exploit --timeout 5 test_timeout.js
        abort : "Uncaught SyntaxError: Must include statements to encode"
         eval : s_concat(["`", (`x0 : __$Str), "`"])
  explode-js: [WARNING] time limit reached
