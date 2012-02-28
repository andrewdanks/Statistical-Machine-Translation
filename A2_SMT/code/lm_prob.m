function logProb = lm_prob(sentence, LM, type, delta, ~)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    %vocabSize = length(fieldnames(LM.uni));
    vocabSize = 0;
  end
  if (isempty(type))
    delta = 0;
    %vocabSize = length(fieldnames(LM.uni));
    vocabSize = 0;
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
    vocabSize = length(fieldnames(LM.uni));
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);
  
  % Calculate P(sentence) = P(w1|w0) x P(w2|w1) x ... x P(w_n,w_n-1)
  
  P = 1;
  
  for w=2:length(words)
      
    first_word = words{w-1};
    second_word = words{w};
    
    count = 0;
    freq = 0;
    if isfield(LM.bi, first_word)
        count = length(fieldnames(LM.bi.(first_word)));
        if isfield(LM.bi.(first_word), second_word)
            freq = LM.bi.(first_word).(second_word);
        end 
    end
    
    if count == 0 && freq == 0 && delta == 0 && vocabSize == 0
        cond_prob = 0;
    else
        cond_prob = (freq + delta) / (count + vocabSize);
    end
    
    P = P * cond_prob;
      
  end
  
  logProb = log(P);
  
  return

end