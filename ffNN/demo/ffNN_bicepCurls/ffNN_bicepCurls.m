function ffNN = ffNN_bicepCurls...
   (loadFileName = '', saveFileName = '', ...
   numsHid = 100, numEpochs = 30, ...
   numAdjustments_perBatch = 3, weightPenaltyTerm = 0);
      
   % load data
   fprintf('\nLoading Bicep Curl Quality Dataset...');
   [X y] = load_bicepCurlQuality;
   mu = mean(X);
   sigma = std(X);
   r = load('bicepCurlQuality_randperm.mat').randperm_39242;
   X_train = X(r(20001 : 35000), :);
   y_train = y(r(20001 : 35000));
   X_valid = X(r(35001 : 39242), :);
   y_valid = y(r(35001 : 39242));
   fprintf('\n   done!\n');   
   
   if strcmp(loadFileName, '')
      % create Forward-Feeding Neural Network (FFNN):
      % all layers are Logistic transformation layers
      % with the top layer automatically set as 
      % a 5-way Softmax layer
      ffNN = class_ffNN...
         (inputDimSizes_perCase___ = 52, ...
         addlLayersNumsNodes___ = [numsHid 5], ...
         transformFuncs = {}, ...
         displayOverview = false, ...
         initWeights_rand = true);
      ffNN.normalizeSubtract = mu;
      ffNN.normalizeDivide = sigma;
   else
      ffNN = ffNN_loadFile(loadFileName);
   endif
   
   if strcmp(saveFileName, '')
      saveFileName = 'ffNN_bicepCurls.mat';
   endif
   
   % train FFNN with CONJUGATE GRADIENT   
   ffNN = train_conjGrad...
      (ffNN_init___ = ffNN, ...
      dataArgs___ = {X_train y_train ...
                     X_valid y_valid}, ...
      targetOutput_isClassIndcsColVec_ofNumClasses___ = 5, ...
      classSkewnesses = [1], ...
      trainNumEpochs___ = numEpochs, ...
      trainBatchSize___ = false, ...
      trainRandShuff___ = false, ...
      trainCostApproxChunk_numBatches___ = 3, ...
      validCostCalcInterval_numChunks___ = 3, ...
      numAdjustments_perBatch___ = numAdjustments_perBatch, ...
      weightRegulArgs___ = {{'L2'} [weightPenaltyTerm]}, ...
      connectProbs___ = [1.0], ...
      bestStop___ = true, ...
      saveFileName___ = saveFileName);  
   
endfunction