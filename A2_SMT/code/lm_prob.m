function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
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
  vocabSize = length(fieldnames(LM.uni));

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
  end
  if (isempty(type))
    delta = 0;
  elseif strcmp(type, 'smooth')
      
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta < 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  elseif ~strcmp(type, 'turing')
    disp( 'type must be either '''' or ''smooth'' or ''turing''' );
    return;
  end

  words = strsplit(' ', sentence);
  
  % Calculate log P(sentence) = P(w1|w0) x P(w2|w1) x ... x P(w_n|w_n-1)
  
  if strcmp(type, 'turing')
    logProb = good_turing(LM, words);
  else
    logProb = delta_smoothing(LM, words, delta, vocabSize);
  end

end

function logProb = delta_smoothing(LM, words, delta, vocabSize)

    logProb = 0;

    for w=2:length(words)
      
        first_word = words{w-1};
        second_word = words{w};

        count_first_word = 0;
        count_first_word_second_word = 0;

        if isfield(LM.bi, first_word)
            count_first_word = LM.uni.(first_word);
            %count_first_word = length(fieldnames(LM.bi.(first_word)));
        end

        if isfield(LM.bi, first_word) && isfield(LM.bi.(first_word), second_word)
            count_first_word_second_word = LM.bi.(first_word).(second_word);
        end

        if count_first_word == 0 && vocabSize == 0 && count_first_word_second_word == 0 && delta == 0
            cond_prob = 0;
        else
            cond_prob = (count_first_word_second_word + delta) / (count_first_word + delta*vocabSize);
        end

        logProb = logProb + log2(cond_prob);
      
    end

end


function logProb = good_turing(LM, words)

    % N = number of training instances
    % r = frequency of N-gram
    % N_r = number of bins that have r training instances
    %
    % For C(w1...w_n) = r > 0:
    % P(w1 ... w_n) = r*/N
    % r* = (r+1)*S(r+1)/S(r)
    %
    % For r = 0:
    % P(w1 ... w_n) ~ N_1/(N_0*N)
    %
    % P(w_n|w_n-1) = P(w_n-1, w_n) / P(w_n-1)

    
    % Calculate N and Calculate N_r - the number of bins with freq r.
    N = 0;
    N_r = java.util.Hashtable;
    N_r.put(0,0); % Make sure these fields exist
    N_r.put(1,0);


    f = fieldnames(LM.uni);
    for i=1:length(f)
        word = f{i};
        r = LM.uni.(word);
        N = N + r;
        if ~N_r.containsKey(r)
          N_r.put(r,1);
        else
          N_r.put(r, N_r.get(r)+1);
        end
    end

    % Find a smoothing curve of the form S(r) = N_r = a*r^b where b < -1
    % estimated by log(N_r) = a + b log(r)

    % We have everything we need in N_r.
    X = [];
    Y = [];

    N_r_freqs = N_r.keySet().toArray();
    for i=1:length(N_r_freqs)
      r = N_r_freqs(i);
      X(i) = log2(r);
      Y(i) = log2(N_r.get(r));
    end

    S = polyfit(X, Y, 1);

    % Free up resources
    clear X Y

    % Finally calculate log-probability
    logProb = 0;

    for w=2:length(words)

      first_word = words{w-1};
      second_word = words{w};

      % Calculate P(first_word second_word)

      if isfield(LM.bi, first_word) && isfield(LM.bi.(first_word), second_word)
        r = LM.bi.(first_word).(second_word);
      else
        r = 0;
      end

      if r == 0
        if N_r.get(0) == 0 || N == 0
          prob_first_word_second_word = 0;
        else
          prob_first_word_second_word = N_r.get(1) / (N_r.get(0) * N);
        end
      else
        r_star = (r+1) * polyval(S,r+1) / polyval(S,r);
        prob_first_word_second_word = r_star / N;
      end

      % Calculate P(first_word)
      if isfield(LM.uni, first_word)
        r = LM.uni.(first_word);
      else
        r = 0;
      end

      if r == 0
        if N_r.get(0) == 0 || N == 0
          prob_first_word = 0;
        else
          prob_first_word =  N_r.get(1) / (N_r.get(0) * N);
        end
      else
        r_star = (r+1) * polyval(S,r+1) / polyval(S,r);
        prob_first_word = r_star / N;
      end

      if prob_first_word == 0
        prob = 0;
      else
        prob = prob_first_word_second_word / prob_first_word;
      end

      logProb = logProb + log2(prob);

    end

    

end


