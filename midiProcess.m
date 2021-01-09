%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) copyright 2021 Sepideh Shafiei (sepideh.shafiee@gmail.com), all rights reserved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MidiFileName = midiProcess(AudioName)
variables;

NoteNames={' C','Cs','Db','Dk'....
    ' D','Ds','Eb','Ek'....
    ' E','Fk',....
    ' F','Fs','F#','Gk'....
    ' G','Gs','Ab','Ak'....
    ' A','As','Bb','Bk'....
    ' B','Bs',...
    };

cd '/Users/sepid/Desktop/RadifAnalysis/AllMidis/'
myFolder='../AllMidis/';
files=AudioName;

midi = readmidi(AudioName);
Notes=midiInfo(midi,0);

j=1;          % index to the full Notes array
while (j~=-1)
    
    [MyNotes,MyNotesDuration,MyNotesDurationflt, MyNotesDurationInt,MySilences,...
        MySilencesInt,   MyMeasureSignature,   GusheNumber,j] =...
        myNotesProperties(myFolder, files,midi,Notes,j);
    
    if (j==-1)
        break
    end
    j=j+1;
    if j>size(Notes,1)
        j=-1;
    end
    
    histogram=zeros(300,1);
    for kh=1:length(MyNotes)
        if ( MyNotes(kh) ~= 0)
            histogram(MyNotes(kh))=histogram(MyNotes(kh))+1;
        end
    end
    
    for i=1:size(MyNotes,2)
        
        NoteString='';
        num=mod(MyNotes(i),24);
        oct = floor(MyNotes(i)/24)-3;
        str = char(NoteNames(num+1));
        
        if (MyNotesDurationInt(i)<22 && MyNotesDurationInt(i)>18)
            Duration="32nd note";
        elseif (MyNotesDurationInt(i)<42 && MyNotesDurationInt(i)>38)
            Duration="16th note";
        elseif (MyNotesDurationInt(i)<82 && MyNotesDurationInt(i)>78)
            Duration="8th  note";
        elseif (MyNotesDurationInt(i)<162 && MyNotesDurationInt(i)>158)
            Duration="quarter  ";
        elseif (MyNotesDurationInt(i)<242 && MyNotesDurationInt(i)>238)
            Duration="quarter. ";
        elseif (MyNotesDurationInt(i)<322 && MyNotesDurationInt(i)>318)
            Duration="half note";
        elseif (MyNotesDurationInt(i)<482 && MyNotesDurationInt(i)>478)
            Duration="half.    ";
        elseif (MyNotesDurationInt(i)<642 && MyNotesDurationInt(i)>638)
            Duration="whole    ";
        elseif (MyNotesDurationInt(i)<202 && MyNotesDurationInt(i)>198)
            Duration="qrtr+16th";
        elseif (MyNotesDurationInt(i)<62 && MyNotesDurationInt(i)>58)
            Duration="16th.    ";
        elseif (MyNotesDurationInt(i)<12 && MyNotesDurationInt(i)>8)
            Duration="64th     ";
        else
            Duration="unknown";
        end
        
        x=mod(MyMeasureSignature(i),10000);
        y=mod(MyMeasureSignature(i),(10000^2));
        z=(y-x)/10000;
        w=floor(MyMeasureSignature(i)/(10000^2));
        
    end
    
    strLen=length(char(AudioName));
    MidiFileName1=strcat(extractBetween(AudioName,1,strLen-5),".csv");
    MidiFileName=strcat("midi_",MidiFileName1);
    cd ../DataMidi
    
    fid=fopen(MidiFileName,'w');
    for i = 1:size(MyNotes,2)
        fprintf(fid,'%d %d %d 0 0 0 %f\n',MyNotes(i),MyNotesDurationInt(i),MySilencesInt(i),MyNotesDurationflt(i));
    end
    fclose(fid);
    
    Zprint=processAllNotes(MyNotes,MyNotesDuration,MyNotesDurationInt,GusheNumber,histogram);
    fprintf("midiProcess: out of process all notes %d   %s\n",GusheNumber, AudioName);
    
end
