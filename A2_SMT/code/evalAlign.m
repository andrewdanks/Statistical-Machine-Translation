
function evalAlign()


    trainDir     = '../data/Hansard/Training';
    testDir      = '../data/Hansard/Testing';
    fn_LME       = '../fn_LME';
    fn_LMF       = '../fn_LMF';


    numSentences = [1000, 10000, 15000, 30000];
    deltas = [0, 0.25, 0.5, 0.75]; 

    % Train language models
    LME = lm_train( trainDir, 'e', fn_LME );
    LMF = lm_train( trainDir, 'f', fn_LMF );
    
    vocabSizeEng = length(fieldnames(LME.uni));
    vocabSizeFre = length(fieldnames(LMF.uni));
    
    for d=1:length(deltas)
        disp(perplexity(LME, testDir, 'e', 'smooth', deltas(d)));
        disp(perplexity(LMF, testDir, 'f', 'smooth', deltas(d)));
    end
    
    

    % Get the sentences to be used for evaluation
    english_sentences = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
    french_sentences = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');
    

    eng = cell(length(french_sentences));

    for n=1:length(numSentences)
        AMFE = align_ibm1( trainDir, numSentences(n) );
        for f=1:length(french_sentences)
            fre = preprocess(french_sentences{f}, 'f');
            % Decode the test sentence 'fre'
            for d=1:length(deltas)
                eng{f} = decode( fre, LME, AMFE, 'smooth', deltas(d), vocabSizeEng );
            end
        end
    end
    
    perform_analysis(english_sentences, eng);
    
end

% Analysis.
function perform_analysis(english_sentences, eng)

    total_sentences = length(eng);

    total_prop = 0;
    for i=1:total_sentences
        correct_words = strsplit(' ', english_sentences{i} );
        test_words = strsplit(' ', eng{i} );
        correct = 0;
        for w=1:length(test_words)
            if test_words{w} == correct_words{w}
                correct = correct + 1;
            end
        end
        proportion_correct = correct / length(correct_words);
        disp(['Correct for sentence', int2str(i), ':', proportion_correct]);
        total_prop = total_prop + proportion_correct;
    end

    average = total_prop / total_sentences;
    disp(['Average proportion correct:', int2str(average)]);

end
