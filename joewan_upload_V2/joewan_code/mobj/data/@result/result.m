%=============================================================================
% result Data structure             
%=============================================================================  
% D=result(object)
% 
% Creates a result container given a databatch object or another result object.
% Warning: a result object is a handle. To make a physical copy of R0, use
% R=result(R0); not R=R0; or use R=subset(R0, idx);
% When the argument is a data object, both X and Y hold the truth values.
%
% For consistency with the Spider objects
% http://www.kyb.mpg.de/bs/people/spider/
% X holds the preprocessed data or the recognition predictions and Y the truth values.
% We added a cell array containing the temporal segmentation results

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- October 2011
%==========================================================================
% Modifications May 2012 to make is more similar to a databatch so either
% can be used and we can chain preprocessings.
% We also added a "cuts" data member allowing to store temporal
% segmentation.
% get_X and get_Y have changed to make them compatible with databatch.
% To omit the argument results in returning the pattern corresponding to the
% current_index, not the entire array. To get the entire array, use
% get_X(this, 'all'); get_Y(this, 'all');

classdef result < handle
	properties (SetAccess = public)
        current_index=0;
        vocabulary_size=0;
        data_size=0;
        subidx=[];
        invidx=[];
        Y={}; % Holds the truth values
        X={}; % Holds the results
        cuts={}; % Each element is a nx2 matrix containing start and end of n cuts (temporal segmentation)
    end
    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = result(obj) 
            if nargin<1, return; end
            this.subidx=obj.subidx;
            this.invidx=obj.invidx;
            this.vocabulary_size=obj.vocabulary_size;
            this.data_size=obj.data_size;
            this.Y=obj.Y;
            this.cuts=obj.cuts;
            this.current_index=1;
            if isprop(obj, 'X') 
                this.X=obj.X;
            else
                this.X=cell(size(this.Y));
            end
        end          
        
        function D = subset(this, idx)
            %D = subset(this, idx)
            % Select a data subset
            D=result(this);
            D.subidx=idx;
            D.invidx(idx)=1:length(idx);
        end 
        
        function Y=get_Y(this, num, cutnum)
            %Y=get_Y(this, num, cutnum)
            if nargin<2 || isempty(num)
                num=this.current_index;
            elseif strcmp(num, 'all')
                num=this.subidx;
                Y=this.Y(num);
                return
            else
                if num<1 || num>length(this), Y=[]; return; end
                num=this.subidx(num);
            end
            Y=this.Y{num};
            
            if nargin<3 || isempty(cutnum), return; end
            if cutnum<1, cutnum=1; end
            if cutnum>length(Y), cutnum=length(Y); end
            Y=Y(cutnum);
        end
        
        function X=get_X(this, num, cutnum)
            %X=get_X(this, num, cutnum)
            if isempty(this.X), X=[]; return; end
            
            % Finds the cuts
            if nargin<3 || isempty(cutnum), 
                cuts=[];
                cutnum=0;
            else
                cuts=get_cuts(this, num);
            end
            if cutnum<1, cutnum=1; end
            if cutnum>size(cuts, 1), cutnum=size(cuts, 1); end
            if ~isempty(cuts)
                cuts=cuts(cutnum,:);
            end
            
            % Finds the pattern number
            if nargin<2 || isempty(num)
                num=this.current_index;
            elseif strcmp(num, 'all')
                num=this.subidx;
                X=this.X(num);
                return
            else
                if num<1 || num>length(this), X=[]; return; end
                num=this.subidx(num);
            end
            
            % Gets the "cut" pattern
            X=this.X{num};
            if size(cuts,1)>1
                X=X(cuts(1):cuts(2),:);
            end
        end
        
        function cuts=get_cuts(this, num)
            %cuts=get_cuts(this, num)
            if isempty(this.cuts), cuts=[]; return; end
            if nargin<2 || isempty(num)
                num=this.current_index;
            elseif strcmp(num, 'all')
                num=this.subidx;
                cuts=this.cuts(num);
                return
            else
                if num<1 || num>length(this), cuts=[]; return; end
                num=this.subidx(num);
            end
            cuts=this.cuts{num};
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
        
        function set_cuts(this, num, val)
            %set_cuts(this, num, val)
            num=this.subidx(num);
            this.cuts{num}=val;
        end
        
        function n=length(this)
            %n=length(this)
            % number of samples
            n=length(this.subidx);
        end
        
        function n=labelnum(this)
            %n=labelnum(this)
            % number of labels (not of samples)
            Y=get_Y(this, 'all');
            n=0;
            for k=1:length(Y)
                n=n+length(Y{k});
            end
        end
            
        
        function [score, local_scores]=length_score(this)
            N=length(this);
            X=get_X(this, 'all');
            Y=get_Y(this, 'all');
            local_scores=zeros(N,1);
            n=0;
            for k=1:N
                true_length=length(Y{k});
                local_scores(k)=abs(length(X{k})-true_length);
                n=n+true_length;
            end
            score=sum(local_scores)/n;
        end
        
        function [score, local_scores]=leven_score(this)
            %lscore(this)
            [score, local_scores]=lscore(get_Y(this, 'all'), get_X(this, 'all'));
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
        
        function show(this, n, h)
            %show(this, n, h)
            % Shows the nth pattern
            if nargin<2, n=num(this); end
            
            X=get_X(this, n);
            Y=get_Y(this, n);
            cuts=get_cuts(this, n);
            if ~isempty(X)
                [p, n]=size(X);
                [pp, nn]=size(Y);
                % A result object can also hold intermediate results
                % (preprocessing). So there are several cases:
                
                if n==1
                    % 1) The results are labels:
                    fprintf('Found= ');
                    fprintf('%d ', X);
                    fprintf('\nTruth= ');
                    fprintf('%d ', Y);
                    fprintf('\n');
                elseif ~isempty(cuts)
                    % 2) The results are a variable length data representation
                    if nargin<3, h=figure; else figure(h); end
                    hold on
                    subplot(2,1,1);
                    imdisplay(X', h, 'DATA REPRESENTATION'); axis normal; colorbar off
                    subplot(2,1,2);
                    display_segment(mean(X, 2), cuts, Y, h); title('LABELS');
                else
                    % 3) A fixed length representation
                    imdisplay([X, Y]);
                end
            end
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
