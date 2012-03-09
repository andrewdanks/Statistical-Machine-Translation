% Analysis.
function show_analysis(english_sentences, test_sentences)

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