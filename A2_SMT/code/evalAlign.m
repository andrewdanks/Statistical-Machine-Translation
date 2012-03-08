
function evalAlign(LME, LMF, deltas)

    global CSC401_A2_DEFNS

    vocabSizeEng = length(fieldnames(LME.uni));    
    

    % Get the sentences to be used for evaluation
    english_sentences = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
    french_sentences = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');

    numSentences = [1000, 10000, 15000, 30000];

    for n=1:length(numSentences)

        disp(['ANALYSIS WITH ' num2str(numSentences(n))] ' SENTENCES FOR AM MODEL...');

        AM = align_ibm1( CSC401_A2_DEFNS.TRAIN_DIR, numSentences(n), 20, strcat('AMFE_',int2str(numSentences(n),'.mat') );
        test_english_sentences = cell(length(english_sentences));

        for f=1:length(french_sentences)
            french_sentence = preprocess(french_sentences{f}, 'f');
            test_english_sentences{f} = decode2( french_sentence, LME, AM, '', 0, vocabSizeEng );
        end

        perform_analysis(english_sentences, test_english_sentences);

        disp('----------------------------------------------');

        %end

    end
    
end

% Analysis.
function perform_analysis(english_sentences, test_sentences)

    total_sentences = length(eng);

    total_prop = 0;
    for i=1:total_sentences
        correct_words = strsplit(' ', english_sentences{i} );
        test_words = strsplit(' ', test_sentences{i} );
        correct = 0;
        for w=1:min(length(test_words),length(correct_words))
            if test_words{w} == correct_words{w}
                correct = correct + 1;
            end
        end
        proportion_correct = correct / length(correct_words);
        disp(['Correct for sentence ', num2str(i), ':', proportion_correct]);
        total_prop = total_prop + proportion_correct;
    end

    average = total_prop / total_sentences;
    disp(['Average proportion correct: ', num2str(average)]);

end
