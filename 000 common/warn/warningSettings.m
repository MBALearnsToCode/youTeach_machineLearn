%warning('on', 'matlab-incompatible');
   % these is turned off because much of Octave's base code
   % has Matlab-incompatible details
warning('off', 'Octave:single-quote-string');
warning('off', 'Octave:separator-insert');
warning('off', 'Octave:possible-matlab-short-circuit-operator');
warning ('error', 'Octave:divide-by-zero');