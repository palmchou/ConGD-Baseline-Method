%=============================================================================
% data structure             
%=============================================================================  
% D=data(object)
% 
% Creates a data structure, similar to the data structures of the Spider.
% X is a data matrix and Y the truth value vector.
% Unlike databatch, a data structure holds a physical data copy in memory.
% Warning: a result object is a handle. To make a physical copy of D0, use
% D=data(D0); not D=D0; or use D=subset(D0, idx);
%
% For consistency with the Spider objects
% http://www.kyb.mpg.de/bs/people/spider/
% X holds the preprocessed data or the recognition predictions and Y the truth values.
% We added a cell array containing the temporal segmentation results
%
% The contructor and the subset method accept both other data objects and
% result objects as arguments. The conversion works only if the cuts are
% defined. The converted data is then segmented in isolated patterns.
% We don't provide conversions from databatch objects because it would be
% too waistful.

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- May 2012
%==========================================================================

classdef data < handle
	properties (SetAccess = public)
        current_index=0;
        subidx=[];
        invidx=[];
        Y=[]; % Holds the truth values
        X=[]; % Holds the data matrix
    end
    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = data(obj, Y) 
            %this = data(X, Y) 
            %this = data(X)
            %this = data(result)
            %this = data(other_data)
            
            if isa(obj, 'data') 
                this.X=obj.X;
                this.Y=obj.Y;
                this.subidx=obj.subidx;
                this.invidx=obj.invidx;
            elseif isnumeric(obj)
                this.X=obj;
                if nargin>1
                    this.Y=Y;
                end
            elseif isa(X, 'result')
                if isprop(obj, 'cuts') && ~isempty(cuts)
                    %%% HERE COMPLICATED : need to get the indices right!
                    i=1;
                    for k=1:length(cuts)
                        C=cuts{k};
                        X=obj.X{k};
                        for j=1:size(C,1)
                            this.X(i,:)=X(C(j,1):C(j:2),:);
                            i=i+1;
                        end
                    end
                end
            end
        end          
        
        function D = subset(this, idx)
            %D = subset(this, idx)
            % Select a data subset
            D=data(this);
            D.subidx=idx;
            D.invidx(idx)=1:length(idx);
        end 
        
        function Y=get_Y(this, num)
            %Y=get_Y(this, num, cutnum)
            if nargin<2
                num=this.current_index;
            elseif isempty(num)
                num=this.subidx;
            else
                num=this.subidx(num);
            end
            if num<1 || num>length(this.Y), Y=[]; return; end
            Y=this.Y(num,:);
        end
        
        function X=get_X(this, num, cutnum)
            %X=get_X(this, num, cutnum)
            if isempty(this.X), X=[]; return; end
            
            % Finds the pattern number
            if nargin<2
                num=this.current_index;
            elseif isempty(num)
                num=this.subidx;
            else
                num=this.subidx(num);
            end
            if num<1 || num>length(this.X), X=[]; return; end
            X=this.X(num,:);
        end
        
        function set_Y(this, num, val)
            %set_Y(this, num, val)
            num=this.subidx(num);
            this.Y{num}=val;
        end
        
        function set_X(this, num, val)
            %set_X(this, num, val)
            num=this.subidx(num);
            this.X{num}=val;
        end  
        
        function n=length(this)
            %n=length(this)
            % number of samples
            n=length(this.subidx);
        end
        
        function n=labelnum(this)
            %n=labelnum(this)
            % number of labels 
            n=length(get_Y(this));
        end
            
        function save(this, filename, prefix, mode)
            %save(this, filename, prefix, mode)
            % Save the results in csv format
            if nargin<3, prefix=''; end
            if nargin<4, mode='w'; end
            samples=this.subidx;
            labels=this.X(samples);
            write_file(filename, samples, labels, prefix, mode);
        end
        
        function show(this, num, h)
            %show(this, num, h)
            % Shows the nth pattern          
            X=get_X(this, num);
            Y=get_Y(this, num);
            imdisplay([X, Y]);
        end % show
        
        function goto(this, num)
            %goto(this, num) 
            % For compatibility with databatch
            if num>0 && num<=length(this)
                this.current_index=this.subidx(num);
            end
        end
        
        function next(this)
            %next(this)
            % For compatibility with databatch
            num=this.invidx(this.current_index)+1;
            if num>length(this)
                num=1;
            end
            goto(this, num);
        end     
        
        function prev(this)
            %prev(this)
            % For compatibility with databatch
            num=this.invidx(this.current_index)-1;
            if num<1
                num=length(this);
            end
            goto(this, num);
        end 
        
        function n=num(this)
            %n=num(this)
            % For compatibility with databatch
            n=this.current_index;
        end
            
    end %methods
end % classdef
