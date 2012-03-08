
function evalPerplexity(LME, LMF, deltas)

	global CSC401_A2_DEFNS

    testDir = CSC401_A2_DEFNS.TEST_DIR;

    for d=1:length(deltas)
        disp(['LME smooth perplexity: ', 'delta=', int2str(d), ', ', int2str(perplexity(LME, testDir, 'e', 'smooth', deltas(d)))]);
        disp(['LMF smooth perplexity: ', 'delta=', int2str(d), ', ', int2str(perplexity(LMF, testDir, 'f', 'smooth', deltas(d)))]);
    end

    disp(['LME GT perplexity: ', int2str(perplexity(LME, testDir, 'e', 'turing', 0)]);
    disp(['LMF GT perplexity: ', int2str(perplexity(LMF, testDir, 'f', 'turing', 0)]);


end