w_sys = [.227, 0.46, .6388, .64, .227]';
n_epochs = 6000;
x = [randn(1), randn(1), randn(1), randn(1), randn(1)]';
p = [0, 0, 0, 0, 0]';
beta = .993;
alpha = .97;
gamma = .39;
step_size = 0.001;
errors = zeros(n_epochs);
w_filter = [0, 0, 0, 0, 0]';
all_x = zeros(n_epochs);
all_desired = zeros(n_epochs);
test = Proposed(gamma, 0, n_epochs);
test_VSS = VSS(1.1 * 10^-3, 0, n_epochs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Dataset Generation%%%%%%%%%%%%%%%%%%%%%%%%%
N = 1000;
dataset = [];
for i=1:N
    dataset(end + 1) = randn(1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





for i=1:n_epochs
    %x update
    new_value = randn(1);
    x = [x(2:5).', new_value]';
    all_x(i) = new_value;
    all_desired(i) = w_sys.' * x;
    %disp([w_sys.' * x, awgn(w_sys.' * x, 10)]);
    output_sys = w_sys.' * x; %+ (randn(1) * 10^0.5)
    output_filter = w_filter.' * x;
    %disp([output_sys; output_filter]);
    error = output_sys - output_filter;
    
    p = p * beta + (1 - beta) * error * x;
    step_size = alpha * step_size + gamma * norm(p, 2) * error * error;
    %disp(error);
    errors(1) = errors(1) + error^2;
    w_filter = w_filter + step_size * error * x;
    test = step(test, x, output_sys);
    test_VSS = step(test_VSS, x, output_sys);
    %disp([step_size, error, norm(p, 2), gamma * norm(p, 2) ]);
end

disp(w_filter);
disp(test.w_filter);

all_x = all_x(:, 1);
all_desired = all_desired(:, 1);
lms = dsp.LMSFilter('Length',5);
[mmse,emse,meanW,mse,traceK] = msepred(lms,all_x,all_desired);
merr = errors(1) / n_epochs;
eerr = merr - mmse;
final_DB = 10 * log10(eerr);

%disp(excess_error(test, all_x, all_desired));
%disp(excess_error(test_VSS, all_x, all_desired));
xxx = [all_x, awgn(all_x, 0)];
