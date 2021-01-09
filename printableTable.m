%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) copyright 2021 Sepideh Shafiei (sepideh.shafiee@gmail.com), all rights reserved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rangeStringArray] = printableTable(A, NoteNames,rangeStringArray)

for p=1:size(A,1)
    SequenceString='';
    for q = 1:size(A,2)
        if (A(p,q) == 0)
            SequenceString=strcat(SequenceString,'+++++');
            continue
        end
        num=mod(A(p,q),24);
        oct = floor(A(p,q)/24)-3;
        str = char(NoteNames(num+1));
        t1=num2str(oct);
        t2 = str;
        SequenceString=strcat(SequenceString,t2, t1,'--');
    end
    SequenceString=strcat(SequenceString,'....');
    rangeStringArray(end+1)={SequenceString}; 
end
end

