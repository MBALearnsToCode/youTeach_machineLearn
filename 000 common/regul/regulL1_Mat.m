function f = regulL1_Mat(biasWeight_Mat, ...
   exceptBiases = [true], returnGrad = false)

   f.val = distAbs...
      (rmBiasElems(biasWeight_Mat, exceptBiases), 0, ...
      'Manhattan');
   if (returnGrad)
      f.grad = sign(zeroBiasElems(biasWeight_Mat, ...
         exceptBiases));
   endif
   
endfunction