function f = rbm_plotLearningCurves...
   (trainGoodnessAvg_exclWeightPenalty_currChunk, ...
   trainGoodnessesAvg_exclWeightPenalty_approx, ...
   validReport_text, ...
   validGoodnessesAvg_exclWeightPenalty_0asNA, chunkNum, ...
   trainGoodnessApproxChunk_numBatches, trainBatchSize, ...
   cd_chainLength, trainElapsedTime_numMins);

   clf;
   hold on;
   title('LEARNING CURVES (Restricted Boltzmann Machine)');
xlabel(sprintf('%i CHUNKS (1 Chunk = %i Batches, 1 Batch = %i Cases) | training w/ CD-%i | elapsed: %.3gm', ...
      chunkNum, trainGoodnessApproxChunk_numBatches, ...
      trainBatchSize, cd_chainLength, ...
      trainElapsedTime_numMins));
   ylabel('Avg GOODNESS (excl Weight Penalty)');
   plot(trainGoodnessesAvg_exclWeightPenalty_approx, 'b');
   plot(validGoodnessesAvg_exclWeightPenalty_0asNA, ...
      '.', 'color', 'r', 'markersize', 9);
   legend(sprintf('TRAINING (last chunk) = %.3g', ...          
      trainGoodnessAvg_exclWeightPenalty_currChunk), ...
      sprintf('VALIDATION = %s', validReport_text));
   hold off;
   pause(0);

endfunction