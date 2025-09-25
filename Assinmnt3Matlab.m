T = readtable('dirty_cafe_sales-1.csv', 'VariableNamingRule', 'preserve'); %used readtable to load the dataset
% Converting Quantity and Price Per Unit to numeric values
T.("Quantity") = str2double(string(T.("Quantity")));
T.("Price Per Unit") = str2double(string(T.("Price Per Unit")));
T.("Total Spent") = str2double(string(T.("Total Spent")));

% Fix Total Spent where it's missing or inconsistent, recalculating it:
calcSpent = T.("Quantity") .* T.("Price Per Unit");
idx_inconsistent = isnan(T.("Total Spent")) | abs(T.("Total Spent") - calcSpent) > 0.01; %explain
T.("Total Spent")(idx_inconsistent) = calcSpent(idx_inconsistent);

%Clean table: 
Tclean = T(~isnan(T.("Total Spent")), :);
invalidItems = ["UNKNOWN", "ERROR"]; %this eliminates "unknown" and "error" as a sold item
Tclean = Tclean(~ismember(upper(string(Tclean.("Item"))), invalidItems) & ~ismissing(Tclean.("Item")), :);
totalSpent = Tclean.("Total Spent");
%Here is the grouped statistics so that it's easier to access and display
summaryStats = struct( ...
    'Count', sum(~isnan(totalSpent)), ... %Note: omitnan 
    'Mean', mean(totalSpent, 'omitnan'), ...
    'Std', std(totalSpent, 'omitnan'), ...
    'Min', min(totalSpent, [], 'omitnan'), ...
    'Median', median(totalSpent, 'omitnan'), ...
    'Max', max(totalSpent, [], 'omitnan'), ...
    'Sum', sum(totalSpent, 'omitnan') ...
);
% Print out summary stats
disp(summaryStats);

% finding the most sold item %
mostFreqItem = groupsummary(Tclean, "Item"); %this is the most frequented item
mostFreqItem = sortrows(mostFreqItem, 'GroupCount', 'descend');
disp("Most sold item:");
disp(mostFreqItem(1, :));
%Most sold item by quantity 
mostQtyItem = groupsummary(Tclean, 'Item', 'sum', 'Quantity');
mostQtyItem = sortrows(mostQtyItem, 'sum_Quantity', 'descend');
disp("Item with greatest total quantity sold:");
disp(mostQtyItem(1, :));

%Because the dataset for the "Payment Method" is also corrupted with
%blanks, ERRORS, and UNKNOWN. the line of code below is the clean up that
%dataset.
Tclean = Tclean(~ismember(upper(string(Tclean.("Payment Method"))), invalidItems) & ~ismissing(Tclean.("Payment Method")), :);
%Note/Reminder: "invalidItems" references the list of invalid statements
%"ERROR" & "UNKNOWN".

%finding the Most preferred payment method: 
mostPrefPayment = groupsummary(Tclean, "Payment Method"); % count transactions per method
mostPrefPayment = sortrows(mostPrefPayment, 'GroupCount', 'descend');
disp("Most preferred payment method:");
disp(mostPrefPayment(1, :));
%Pie chart of payment methods
figure;
pie(mostPrefPayment.GroupCount, mostPrefPayment.("Payment Method"));
title('Payment Method Distribution');

%% Bar Chart: Total spent per item %%
itemSpent = groupsummary(Tclean, "Item", "sum", "Total Spent");

% Find the sums of money spent for each item, sort it as a column
colName = itemSpent.Properties.VariableNames{ ...
    contains(itemSpent.Properties.VariableNames, "sum_")};

% Sort by that column
itemSpent = sortrows(itemSpent, colName, "descend");

% Plot bar chart
figure;
bar(categorical(itemSpent.Item), itemSpent.(colName), ...
    'FaceColor', [0.2 0.6 0.8]);
title('Total Spent per Item');
xlabel('Item');
ylabel('Total Spent');
grid on;

%% Transactions per item Bar chart %%
itemTrans = groupsummary(Tclean, "Item");  % counts rows per Item
itemTrans = sortrows(itemTrans, "GroupCount", "descend");

figure;
bar(categorical(itemTrans.Item), itemTrans.GroupCount, ...
    'FaceColor', [0.8 0.4 0.4]);
title('Number of Transactions per Item');
xlabel('Item');
ylabel('Number of Transactions');
grid on;

%% Pie chart of payment methods %%
% This is just an extra seperate section can run independently, the first
% chunk of code already has the pie chart
figure;
pie(mostPrefPayment.GroupCount, mostPrefPayment.("Payment Method"));
title('Payment Method Distribution');

%% Histogram of total spent %%
figure;
histogram(Tclean.("Total Spent"), 20, ...   % 20 bins
    'FaceColor', [0.3 0.7 0.9], 'EdgeColor', 'green');
title('Distribution of Spending Amounts per Transaction');
xlabel('Spending Amount (per Transaction)');
ylabel('Number of Transactions');
grid on;