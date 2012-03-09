function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., AM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
   
  global CSC401_A2_DEFNS
    
  % Read in the training data
  % We use avg_english_sentence_length to determine how many NULL tokens to
  % add to the english sentence.
  [eng, fre, avg_eng_sentence_length] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter
    disp(['em_step iteration ', int2str(iter)]);
    AM = em_step(AM, eng, fre, avg_eng_sentence_length);
  end 

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  return
  
end


% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre, avg_eng_sentence_length] = read_hansard(trainDir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
    eng = cell(numSentences);
    fre = cell(numSentences);
    
    DD = dir( [ trainDir, filesep, '*', 'e'] );
    
    sentence_number = 1;

    avg_eng_sentence_length = 0;

    for iFile=1:length(DD)
        
        if sentence_number > numSentences
            break
        end
        
        english_file_name = DD(iFile).name;
        french_file_name = strcat(english_file_name(1:length(english_file_name)-1), 'f');
        
        english_lines = textread([trainDir, filesep, english_file_name], '%s','delimiter','\n');
        french_lines = textread([trainDir, filesep, french_file_name], '%s','delimiter','\n');

        avg_eng_sentence_length_file = 0;
  
        for i=1:length(english_lines)
            
            if sentence_number > numSentences
                break
            end
            
            words = strsplit(' ', preprocess(english_lines{i}, 'e'));
            eng{sentence_number} = words(2:length(words)-1); % skip SENTSTART / SENTEND

            words = strsplit(' ', preprocess(french_lines{i}, 'f'));
            fre{sentence_number} = words(2:length(words)-1);
            
            sentence_number = sentence_number + 1;

            avg_eng_sentence_length_file = avg_eng_sentence_length_file + length(fre);
      
        end

        avg_eng_sentence_length_file = avg_eng_sentence_length_file / length(french_lines);
        avg_eng_sentence_length = avg_eng_sentence_length + avg_eng_sentence_length_file;

    end

    avg_eng_sentence_length = avg_eng_sentence_length / length(DD);
  

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)
    AM.NULL_ = struct();

    for i=1:length(eng)
        
        english_sentence = eng{i};
        french_sentence = fre{i};
        
        for j=1:length(english_sentence)
            
            english_word = eng{i}{j};
            
            if ~isfield(AM, english_word)
               AM.(english_word) = struct(); 
            end
            
            for k=1:length(french_sentence)
                french_word = fre{i}{k};
                AM.(english_word).(french_word) = 1;
            end
            
        end
        
    end
    
    
    % Set of all unique english words
    f1 = fieldnames(AM);
    
    for e=1:length(f1)
        
        english_word = f1{e};
        
        % All french words possibly aligned with english_word
        f2 = fieldnames(AM.(english_word));
        
        
        for f=1:length(f2)         
            french_word = f2{f};          
            AM.(english_word).(french_word) = 1 / length(f2);         
        end 
        
    end
    
    
end


function distortion = initialize_D(eng, fre)

    % Implement the Distortion model such that the probability
    % for D(i|i,L_E,L_F) is high and the probability for
    % D(i|j,L_E,L_F) is uniform.

    distortion = 0;

end


function t = em_step(t, eng, fre, AVG_ENG_LEN)
% 
% One step in the EM algorithm.
%

    tcount = struct();
    total = struct();
    

%   It is much slower to initialize first then
%   go through with E-M. We will initialize
%   the necessary tcounts/total when we get
%   to the field

%   disp('Initializing tcount/total values...');
    % Set tcounts to 0 for each (f,e)
%     for i=1:length(eng)
%       for j=1:length(eng{i})
%           english_word = eng{i}{j};
%           
%           if ~isfield(tcount, english_word) && ~isfield(total, english_word)
%              tcount.(english_word) = struct();
%              total.(english_word) = 0;
%           end
%           
%           for k=1:length(fre)
%               for l=1:length(fre{k})
%                   french_word = fre{k}{l};
%                   tcount.(english_word).(french_word) = 0;
%               end
%           end
% 
%       end
%     end

    
    disp('Running Expectation step...');
    
    % Expectation / Tractable M-Step
    
    for s=1:length(eng)
                
        english_sentence = eng{s};
        french_sentence = fre{s};


        % Add NULL token: We could add a certain number of NULL_tokens
        % proportional to the sentence length, but it's difficult to 
        % know if a sentence is long or short if we don't know the
        % average. For future reference, it could have been useful
        % to know the variance, as well.
        for x=1:min(3,length(english_sentence)-round(AVG_ENG_LEN))
            english_sentence{length(english_sentence)+1} = 'NULL_';
        end

        french_words_seen = struct();
        
        for f=1:length(french_sentence)
            
            french_word = french_sentence{f};
            
            if isfield(french_words_seen, french_word)
                continue
            end
                
            french_words_seen.(french_word) = 1; % mark seen
            
            % Calculate denom_c
            denom_c = 0;
            english_words_seen = struct();
            for e=1:length(english_sentence)
                english_word = english_sentence{e};
                if ~isfield(english_words_seen, english_word) && isfield(t, english_word) && isfield(t.(english_word), french_word)
                    english_words_seen.(english_word) = 1; % mark seen
                    denom_c = denom_c + (t.(english_word).(french_word) * count(french_word, french_sentence));
                end
            end
            

            english_words_seen = struct();
            for e=1:length(english_sentence)

                english_word = english_sentence{e};
                
                if isfield(english_words_seen, english_word)
                    continue
                end
                
                % Initialize Tcount and Total?
                if ~isfield(tcount, english_word)
                    tcount.(english_word) = struct();
                end
                if ~isfield(tcount.(english_word), french_word)
                    tcount.(english_word).(french_word) = 0;
                end
                if ~isfield(total, english_word)
                    total.(english_word) = 0;
                end
                % Done possible initializations
                
                english_words_seen.(english_word) = 1; % mark seen
                
                % Current probability that french_word is aligned with
                % english_word
                prob_f_e = t.(english_word).(french_word);
                

                % Compute expectations

                to_add = (prob_f_e * count(english_word, english_sentence) * count(french_word, french_sentence)) / denom_c;
                
                tcount.(english_word).(french_word) = tcount.(english_word).(french_word) + to_add;
                total.(english_word) = total.(english_word) + to_add;


            end
                
            
            
        end
        
    end
  
    disp('Running maximization step...');
    
    % Maximization step.
    fieldnames_total = fieldnames(total);
    for e=1:length(fieldnames_total)
        english_word = fieldnames_total{e};
        fieldnames_tcount = fieldnames(tcount.(english_word));
        for f=1:length(fieldnames_tcount)
            french_word = fieldnames_tcount{f};
            t.(english_word).(french_word) = tcount.(english_word).(french_word) / total.(english_word);
        end
    end
    
end
                        
                        
                        
% This is a helper function to count instances of 'element' in 'cell'
function n = count(element, cell)
    n = 0;
    for i=1:length(cell)
        if strcmpi(cell{i}, element)
            n = n + 1;
        end
    end
end




