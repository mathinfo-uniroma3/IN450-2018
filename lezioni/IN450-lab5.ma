(* Funzioni Ausiliarie *)
Pad[l_, lk_] := Join[l, Table[l[[i]], {i, 1, lk - Mod[Length[l], lk]}]];
Sort2[s_]:=Sort[s,(#1[[2]] > #2[[2]])&];

(* AFFINE *)
AFFINE = 2;
Test[AFFINE,key_,message_]:= ((Head[key]==List) && (Length[key] ==2) && (GCD[key[[1]],m]==1)
                             &&(key[[2]]>= 0) && (key[[2]] <=25));
EncodingFunction[AFFINE,k_,p_] := Mod[p k[[1]] + k[[2]], m] ;
DecodingFunction[AFFINE,k_,c_] := Mod[Expand[1/k[[1]], Modulus->m ](c - k[[2]]), m] ;


(* VIGENERE *)

VIGENERE = 3;
m=26;
Test[VIGENERE,k_,p_]:=True ;
EncodingFunction[VIGENERE,k_,p_] := Module[
                 {kk,lk,i},
                 (
                  kk = ToCharacterCode[k] - 97;
                  lk = Length[kk];
                  Table[  Mod[p[[i]] + kk[[Mod[i-1,lk]+1]] , m]   ,{i,1,Length[p]}]
)]

DecodingFunction[VIGENERE,k_,c_] :=  Module[
                 {kk,lk,i},
                 (
                  kk = ToCharacterCode[k] - 97;
                  lk = Length[kk];	
Print[kk, " ", lk, " ",m];	  
                  Table[  Mod[c[[i]] - kk[[Mod[i-1,lk]+1]] , m]   ,{i,1,Length[c]}]
)]

(* HILL *)

HILL = 4;
m=26;
Test[HILL,k_,p_]:=True ;

EncodingFunction[HILL,k_,p_] := Module[
                 {kk,lk,i,lp},
                 (
                  lk = Length[k];
                  lp=Pad[l, lk];
                  Flatten[
                      Table[
                           Mod[Take[lp, {i, i + lk - 1}].k, m], 
                           {i, 1, Length[l], lk}
                      ]
                  ]

(*                  Flatten[Table[ Mod[Take[p , {(i-1)*lk+1 ,i*lk}].k,m],{i,1,Length[p]/lk}]]*)
)]

DecodingFunction[HILL,k_,c_] :=  Module[
                 {kk,lk,i},
                 (
                  kinv = Inverse[k,Modulus->m];
                  lk = Length[kinv];	
                  Flatten[
                      Table[
                           Mod[Take[c, {i, i + lk - 1}].kinv, m], 
                           {i, 1, Length[l], lk}
                      ]
                  ]
)]


(* SHIFT *)

SHIFT = 1 ;
m = 26;

Test[SHIFT,key_,message_]:= ((key>= 0) && (key <=25));
EncodingFunction[SHIFT,k_,p_] := Mod[p + k, m] ;
DecodingFunction[SHIFT,k_,c_] := Mod[c - k, m] ;




(**************************** ciphercode ******************)

Codifica[cipher_,key_,msg_]:=
   Module[{plaintext,ciphercode},
       (
	If[Test[key,msg],
            (
             plaintext = ToCharacterCode[msg] - 97;
	     ciphercode = EncodingFunction[cipher,key,plaintext];
             FromCharacterCode[ciphercode + 97]
            ),
            (
             Print["exit"];
            )
         ]
       )
];


CodificaFile[cipher_,key_,msgfile_]:=
   Module[{plaintext,ciphercode},
       (
	plaintext = ToCharacterCode[Read[msgfile,String]] - 97;
	ciphercode = EncodingFunction[cipher,key,plaintext];
        FromCharacterCode[ciphercode + 97]
       )
];


DeCodifica[cipher_,key_,code_]:=
   Module[{plaintext,ciphercode},
       (
	ciphercode = ToCharacterCode[code] - 97;
	plaintext = DecodingFunction[cipher,key,ciphercode];
        FromCharacterCode[plaintext + 97]
       )
];



(********* CRITTOANALISI ***********)

SetFrequences[c_] := Module[
    {e},
    (
      e = Union[c];
      l = Length[c];
      Transpose[{e,Table[Length[Select[c, (# == e[[i]]) &]]/N[l], {i, 1, Length[e]}]}]
      )];

AlphaFrequences[c_] := Module[
    {e},
    (
      e = Table[i,{i,0,25}];
      l = Length[c];
      Transpose[{e,Table[Length[Select[c, (# == e[[i]]) &]]/N[l], {i, 1, Length[e]}]}]
      )];

osigma = {{"A", 0.082}, {"B", 0.015}, {"C", 0.028}, {"D", 0.043}, {"E", 
      0.127}, {"F", 0.022}, {"G", 0.020}, {"H", 0.061}, {"I", 0.070}, {"J", 
      0.002}, {"K", 0.008}, {"L", 0.040}, {"M", 0.024}, {"N", 0.067}, {"O", 
      0.075}, {"P", 0.019}, {"Q", 0.001}, {"R", 0.060}, {"S", 0.063}, {"T", 
      0.091}, {"U", 0.028}, {"V", 0.010}, {"W", 0.023}, {"X", 0.001}, {"Y", 
      0.020}, {"Z", 0.001}} ;

french_sigma=

cc=ToCharacterCode[c=CodificaFile[SHIFT,7,"testo"]]-97;

tamara="PRFCERZVREFZRFFNTRFFBAGYNCBHEGVGVYYREABFNQIREFNVERFDHVYFFNPURAGDHRWRARSRENVCNFYRFZRZRFREERHEFDHRYNAARRCNFFRRWRCBFGRENVQRFZRFFNTRFCYHFPBZCYVDHRFCYHFGNEQYBEFDHRZBACYNAQNPGVBAFRENCERGRANGGRAQNAGCERIRARMIBFPBAGNPGFQRABGERABHIRNHZBLRAQRPBZZHAVPNGVBA"

cc=ToCharacterCode[tamara]-65

osigman=Map[{(ToCharacterCode[#[[1]]]-65)[[1]],#[[2]]}&,osigma];

keymap=Transpose[{Sort2[AlphaFrequences[cc]],Sort2[osigman]}];

keycandidates=Map[(Mod[#[[1]][[1]]-#[[2]][[1]],m])&,keymap];

bestkeys=Sort2[SetFrequences[keycandidates]]

bestkey=bestkeys[[1]][[1]]

DeCodifica[SHIFT,bestkey,c]

