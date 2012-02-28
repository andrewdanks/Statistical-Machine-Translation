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
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
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

function [eng, fre] = read_hansard(dir, numSentences)
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
    eng = {};
    fre = {};
  
    DD = dir([ dataDir, filesep, '*', 'e']);

    for iFile=1:length(DD)
        
        english_file_name = DD(iFile).name;
        french_file_name = strcat(english_file_name(1:length(english_file_name)-1), 'f'); 
        
        english_lines = textread([dataDir, filesep, english_file_name], '%s','delimiter','\n');
        french_lines = textread([dataDir, filesep, french_file_name], '%s','delimiter','\n');
        
  
        for i=1:length(english_lines)
            
            if i > numSentences
                break
            end
            
            eng{i} = strsplit(' ', preprocess(english_lines{i}, 'e'));
            fre{i} = strsplit(' ', preprocess(french_lines{i}, 'f'));
      
        end

    end
  

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    for i=1:length(eng)
        
        english_sentence = eng{i};
        french_sentence = fre{i};
        
        for j=1:length(english_sentence)
            english_word = eng{i}{j};
            
            if ~isfield(AM, english_word)
               AM.(english_word) = {}; 
            end
            
            for k=1:length(french_sentence)
                french_word = fre{i}{k};
                
                if ~isfield(AM.(english_word), french_word)
                    AM.(english_word).(french_word) = 1;
                end
                
            end
            
        end
        
    end
    
    
    for e=1:length(fieldnames(AM))
        
        f1 = fieldnames(AM);
        english_word = AM.(f1{e});
        
        for f=1:lengh(fieldnames(AM.(english_word)))
            
            f2 = fieldnames(AM.(english_word));
            french_word = AM.(f1{e}).(f2{f});
            
            AM.(english_word).(french_word) = 1 / length(f2);
            
        end
        
        
    end
    
    
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
    tcount = {};
    total = {};
    
    % Set tcounts to 0 for each (f,e)
    for i=1:length(eng)
       for j=1:length(eng{i})
          tcount.(eng{i}{j}).(fre{i}{j}) = 0;
       end
    end
    
    % Set total to 0 for each (e)
    for i=1:length(eng)
       for j=1:length(eng{i})
          total.(eng{i}{j}) = 0;
       end
    end
    
    for s=1:length(eng)
        
        english_sentence = eng{s};
        french_sentence = fre{s};
        
        french_words_seen = {};
        
        for f=1:length(french_sentence)
            french_word = french_sentence{f};
            
            if ~isfield(tcount, french_word)
                tcount.french_word = {};
            end
            
            if ~isfield(french_words_seen, french_word)
                
                french_words_seen.(french_word) = 1; % mark seen
                denom_c = 0;
                
                english_words_seen = {};
                
                for e=1:length(english_sentence)
                    
                    english_word = english_sentence{e};
                    
                    if ~isfield(english_words_seen, english_word)
                        english_words_seen.(english_word) = 1; % mark seen
                        denom_c = denom_c + (t.(english_word).(french_word) * count(french_word, french_sentence));
                    end
                    
                end
                
                english_words_seen = {};
                
                for e=1:length(english_sentence)
                    
                    english_word = english_sentence{e};
                    
                    if ~isfield(tcount.(french_word), english_word)
                        tcount.(french_word).(english_word) = 0;
                    end
                    
                    if ~isfield(total, english_word)
                        tcount.(english_word) = 0;
                    end
                    
                    if ~isfield(english_words_seen, english_word)
                        english_words_seen.(english_word) = 1; % mark seen
                        prob_f_e = t.(english_word).(french_word);
                        tcount.(french_word).(english_word) = tcount.(french_word).(english_word) + (prob_f_e * count(english_word, english_sentence)) / denom_c;
                        total.(english_word) = total.(english_word) + (prob_f_e * count(english_word, english_sentence) * count(french_word, french_sentence)) / denom_c;
                    end
                    
                end
                
            end
            
        end
        
    end
    
end
                        
                        
                        

function n = count(element, cell)
    n = 0;
    for i=1:length(cell)
        if cell{i} == element
            n = n + 1;
        end
    end
end




