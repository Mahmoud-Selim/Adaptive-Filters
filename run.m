results = zeros([10000, 1]);
for i=1:5
    results = results + (Paper(100) / 5);
end
results = 10 * log10(results);
%plot(results(:,1)', 1:3500)

plot(1:10000, results(:,1)');
hold
plot(1:10000, results(:,2)');
plot(1:10000, results(:,3)');
plot(1:10000, results(:,4)');
xlabel('Number of iterations');
ylabel('Excess MSE');
legend('Proposed', 'VSSLMS', 'GVSSLMS', 'MVSSLMS');