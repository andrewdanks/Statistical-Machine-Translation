
% Use this function to generate the necessary paramters for running
% evalAlign and evalPerplexity

function [LME, LMF, deltas] = function evalStart()

	global CSC401_A2_DEFNS

    % Train language models
    LME = lm_train( CSC401_A2_DEFNS.TRAIN_DIR, 'e', 'model_LME.mat' );
    LMF = lm_train( CSC401_A2_DEFNS.TRAIN_DIR, 'f', 'model_LMF.mat' );

    deltas = [0, 0.25, 0.5, 0.75, 1.0];

end

