classdef GVSSLMS
    properties
        beta = .99;
        alpha = .08;
        gamma = .39;
        w_filter = [0, 0, 0, 0, 0]';
        step_size = .001;
        p = [0, 0, 0, 0, 0]';
        n_epochs = 10000;
        errors = [];
        error = 0
    end

    methods
        function obj = GVSSLMS( step_size, n_epochs)
            obj.step_size = step_size;
            obj.n_epochs = n_epochs;
            obj.errors = zeros(n_epochs);
        end
        function [inst_error, obj] = step(obj, x, output_sys)
            output_filter = x * obj.w_filter;
            %disp([output_sys; output_filter]);
            inst_error = output_sys - output_filter;
            %obj.p = obj.p * obj.beta + (1 - obj.beta) * acc_error * x;
            %obj.step_size = obj.alpha * obj.step_size + obj.gamma * norm(obj.p, 2) * acc_error * acc_error;
            obj.w_filter = obj.w_filter + obj.step_size * inst_error * x';
            obj.p = obj.beta * obj.p + (1 - obj.beta) * inst_error * x';
            %inst_error = bj.error + acc_error^2;
        end
        
        function excess_error = excess_error(obj, all_x, all_desired)
            lms = dsp.LMSFilter('Length',5);
            [mmse,emse,meanW,mse,traceK] = msepred(lms,all_x,all_desired);
            merr = obj.errors(obj.n_epochs, 1) / 20;
            eerr = merr - mmse;
            %disp('asd');
            %disp(mse(end));
            %disp(merr);
            excess_error = 10 * log10(eerr);
        end
        
        function obj = update_stepsize(obj, error)
            obj.step_size = obj.alpha * norm(obj.p, 2);
        end
        
        function obj = train(obj, dataset, results)
            
            for j=1:obj.n_epochs
                cnt = 1;
                obj.error = 0;
                obj.p = [0, 0, 0, 0, 0]';
                for i=1:size(obj.w_filter):size(dataset, 2)
                    %disp(dataset(i : i - 1+ size(obj.w_filter)));
                    [inst_error, obj] = step(obj, dataset(i : i - 1 + size(obj.w_filter)), results(cnt));
                    obj.error = obj.error + inst_error;
                    obj.errors(j) = obj.errors(j) + inst_error^2;
                    cnt = cnt + 1;
                end
                %obj.errors(j) = obj.step_size;
                obj = update_stepsize(obj, obj.error / (size(dataset, 2) / 5));
                obj.w_filter = obj.w_filter;
            end
        end
        
    end
    
end