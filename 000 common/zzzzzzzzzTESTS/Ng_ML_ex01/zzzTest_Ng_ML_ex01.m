%% Machine Learning Online Class
%  Exercise 1: Linear regression with multiple variables
%
%  Instructions
%  ------------
% 
%  This file contains code that helps you get started on the
%  linear regression exercise. 
%
%  You will need to complete the following functions in this 
%  exericse:
%
%     warmUpExercise.m
%     plotData.m
%     gradientDescent.m
%     computeCost.m
%     gradientDescentMulti.m
%     computeCostMulti.m
%     featureNormalize.m
%     normalEqn.m
%
%  For this part of the exercise, you will need to change some
%  parts of the code below for various experiments (e.g., changing
%  learning rates).
%

%% Initialization

%% ================ Part 1: Feature Normalization ================

%% Clear and Close Figures
% clear ; 
%close all; clc

fprintf('Loading data ...\n');

%% Load Data
data = load('ex1data2.txt');
X = data(:, 1:2);
y = data(:, 3);
m = length(y);

% Print out some data points
fprintf('First 10 examples from the dataset: \n');
fprintf(' x = [%.0f %.0f], y = %.0f \n', [X(1:10,:) y(1:10,:)]');

%fprintf('Program paused. Press enter to continue.\n');
% pause;

% Scale features and set them to zero mean
fprintf('Normalizing Features ...\n');

[X mu sigma] = featureNormalize(X);

% Add intercept term to X
X = [ones(m, 1) X];


%% ================ Part 2: Gradient Descent ================

% ====================== YOUR CODE HERE ======================
% Instructions: We have provided you with the following starter
%               code that runs gradient descent with a particular
%               learning rate (alpha). 
%
%               Your task is to first make sure that your functions - 
%               computeCost and gradientDescent already work with 
%               this starter code and support multiple variables.
%
%               After that, try running gradient descent with 
%               different values of alpha and see which one gives
%               you the best result.
%
%               Finally, you should complete the code at the end
%               to predict the price of a 1650 sq-ft, 3 br house.
%
% Hint: By using the 'hold on' command, you can plot multiple
%       graphs on the same figure.
%
% Hint: At prediction, make sure you do the same feature normalization.
%

fprintf('Running gradient descent ...\n');

% Choose some alpha value
alpha = 0.01;
num_iters = 100;

% Init Theta and Run Gradient Descent 
theta = zeros(3, 1);
[theta, J_history] = gradientDescentMulti(X, y, theta, alpha, num_iters);

% Plot the convergence graph
figure;
plot(1:numel(J_history), J_history, '-b', 'LineWidth', 2);
xlabel('Number of iterations');
ylabel('Cost J');

% Display gradient descent's result
fprintf('Theta computed from gradient descent: \n');
fprintf(' %f \n', theta);
fprintf('\n');

   X = X(:, 2 : end);
   %% SET UP NEURAL NET
   %% -----------------
   ffNN = class_ffNN...
      (inputDimSizes_perCase_vec = 2, ...
      addlLayersNumsNodes_vec = [], ...
      transformFuncs_list = {'linear'}, ...
      displayOverview = true, ...
      initWeights_rand = false);
   % TRAIN w/o MOMENTUM/NESTEROV
   % ----------------------------
   [ffNN trainCostAvg_noRegul ...
      validCostAvg_noRegul testCostAvg_noRegul ...
      trainCostsAvg_noRegul_approx ...
      validCostsAvg_noRegul] = train_gradDesc...
      (ffNN_init = ffNN, ...
      dataArgs_list = {X y X y X y}, ...
      targetOutputs_areClassIndcsColVecs = false, ...
      trainNumEpochs = num_iters, ...
      trainBatchSize = false, ...   
      trainRandShuff = false, ...
      trainCostApproxChunk_numBatches = 1, ...
      validCostCalcInterval_numChunks = num_iters, ...
      learningRate_init = alpha, ...
      momentumRate_init = 0, ...
      nesterovAccGrad = false, ...
      weightRegulArgs_list = {{'L2'} [0]}, ...
      connectProbs = [1.0], ...
      bestStop = false, ...
      immedWeightChangesMemory_init = {}, ...
      plotLearningCurves = false);

   costs_list = {J_history(end) trainCostAvg_noRegul ...
      validCostAvg_noRegul testCostAvg_noRegul ...
      trainCostsAvg_noRegul_approx(end) ...
      validCostsAvg_noRegul(end)}
   
   equalTest_chain(costs_list, 1e-9)
   thetas_ffNN = ffNN.weights;
   weights_list = [theta thetas_ffNN{1}]
   equalTest(theta, thetas_ffNN{1})