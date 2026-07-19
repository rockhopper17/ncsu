%%

countryNames = char('France', 'USA', 'Japan', 'Egypt', 'China');
capitalNames = {'Paris', 'Washington D.C.', 'Tokyo', 'Cairo', 'Beijing'};
population = [9645000 3934000 33200000 12200000 8614000];
numCountries = length(capitalNames);

for i=numCountries:-1:1
    SCountries(i).name = countryNames(i,:);
    SCountries(i).capital = capitalNames{i};
    SCountries(i).population =  population(i);
end

%questions
SCountries(4).capital
size([SCountries.population])