function f1(a) {
  return function f2(b) {
    if (b > 0) {
      eval(a);
    }
  };
};
