function text2screen(textstring, linewidth, linespace, leftpos)

% This function takes a text string, splits it up into lines, and writes it
% onto the screen
% FORMAT: text2screen(textstring, linewidth, linespace, leftpos) 
%       with    textstring: string, \n indicating new line
%               linewidth: maxium width of each line in characters
%               linespace: line spacing in pixels
%               leftpos: left position of the textblock
%               (if leftpos == 0, text is centered)

linebreak(1)=0;
i=1;
while linebreak(i)<numel(textstring)
    i=i+1;
    linebreak(i)=min(linebreak(i-1)+linewidth, numel(textstring));
    % look for new line markers
    if ~isempty(strfind(textstring((linebreak(i-1)+1):linebreak(i)), '\n'))
       linebreak(i)=linebreak(i-1)+min(strfind(textstring((linebreak(i-1)+1):linebreak(i)), '\n'))-1;
       textstring((linebreak(i)+1):(linebreak(i)+2))=[];
    else
        if linebreak(i-1)+linewidth > numel(textstring)
            linebreak(i)=numel(textstring);
        else
            linebreak(i)=linebreak(i-1)+linewidth;
            % else look for space characters
            linebreak(i)=max(strfind(textstring(1:linebreak(i)), ' '))-1;
            textstring(linebreak(i)+1)=[];
        end;
    end;
end;

for i=2:(numel(linebreak))
    if linebreak(i)==linebreak(i-1)
        textline{i-1}= ' ';
    else
        textline{i-1}=textstring((linebreak(i-1)+1):linebreak(i));
    end;
end;

lines = size (textline, 2);
if leftpos==0, cgalign('c', 'c'); else, cgalign ('l', 'c'); end;
for line = 1:lines
    cgtext (textline{line}, leftpos, (lines/2 - line) * linespace);
end;
