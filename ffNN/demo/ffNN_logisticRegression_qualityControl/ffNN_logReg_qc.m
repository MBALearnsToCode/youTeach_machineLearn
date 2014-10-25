function ffNN_logReg_qc(weightPenaltyTerm = 0, polyDeg = 6, ...
   numIters = 300);

   close all;

   data = load('qualityControl.txt');
   X = data(:, [1 2]);
   y = data(:, 3);
   m = length(y);
   plot2D_binClasses(y, X);
   
   X_poly = polyUpToDeg(X, polyDeg);   
   % NEURAL NET
   % ----------
   ffNN = class_ffNN...
      (inputDimSizes_perCase_vec = columns(X_poly), ...
      addlLayersNumsNodes_vec = [], ...
      transformFuncs_list = {'logistic'}, ...
      displayOverview = false, ...
      initWeights_rand = false);

   ffNN = train_gradDesc...
      (ffNN_init = ffNN, ...
      dataArgs_list = {X_poly y 1.0}, ...
      targetOutputs_areClassIndcsColVecs = false, ...
      trainNumEpochs = numIters, ...
      trainBatchSize = false, ...   
      trainRandShuff = false, ...
      trainCostApproxChunk_numBatches = 1, ...
      validCostCalcInterval_numChunks = 1, ...
      stepRate_init = 0.3, ...      
      momentumRate_init = 0.9, ...
      nesterovAccGrad = true, ...
      weightRegulArgs_list = {{'L2'} [weightPenaltyTerm]}, ...
      connectProbs = [1.0], bestStop = false);
   
   weights = ffNN.weights;
   w = weights{1};
   func_decision_vsZero = @(X) ...
      addBiasElems(polyUpToDeg(X, polyDeg)) * w;
   plot2D_decisionBoundary(y, X, func_decision_vsZero);

   predictions = predict(ffNN, X_poly);
   fprintf('Train Accuracy: %f\n', mean(double(predictions == y)) * 100);

endfunction