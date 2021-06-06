function [fig,xpoints,plotvals,sem] = make_params(vars,plottype,labels,ylimits,colours)
% plots means with sem error bars connected with a line
% expects data row-wise, each row is a variable

xpoints = 1:size(vars,1);
plots = 1:size(vars,3);
            
if ~isempty(plottype)
    switch plottype
        case 'means'
            for thisplot = 1:numel(plots)
                for xpoint = 1:numel(xpoints)
                    plotvals(thisplot,xpoint) = mean(vars(xpoint,:,thisplot),'omitnan');
                    sem(thisplot,xpoint) = nansem(vars(xpoint,:,thisplot));
                end; clear xpoint
            end; clear thisplot
        case 'accuracy'
            for thisplot = 1:numel(plots)
                for xpoint = 1:numel(xpoints)
                    plotvals(thisplot,xpoint) = 100*(sum(vars(xpoint,:,thisplot))/numel(vars(xpoint,:,thisplot)));
                    sem(thisplot,xpoint) = nansem(vars(xpoint,:,thisplot));
                end; clear xpoint
            end; clear thisplot
    end
end

if ~exist('colours')
    for i = 1:numel(plots)
        colours{i} = '*';
    end
end

fig = figure;
for thisplot = 1:numel(plots)
    plot(xpoints,plotvals(thisplot,:),colours{thisplot})
    if exist('labels')
        xticks([1:numel(xpoints)]);
        xticklabels(labels);
    end
    hold on
    er = errorbar(xpoints,plotvals(thisplot,:),sem(thisplot,:));
%     hold on
%     line(xpoints,means(thisplot,:))
end
extendy = 10;
extendx = 1;
%     axis([min(xpoints)-extendx max(xpoints)+extendx min(means)-extendy max(means)+extendy]);
if ~exist('ylimits')
    ylimits = [min(min(plotvals))-extendy,max(max(plotvals))+extendy];
end
axis([min(xpoints)-extendx max(xpoints)+extendx ylimits(1) ylimits(2)]);

hold off

end