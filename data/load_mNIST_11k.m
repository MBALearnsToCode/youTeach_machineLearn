function [trainInput trainTargetOutput ...
   trainTargetOutput_labels ...
   validInput validTargetOutput validTargetOutput_labels ...
   testInput testTargetOutput testTargetOutput_labels ...
   imgHeight imgWidth] = load_mNIST_11k

   data = load('mNIST_11k.mat').data;
   imgHeight = imgWidth = 16;
   
   tidyUp_input = @(imgArr) permute...
      (reshape(imgArr, [size(imgArr, 1) imgWidth imgHeight]),
      [1 3 2]);
   tidyUp_targetOutput = @(rowMat) rowMat(:, [(2 : end) 1]);
   
   trainInput = tidyUp_input(data.test.inputs');
   trainTargetOutput = tidyUp_targetOutput...
      (data.test.targets');
   [~, trainTargetOutput_labels] = ...
      max(trainTargetOutput, [], 2);
      
   validInput = tidyUp_input(data.validation.inputs');
   validTargetOutput = tidyUp_targetOutput...
      (data.validation.targets');
   [~, validTargetOutput_labels] = ...
      max(validTargetOutput, [], 2);
      
   testInput = tidyUp_input(data.training.inputs');
   testTargetOutput = tidyUp_targetOutput...
      (data.training.targets');
   [~, testTargetOutput_labels] = ...
      max(testTargetOutput, [], 2);
   
endfunction