%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) copyright 2021 Sepideh Shafiei (sepideh.shafiee@gmail.com), all rights reserved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MyNotes,MyNotesDuration,MyNotesDurationflt,MyNotesDurationInt,MySilences,...
    MySilencesInt,MyMeasureSignature,GusheNumber,j] = ...
    myNotesProperties(myFolder, files,midi,Notes,j)

MyNotes=[]; %sept 2020 --- but need to do it for all return args.
GusheNumber=0;  % is this being used? DOes this handle more than one Gushe?

% This covers for the cases where pitch bend and note have the same ticks but pich bend
% appears in the row after the note...Need to cover the exceptional cases where we
% have two consectutive pitch bends on the same tick and a note after them with the same tick.

for i=1:size(Notes,1)-1
    if ((Notes(i,5)==Notes(i+1,5)) && (Notes(i+1,9)~=0)) % Note(i ,9)=pitch bend, Notes(i,5)=start time
        ttt= Notes(i+1,:);
        Notes(i+1,:)= Notes(i,:);
        Notes(i,:)=ttt;
    end
end

MAXGUSHESIZE=2500;

while (j<=size(Notes,1))  %for all in Notes arrray
    %fprintf("j=%d\n", j);
    if ( j == 3)
        fprintf("j=2\n");
    end
    if j>size(Notes,1)
        j=-1;
        return
    end
    MyNotesindex=1;
    MyNotesDuration=zeros(MAXGUSHESIZE,1);
    MyNotesDurationInt=zeros(MAXGUSHESIZE,1);
    MySilences=zeros(MAXGUSHESIZE,1);
    MySilencesInt=zeros(MAXGUSHESIZE,1);
    MyMeasureSignature=zeros(MAXGUSHESIZE,1);
    MicroT=0;
    endOfGushe=false;
    
    
    while (endOfGushe==false)
        
        %{
        if (j==size(Notes,1)) %if it reaches the end of file (only one midi)
            endOfGushe=true;
            fprintf(" myNotesProperties: End of Gushe 581\n")
            GusheNumber=GusheNumber+1;
            return; % sept 2020 sh
        end
        %}
        if(Notes(j,10)==176)   %looking for EndofGushe,
            
            endOfGushe=true;
            return
            
            fprintf("myNotesProperties: NEW GUSHE %d  %d\n",Notes(j,10),Notes(j,3));
            GusheNumber=GusheNumber+1;
            
            
        elseif (Notes(j,10)==88)
            
            MyMeasureSignature(MyNotesindex)=Notes(j,12);
            
        elseif ((Notes(j,9))==-2048 || (Notes(j,9))==-341 || (Notes(j,9))==-1540 || (Notes(j,9))==-682)  %PitchBend.   Need to take care of other conventions... later -361 is not a real pitch bend.. it was among Joel mistakes... thats why we have it.
            MicroT=-1;
            
            if (j>1)
                Notes(j,5)=Notes(j-1,5);
                Notes(j,6)=Notes(j-1,6);
            end
        elseif ((Notes(j,9))==2048)  %PitchBend.   Need to take care of other conventions... later
            MicroT=1;
            if (j>1)
                Notes(j,5)=Notes(j-1,5);
                Notes(j,6)=Notes(j-1,6);
            end
            
        elseif Notes(j,9)==-1
            MicroT=0;
            if (j>1)
                Notes(j,5)=Notes(j-1,5);
                Notes(j,6)=Notes(j-1,6);
            end
        elseif (Notes(j,9)==0)  % it is a note and not a pitchbend
            
            MyNotes(MyNotesindex)=Notes(j,3)*2+MicroT;
            if(j>3)
                %if ((   Notes(j-1,10)==88   ) && j >2 )
                r=1;
                ThereIsNoNote=false;
                while (Notes(j-r,3)< 1)  % not a note...
                    
                    if (j-r==1)
                        ThereIsNoNote=true;
                        break
                    end
                    r=r+1;
                end
                %-5= measure .  -4=endofgushe .   -3 = pitchbend
                
                if (ThereIsNoNote==true)
                    MySilences(MyNotesindex)=0;
                else
                    MySilences(MyNotesindex)=Notes(j,5)-Notes(j-r,6);
                end
                
                MySilencesInt(MyNotesindex)=round ( (MySilences(MyNotesindex))  * 10000000*16  /Notes(j,11)  );
            end
            
            
            MyNotesDuration( MyNotesindex) = (Notes(j,6) - Notes(j,5)); %/midi ticks_per_quarter_note
            MyNotesDurationInt( MyNotesindex) = round (   (Notes(j,6) - Notes(j,5))  * 10000000*16  /Notes(j,11)  );
            MyNotesDurationflt( MyNotesindex) =  (   (Notes(j,6) - Notes(j,5))  * 10000000*16  /Notes(j,11)  );
            %MyNotesDurationInt( MyNotesindex) = round((Notes(j,6) - Notes(j,5))/0.0625);
            
            
            if (  MyNotesDurationInt( MyNotesindex)  < 7)%((Notes(j,6) - Notes(j,5))/0.0625)< .7 )
                fprintf("myNotesProperties:  ******** sub 4la-chang note! j=%d  duration=%d   -- \n",j, MyNotesDurationInt( MyNotesindex));%(Notes(j,6) - Notes(j,5))/0.0625,(Notes(j,6) - Notes(j,5)), Notes(j,6),Notes(j,5));
            end
            
            MyNotesindex=MyNotesindex + 1;
        else
            fprintf("myNotesProperties: ******error-pitch bend not recognized %d\n",Notes(j,9))
        end
        
        
        if (MyNotesindex>MAXGUSHESIZE)
            fprintf("myNotesProperties: ERROR GUSHE SIZE TOO BIG %d, %d\n", j,MyNotesindex);
            error('myNotesProperties: ERROR GUSHE SIZE TOO BIG');
        end
        
        if (j==size(Notes,1)) %if it reaches the end of file (only one midi)
            endOfGushe=true;
            fprintf(" myNotesProperties: End of Gushe 581\n")
            GusheNumber=GusheNumber+1;
            return; % sept 2020
        end
        
        j=j+1;
        
    end % of Gushe loop
end

if ~exist('MyNotes','var')
    error("MyNotesProperties: MyNotes not created!");
end

end


