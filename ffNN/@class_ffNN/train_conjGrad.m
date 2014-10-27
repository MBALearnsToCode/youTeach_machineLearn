function [ffNN_avgWeights ...
   trainCostAvg_exclWeightPenalty_approx ...
   validCostAvg_exclWeightPenalty ...
   testCostAvg_exclWeightPenalty ...
   trainCostsAvg_exclWeightPenalty_approx ...
   validCostsAvg_exclWeightPenalty] = ...
   train_conjGrad(ffNN_init, dataArgs_list, ...
   targetOutputs_areClassIndcsColVecs_ofNumClasses = false, ...
   numIters_perBatch = 1, trainNumEpochs = 1, ...
   trainBatchSize = false, trainRandShuff = true, ...
   trainCostApproxChunk_numBatches = 1, ...
   validCostCalcInterval_numChunks = 1, ...
   weightRegulArgs_list = {{'L2'} [0]}, ...
   connectProbs = [1.0], bestStop = true, ...
   plotLearningCurves = true, batchDim = 3, ...
   saveEvery_numMins = 3, saveFileName = 'ffNN_trained.mat')
   % zzzBORED = 'Z' - waiting for Octave's TIMER functionality
   
   ffNN = ffNN_init;
   ffNN_avgWeights = avgWeights_byConnectProbs...
      (ffNN, connectProbs);
   numTransforms = ffNN.numTransforms;
   weightDimSizes = ffNN.weightDimSizes;
   numTargets = columns(weightDimSizes{numTransforms});
   costFuncType = ffNN.costFuncType;
   costFuncType_isCrossEntropy = ...
      strcmp(costFuncType, 'CE-L') || ...
      strcmp(costFuncType, 'CE-S');   
   
   trainCostAvg_exclWeightPenalty_approx = ...
      validCostAvg_exclWeightPenalty = ...
      testCostAvg_exclWeightPenalty = 0;
   trainAccuracyAvg_text = validAccuracyAvg_text = '';
   trainCostsAvg_exclWeightPenalty_approx = ...
      validCostsAvg_exclWeightPenalty = [];
      
   setData = setTrainValidTestData(dataArgs_list, ...
      trainBatchSize, trainRandShuff);
   batchSize = setData.trainBatchSize;
   trainNumBatches = setData.trainNumBatches;
   trainBatchDim = setData.trainBatchDim;
   trainInput = setData.trainInput;
   trainTargetOutput = setData.trainTargetOutput;
   trainInput_batches = setData.trainInput_batches;
   trainTargetOutput_batches = ...
      setData.trainTargetOutput_batches;
   validInput = setData.validInput;
   validTargetOutput = setData.validTargetOutput;
   testInput = setData.testInput;
   testTargetOutput = setData.testTargetOutput;

   valid_provided = ~(isempty(validInput) ...
      || isempty(validTargetOutput));   
   if (valid_provided)
      validBatchDim = max([batchDim ...
         arrNumDims(validInput) ...
         arrNumDims(validTargetOutput)]);
   endif
   bestStop = valid_provided && bestStop;
   if (bestStop)
      ffNN_avgWeights_best = ffNN_avgWeights;
      validCostAvg_exclWeightPenalty_best = Inf;
      toSaveBest = false;
   endif 
   
   test_provided = ~(isempty(testInput) ...
      || isempty(testTargetOutput));
   if (test_provided)
      testBatchDim = max([batchDim ...
         arrNumDims(testInput) ...
         arrNumDims(testTargetOutput)]);
   endif
       
   trainCostAvg_exclWeightPenalty_currChunk = ...
      trainAccuracyAvg_currChunk = ...
      chunk = chunk_inEpoch = batch_inChunk = 0;
   
   validCostCalcInterval_numBatches = ...
      validCostCalcInterval_numChunks ...
      * trainCostApproxChunk_numBatches;
   
   saveFileName_upper = upper(saveFileName);
      
   overview(ffNN);
fprintf('\n\nTRAIN FORWARD-FEEDING NEURAL NETWORK (FFNN) (METHOD: CONJUGATE GRADIENT):\n\n');
   fprintf('   DATA SETS:\n');
   fprintf('      Training: %i cases\n', ...
      size(trainTargetOutput, 1));
   if (valid_provided)
      fprintf('      Validation: %i cases\n', ...
         rows(validTargetOutput));      
   endif
   if (test_provided)
      fprintf('      Test: %i cases\n', ...
         rows(testTargetOutput));
   endif
   
   fprintf('\n   TRAINING SETTINGS:\n');
   fprintf('      Training Epochs: %i\n', trainNumEpochs); 
fprintf('      Training Batches per Epoch: %i batches of %i', ...
      trainNumBatches, batchSize);
   trainRandShuff = trainRandShuff && (trainNumBatches > 1);
   if (trainRandShuff)
      fprintf(', shuffled in each epoch\n')
   else
      fprintf('\n');
   endif
   fprintf('      Conjugate Gradient Iterations per Batch: %i\n', ...
      numIters_perBatch); 

   fprintf('      Weight Penalty Methods & Parameters:\n');
   weightRegulFuncs = weightRegulArgs_list{1};
   weightRegulParams = weightRegulArgs_list{2};
   for (l = 1 : numTransforms)
      if (l > 1)
         if (length(connectProbs) < l)
            connectProbs(l) = connectProbs(l - 1);
         endif
         if (length(weightRegulFuncs) < l)
            weightRegulFuncs{l} = weightRegulFuncs{l - 1};
         endif        
         if (length(weightRegulParams) < l)
            weightRegulParams(l) = weightRegulParams(l - 1);
         endif
      endif      
      if strcmp(weightRegulFuncs{l}, ...
         const_MacKay_empBayes_str)         
         weightRegulParam_print = '';
      else
         weightRegulParam_print = ...
            sprintf(', penalty term = %g', ...
            weightRegulParams(l));
      endif      
      fprintf('         Layer #%i: %i%%, %s%s\n', l, ...
         100 * connectProbs(l), weightRegulFuncs{l}, ...
         weightRegulParam_print);
   endfor
   
   if (bestStop)
fprintf('      Model Selection by Best Validation Performance\n');
   endif
   
   fprintf('      Saving Results in %s on Working Directory every %i Minutes\n', ...
      saveFileName_upper, saveEvery_numMins);
      
   fprintf('\n');
   
   fprintf('   TRAINING PROGRESS:\n');
% fprintf(cstrcat('      (pre-terminate by "', zzzBORED, '" key stroke)\n'));
fprintf('      Training Avg Cost (excl Weight Penalty) approx''d w/ each chunk of %i batches\n',
      trainCostApproxChunk_numBatches);
fprintf('      Validation Avg Cost (excl Weight Penalty) updated every %i batches\n', ...
      validCostCalcInterval_numBatches);
   if (costFuncType_isCrossEntropy)
fprintf('         (Est Avg Classification Accuracy %%s in brackets)\n');
   endif
   
   conjGrad_options = optimset('GradObj', 'on', 'MaxIter', ...
      numIters_perBatch); 
   
   if (plotLearningCurves)
      figure;
   endif
   lastSaveTime = trainStartTime = time;
   
   for (epoch = 1 : trainNumEpochs)
      
      if (trainRandShuff) && (epoch > 1)
         train_reshuffled = setTrainValidTestData...
            ({trainInput trainTargetOutput 1.0}, ...
            batchSize, trainRandShuff);
         trainInput_batches = ...
            train_reshuffled.trainInput_batches;
         trainTargetOutput_batches = ...
            train_reshuffled.trainTargetOutput_batches;    
      endif
      
      for (batch = 1 : trainNumBatches)
         
         if (trainNumBatches > 1)
            trainInput_batch = arrSubsetHighestDim...
              (trainInput_batches, batch);
            trainTargetOutput_batch = ...
               arrSubsetHighestDim...
               (trainTargetOutput_batches, batch);
         else
            trainInput_batch = trainInput_batches;
            trainTargetOutput_batch = ...
               trainTargetOutput_batches;
         endif
         
         for (l = 1 : numTransforms)
            connectivitiesOnOff{l} = binornd(1, ...
               connectProbs(l), weightDimSizes{l});
         endfor
         
         func = @(w) costAvgInclWeightPenalty_n_weightGrads...
            (ffNN, w, trainInput_batch, ...
            trainTargetOutput_batch, ...
         targetOutputs_areClassIndcsColVecs_ofNumClasses, ...
            {weightRegulFuncs weightRegulParams}, ...
            connectivitiesOnOff, true);
         
         ffNN.weights = convertColVecToArrs...
         (fmincg(func, convertArrsToColVec(ffNN.weights), ...
            conjGrad_options), weightDimSizes);
                        
         ffNN_avgWeights = avgWeights_byConnectProbs...
            (ffNN, connectProbs);            
         [trainCostAvg_exclWeightPenalty_currBatch ...
            trainAccuracyAvg_currBatch] = ...
            costAvg_exclWeightPenalty(ffNN_avgWeights, ...
            trainInput_batch, trainTargetOutput_batch, ...
         targetOutputs_areClassIndcsColVecs_ofNumClasses, ...
            trainBatchDim);
         
         batch_inChunk++;         
         trainCostAvg_exclWeightPenalty_currChunk += ...
            (trainCostAvg_exclWeightPenalty_currBatch ...
            - trainCostAvg_exclWeightPenalty_currChunk) ...
            / batch_inChunk;
         trainAccuracyAvg_currChunk += ...
            (trainAccuracyAvg_currBatch ...
            - trainAccuracyAvg_currChunk) ...
            / batch_inChunk;
         if (costFuncType_isCrossEntropy)
            trainAccuracyAvg_text = sprintf...
               (' (%.3g%%)', 100 * ...
               trainAccuracyAvg_currChunk);
         endif
         
         if (batch_inChunk ==
            trainCostApproxChunk_numBatches) || ...
            (batch == trainNumBatches)
                        
            chunk_inEpoch++; chunk++;
         trainCostsAvg_exclWeightPenalty_approx(chunk) = ...
               trainCostAvg_exclWeightPenalty_currChunk;
               
            if (valid_provided && ((mod(batch, ...
               validCostCalcInterval_numBatches) == 0) || ...
               (batch == trainNumBatches)))
            
               [costAvg_valid validAccuracyAvg] = ...
                  costAvg_exclWeightPenalty(ffNN_avgWeights, ...
                  validInput, validTargetOutput, ...
         targetOutputs_areClassIndcsColVecs_ofNumClasses, ...
                  validBatchDim);
               validCostAvg_exclWeightPenalty = ...
                  validCostsAvg_exclWeightPenalty(chunk) = ...
                  costAvg_valid;
               if (costFuncType_isCrossEntropy)
                  validAccuracyAvg_text = sprintf...
                     (' (%.3g%%)', 100 * validAccuracyAvg);
               endif               
               if (bestStop && ...
                  (validCostAvg_exclWeightPenalty ...
                  < validCostAvg_exclWeightPenalty_best))
                  ffNN_avgWeights_best = ffNN_avgWeights;
                  validCostAvg_exclWeightPenalty_best = ...
                     validCostAvg_exclWeightPenalty;
                  validAccuracyAvg_best = validAccuracyAvg;
                  validAccuracyAvg_text_best = ...
                     validAccuracyAvg_text;
                  toSaveBest = true;
               endif
            
            else
            
               validCostsAvg_exclWeightPenalty(chunk) = NA;            
            
            endif
            
            if (time > lastSaveTime + saveEvery_numMins * 60)
               if (bestStop)
                  if (toSaveBest)
                     saveFile(ffNN_avgWeights_best, ...
                        saveFileName);
                     lastSaveTime = time;                  
                     toSaveBest = false;
                  endif
               else
                  saveFile(ffNN_avgWeights, saveFileName);
                  lastSaveTime = time;
               endif
               
            endif            
            
            if (bestStop) && ...
               isfinite(validCostAvg_exclWeightPenalty_best)
               validReport_text = sprintf('%.3g Best %.3g%s', ...
                  validCostAvg_exclWeightPenalty, ...
                  validCostAvg_exclWeightPenalty_best, ...
                  validAccuracyAvg_text_best);
            else
               validReport_text = sprintf('%.3g%s', ...
                  validCostAvg_exclWeightPenalty, ...
                  validAccuracyAvg_text);
            endif
            
            trainCurrTime = time;
            trainElapsedTime_numMins = ...
               (trainCurrTime - trainStartTime) / 60;
fprintf('\r      Epoch %i Batch %i: TRAIN %.3g%s, VALID %s, elapsed %.3gm      ', ...
               epoch, batch, ...
               trainCostAvg_exclWeightPenalty_currChunk, ...
               trainAccuracyAvg_text, validReport_text, ...
               trainElapsedTime_numMins);
            
            if (plotLearningCurves)               
               ffNN_plotLearningCurves...
                  (trainCostAvg_exclWeightPenalty_currChunk, ...
                  trainAccuracyAvg_text, ...
                  trainCostsAvg_exclWeightPenalty_approx, ...   
                  validReport_text, ...
                  validCostsAvg_exclWeightPenalty, ...  
                  chunk, trainCostApproxChunk_numBatches, ...
                  batchSize, trainElapsedTime_numMins);
            endif
               
            trainCostAvg_exclWeightPenalty_currChunk = ...
               trainAccuracyAvg_currChunk = batch_inChunk = 0;  
 
            if (batch == trainNumBatches)         
               chunk_inEpoch = 0;
            endif
 
         endif
         
      endfor
   
   endfor

fprintf('\n\n   RESULTS:   Training Finished w/ Following Avg Costs (excl Weight Penalty):\n');

   trainCostAvg_exclWeightPenalty_approx = ...
      trainCostsAvg_exclWeightPenalty_approx(end);
   fprintf('      Training (approx''d by last chunk): %.3g%s\n', ...
      trainCostAvg_exclWeightPenalty_approx, ...
      trainAccuracyAvg_text);
      
   if (valid_provided)
      if (bestStop)
         ffNN_avgWeights = ffNN_avgWeights_best;
         validCostAvg_exclWeightPenalty = ...
            validCostAvg_exclWeightPenalty_best;
         validAccuracyAvg = validAccuracyAvg_best;
         validAccuracyAvg_text = validAccuracyAvg_text_best;
      endif
      fprintf('      Validation: %.3g%s\n', ...
         validCostAvg_exclWeightPenalty, ...
         validAccuracyAvg_text);
   endif   
   
   if (test_provided)
      [testCostAvg_exclWeightPenalty testAccuracyAvg] = ...
         costAvg_exclWeightPenalty(ffNN_avgWeights, ...
         testInput, testTargetOutput, ...
         targetOutputs_areClassIndcsColVecs_ofNumClasses, ...
         testBatchDim);
      if (costFuncType_isCrossEntropy)
         testAccuracyAvg_text = sprintf...
            (' (%.3g%%)', 100 * testAccuracyAvg);
      else
         testAccuracyAvg_text = '';
      endif
      fprintf('      Test: %.3g%s\n', ...
         testCostAvg_exclWeightPenalty, ...
         testAccuracyAvg_text);
   endif  

   fprintf('\n');
   
   saveFile(ffNN_avgWeights, saveFileName);
   
endfunction