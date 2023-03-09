classdef RegisterStack < handle

    properties (SetAccess = private)
        % View related properties
        fig
        
        % Display axes
        axesStack
        stackView
        
        axesReference
        referenceView
        
        axesTransform
        transformView
        
        % GUI controls
        pbSelectCPStack
        pbSelectCPReference
        pbFindCP
        pbFindPoint
        pmCP
        pbLoadStack
        pbLoadReference
        tbStackChannels
        tbReferenceChannels
        pmStackChannel
        pmReferenceChannel
        pmGreen
        
        pbTransform
        pbLoad
        pbLoadImreg
        pbSave
        
        sliderStackMin
        sliderStackMax
        sliderReferenceMin
        sliderReferenceMax
        tbStackMin
        tbStackMax
        tbReferenceMin
        tbReferenceMax
        
        sliderStackFrame
        sliderReferenceFrame
                
        % Image stacks
        reference
        zstack
        stackpath
        transformed
        
        % Control points
        cp_zstack
        cp_reference
        
        % Transformation matrices
        A_for
        A_rev
    end

    methods

        function obj = RegisterStack(zstack, reference)
            % load figure
            fig = openfig('RegisterStack.fig');
            obj.fig = fig;
            set(fig,'toolbar','figure');
            
            obj.zstack = [];
            obj.reference = [];
            obj.transformed = [];
           
            obj.cp_zstack = [nan nan nan];
            obj.cp_reference = [nan nan nan];
            
            % find components
            obj.axesStack = findobj(fig, 'tag', 'axesStack');
            obj.axesReference = findobj(fig, 'tag', 'axesReference');
            obj.axesTransform = findobj(fig, 'tag', 'axesTransform');
            
            obj.pbLoadStack = findobj(fig, 'tag', 'pbLoadStack');
            obj.pbLoadReference = findobj(fig, 'tag', 'pbLoadReference');
            obj.tbStackChannels = findobj(fig, 'tag', 'tbStackChannels');
            obj.tbReferenceChannels = findobj(fig, 'tag', 'tbReferenceChannels');
            
            obj.pmStackChannel = findobj(fig, 'tag', 'pmStackChannel');
            obj.pmReferenceChannel = findobj(fig, 'tag', 'pmReferenceChannel');
            
            obj.sliderStackMin = findobj(fig, 'tag', 'sliderStackMin');
            obj.sliderStackMax = findobj(fig, 'tag', 'sliderStackMax');
            obj.sliderReferenceMin = findobj(fig, 'tag', 'sliderReferenceMin');
            obj.sliderReferenceMax = findobj(fig, 'tag', 'sliderReferenceMax');
            
            obj.tbStackMin = findobj(fig, 'tag', 'tbStackMin');
            obj.tbStackMax = findobj(fig, 'tag', 'tbStackMax');
            obj.tbReferenceMin = findobj(fig, 'tag', 'tbReferenceMin');
            obj.tbReferenceMax = findobj(fig, 'tag', 'tbReferenceMax');

            obj.sliderStackFrame = findobj(fig, 'tag', 'sliderStackFrame');
            obj.sliderReferenceFrame = findobj(fig, 'tag', 'sliderReferenceFrame');
        
            obj.pbSelectCPStack = findobj(fig, 'tag', 'pbSelectCPStack');            
            obj.pbSelectCPReference = findobj(fig, 'tag', 'pbSelectCPReference');
             
            obj.pmGreen = findobj(fig, 'tag', 'pmGreen');
            
            obj.pmCP = findobj(fig, 'tag', 'pmCP');
            obj.pbFindCP = findobj(fig, 'tag', 'pbFindCP');
            obj.pbFindPoint = findobj(fig, 'tag', 'pbFindPoint');
             
            obj.pbLoad = findobj(fig, 'tag', 'pbLoad');
            obj.pbLoadImreg = findobj(fig, 'tag', 'pbLoadImreg');            
            obj.pbSave = findobj(obj.fig, 'tag', 'pbSave');
            obj.pbTransform = findobj(obj.fig, 'tag', 'pbTransform');

            addlistener(obj.pmCP, 'Value', 'PostSet', ...
                @obj.update_pmCP);
    
            
            % set button callbacks
            obj.pbSelectCPReference.Callback = @obj.set_reference_cp;                
            obj.pbLoadStack.Callback = @obj.load_stack;
            obj.pbLoadReference.Callback = @obj.load_reference;
            obj.pbTransform.Callback = @obj.transform_zstack;
            obj.pbSave.Callback = @obj.save_transform;
            obj.pbLoadImreg.Callback = @obj.load_imreg;
            obj.pbLoad.Callback = @obj.load;
            obj.pbFindCP.Callback = @obj.find_cp;
            obj.pbFindPoint.Callback = @obj.find_point;   
            obj.pbSelectCPStack.Callback = @obj.set_stack_cp;            

            % load stacks if passed
            if exist('zstack','var')
                obj.zstack = zstack;
                obj.stackView = StackView(obj.zstack, ...
                    obj.axesStack, ...
                    obj.sliderStackFrame, ...
                    obj.sliderStackMin, ...
                    obj.sliderStackMax, ...
                    obj.pmStackChannel);
                addlistener(obj.sliderStackFrame, 'Value', 'PostSet', ...
                    @obj.update_stack_axes);                  
            end
            
            if exist('reference','var')
                obj.reference = reference;
                obj.referenceView = StackView(obj.reference, ...
                    obj.axesReference, ...
                    obj.sliderReferenceFrame, ...
                    obj.sliderReferenceMin, ...
                    obj.sliderReferenceMax, ...
                    obj.pmReferenceChannel);
                addlistener(obj.sliderReferenceFrame, 'Value', 'PostSet', ...
                    @obj.update_reference_axes);                  
            end
            
            obj.tbReferenceMin.String = num2str(obj.sliderReferenceMin.Value);
            obj.tbReferenceMax.String = num2str(obj.sliderReferenceMax.Value);            
            obj.tbStackMin.String = num2str(obj.sliderStackMin.Value);
            obj.tbStackMax.String = num2str(obj.sliderStackMax.Value);
            
            addlistener(obj.sliderReferenceMin, 'Value', 'PostSet', ...
                @obj.update_textboxes);
            addlistener(obj.sliderReferenceMax, 'Value', 'PostSet', ...
                @obj.update_textboxes);
            addlistener(obj.sliderStackMin, 'Value', 'PostSet', ...
                @obj.update_textboxes);
            addlistener(obj.sliderStackMax, 'Value', 'PostSet', ...
                @obj.update_textboxes);
            
            addlistener(obj.tbReferenceMin, 'String', 'PostSet', ...
                    @obj.update_sliders);
            addlistener(obj.tbReferenceMax, 'String', 'PostSet', ...
                    @obj.update_sliders);
            addlistener(obj.tbStackMin, 'String', 'PostSet', ...
                    @obj.update_sliders);
            addlistener(obj.tbStackMax, 'String', 'PostSet', ...
                    @obj.update_sliders);
        end
        
        function update_textboxes(obj, varargin)
            if ~strcmp(obj.tbReferenceMin.String, num2str(obj.sliderReferenceMin.Value))
            	obj.tbReferenceMin.String = num2str(obj.sliderReferenceMin.Value);
            end
            if ~strcmp(obj.tbReferenceMax.String, num2str(obj.sliderReferenceMax.Value))
                obj.tbReferenceMax.String = num2str(obj.sliderReferenceMax.Value);            
            end
            if ~strcmp(obj.tbStackMin.String, num2str(obj.sliderStackMin.Value))
                obj.tbStackMin.String = num2str(obj.sliderStackMin.Value);
            end
            if ~strcmp(obj.tbStackMax.String, num2str(obj.sliderStackMax.Value))
                obj.tbStackMax.String = num2str(obj.sliderStackMax.Value);
            end
        end
        
        function update_sliders(obj, varargin)
            if ~strcmp(obj.tbReferenceMin.String, num2str(obj.sliderReferenceMin.Value))
            	obj.sliderReferenceMin.Value = str2num(obj.tbReferenceMin.String);
            end
            if ~strcmp(obj.tbReferenceMax.String, num2str(obj.sliderReferenceMax.Value))
                obj.sliderReferenceMax.Value = str2num(obj.tbReferenceMax.String);            
            end
            if ~strcmp(obj.tbStackMin.String, num2str(obj.sliderStackMin.Value))
                obj.sliderStackMin.Value = str2num(obj.tbStackMin.String);
            end
            if ~strcmp(obj.tbStackMax.String, num2str(obj.sliderStackMax.Value))
                obj.sliderStackMax.Value = str2num(obj.tbStackMax.String);
            end            
        end
        
        function find_point(obj, varargin)
            % set callbacks to find matching points if an axis is clicked
            obj.stackView.im.ButtonDownFcn = @obj.axes_click;
            obj.referenceView.im.ButtonDownFcn = @obj.axes_click;
            if ~isempty(obj.transformed)
                obj.transformView.im.ButtonDownFcn = @obj.axes_click;
            end
        end
        
        function axes_click(obj, varargin)
            % find matching points between axes
            pos = varargin{2}.IntersectionPoint(1:2);
            
            % left stack was clicked            
            if varargin{1} == obj.stackView.im          
                set(obj.stackView.overlay, 'XData', pos(1),...
                    'YData', pos(2), 'Color', 'r');
                % if registration complete, find point in other stacks
                if ~isempty(obj.transformed)
                    pos = [ pos(2) pos(1) obj.stackView.iframe 1];
                    referencepos = pos * obj.A_rev;
                    if round(referencepos(3)) <= size(obj.reference,4) && ...
                            round(referencepos(3)) >= 1
                        obj.sliderReferenceFrame.Value = round(referencepos(3));
                        set(obj.referenceView.overlay, 'XData', referencepos(2),...
                            'YData', referencepos(1), 'Color', 'r');
                        set(obj.transformView.overlay, 'XData', referencepos(2),...
                            'YData', referencepos(1), 'Color', 'r');
                    end
                end                
            end
            
            % right stack was clicked
            if varargin{1} == obj.referenceView.im || varargin{1} == obj.transformView.im
                set(obj.referenceView.overlay, 'XData', pos(1),...
                    'YData', pos(2), 'Color', 'r');
                if ~isempty(obj.transformed)
                    set(obj.transformView.overlay, 'XData', pos(1),...
                        'YData', pos(2), 'Color', 'r');
                    pos = [ pos(2) pos(1) obj.referenceView.iframe 1];
                    zstackpos = pos * obj.A_for;
                    
                    obj.sliderStackFrame.Value = round(zstackpos(3));
                    set(obj.stackView.overlay, 'XData', zstackpos(2),...
                        'YData', zstackpos(1), 'Color', 'r');
                end
            end
            
            % clear callbacks
            obj.stackView.im.ButtonDownFcn = [];
            obj.referenceView.im.ButtonDownFcn = [];
            if ~isempty(obj.transformed)
                obj.transformView.im.ButtonDownFcn = [];
            end
        end
        
        function find_cp(obj, varargin)
            % show control point an all stacks
            ncp = obj.pmCP.Value;
            cp_zstack = obj.cp_zstack(ncp,:);
            cp_reference = obj.cp_reference(ncp,:);
            if cp_zstack(3)>0   % if the z coordinate is positive
                obj.sliderStackFrame.Value = cp_zstack(3);
                set(obj.stackView.overlay, 'XData', cp_zstack(2),...
                        'YData', cp_zstack(1), 'Color', 'r');
            end
            if cp_reference(3)>0
                obj.sliderReferenceFrame.Value = cp_reference(3);
                set(obj.referenceView.overlay, 'XData', cp_reference(2),...
                    'YData', cp_reference(1), 'Color', 'r');
                if ~isempty(obj.transformed)
                    set(obj.transformView.overlay, 'XData', cp_reference(2),...
                        'YData', cp_reference(1), 'Color', 'r');
                end
            end
        end
        
        function update_pmCP(obj, varargin)
            % add new control point to drop down menu if it doesn't exist
            if strcmp(obj.pmCP.String{obj.pmCP.Value}, ' ')
                obj.pmCP.String{obj.pmCP.Value} = num2str(obj.pmCP.Value);
                obj.pmCP.String{obj.pmCP.Value+1} = ' ';
            end
        end
        
        function load_imreg(obj, varargin)
            % this loads files saved in our old registration format
            [fname, pathname] = uigetfile('*.mat');
            if fname
                % load file and extract CP coords
                [ obj.cp_zstack, obj.cp_reference, obj.zstack, obj.reference ] = ...
                    loadimreg(fullfile(pathname,fname));
                
                % initialize views
                obj.stackView = StackView(obj.zstack, ...
                    obj.axesStack, ...
                    obj.sliderStackFrame, ...
                    obj.sliderStackMin, ...
                    obj.sliderStackMax, ...
                    obj.pmStackChannel);
                addlistener(obj.sliderStackFrame, 'Value', 'PostSet', ...
                    @obj.update_stack_axes);
                
                obj.referenceView = StackView(obj.reference, ...
                    obj.axesReference, ...
                    obj.sliderReferenceFrame, ...
                    obj.sliderReferenceMin, ...
                    obj.sliderReferenceMax, ...
                    obj.pmReferenceChannel);     
                addlistener(obj.sliderReferenceFrame, 'Value', 'PostSet', ...
                    @obj.update_reference_axes);                
            end
        end
        
        function save_transform(obj, varargin)
            % save transformation matrices, CPs and stacks
            if isempty(obj.transformed)
                return;
            end
            A_for = obj.A_for;
            A_rev = obj.A_rev;
            cp_zstack = obj.cp_zstack;
            cp_reference = obj.cp_reference;
            transformed = obj.transformed;
            zstack = obj.zstack(:,:,:,:);
            reference = obj.reference(:,:,:,:);
            uisave({'A_for' 'A_rev' 'cp_zstack' 'cp_reference' 'transformed' 'zstack' 'reference'}, ...
                fullfile(obj.stackpath, ['referenceRegistration_' datestr(now,'yyyy_mm_dd') '.mat'])); 
        end
        
        function load(obj, varargin)
            % load transformation matrices, CPs and stacks
            [fname, pathname] = uigetfile('*.mat');
            if fname
                load(fullfile(pathname, fname));
                obj.A_for = A_for;
                obj.A_rev = A_rev;
                obj.cp_zstack = cp_zstack;
                obj.cp_reference = cp_reference;
                obj.transformed = transformed;
                obj.zstack = zstack;
                obj.reference = reference;
                
                obj.stackView = StackView(obj.zstack, ...
                    obj.axesStack, ...
                    obj.sliderStackFrame, ...
                    obj.sliderStackMin, ...
                    obj.sliderStackMax, ...
                    obj.pmStackChannel);
                addlistener(obj.sliderStackFrame, 'Value', 'PostSet', ...
                    @obj.update_stack_axes);
                
                obj.referenceView = StackView(obj.reference, ...
                    obj.axesReference, ...
                    obj.sliderReferenceFrame, ...
                    obj.sliderReferenceMin, ...
                    obj.sliderReferenceMax, ...
                    obj.pmReferenceChannel);     
                addlistener(obj.sliderReferenceFrame, 'Value', 'PostSet', ...
                    @obj.update_reference_axes);   
                
                % create transform view
                obj.transformView = StackView(obj.transformed, ...
                    obj.axesTransform, ...
                    obj.sliderReferenceFrame, ...
                    obj.sliderStackMin, ...
                    obj.sliderStackMax, ...
                    obj.pmStackChannel);
                
                % link reference and transform axes together
                linkaxes([obj.axesReference, obj.axesTransform]);
            end
        end
        
        function transform_zstack(obj,varargin)
            % fit affine matrix and transform zstack into reference coords
            if size(obj.cp_zstack,1)<4 || size(obj.cp_reference,1)<4
                return;
            end
            
            % make control point matrices
            X_zstack = [ obj.cp_zstack ones(size(obj.cp_zstack,1),1)];
            X_reference = [ obj.cp_reference ones(size(obj.cp_reference,1),1)];
            % solve for transformation matrix
            if size(obj.reference, 3) == 1
                 X_reference = X_reference(:, [1,2,4]);
            end
            obj.A_for = X_reference \ X_zstack;    % coefs for transforming reference coords into zstack, X_reference * A_for = X_zstack
            obj.A_rev = X_zstack \ X_reference;    % the inverse
            
            % load zstack into RAM
            q = obj.zstack(:,:,:,:);
            obj.transformed = transformstack(q, obj.reference, obj.A_for);
            
            % create transform view
            obj.transformView = StackView(obj.transformed, ...
                obj.axesTransform, ...
                obj.sliderReferenceFrame, ...
                obj.sliderStackMin, ...
                obj.sliderStackMax, ...
                obj.pmStackChannel);
            
            linkaxes([obj.axesReference, obj.axesTransform]);            
        end
        
        function set_stack_cp(obj,varargin)
            % create an impoint and use to pick a new control point            
            ncp = str2double(obj.pmCP.String{obj.pmCP.Value});
            if ~isempty(obj.zstack)
                xdim = xlim(obj.axesStack);
                ydim = ylim(obj.axesStack);
                h = impoint(obj.axesStack,mean(xdim),mean(ydim));
                setColor(h,'w');
                wait(h);
                pos = h.getPosition;
                obj.cp_zstack(ncp,1:3) = [ pos(2) pos(1) obj.stackView.iframe ];
                delete(h);
                obj.update_stack_axes();
            end
        end
        
        function set_reference_cp(obj,varargin)
            % create an impoint and use to pick a new control point
            ncp = str2double(obj.pmCP.String{obj.pmCP.Value});
            if ~isempty(obj.reference)
                xdim = xlim(obj.axesReference);
                ydim = ylim(obj.axesReference);
                h = impoint(obj.axesReference,mean(xdim),mean(ydim));
                setColor(h,'w');
                wait(h);
                pos = h.getPosition;
                obj.cp_reference(ncp,1:3) = [ pos(2) pos(1) obj.referenceView.iframe ];
                delete(h);
                obj.update_reference_axes();
            end
        end        
        
        function update_reference_axes(obj,varargin)
            if isempty(obj.reference)
                return;
            end
            frame = round(obj.sliderReferenceFrame.Value);
            
            % if we didn't move the slider more than 1 frame, do nothing            
            if frame==obj.referenceView.iframe & numel(varargin)>=2
                if strcmp(varargin{2}.AffectedObject.Tag,'sliderStackFrame')
                    return;
                end
            end
            obj.referenceView.update_axes();
                        
            % plot control points, if any
            cpidx = round(obj.cp_reference(:,3)) == frame;
            if sum(cpidx)
                set(obj.referenceView.overlay, 'XData', obj.cp_reference(cpidx,2),...
                    'YData', obj.cp_reference(cpidx,1), 'Color', [1 1 1]);
            else
                set(obj.referenceView.overlay, 'XData', [],...
                    'YData', []);
            end
            
            % update the transformed view, if registration has been done
            if ~isempty(obj.transformed) && frame~=obj.transformView.iframe
                obj.transformView.update_axes();
                if sum(cpidx)
                    set(obj.transformView.overlay, 'XData', obj.cp_reference(cpidx,2),...
                        'YData', obj.cp_reference(cpidx,1), 'Color', [1 1 1]);
                else
                    set(obj.transformView.overlay, 'XData', [],...
                        'YData', []);
                end
            end
        end
        
        function update_stack_axes(obj,varargin)
            if isempty(obj.zstack)
                return;
            end
            frame = round(obj.sliderStackFrame.Value);
            
            % if we didn't move the slider more than 1 frame, do nothing
            if frame==obj.stackView.iframe & numel(varargin)>=2
                if strcmp(varargin{2}.AffectedObject.Tag,'sliderStackFrame')
                    return;
                end
            end
            
            % update image
            obj.stackView.update_axes();            
            
            % plot control points, if any
            cpidx = round(obj.cp_zstack(:,3)) == frame;
            if sum(cpidx)
                set(obj.stackView.overlay, 'XData', obj.cp_zstack(cpidx,2),...
                    'YData', obj.cp_zstack(cpidx,1), 'Color', [1 1 1]);
            else
                set(obj.stackView.overlay, 'XData', [],...
                    'YData', []);
            end       
        end
        
        function load_stack(obj,varargin)
            [fname, pathname] = uigetfile('*.tif;*.tiff','MultiSelect','on');
            if iscell(fname) || ischar(fname(1))
                if ~iscell(fname)    % single file selected
                    fullpath = fullfile(pathname, fname);
                    
                    nchannels = str2double(obj.tbStackChannels.String);
                    
                    if nchannels==1
                        obj.zstack = TIFFStack(fullpath, false);
                        obj.zstack = permute(obj.zstack,[1 2 4 3]);
                    else
                        obj.zstack = TIFFStack(fullpath, false, nchannels);
                    end
                else     % one file for each channel
                    tif_paths = fullfile(pathname, fname);
                    imgs = cellfun(@(p) TIFFStack(p, false), tif_paths, 'un', false);
                    obj.zstack = TensorStack(4, imgs{:});
                    obj.zstack = permute(obj.zstack,[1 2 4 3]);
                    
                end
                
                obj.zstack = obj.zstack(:,:,:,:);
                
                % switch first two channels
%                 tmp = obj.zstack(:,:,2);
%                 obj.zstack(:,:,2) = obj.zstack(:,:,1);
%                 obj.zstack(:,:,1) = tmp;
                
                obj.stackView = StackView(obj.zstack, ... % load on init
                    obj.axesStack, ...
                    obj.sliderStackFrame, ...
                    obj.sliderStackMin, ...
                    obj.sliderStackMax, ...
                    obj.pmStackChannel, ...
                    str2num(obj.pmGreen.String{obj.pmGreen.Value}));
                addlistener(obj.sliderStackFrame, 'Value', 'PostSet', ...
                    @obj.update_stack_axes);                
            end
        end
        
        function load_reference(obj,varargin)
            [fname, pathname] = uigetfile('*.tif;*.tiff;*.mat','MultiSelect','on');
            if iscell(fname) || ischar(fname(1))
                if ~iscell(fname)    % single file selected
                    fullpath = fullfile(pathname, fname);
                    [~, ~, ext] = fileparts(fname);
                    if strcmp(ext, '.mat')
                        load(fullpath,'reference_corrected');
                        obj.reference = permute(reference_corrected{1},[1 2 4 3]);
                    else
                        nchannels = str2double(obj.tbReferenceChannels.String);
                        
                        if nchannels==1
                            obj.reference = TIFFStack(fullpath, false);
                            obj.reference = permute(obj.reference,[1 2 4 3]);
                        else
                            obj.reference = TIFFStack(fullpath, false, nchannels);
                        end
                    end
                else     % one file for each channel
                    tif_paths = fullfile(pathname, fname);
                    imgs = cellfun(@(p) TIFFStack(p, false), tif_paths, 'un', false);
                    obj.reference = TensorStack(4, imgs{:});
                    obj.reference = permute(obj.reference,[1 2 4 3]);
                    
                end
                obj.referenceView = StackView(obj.reference(:,:,:,:), ... % load on init
                    obj.axesReference, ...
                    obj.sliderReferenceFrame, ...
                    obj.sliderReferenceMin, ...
                    obj.sliderReferenceMax, ...
                    obj.pmReferenceChannel, ...
                    str2num(obj.pmGreen.String{obj.pmGreen.Value}));
                addlistener(obj.sliderReferenceFrame, 'Value', 'PostSet', ...
                    @obj.update_reference_axes);                
            end
        end  
    end
end