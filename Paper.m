function result = Paper(N)

    N = 100;
    dataset = [];
    %for i=1:N
    %dataset(end + 1) = awgn(randn(1), 10);
    %end
    dataset = awgn(randn([1,N]), 10);
    dataset_excess = reshape(dataset, [5, N / 5]);
    w_sys = [.227, 0.46, .6388, .64, .227]';
    results = [];
    for i=1:size(w_sys):size(dataset, 2)
    results(end + 1) = dataset(i : i - 1 + size(w_sys)) * w_sys;
    end
    
    all_desired = w_sys' * dataset_excess;
    lms = dsp.LMSFilter('Length',5);
    [mmse,emse,meanW,mse,traceK] = msepred(lms,w_sys' * dataset_excess, results);

    proposed_impl = Proposed(0.39, 0, 10000);
    train_result = train(proposed_impl, dataset, results);
    %excess_error(train_result, w_sys' * dataset_excess, results)


    vss_impl = VSS(1.1 * 10^-3, 0, 10000);
    train_result2 = train(vss_impl, dataset, results);
    %excess_error(train_result2, w_sys' * dataset_excess, results)

    gvsslms_impl = GVSSLMS(0, 10000);
    train_result3 = train(gvsslms_impl, dataset, results);
    %excess_error(train_result3, w_sys' * dataset_excess, results)

    mvss_impl = MVSS(0.013, 0, 10000);
    train_result4 = train(mvss_impl, dataset, results);
    %excess_error(train_result4, w_sys' * dataset_excess, results)
    
    proposed_errors = train_result.errors(:, 1) / 20 - mmse;
    vss_errors = train_result2.errors(:, 1) / 20 - mmse;
    gvss_errors = train_result3.errors(:, 1) / 20 - mmse;
    mvss_errors = train_result4.errors(:, 1) / 20 - mmse;
    result = [proposed_errors, vss_errors, gvss_errors, mvss_errors];
    %result = [train_result.errors(:, 1), train_result2.errors(:, 1), train_result3.errors(:, 1), train_result4.errors(:, 1)];
end



