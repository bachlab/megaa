% AAA 5 - approach avoidance anxiety, MEG
% based on AAA 1, version 1-6 from 20.6.2013

% changed for MEG:
% (a) randomisation of colours (as in AAA_3)
% (b) Post hoc test (as in AAA_3)
% (c) Only one token per round (epoch = trial = token), just one
%     appearance/disappereance time pair, but kept structure of the code
%     which allows for several tokens, indexed by state.tokenindx (which
%     now only takes values 0 and 1)
% (d) Potential loss defined per trial: tm(:, 3) and state.tokenloss
% (e) Introduced lost token sprite (graphset and makeplayers.m)
% (f) Negative token count for realised loss (see drawgrid.m)
% (g) Additional display line for potential loss (see drawgrid.m)
% (g) Display time after token: ctrl.posttime
% (h) If no response: zero state.tokencnt upon token disappeareance
% (i) added blank screen (ctrl.waitbreak) at block start
% (j) changed game.record to account for new trial structure
% (k) variable inter-trial-interval from gamma distribution

% changed for version 2: a training round without token loss (04.02.14)
% changed for version 3: fixed a bug with token appearance (05.02.14)
% changed for version 4: accepting response from response pad, getting
%                        triggers for MEG (19.02.14)

% Dominik R Bach 23.01.2014
% -------------------------------------------------------------------------
% last edited by Saurabh Khemka 13.03.2014

% list of subscripts
% definegrid.m: defines grid block centres for rotated grid
% makeplayers.m: creates player sprites
% makegrid.m: creates grid sprite
% makegridframe.m: draws grid sprite on frame sprite
% drawgrid.m: draws players onto grid&frame sprite

clear all
close all
clc
addpath subscripts
% addpath C:\Cogent2000v1.32\Toolbox

% CONSTANTS
% -------------------------------------------------------------------------

% cogent constants --------------------------------------------------------
screen_display = 1;            % whole screen = 1 or window = 0
screen_resolution  = 3;        % 6: 1600 x 1200; 2: 800 x 600

% graphics settings -------------------------------------------------------
graphset.gridsize = 2;
graphset.gridblock = 100;
graphset.gridline = 5;
graphset.griddiag = (graphset.gridblock + graphset.gridline) * sqrt(2 * graphset.gridsize.^2);
graphset.blockcentre = definegrid(graphset); % external function
graphset.bckgrnd = [0, 0, 0];
graphset.gridcol = [1, 1, 1];
graphset.safecol = [0.2, 0.2, 0.2];
graphset.trans = 'c';           % transparent colour label (for cgtrncol)
graphset.transcol = [0, 1, 1];  % transparent colour
graphset.framecol = [0, 0, 0.8; ... % pred discrimination colours displayed in grid frame
    1, 0.5, 0; ...
    1, 0, 0.5];

% list of sprites ---------------------------------------------------------
graphset.dispsprite = 1;        % # 1 display sprite (grid w/ players)
graphset.framesprite = 2;       % # 2 grid with frame
graphset.gridsprite = 3;        % # 3 grid

graphset.preysprite = 11;       % # 11 prey (human player)
graphset.spritecol{graphset.preysprite} = [0 1 0]; % green
graphset.tokensprite = 12;      % # 12 token
graphset.spritecol{graphset.tokensprite} = [0.9 0.8 0.1]; % yellow
graphset.losttokensprite = 13;      % # 13 lost token
graphset.spritecol{graphset.losttokensprite} = [1 0 0]; % red
graphset.sleeppredsprite = 21;  % # 21 sleeping pred (robber-computer)
graphset.spritecol{graphset.sleeppredsprite} = [.5 .5 .5]; % grey
graphset.activepredsprite = 22; % # 12 activated pred
graphset.spritecol{graphset.activepredsprite} = [1 0 0]; % red
graphset.predsprite = [graphset.sleeppredsprite, graphset.activepredsprite];


% xy positions:
% ------------|------------------------------------------------------------
%    2,2      |
% 1,2 -- 2,1  |
%    1,1      |
% ------------|

% control constants -------------------------------------------------------
ctrl.looptime = 20; % discretise loop at 50 Hz
% rng('shuffle');     % random seed for random number generator
ctrl.rnd = rand(10^6, 1);
ctrl.lambda = [1 1 1.0536 2.2314 3.5667]; % time constants for various processes:
% (1) token appearance, (2) token
% disappearance, [scale parameter of gamma distribution]
% (3) - (5) predator event
% (see simulations for exact values)
ctrl.waitstart = 0;  % initial waiting time at trial start in ms
ctrl.waitbreak = 1000;  % waiting time at block start
ctrl.waittok = 0;       % minimum waiting time between tokens
ctrl.tokenmax = 1;      % no of tokens presented per trial
ctrl.tokenmaxupdate = 6000; % max time for token appearance/disappearance
ctrl.maxwaitbreak = 4000; % max waiting time between trials
ctrl.posttime = 1000;       % post token display time
ctrl.trlno = 540;            % no of trials
ctrl.blkno = 5;              % no of blocks
ctrl.miniblk = 36;            % trials per mini-block
ctrl.miniblkno = ctrl.trlno/ctrl.miniblk;
ctrl.training = 0;      % no of training trials


% user input
% -------------------------------------------------------------------------
overwrite=0;
while overwrite==0
    subject.number=input('Participant number: ', 's');
    if isempty(str2num(subject.number))
        resfile='testoutput.mat';
    else
        resfile=['AAA_05_MEG_Sno_', num2str(subject.number),'.mat'];
    end;
    if exist(resfile)==2
        overwrite=input('File already exists. Overwrite (y/n)? ', 's');
        if ~isempty(overwrite)
            if overwrite=='y', overwrite=1; else overwrite=0; end;
        else
            overwrite=0;
        end;
    else
        overwrite=1;
    end;
end;
disp(['Result file: ', resfile]);

subject.group = 0;
while subject.group == 0
    group = input('Participant group (1-6): ', 's');
    if ~isempty(str2num(group)) && ismember(str2num(group), 1:6)
        subject.group = str2num(group);
    end;
end;

subject.age       = input('Participant age: ', 's');
subject.gender    = input('Participant gender: ', 's');
subject.resfile   = resfile;


% randomize colour-threat association
% -------------------------------------------------------------------------
foo = perms(1:3);
graphset.framecol = graphset.framecol(foo(subject.group, :), :);

% EXPERIMENT
% -------------------------------------------------------------------------

% create trial matrix, randomise over mini-blocks
% -------------------------------------------------------------------------
% no | pred | tokencnt
for miniblk = 1:ctrl.miniblkno
    cnt  = repmat(0:5, 1, ctrl.miniblk/6);
    pred = repmat(1:3, ctrl.miniblk/6, ctrl.miniblk/18);
    pred = pred(:);
    tm{miniblk} = [pred cnt'];
    tm{miniblk} = tm{miniblk}(randperm(ctrl.miniblk), :);
end;
tm = [(1:ctrl.trlno)', cell2mat(tm')];

% add training rounds
foo = repmat(1:3, ctrl.training/3, 1);
pretm = [zeros(ctrl.training, 1), ...
    foo(randperm(ctrl.training))', ...
    zeros(ctrl.training, 1)];
tm = [pretm;tm];

ctrl.trialmatrix = tm;

% cogent setup & start
% -------------------------------------------------------------------------
config_display(screen_display, screen_resolution);
config_keyboard;
start_cogent;

% create sprites
makegrid(graphset);
makeplayers(graphset);

% response keys
ctrl.keys = getkeymap;
ctrl.respkeys = [ctrl.keys.K1, ctrl.keys.K4, ctrl.keys.K3];
ctrl.escKey = ctrl.keys.Escape;
% create output file header
% -------------------------------------------------------------------------
header.experiment = 'AAA 5, Approach-avoidance pilot for MEG';
header.principal  = 'Dominik Bach';
header.fellow  = 'Saurabh Khemka';
header.scriptversion = '4';
header.modality = 'MEG';
header.version   = ver;
header.cogent    = 'Cogent2000v1.32';
header.graphset = graphset;
header.control = ctrl;
header.date = date;
foo = clock; % local dummy variable
header.starttime = sprintf('%02.0f:%02.0f:%02.0f', foo(4:6));
clear foo    % remove local dummy variable

save(subject.resfile, 'header', 'subject');

% main loop
% -------------------------------------------------------------------------
state.rndindx = 1;  % random number index
state.blkindx = 0;
for trl = 1:size(tm, 1)
    readkeys;
    [key1] = getkeydown; % get all keys
    % test if it is escaping
    if find(ismember(key1, ctrl.escKey), 1)
        break;
    else
        % check block start
        if trl == 1 || mod(tm(trl, 1), ceil(ctrl.trlno/ctrl.blkno)) == 1
            if trl > 1
                foo = clock; % local dummy variable
                header.blkend{state.blkindx} = sprintf('%02.0f:%02.0f:%02.0f', foo(4:6));
                clear foo    % remove local dummy variable
            end;
            cgflip(0, 0, 0),
            cgpencol(1, 1, 1);
            cgfont('Arial', 36);
            if trl == 1
                cgtext('Press green button to start the training block.', 0, 0);
            elseif trl == (ctrl.training + 1)
                cgtext('Press green button to start the first block', 0, 0);
                cgtext('Now your wins and losses counts', 0, -50);
            else
                cgtext('Press green button to start the next block.', 0, 0);
            end;
            cgflip(0, 0, 0);
            waitkeydown(inf, ctrl.respkeys(3));
            % Waiting for the researcher to press return key
            cgflip(0,0,0);
            cgpencol(1,1,1);
            cgfont('Arial', 36);
            cgtext('Please wait .............', 0, 0);
            cgflip(0,0,0);
            waitkeydown(inf, ctrl.keys.Return);
            % record block start
            state.blkindx = state.blkindx + 1;
            foo = clock; % local dummy variable
            header.blkstart{state.blkindx} = sprintf('%02.0f:%02.0f:%02.0f', foo(4:6));
            clear foo    % remove local dummy variable
            cgflip(0, 0, 0);
            %send trigger in the begining of the block
            outportb(888, 24);
            wait(10);
            outportb(888, 0);
            wait(ctrl.waitbreak);
            
            blockstart = time; % block start time
            
        end;
        % initialise trial
        state.trlstart = time;
        state.trl = tm(trl, 1);     % trial number
        state.continue = 1;         % continue loop
        state.pos = [1 1];          % intial subject position in safe place
        state.moveno = 1;           % initialise first move
        state.predpos = [2, 2];     % inital pred position is opposite
        state.pred = 0;             % pred not live
        state.predno = tm(trl, 2);  % pre-defined predator type
        state.predrecord = [0 0];   % initialise predator record
        state.update = 1;           % update output on first loop
        state.token = -1;           % token state not yet defined
        state.tokenpos = [0 0];     % no token position
        state.gottoken = 0;         % no token colleced
        state.tokenlastupdate = 0;  % last token update
        state.tokencnt = 0;         % no tokens collected
        state.tokenloss = tm(trl, 3);% potential loss
        state.tokenindx = 0;        % no tokens presented
        state.tokenstart = 0;       % initialise token start (for RT calculation)
        state.indx = 1;             % output matrix index
        state.trigger = 1;          % send triggers upon trial start (for MEG)
        game(trl).record = zeros(1, 10); % initialise first record line
        % define token appearance and disappearance times for this token
        state.tokentime(1, 1) = min([ctrl.tokenmaxupdate, 1000 * gaminv(ctrl.rnd(state.rndindx),     2, ctrl.lambda(1))]) + ctrl.waittok; % control appearance times
        state.tokentime(1, 2) = min([ctrl.tokenmaxupdate, 1000 * gaminv(ctrl.rnd(state.rndindx + 1), 2, ctrl.lambda(2))]); % control disappearance times
        state.rndindx = state.rndindx + 2;
        state.tokentime(2, :) = [ctrl.posttime, 0]; % waiting time after last token
        state.tokenupdate = state.tokentime(1, 1); % first token minimum waiting time
        % define inter trial interval
        state.waitbreak = min([ctrl.maxwaitbreak, 1000 * gaminv(ctrl.rnd(state.rndindx), 2, ctrl.lambda(1))]); % control appearance times
        state.rndindx = state.rndindx + 1;
        % create framed grid
        makegridframe(graphset.framecol(state.predno, :), graphset);
        % initialise keyboard
        clearkeys;
        while state.continue
            % record time -----------------------------------------------------
            state.loopstart = time;
            % update human player position ------------------------------------
            readkeys;
            [key, t, n] = getkeydown; % get all keys
            indx = find(ismember(key, ctrl.respkeys), 1); % find first response key
            if ~isempty(indx)
                if sum(state.pos == [1, 1]) == 2 % if in safe place, check L/R
                    if key(indx) == ctrl.respkeys(1)
                        state.pos = [1, 2];
                    elseif key(indx) == ctrl.respkeys(2)
                        state.pos = [2, 1];
                    end;
                elseif sum(state.pos == [1, 2]) == 2 % if left, only check R
                    if key(indx) == ctrl.respkeys(2)
                        state.pos = [1, 1];
                    end;
                elseif sum(state.pos == [2, 1]) == 2 % if R, only check L
                    if key(indx) == ctrl.respkeys(1)
                        state.pos = [1, 1];
                    end;
                end;
                state.update = 1;
                if state.moveno == 1 && state.tokenindx > 0   % record output data: position of first move (if not before first token presentation)
                    game(trl).record(state.tokenindx, 6) = state.pos(1);
                end;
                if state.moveno <=2  && state.tokenindx > 0    % record output data: first move and back
                    game(trl).record(state.tokenindx, 6 + state.moveno) =  t(indx) - state.tokenstart;
                end;
                state.moveno = state.moveno + 1;               % update move number post token
            end;
            % if human outside, update pred & token count ---------------------
            if sum(state.pos == [1, 1]) ~= 2
                state.p_pred = 1 - exp(-ctrl.lambda(2 + state.predno) * (ctrl.looptime/1000)); %
                state.predrecord(1) = state.predrecord(1) + ctrl.looptime;
                if state.p_pred > ctrl.rnd(state.rndindx)
                    state.pred = 1;            % pred live
                    state.continue = 0;        % round finishes
                    state.predpos = state.pos; % pred moves to prey pos
                    state.token = 0;           % remove current tokens
                    state.tokencnt = -tm(trl, 3); % realise token loss
                    state.tokenpos = [0 0];    % and remove current tk pos
                    state.update = 1;          % update position and output
                    state.predrecord(2) = state.predrecord(2) + 1; % record predator statistics
                    if state.moveno <= 2 && state.tokenindx > 0        % if first move after token presentation
                        game(trl).record(state.tokenindx, 9) = 1; % record output data: caught
                    end;
                elseif state.token == 1 && (sum(state.pos == state.tokenpos) == 2) % update tokens
                    state.tokencnt = 1;                    % update token count
                    state.gottoken = 1;                    % update token
                    game(trl).record(state.tokenindx, 10) = 1; % record output data: got token
                end;
                state.rndindx = state.rndindx + 1;
            end;
            % update token
            if state.continue && (((state.loopstart - state.tokenlastupdate) >= state.tokenupdate) || (state.gottoken == 1))
                if (state.tokenindx == ctrl.tokenmax) && (state.token ~= 1) && (state.gottoken == 0) % all tokens presented: stop
                    state.continue = 0;
                elseif state.token == 0 && ~state.gottoken % no current token: token appears
                    state.tokenstart = time;
                    state.token = 1;                        % token visible
                    state.moveno = 1;                       % reset move number
                    if ctrl.rnd(state.rndindx) < .5
                        state.tokenpos = [1, 2]; % left
                    else
                        state.tokenpos = [2, 1]; % right
                    end;
                    state.rndindx = state.rndindx + 1;
                    state.tokenindx = state.tokenindx + 1;  % update token index
                    state.tokenupdate = state.tokentime(state.tokenindx, 2);    % gather disappearance time
                    game(trl).record(state.tokenindx, 1) = state.tokenindx;     % record output data: token no
                    game(trl).record(state.tokenindx, 2) = state.tokencnt;      % collected tokens
                    game(trl).record(state.tokenindx, 4) = state.tokentime(state.tokenindx, 1);   % pre-token time
                    game(trl).record(state.tokenindx, 3) = state.tokentime(state.tokenindx, 2);   % token duration
                    game(trl).record(state.tokenindx, 5) = state.tokenpos(1);   % token position: L/R
                    state.tokenlastupdate = state.loopstart; % update time
                elseif state.token == 1 && state.gottoken        % current token caught: token disappears but waiting time continues, no update time record
                    state.token = 0;
                    state.tokenpos = [0 0]; % no token position
                else                         % current token not caught: token disappears but waiting time continues
                    state.token = 0;
                    state.tokenpos = [0 0]; % no token position
                    state.tokenupdate = state.tokentime(state.tokenindx + 1, 1); % gather appearance time
                    if state.tokenindx > 0 && ~state.gottoken
                        state.tokencnt = 0;
                    end;
                    state.tokenlastupdate = state.loopstart; % update time
                    state.gottoken = 0; % no token currently collected
                end;
                state.update = 1; % update token and output
            end;
            % update graphics & output ----------------------------------------
            if state.update
                % graphics
                state.players = [];
                fooindx = 1; % local index variable
                if ~state.pred
                    state.players(fooindx).pos = state.pos; state.players(fooindx).sprite = graphset.preysprite;
                    fooindx = fooindx + 1;
                end;
                state.players(fooindx).pos = state.predpos;
                state.players(fooindx).sprite = graphset.predsprite(state.pred + 1);
                fooindx = fooindx + 1;
                if state.token == 1
                    state.players(fooindx).pos = state.tokenpos; state.players(fooindx).sprite = graphset.tokensprite;
                end;
                clear fooindx % remove local index variable
                drawgrid(state.players, state.tokencnt, state.tokenloss, graphset);
                cgdrawsprite(1, 0, 0);
                fliptime = cgflip(graphset.bckgrnd);
                % send triggers at trial start
                if state.trigger
                    outportb(888, state.predno + 3 * state.tokenloss);
                    wait(10);
                    outportb(888, 0);
                    state.trigger = 0;
                end;
                % output matrix:
                game(trl).posmat(state.indx, :) = [state.pos, state.predpos, state.tokenpos, state.tokencnt, state.tokenindx, state.loopstart - state.trlstart,fliptime*1000-blockstart];
                % reset state
                state.indx = state.indx + 1;
                state.update = 0;
                if state.pred % wait until the remaining trial time is over
                    state.waitcaught = (sum(state.tokentime(:)) + ctrl.tokenmax * ctrl.waittok + ctrl.waitstart) - (state.loopstart - state.trlstart);
                    wait(state.waitcaught);
                end;
                
            end;
            % discretise loop
            waituntil(state.loopstart + ctrl.looptime);
            % loop end
        end;
    
    
    % End of the experiment
    outportb(888, 25);
    wait(10);
    outportb(888, 0);
    end
    % save output
    % output matrix:
    % 1-2 player position
    % 3-4 predator position
    % 5-6 token position
    % 7   token count
    % 8   token index
    % 9  loop time
    %10  fliptime
    % game record:
    % 1   token number
    % 2   tokens collected so far
    % 3   token duration
    % 4   post token time
    % 5   token position (L/R)
    % 6   first move direction (L/R)
    % 7   first move latency
    % 8   first withdrawal latency
    % 9   caught
    % 10  got token
    game(trl).laststate = state;
    game(trl).tokenrecord = state.tokencnt;
    % break
    cgflip(graphset.bckgrnd);
    save(subject.resfile, 'header', 'subject', 'game');
    wait(state.waitbreak);
end;

% complete output
clck = clock;
header.endtime = sprintf('%02.0f:%02.0f:%02.0f', clck(4:6));
header.blkend{state.blkindx} = header.endtime;
save(subject.resfile, 'header', 'subject', 'game');

% stop cogent if the esc key is pressed during the experiment
if find(ismember(key1, ctrl.escKey), 1)
    stop_cogent;
end
% post test
% -------------------------------------------------------------------------
% #5-7 ratesprite
cgmakesprite (5, 1000, 200, 0, 0, 0);    %make black ratesprite
cgsetsprite (5);                        %ready sprite to draw into
cgalign ('c', 'c');                     %center alignment
cgpencol (1, 1, 1);                     %black on white background
cgrect (0, 0, 500, 4);                  %draw horizontal line
cgrect (-250, 0, 4, 15);                %draw left major tick
cgrect (250, 0, 4, 15);                 %draw right major tick
for tick = 1:9
    cgrect (50* (tick - 5), 0, 2, 15);  %draw minor ticks
end;
cgfont ('Arial', 30);
cgtext ('0%', -250, -35);                %write anchors
cgtext ('100%', 250, -35);
cgfont ('Arial', 24);
cgtext ('Please use the blue(left)/red (right) buttons to move the arrow, and Green button to confirm.', 0, -70);

cgmakesprite (6, 20, 20, 0, 0, 0);               %make arrowsprite
cgsetsprite (6);
cgpencol (1, 1, 1);                     %black arrow
cgpolygon ([-10 0 10], [-10 10 -10]);
cgtrncol(6, 'n');
cgsetsprite (0);

cgmakesprite (7, 1000, 200, 0, 0, 0);    %make black full ratesprite for later use

confirmkey = ctrl.respkeys(3);
rightkey   = ctrl.respkeys(2);
leftkey    = ctrl.respkeys(1);
cgpencol (1, 1, 1);
cgfont('Arial', 30);

instruction = ...
    ['Now we show you the different game boards that you saw during the experiment. ', ...
    'For every board we ask you to rate how likely it was that the robber would get you, if you left the safe place. ', ...
    'If you are unsure, please give a quick, intuitive rating. There is no right or wrong here. We are ', ...
    'interested in your personal opinion\n\n. Please press the blue(left)/red (right) buttons to move the arrow, ', ...
    'and Green button to confirm.\n\nPlease press Green button to start.'];

text2screen(instruction, 80, 32, 0);
cgflip (0, 0, 0);
waitkeydown (inf, confirmkey);

tm = [1 1 1; 2 2 2; 3 3 3];
tm = tm(randperm(3), :);

cgfont ('Arial', 36);
cgpencol (1, 1, 1);
cgflip (0, 0, 0);
cgalign ('c', 'c');


counter = 1;

for iTrl = 1:size(tm, 1)
    % prepare sprite
    players = [];
    players(1).sprite = graphset.preysprite; players(1).pos = [1 1];
    players(2).sprite = graphset.sleeppredsprite; players(2).pos = [2 2];
    makegridframe(graphset.framecol(tm(iTrl, 1), :), graphset);
    drawgrid(players, 0,0, graphset);
    % show question
    xpos = 0;
    ypos = 200;
    cgsetsprite (0);
    cgpencol(1, 1, 1);
    cgtext ('How likely were you caught on this board', 0, 25);
    cgtext ('if you left the safe place?', 0, -25);
    cgflip (0, 0, 0);
    wait (1500);
    cgsetsprite (0);
    % show sprite and rating scale
    cgdrawsprite (1, 0, ypos);
    wait(500);
    key.down.ID = 0;
    key.direction = 0;
    clearkeys;
    key.down.ID = 0;
    while key.down.ID ~= confirmkey
        cgsetsprite (7);                % ready whole ratingsprite to draw into
        cgdrawsprite (5, 0, 0);         % draw ratingscale
        cgdrawsprite (6, xpos, -12);    % draw ratingarrow
        cgsetsprite (0);
        cgdrawsprite (7, 0, -ypos);     % draw ratingsprite onto offscreen
        cgdrawsprite (1, 0, ypos);
        cgflip(graphset.bckgrnd);
        readkeys;
        [key.down.ID, key.down.time] = lastkeydown;
        [key.up.ID, key.up.time] = lastkeyup;
        if key.down.ID == key.up.ID     % was key pressed & released?
            if key.down.ID == rightkey  % go one step into direction of keypress
                key.direction = 0;      % then define direction as zero
                xpos = xpos + 2;
                if xpos > 250
                    xpos = 250;
                end;
            elseif key.down.ID == leftkey
                key.direction = 0;
                xpos = xpos - 2;
                if xpos < -250
                    xpos = -250;
                end;
            end;
        elseif key.down.ID == rightkey  % if key is pressed and held then define direction
            key.direction = 2;
        elseif key.down.ID == leftkey
            key.direction = -2;
        elseif (key.up.ID == rightkey) | (key.up.ID == leftkey) % if key is released only - then stop movement
            key.direction = 0;
        end;
        
        xpos = xpos + key.direction;        % update xpos
        if xpos > 250
            xpos = 250;
        elseif xpos < -250
            xpos = -250;
        end;
        clearkeys;
    end;
    postdata(tm(iTrl, 1), :) = [tm(iTrl, 1), iTrl, xpos/5 + 50];
end;

clck = clock;
header.postendtime = sprintf('%02.0f:%02.0f:%02.0f', clck(4:6));
save(subject.resfile, 'header', 'subject', 'game', 'postdata');


stop_cogent;


