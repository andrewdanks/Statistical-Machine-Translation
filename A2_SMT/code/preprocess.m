function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

% out = regexprep(out, '\*', CSC401_A2_DEFNS.STAR);
% out = regexprep(out, '\-', CSC401_A2_DEFNS.DASH);
% out = regexprep(out, '\+', CSC401_A2_DEFNS.PLUS);
% out = regexprep(out, '\=', CSC401_A2_DEFNS.EQUALS);
% out = regexprep(out, '\,', CSC401_A2_DEFNS.COMMA);
% out = regexprep(out, '\.', CSC401_A2_DEFNS.PERIOD);
% out = regexprep(out, '\?', CSC401_A2_DEFNS.QUESTION);
% out = regexprep(out, '\!', CSC401_A2_DEFNS.EXCLAM);
% out = regexprep(out, ':', CSC401_A2_DEFNS.COLON);
% out = regexprep(out, ';', CSC401_A2_DEFNS.SEMICOLON);
% out = regexprep(out, '''', CSC401_A2_DEFNS.SINGQUOTE);
% out = regexprep(out, '"', CSC401_A2_DEFNS.DOUBQUOTE);
% out = regexprep(out, '`', CSC401_A2_DEFNS.BACKQUOTE);
% out = regexprep(out, '\(', CSC401_A2_DEFNS.OPENPAREN);
% out = regexprep(out, '\)', CSC401_A2_DEFNS.CLOSEPAREN);
% out = regexprep(out, '\[', CSC401_A2_DEFNS.OPENBRACK);
% out = regexprep(out, '\]', CSC401_A2_DEFNS.CLOSEBRACK);
% out = regexprep(out, '/', CSC401_A2_DEFNS.SLASH);
% out = regexprep(out, '\$', CSC401_A2_DEFNS.DOLLAR);
% out = regexprep(out, '\%', CSC401_A2_DEFNS.PERCENT);
% out = regexprep(out, '\&', CSC401_A2_DEFNS.AMPERSAND);
% out = regexprep(out, '<', CSC401_A2_DEFNS.LESS);
% out = regexprep(out, '>', CSC401_A2_DEFNS.GREATER);
% out = regexprep(out, '^(\d)', 'N$1');  % leading digit only
% out = regexprep(out, '\s(\d)', ' N$1');  % leading digit only


  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');
  outSentence = regexprep( outSentence, '([`"\*,:;\(\)\[\]/\+\-<>\=\.\?\!\\$\%\&])', ' $1 ' );

  switch language
   case 'e'
    outSentence = regexprep( outSentence, '([a-z]+)(''ve) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+)(''m) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+)(''s) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+)(n''t) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+)(''d) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+)(''ll) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+)(''re) ', '$1 $2 ', 'ignorecase' );
    outSentence = regexprep( outSentence, '([a-z]+s)('') ', '$1 $2 ', 'ignorecase' );
    
    
   case 'f'
    outSentence = regexprep( outSentence, ' (l'')([a-z])', ' $1 $2', 'ignorecase' );
    % Separate ___qu'(on/il) -> ___qu' (on/il)
    outSentence = regexprep( outSentence, '(qu'')(on|il)', '$1 $2', 'ignorecase' );

  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

