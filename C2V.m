classdef C2V < handle
    
    methods(Static)
        function resVolume = applyApects(volume, aspects)
            numRowsOrg = size(volume,1);
            numColsOrg = size(volume,2);
            numPlanesOrg = size(volume,3);
            
            resVolume = imresize3(volume, ...
                [numRowsOrg*aspects(1), ...
                numColsOrg*aspects(2), ...
                numPlanesOrg*aspects(3)]);
        end
        
        function ax = previewVolume(varargin)
            
            % Input handling
            ax = [];
            doSmooth = false;
            volume = varargin{1};
            if nargin > 1
                meta = varargin{2};
                if any(strcmp(varargin, 'smooth'))
                    doSmooth = true;
                end
                for i = 1:length(varargin)
                    if(ishandle(varargin{i}))
                        ax = varargin{i};
                    end
                end
            end
            
            
            
            if isempty(ax) || ~isvalid(ax)
                ax = axes;
                setView = 3;
                setAspect = [meta.spacingY/meta.spacingX meta.spacingZ/meta.spacingZ meta.spacingY/meta.spacingZ]; % still not sure if this is absolutely right...
                
            else
                setView = ax.View;
                setAspect = ax.DataAspectRatio;
                cla(ax, 'reset')
            end
            
            % actual plotting of volume
            if doSmooth
                volume = smooth3(volume);
            end
            isovalue = 10;
            p = patch(ax, isosurface(volume));
            isonormals(volume, p);
            view(3);
            set(p, 'FaceColor', [1 0 0], 'EdgeColor', 'none','FaceAlpha',1);
            camlight; lighting phong
            view(setView);
            daspect(setAspect);
            
            % show volume in textbox
            C2V.addVolumeAnnotation(volume, meta.voxelVolume);
            
            % change axes labels to actual values in mm
            
            axis(ax,'tight');
            mmTickSpacingX = 0.2;
            mmTickSpacingY = 0.1;
            mmTickSpacingZ = 0.1;
            % give it some extra space
            
            ax.XTick = ax.XLim(1):mmTickSpacingX/meta.spacingX:ax.XLim(2);
            ax.YTick = ax.YLim(1):mmTickSpacingY/meta.spacingY:ax.YLim(2);
            ax.ZTick = ax.ZLim(1):mmTickSpacingZ/meta.spacingZ:ax.ZLim(2);
            % make them start at 0
            ax.XTickLabel = cellfun(@num2str, num2cell(str2double(ax.XTickLabel) - ax.XLim(1)), 'UniformOutput', false);
            ax.YTickLabel = cellfun(@num2str, num2cell(str2double(ax.YTickLabel) - ax.YLim(1)), 'UniformOutput', false);
            ax.ZTickLabel = cellfun(@num2str, num2cell(str2double(ax.ZTickLabel) - ax.ZLim(1)), 'UniformOutput', false);
            % handling a numerical problem: workaround is just manually
            % inserting 0 as start
            ax.XTickLabel{1} = '0';
            ax.YTickLabel{1} = '0';
            ax.ZTickLabel{1} = '0';
            
            % convert to mm
            %ax.XTickLabel = num2str(str2double(ax.XTickLabel)*meta.spacingX);
            ax.XTickLabel =  cellfun(@num2str, num2cell(str2double(ax.XTickLabel)*meta.spacingX), 'UniformOutput', false);
            ax.YTickLabel =  cellfun(@num2str, num2cell(str2double(ax.YTickLabel)*meta.spacingY), 'UniformOutput', false);
            ax.ZTickLabel =  cellfun(@num2str, num2cell(str2double(ax.ZTickLabel)*meta.spacingZ), 'UniformOutput', false);
            
            
        end
        
        function addVolumeAnnotation(volume, voxelVolume)
           
            dim = [0.2 0.5 0.3 0.3];
            str = {'Volume:', [num2str(nnz(volume) * voxelVolume) ' mm^3']};
            annotation('textbox',dim,'String',str,'FitBoxToText','on');
        end
        
        function corrVolume = getCorrectedVolume(masks, sliceIdx)
            % construct volume from cell
            x = size(masks{1},1);
            y = size(masks{1},2);
            z = length(masks);
            rawVolume = flipud(reshape(cell2mat(masks), x,y,z));
            exVolume = C2V.extrapolateVolume(rawVolume, sliceIdx);
            corrVolume = permute(exVolume, [3,2,1]);
            
        end
        
        function saveFigureVideo(filePath)
            OptionZ.FrameRate=30;OptionZ.Duration=10;OptionZ.Periodic=true;
            CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10],filePath,OptionZ)
            
        end
        
        function exVol = extrapolateVolume(volume, sliceIdx)
            
            volume = uint8(volume);
            markers = zeros(1,max(sliceIdx));
            markers(sliceIdx) = 1;
            markers = [0, diff(markers)];
            missingStartIdx = find(markers==-1);
            missingEndIdx = find(markers==1)-1;
            missingEndIdx = missingEndIdx(2:end);
            
            exVol = zeros(size(volume,1), size(volume,2), max(sliceIdx));
            if min(missingStartIdx)-1 < min(sliceIdx)-1
                startLength = (min(missingStartIdx)-1) - min(sliceIdx);
                exVol(:,:,min(sliceIdx):(min(missingStartIdx)-1)) = volume(:,:,1:startLength);
            end
            for i = 1:length(missingStartIdx)
                newLength = ((missingEndIdx(i)+1) - (missingStartIdx(i)-1));
                exVol(:,:,missingStartIdx(i)-1:missingEndIdx(i)+1) = imresize3(volume(:,:,i:i+1),[size(volume,1), size(volume,2), newLength+1]);
            end
            if missingEndIdx(end)+1 <= size(exVol,3)
                exVol(:,:,missingEndIdx(end)+1:end) = volume(:,:, (end-(max(sliceIdx)-max(missingEndIdx))+1):end);
            end
            
            exVol = logical(exVol);
        end
        
        
    end
end