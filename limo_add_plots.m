function limo_add_plots

% interactive ploting functon for data generated by
% limo_central_tendency_and_ci or any data in 4D with dim channel
% * time * conditions * 3 with this last dim being the low end of the
% confdidence interval, the estimator (like eg mean), high end of the 
% confidence interval and the variable is called M, TM, Med or HD

out = 0;
turn = 1;
subjects_plot = 0;
current = pwd;

while out == 0

%% Data selection
% ------------------
[file,path,index]=uigetfile('*mat','Select 4D file for ERP or Power');
if index == 0
    out = 1; return
else
    data = load(sprintf('%s%s',path,file));
    if isfield(data,'M')
        name{turn} = 'Mean';
        tmp = data.M;
    elseif isfield(data,'TM')
        name{turn} = 'Trimmed Mean';
        tmp = data.TM;
    elseif isfield(data,'Med')
        name{turn} = 'Median';
        tmp = data.Med;
    elseif isfield(data,'HD')
        name{turn} = 'Harrell-Davis';
        tmp = data.HD;
    elseif isfield(data,'data')
        if ~isempty(strfind(file, 'Mean'))
            name{turn} = 'Subjects'' Means';
        elseif ~isempty(strfind(file, 'Trimmed mean'))
            name{turn} = 'Subjects'' Trimmed Means';
        elseif ~isempty(strfind(file, 'HD'))
            name{turn} = 'Subjects'' Mid Deciles HD';
        elseif ~isempty(strfind(file, 'Median'))
            name{turn} = 'Subjects'' Medians';
        else
            name{turn} = file;
        end
        tmp = data.data;
        subjects_plot = 1;
    else
        errordlg2('unknown file format');
        return
    end
end

clear data
if size(tmp,3) == 1
    Data = squeeze(tmp(:,:,1,:));
else
    v = inputdlg(['which variable to plot, 1 to ' num2str(size(tmp,3))],'plotting option');
    if isempty(v)
        out = 1; return
    else
        Data = squeeze(tmp(:,:,eval(cell2mat(v)),:));
    end
end
clear tmp


%% prep figure the 1st time rounnd
% ------------------------------
if turn == 1
    plotfig = figure('Name','Estimator and CI plots','color','w'); hold on
    
    % timing info
    % ----------
    [file,locpath,ind]=uigetfile('.mat','Select any LIMO with right timing info');
    if ind == 0
        v = inputdlg('enter time interval by hand e.g. [0:0.5:200]');
        if isempty(v)
            return
        else
            try
                timevect = eval(cell2mat(v));
                if length(timevect) ~= size(Data,2)
                    disp('time interval invalid format');
                    timevect = 1:size(Data,2);
                end
            catch ME
                disp('time interval invalid format');
                timevect = 1:size(Data,2);
            end
        end
    else
        cd(locpath); load LIMO; cd(current);
        timevect = LIMO.data.start:(1000/LIMO.data.sampling_rate):LIMO.data.end;  % in msec
    end
end
    
%% electrode to plot
% ----------------
if size(Data,1) == 1
    Data = squeeze(Data(1,:,:));
else
    e = inputdlg(['which electgrode top plot 1 to' num2str(size(Data,1))],'electrode choice');
    if isempty(e)
        return
    else
        Data = squeeze(Data(eval(cell2mat(e)),:,:));
    end
end

% finally plot
% ---------------
figure(plotfig)
if turn==1
    if subjects_plot == 1
        plot(timevect,Data,'LineWidth',1);
    else
        plot(timevect,Data(:,2)','LineWidth',3);
    end
    colorOrder = get(gca, 'ColorOrder');
    colorindex = 1;
else
    plot(timevect,Data(:,2)','Color',colorOrder(colorindex,:),'LineWidth',3);
end

if subjects_plot == 0
    fillhandle = patch([timevect fliplr(timevect)], [Data(:,1)',fliplr(Data(:,3)')], colorOrder(colorindex,:));
    set(fillhandle,'EdgeColor',colorOrder(colorindex,:),'FaceAlpha',0.2,'EdgeAlpha',0.8);%set edge color
end

grid on; axis tight; box on;
xlabel('Time ','FontSize',14)
ylabel('Amplitude','FontSize',14)
if turn == 1
    mytitle = name{1};
else
     mytitle = sprintf('%s & %s',mytitle,name{turn});
end
title(mytitle,'Fontsize',16);
hold on

% updates
turn = turn+1;
if colorindex <7
    colorindex = colorindex + 1;
else
    colorindex = 1;
end
subjects_plot = 0;

end

