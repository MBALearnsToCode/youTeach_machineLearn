function f = zzzTest_ffNN_vs_softmReg(numRuns = 1)

   % PARAMETERS
   % ----------
   maxNumCases = 9;
   maxNumInputs = 9;
   maxNumClasses = 9;
   inputMagnOrder = 1e1;
   weightMagnOrder = 1e-1;

   succs = 0; fails = [];

   for (r = 1 : numRuns)

      fprintf('\rTest #%i', r);
      
      regulParam = randElem(const_regulParams_10);

      m = tests{r}.m = unidrnd(maxNumCases);
      aB = tests{r}.aB = rand > 0.5;
      nI = tests{r}.nI = unidrnd(maxNumInputs);
      nC = tests{r}.nC = unidrnd(maxNumClasses);     

      % VARIABLES
      % ---------
      X = tests{r}.X = ...
         randUnif([m nI], inputMagnOrder);     
      bX = tests{r}.bX = [ones([m aB]) X];

      b = tests{r}.b = ...
         randUnif([aB nC], weightMagnOrder);
      W = tests{r}.W = ...
         randUnif([nI nC], weightMagnOrder);
      bW = tests{r}.bW = [b; W];

      Y0 = rand([m nC]);

      Y = tests{r}.Y = ...
         Y0 == repmat(max(Y0, [], 2), [1 nC]);

      % SOFTMAX REGRESSION
      % -----------------
      Z = bX * bW; expZ = exp(Z);
      H = softmRegModel{r}.hypoOutput = ...
         expZ ./ repmat(sum(expZ, 2), [1 nC]);         
      err = H - Y;
      softmRegModel{r}.costAvg = ...
         - sum(sum(Y .* log(H + exp(-36)))) / m ...
         + regulParam * sum(sum(W .^ 2)) / 2;
      softmRegModel{r}.activGrad = - (Y ./ H) / m;
      softmRegModel{r}.biasWeightGrad = bX' * err / m ...
         + regulParam * [zeros([aB nC]); W];     

      % NEURAL NETWORK
      % --------------
      ffNN = class_ffNN(nI, {[(nI + aB) nC]}, ...
         {softmax_transformFuncHandles(aB)}, false, false);
      ffNN.weights{1} = bW;
           
      [weightGrads, ~, costAvg_inclWeightPenalty, ...
         hypoOutput] = fProp_bProp(ffNN, X, Y, false, ...
         {{'L2'} regulParam}, true);     

      ffNNModel{r}.hypoOutput = hypoOutput;
      ffNNModel{r}.costAvg = costAvg_inclWeightPenalty;
      ffNNModel{r}.biasWeightGrad = weightGrads{1};

      % COMPARE MODELS
      % --------------
      if equalTest(ffNNModel{r}.hypoOutput, ...
            softmRegModel{r}.hypoOutput) && ...
         equalTest(ffNNModel{r}.costAvg, ...
            softmRegModel{r}.costAvg) && ...
         equalTest(ffNNModel{r}.biasWeightGrad, ...
            softmRegModel{r}.biasWeightGrad)
  
         succs++;
       
      else
          
         fails = [fails r];
      
      endif

   endfor

   f.tests = tests;
   f.softmRegModel = softmRegModel;
   f.ffNNModel = ffNNModel;
   f.fails = fails;

   fprintf('\n%i Successes / %i Tests\n\n', succs, numRuns);

end
