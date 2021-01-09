%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) copyright 2021 Sepideh Shafiei (sepideh.shafiee@gmail.com), all rights reserved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this code takes a piece (MIDI format) and improvises another piece  based on its statistics
% and return a MIDI file as output.
% This has been tested for Persian Classical Music and we have provided the
% code with cyclic matrix of rhythms based on poetic meter.

% Algorithm: We have used Bigrams


midi = readmidi('chahargah-talayi-1 Daramad-e avval.midi');
MidiFileName = midiProcess('chahargah-talayi-1 Daramad-e avval.midi');
MidiData=load(MidiFileName);
MyNotes=MidiData(:,1);

ProbabilityMatrix=zeros(500,500); % probability array: P(x, y) is the probability of note y comming after note x
for i=1:size(MyNotes,1)-1
    ProbabilityMatrix(MyNotes(i),MyNotes(i+1))=ProbabilityMatrix(MyNotes(i),MyNotes(i+1))+1;
end

columnSum=sum(ProbabilityMatrix); %sum of the elements of columns
rowSum=sum(ProbabilityMatrix,2); %sum of the elements of rows
X=rand;

%Shahed is the most used note in the original piece.
[shahedTotal, shahed]= max ( columnSum);
nextNote = shahed; % start the generation from Shahed

%MyNotesDurationKereshmeh=[1,3,1,3,1,1,3,3,   1,3,1,3,1,1,4];
%MyNotesDurationMasnavi=[2,1,2,2,2,1,2,2,2,1,4];
MyNotesDurationMasnavi=[2,1,3,3,2,1,3,3,2,1,4]; %masnavi%[3,1,2,2,4, 3,1,2,2,2,2,4,4,4];
generatedLength= 200 ;

MyDurations=MyNotesDurationMasnavi;
noteStartTime=0;
for i=1:generatedLength
    % index is a number between 1 and total number of occurances of this note.
    index = floor(rand*rowSum(nextNote))+1;
    nextNoteFinder=0;
    j=1;
    while nextNoteFinder < index
        nextNoteFinder = nextNoteFinder + ProbabilityMatrix(nextNote, j);
        j = j+ 1;
    end
    M(1,3)=shahed;
    M(i, 3 ) = j-1;
    M(i, 4 ) = 120;
    M(i, 5 ) = noteStartTime;
    M(i, 6 ) =      noteStartTime + MyDurations(mod(i-1, size(MyDurations,2))+1)/8;
    noteStartTime = noteStartTime + MyDurations(mod(i-1, size(MyDurations,2))+1)/8;
    nextNote = j-1;
end

% To end the generated piece at shahed
for i=200:-1:1
    if (M(i,3)==shahed)
        L=M(1:i,:);
        break
    end
end

midi1=matrix2midi(L,midi.ticks_per_quarter_note,[6,3,24,8]);
writemidi(midi1,'~/Desktop/MasnaviImprovised.mid',0);