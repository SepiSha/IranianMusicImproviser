%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) copyright 2021 Sepideh Shafiei (sepideh.shafiee@gmail.com), all rights reserved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Zprint = processAllNotes(MyNotes,MyNotesDuration,MyNotesDurationInt,GusheNumber,histogram)

NoteNames={' C','Cs','Db','Dk'....
    ' D','Ds','Eb','Ek'....
    ' E','Fk',....
    ' F','Fs','F#','Gk'....
    ' G','Gs','Ab','Ak'....
    ' A','As','Bb','Bk'....
    ' B','Bs',...
    };

%Find end of sequences
c=MyNotesDurationInt>160; % larger than 8th note
EndofSequencesIndex1=find(c);
EndofSequencesIndex=[0;EndofSequencesIndex1];
NoteSequence=zeros(size(EndofSequencesIndex,1),80);


for i=2:length(EndofSequencesIndex)
    NoteSequence(i-1,1:length(MyNotes(  EndofSequencesIndex(i-1)+1:EndofSequencesIndex(i)  )))=...
        MyNotes(   EndofSequencesIndex(i-1)+1:EndofSequencesIndex(i)   );
end

A=NoteSequence(any(NoteSequence,2),:);  %remove all-zero rows


Z=zeros(size(A,1),size(A,2)); % make a new sorted (rows) matrix eliminating the repeated notes in a segment
for m=1:size(A,1)
    Z(m,1:size(unique(A(m,:)),2))=unique(A(m,:)); %unique sorts
end

Z1=Z(any(Z,2),any(Z,1));  % only the non-zero rows and columns of the matrix Z
rangeStringArray={};

% This part transforms the notes from midi number (e.g. 120) to note name plus octave (e.g. F2)
% and put the sequence of notes in the printable table.

rangeStringArray = printableTable(A, NoteNames,rangeStringArray);
rangeStringArray(end+1)={'****************  FindingRangeofSequences1'};
transpose(rangeStringArray);
% lists the unique elements of each sequence: (range) of each sequence

rangeStringArray = printableTable(Z1, NoteNames,rangeStringArray);
rangeStringArray(end+1)={'*************  AllRangesofTheGushe'};
transpose(rangeStringArray);

% This loop eliminates the ranges that are a subsequence of other ranges
% rows that are subsequence of other rows)
Z1 = [Z1 zeros(size(Z1,1))]; % add a column of zero to Z1 for ismember to work

for p=1:size(Z1,1)
    for q=1:size(Z1,1)
        if(p~=q);
            if (all (ismember   (Z1(p,:),Z1(q,:))  ))
                Z1(p,:)=0;
            end
        end
    end
end

X=Z1(any(Z1,2),:);
Zprint= zeros(size(X,1), 24*3);

%fixed-length format for printing so that the same notes in different sequences are located below each other

for p=1:size(X,1)
    for q = 1:size(X,2)
        if (X(p,q) == 0)
            continue
        end
        
        if (X(p,q)<96)
            fprintf("ERROR96 . %d\n",X(p,q));
            X(p,q)=X(p,q)+24;
        end
        
        if ((p<1) || (q<1)) % this should be removed??
            error("ERROR pq0\n")
        end
        Zprint(p, X(p,q)-95)=X(p,q);
        num=mod(X(p,q),24);
        oct = floor(X(p,q)/24)-3;
        str = char(NoteNames(num+1));
 
    end
    if ( any(X(p,:)))
        %fprintf("====\n");
    end
end

Zprint=Zprint(any(Zprint,2),any(Zprint,1));
firstIndex=size(rangeStringArray,2);
rangeStringArray = printableTable(Zprint, NoteNames,rangeStringArray);
lastIndex=size(rangeStringArray,2);
transpose(rangeStringArray(firstIndex:lastIndex));
