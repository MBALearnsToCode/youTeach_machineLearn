function f = predictPokerHands(pokerHands_texts = '', ...
   loadFileName = 'ffNN_poker.mat')
   
   ffNN = ffNN_loadFile(loadFileName);
   if strcmp(pokerHands_texts, '')
      pokerHands_texts = ...
         {'0h Jc Js Jd 8c', ...          
          '4s 4d 0s 7h 0d', ...
          '5c 5s Kc Kh Ks', ...
          '6c 6d 8h 9h 0h', ...
          '6d 5h 3s 4h 7h', ...
          '4c 8c 9c Kc Jc', ...
          'Jc 8c Ac 0c 9c', ...
          '4c 5c 6c 7c Kc', ...
          '4d 5d 6d 7d 0d', ...
          'Ks Jd Qd 0h As', ...
          'Ac 8d Ad As Ah', ...
          '2h 3h 4h 5h 6h'}
   else
      pokerHands_texts      
   endif   
   pokerHands = convertTexts_toPokerHands(pokerHands_texts);
   pokerHands_labels = predict(ffNN, pokerHands);
   if iscell(pokerHands_texts)
      for i = 1 : length(pokerHands_labels)
         f{i} = const_pokerHandLabels(){pokerHands_labels(i)};
      endfor
   else
      f = const_pokerHandLabels(){pokerHands_labels};
   endif
   
endfunction