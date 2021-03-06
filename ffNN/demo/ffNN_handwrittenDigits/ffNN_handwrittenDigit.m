function ffNN = ffNN_handwrittenDigit...
   (digitLabel_toLearn = 10, numsHid = 9, ...
   weightPenaltyTerm = 0, ...
   numIters_perBatch = 3, numEpochs = 60, bestStop = true); 
   
   % close all existing plots
   close all;
   
   % load data
   [trainInput trainTargetOutput trainTargetOutput_labels ...
   validInput validTargetOutput validTargetOutput_labels ...
   testInput testTargetOutput testTargetOutput_labels ...
   imgHeight imgWidth] = load_mNIST_11k;
   % for this exercise we are learning only one digit class
   % hence, we simplify Target Outputs to TRUE / FALSE
   % for that one digit class as specified
   trainTargetOutput = ...
      trainTargetOutput_labels == digitLabel_toLearn;
   validTargetOutput = ...
      validTargetOutput_labels == digitLabel_toLearn;
   testTargetOutput = ...
      testTargetOutput_labels == digitLabel_toLearn;
   
   % display sample labels & images
   numDisplaySamples = 10 ^ 2;
   indices_displaySamples = 1 : numDisplaySamples;
   displaySamples_numRowsCols = sqrt(numDisplaySamples);   
   displayLabels = trainTargetOutput_labels...
      (indices_displaySamples);
   fprintf('\n%i Sample Labels & Images:\n', ...
      numDisplaySamples);
   reshape(displayLabels, [displaySamples_numRowsCols ...
      displaySamples_numRowsCols])'      
   plot2D_grayImages...
      (permute(trainInput(indices_displaySamples, :, :), ...
      [2 3 1]));
   
   % create Forward-Feeding Neural Network (FFNN):
   % all layers are Logistic transformation layers
   ffNN = class_ffNN...
      (inputDimSizes_perCase___ = 256, ...
      addlLayersNumsNodes___ = [numsHid 1], ...
      transformFuncs___ = {}, ...
      displayOverview___ = false, ...
      initWeights_rand___ = true);   
   
   % reshape Input data to fit model's architecture
   trainInput = trainInput(:, :);
   validInput = validInput(:, :);
   testInput = testInput(:, :);
   
   % train FFNN with CONJUGATE GRADIENT
   ffNN = train_conjGrad...
      (ffNN_init___ = ffNN, ...
      dataArgs___ = {trainInput trainTargetOutput ...
                  validInput validTargetOutput ...
                  testInput testTargetOutput}, ...
      targetOutput_isClassIndcsColVec___ = false, ...
      classSkewnesses = 0.1, ...      
      trainNumEpochs___ = numEpochs, ...
      trainBatchSize___ = false, ...
      trainRandShuff___ = false, ...
      trainCostApproxChunk_numBatches___ = 1, ...
      validCostCalcInterval_numChunks___ = 3, ...
      numIters_perBatch___ = numIters_perBatch, ...
      weightRegulArgs___ = {{'L2'} [weightPenaltyTerm]}, ...
      connectProbs___ = [1.0], ...
      bestStop___ = bestStop);
      
   % visualize learned 1st-layer weights
   % to see what detected features are like;
   % we will see many features detecting strokes
   % and hooks, which are relevant in distinguishing
   % one digit from another
   weights = ffNN.weights;
   weights_layer1 = weights{1};
   % for visualization purposes, we ignore bias terms
   weights_layer1 = rmBiasElems(weights_layer1);
   % reshape weights for visualization
   weights_layer1 = permute(reshape(weights_layer1', ...
      [numsHid(1) imgHeight imgWidth]), [2 3 1]);
   % visualize weights
   plot2D_grayImages(weights_layer1);   
   
endfunction