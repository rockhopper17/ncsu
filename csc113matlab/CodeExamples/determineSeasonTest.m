fprintf('%%%%%%%%%%%% Testing determineSeason %%%%%%%%%%%%')
test = 0;
tot_points = 12;

% --- Test 1 ---
test = test + 1;
fprintf('\n--> Test %d: Testing Winter.\n', test);
try
    exp_season = 'Winter';
    act_season = determineSeason( 1, 4 );
    assert(isequal(exp_season, act_season));   
    fprintf('--> Test %d: PASS\n', test)
catch
    tot_points = tot_points - 1;
    fprintf('--> Test %d: FAIL -> [-%d]', test);
    fprintf('determineSeason did not return Winter for Jan,4\n');
end

% --- Test 2 ---
test = test + 1;
fprintf('\n--> Test %d: Testing Spring.\n', test);
try
    exp_season = 'Spring';
    act_season = determineSeason( 4, 14 );
    assert(isequal(exp_season, act_season));   
    fprintf('--> Test %d: PASS\n', test)
catch
    tot_points = tot_points - 1;
    fprintf('--> Test %d: FAIL -> [-%d]', test);    
    fprintf('determineSeason did not return Spring for Apr,14\n');
end

% --- Test 3 ---
test = test + 1;
fprintf('\n--> Test %d: Switching to Spring on March 21.\n', test);
try
    exp_season = 'Spring';
    act_season = determineSeason( 3, 21 );
    assert(isequal(exp_season, act_season));   
    fprintf('--> Test %d: PASS\n', test)
catch
    tot_points = tot_points - 1;
    fprintf('--> Test %d: FAIL -> [-%d]', test);        
    fprintf('determineSeason did not return Spring for Mar,21\n');
end


%fprintf('\n--> Total Points: %d\n', tot_points)