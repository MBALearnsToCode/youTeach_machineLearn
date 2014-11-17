function ffNN_housePrices_multiLinReg...
   (weightRegulParam = 0.03)
   
   % load House Prices data
   data = load('housePrices.txt');   
   x = houseAreas_sqft = data(:, 1);
   y = housePrices_000 = data(:, 3) / (10 ^ 3);

   % split data into:
   % 1. Training set (which machine will see and adjust
   % itself to);
   % 2. Validation set (which the machine will also see
   % to cross-check its own out-of-sample performance
   % during Training); and
   % 3. Test set (which the machine will not see during 
   % Training; this will be used to finally evaluate
   % the machine's performance)
   numCases_train = 20;
   numCases_valid = 12;
   numCases_test = 15;
   indices_train = 1 : numCases_train;
   indices_valid = numCases_train + (1 : numCases_valid);
   indices_test = numCases_train + numCases_valid ...
      + (1 : numCases_test);
      
   [x_train x_sortedIndices_train] = ...
      sort(x(indices_train));
   y_train = ...
      y(indices_train)(x_sortedIndices_train);
   
   [x_valid x_sortedIndices_valid] = ...
      sort(x(indices_valid));
   y_valid = ...
      y(indices_valid)(x_sortedIndices_valid);
      
   [x_test x_sortedIndices_test] = ...
      sort(x(indices_test));
   y_test = ...
      y(indices_test)(x_sortedIndices_test);   
   
   % construct a small-interval x series
   % for fitted-curve plotting purpose
   x_seriesLength = 100;
   x_smallIntervals = linspace(min(x) - range(x) / 12, ...
      max(x) + range(x) / 12, x_seriesLength)';
      
   % plot Training set
   close all;
   figure; %figure #1  
   plot(x_train, y_train, '.', 'color', 'k', 'markersize', 9);
   title('TRAINING SET');
   legend('Training Set', ...
      'Location', 'northwest');
   fprintf('\nTraining set plotted\n\n');
   pausePressKey;
   fprintf('\n');
   
   % Request highest polynomial degree to which
   % to map input x 
   polyDeg = input('Map Input x to Highest Polynomial Degree: ');
   % Map x into polynomial of higher degree
   % for modelling flexibility
   X_train = polyUpToDeg(x_train, polyDeg);
   X_valid = polyUpToDeg(x_valid, polyDeg);
   X_test = polyUpToDeg(x_test, polyDeg);
   X_smallIntervals = polyUpToDeg(x_smallIntervals, polyDeg);   
   % We normalize X (i.e. subtract mean and 
   % divide by standard deviation) for numerical stability
   % purposes
   [X_train_normalized mu sigma] = ...
      normalizeSubtractDivide(X_train);      
      
   
   
   fprintf('\n\n\n\n');
   % EXPERIMENT 1
   fprintf('RUN 1: Linear Regression without Weight Regularization:\n\n');
   % Linear regression coefficients - analytic solution
   fprintf('Weights:\n');
   weights_analytic_normalized = linRegWeights_analytic...
      (y_train, X_train_normalized)   
   
   % Calculate predicted values
   h_train = ...
      [ones(numCases_train, 1), X_train_normalized] ...
      * weights_analytic_normalized;
   h_test = ...
      [ones(numCases_test, 1), ...
      normalizeSubtractDivide(X_test, mu, sigma)] ...
      * weights_analytic_normalized;
   h_smallIntervals = ...
      [ones(x_seriesLength, 1), ...
      normalizeSubtractDivide(X_smallIntervals, mu, sigma)] ...
      * weights_analytic_normalized;
   
   % Plot fitted values & calculate Costs
   figure(1);
   hold on; # this is for retaining the existing plot on Figure 1; we are plotting on top of it
   plot(x_smallIntervals, h_smallIntervals, 'r');
   legend('Training Set', 'No Regularization', ...
      'Location', 'northwest');
   cost_train = sum((h_train - y_train) .^ 2) ...
      / (2 * numCases_train);
   fprintf('Training set RMSE = %.3g\n\n', ...
      sqrt(2 * cost_train));
   pausePressKey;
   figure(2);
   hold on;
   plot(x_test, y_test, '.', 'color', 'b', 'markersize', 9);
   title('TEST SET');
   plot(x_smallIntervals, h_smallIntervals, 'r');
   legend('Test Set', 'No Regularization', ...
      'Location', 'northwest');
   cost_test = sum((h_test - y_test) .^ 2) ...
      / (2 * numCases_test);
   fprintf('\nTest set RMSE = %.3g\n\n', sqrt(2 * cost_test));
   
   
   
   fprintf('\n\n\n');
   % We will now PENALIZE the sum of squared weights
   % to reduce overfitting
   run2 = ...
      input(sprintf('RUN 2: Linear Regression with Weight Penalty Term = %.3g: PROCEED? (0 / 1): ', ...
      weightRegulParam));
   
   if (run2)
   
      fprintf('Weights:\n');
      weights_analytic_normalized = linRegWeights_analytic...
         (y_train, X_train_normalized, weightRegulParam)
         
      % Calculate predicted values
      h_train = ...
         [ones(numCases_train, 1), X_train_normalized] ...
         * weights_analytic_normalized;
      h_test = ...
         [ones(numCases_test, 1), ...
         normalizeSubtractDivide(X_test, mu, sigma)] ...
         * weights_analytic_normalized;
      h_smallIntervals = ...
         [ones(x_seriesLength, 1), ...
         normalizeSubtractDivide(X_smallIntervals, mu, sigma)] ...
         * weights_analytic_normalized;
         
      % Plot fitted values & calculate Costs      
      figure(1);
      hold on;
      plot(x_smallIntervals, h_smallIntervals, ...
         'g', 'LineWidth', 3);
      legend('Training Set', 'No Regularization', ...
         'Regularization by Weight Penalty', ...
         'Location', 'northwest');
      cost_train = sum((h_train - y_train) .^ 2) ...
         / (2 * numCases_train);
      fprintf('\nTraining set RMSE = %.3g\n\n', ...
         sqrt(2 * cost_train));
      figure(2);
      hold on;
      plot(x_smallIntervals, h_smallIntervals, ...
         'g', 'LineWidth', 3);
      legend('Test Set', 'No Regularization', ...
         'Regularization by Weight Penalty', ...
         'Location', 'northwest');
      cost_test = sum((h_test - y_test) .^ 2) ...
         / (2 * numCases_test);
      fprintf('Test set RMSE = %.3g\n\n', ...
         sqrt(2 * cost_test));
      
      pausePressKey;
      % ***************************************************
      % We will now re-run Run 2 by a Neural Network
      % learning model
      fprintf('\n\n\nRe-running using Neural Network learning:\n');
      
      % Create simple neural net with linear function and 
      % 1 top-layer node
      ffNN = class_ffNN...
         (inputDimSizes_perCase___ = polyDeg, ...
         addlLayersNumsNodes___ = [1], ...
         transformFuncs___ = {'linear'}, ...
         displayOverview___ = false, ...
         initWeights___ = true);
      % Set normalizing parameters to preprocess input
      ffNN.normalizeSubtract = mu;
      ffNN.normalizeDivide = sigma;
      
      ffNN = train_conjGrad...
         (ffNN_init___ = ffNN, ...
         dataArgs___ = {X_train y_train ... % Training data
                        [] [] ... % no Validation data
                        X_test y_test}, ... % Test data
         targetOutputs_areClassIndcsColVecs___ = false, ...
         classSkewnesses = [1], ...
         numIters_perEpoch___ = 3000, ...
         trainNumEpochs___ = 1, ...
         trainBatchSize___ = false, ...   
         trainRandShuff___ = false, ...
         trainCostApproxChunk_numBatches___ = 1, ...
         validCostCalcInterval_numChunks___ = 1, ...
         weightRegulArgs___ = ...
            {{'L2'} [weightRegulParam]}, ... % weight penalty parameter in []
         connectProbs___ = [1.0], ...
         bestStop___ = true);
         
      fprintf('Weights:\n');
      ffNN.weights
      
   endif
   
   
   
   fprintf('\n\n\n');
   % We will now include a Validation data set 
   % and try a different method for regularizing weights:
   % we shall let the weights learn much more slowly
   % from the Training set (the weights look look at the
   % Training data again and again through multiple "epochs"
   % but in each epoch the weights will only adjust themselves
   % a relatively small bit); and if the model over-learns
   % from the Training set and starts performing worse on
   % the Validation set, then we disregard such excessive
   % learning and roll the model back to where its Validation
   % performance is best
   if (run2)
      run3 = input(sprintf...
         ('RUN 3: Neural Network Learning with Validation Set and Weight Regularization by Early Stopping: PROCEED? (0 / 1): '));
   else
      run3 = false;
   endif
   
   if (run3)
      
      # plot Validation set
      figure(3);
      plot(x_valid, y_valid, '.', 'color', 'r', 'markersize', 9);
      title('VALIDATION SET');
      legend('Validation Set', ...
         'Location', 'northwest');
      fprintf('\nValidation set plotted\n\n');
      pausePressKey;
      fprintf('\n');
      
      % Create simple neural net with linear function and 
      % 1 top-layer node
      ffNN = class_ffNN...
         (inputDimSizes_perCase___ = polyDeg, ...
         addlLayersNumsNodes___ = [1], ...
         transformFuncs___ = {'linear'}, ...
         displayOverview___ = false, ...
         initWeights___ = true);
      % Set normalizing parameters to preprocess input
      ffNN.normalizeSubtract = mu;
      ffNN.normalizeDivide = sigma;

      ffNN = train_conjGrad...
         (ffNN_init___ = ffNN, ...
         dataArgs___ = {X_train y_train ...
                        X_valid y_valid ... % Validation data
                        X_test y_test}, ...
         targetOutputs_areClassIndcsColVecs___ = false, ...
         classSkewnesses = [1], ...
         numIters_perEpoch___ = 1, ... % slower learning per epoch
         trainNumEpochs___ = 30, ... % but more repeated epochs
         trainBatchSize___ = false, ...   
         trainRandShuff___ = false, ...
         trainCostApproxChunk_numBatches___ = 1, ...
         validCostCalcInterval_numChunks___ = 1, ...
         weightRegulArgs___ = ...
            {{'L2'} [0]}, ... % we do not penalize weights this time, so that we can see the pure 'early stopping' effect
         connectProbs___ = [1.0], ...
         bestStop___ = true);
      
      # extract trained FFNN's weights
      fprintf('Weights:\n');
      w = ffNN.weights
      weights_normalized = w{1};
      
      % Calculate predicted values
      h_train = ...
         [ones(numCases_train, 1), X_train_normalized] ...
         * weights_normalized;
      h_test = ...
         [ones(numCases_test, 1), ...
         normalizeSubtractDivide(X_test, mu, sigma)] ...
         * weights_normalized;
      h_valid = ...
         [ones(numCases_valid, 1) ...
         normalizeSubtractDivide(X_valid, mu, sigma)] ...
         * weights_normalized;
      h_smallIntervals = ...
         [ones(x_seriesLength, 1), ...
         normalizeSubtractDivide(X_smallIntervals, mu, sigma)] ...
         * weights_normalized;
      
      % Plot fitted values
      figure(1);
      hold on;
      plot(x_smallIntervals, h_smallIntervals, ...
         'm', 'LineWidth', 3);
      legend('Training Set', 'No Regularization', ...
         'Regularization by Weight Penalty', ...
         'Regularization by Early Stopping', ...
         'Location', 'northwest');
      figure(2);
      hold on;
      plot(x_smallIntervals, h_smallIntervals, ...
         'm', 'LineWidth', 3);
      legend('Test Set', 'No Regularization', ...
         'Regularization by Weight Penalty', ...
         'Regularization by Early Stopping', ...
         'Location', 'northwest');
      figure(3);
      hold on;
      plot(x_smallIntervals, h_smallIntervals, ...
         'm', 'LineWidth', 3);
      legend('Validation Set', ...
         'Regularization by Early Stopping', ...
         'Location', 'northwest');
      
   endif
   
endfunction