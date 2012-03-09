
function evalAlign(LME, LMF)

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

        show_analysis(english_sentences, test_english_sentences);

        disp('----------------------------------------------');

    end
    
end

