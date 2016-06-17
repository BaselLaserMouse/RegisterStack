classdef StackView < handle
    
    properties
        stack           % stack containing image data
        ax              % handle of axes object to display image
        im              % handle of image object
        overlay         % handle of overlay plot
        sliderFrame     % slider selecting frame to display
        sliderMin       % slider setting max channel range
        sliderMax       % slider setting min channel range
        pmChannel       % channel selection menu
        max_range       % min display value for each channel
        min_range       % max display value for each channel
        iframe          % last frame displayed
    end
    
    methods
        function obj = StackView(stack, ax, sliderFrame, sliderMin, sliderMax, pmChannel)
            % store inputs
            obj.stack = stack;
            obj.ax = ax;
            obj.sliderFrame = sliderFrame;
            obj.sliderMin = sliderMin;
            obj.sliderMax = sliderMax;
            obj.pmChannel = pmChannel;
            
            % initialize sliders
            nchannels = size(obj.stack,3);
            obj.pmChannel.String = mat2cell(num2str([1:nchannels]'),...
                    ones(1,nchannels));            
            obj.min_range(1:nchannels) = 0;
            obj.max_range(1:nchannels) = 1;
            obj.sliderFrame.Min = 1;
            obj.sliderFrame.Max = size(obj.stack,4);
            if obj.sliderFrame.Value < obj.sliderFrame.Min || ...
                    obj.sliderFrame.Value > obj.sliderFrame.Max
                obj.sliderFrame.Value = 1;
            end
            obj.sliderFrame.SliderStep = [ 1/size(obj.stack,4) 10/size(obj.stack,4) ];
            
            % create image object
            obj.im = image(obj.stack(:,:,1,1),'parent',obj.ax);
            % create overlay
            hold(obj.ax,'on');
            obj.overlay = plot(obj.ax,1,1,...
                 'o','Color', [1 1 1], 'MarkerSize',20);
            set(obj.overlay, 'XData', [],...
                    'YData', []);
            
            % set display props 
            xlim(obj.ax,[1 size(obj.stack,2)]);
            ylim(obj.ax,[1 size(obj.stack,1)]);
            axis(obj.ax, 'equal');
            axis(obj.ax, 'off');            
            
            % add listeners
            addlistener(obj.pmChannel, 'Value', 'PostSet', ...
                @obj.update_sliders);    
            addlistener(obj.sliderMax, 'Value', 'PostSet', ...
                @obj.update_range);
            addlistener(obj.sliderMin, 'Value', 'PostSet', ...
                @obj.update_range);    
            
            obj.update_axes();
        end
        
        function update_range(obj,varargin)
            % update min/max values and refresh image
        	channelnum = obj.pmChannel.Value;
            obj.max_range(channelnum) = obj.sliderMax.Value;
            obj.min_range(channelnum) = obj.sliderMin.Value;    
            
            obj.update_axes();
        end
        
        function update_sliders(obj,varargin)
            % update min/max sliders to saved value when channel selected
            channelnum = obj.pmChannel.Value;
            obj.sliderMax.Value = obj.max_range(channelnum);
            obj.sliderMin.Value = obj.min_range(channelnum);
        end
        
        function update_axes(obj,varargin)
            % update image on frame on range change
            nchannels = size(obj.stack,3);
            obj.iframe = round(obj.sliderFrame.Value);
            thisframe = double(obj.stack(:,:,:,obj.iframe));
            % find range of frame or stack
            if isnumeric(obj.stack)
                m = max(obj.stack(:));
            else
                m = max(thisframe(:));
            end
            % rescale depending on range of input data
            if m > 1 && m < 16385
                thisframe = thisframe/16384;
            elseif m >= 16385
                thisframe = thisframe/65536;
            end
            
            % rescale image
            for indCh = 1:nchannels
                thisframe(:,:,indCh) = (thisframe(:,:,indCh) - obj.min_range(indCh)) / ...
                    (obj.max_range(indCh) - obj.min_range(indCh));
            end
            
            % make color image
            switch nchannels
                case 1
                    cdata = cat(3,zeros(size(thisframe,1),size(thisframe,2)),...
                       thisframe(:,:,1),...
                       zeros(size(thisframe,1),size(thisframe,2)));                   
                case 2
                    cdata = cat(3,thisframe(:,:,2),...
                       thisframe(:,:,1),...
                       zeros(size(thisframe,1),size(thisframe,2)));
                otherwise
                    cdata = cat(3,thisframe(:,:,2),...
                       thisframe(:,:,1),...
                       thisframe(:,:,3));
            end
            set(obj.im,'CData',cdata);                   
        end        
    end
    
end