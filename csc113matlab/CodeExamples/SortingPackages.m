%%
%Creating the Structure Array
Packages(1).itemNumber = 123;
Packages(1).cost=19.99;
Packages(1).price=39.95;
Packages(1).code='g';
Packages(2).itemNumber = 456;
Packages(2).cost=5.99;
Packages(2).price=49.99;
Packages(2).code='l';
Packages(3).itemNumber = 587;
Packages(3).cost=11.11;
Packages(3).price=33.33;
Packages(3).code='w';

printPackages(Packages); %print the UNSORTED Structure Array

%sort based on Price and store the indices, upon execution
%IndexOrderByPrice will be [3 1 2]
%PricesSorted will be [33.3300  39.9500 49.9900] - not really needed
[PricesSorted, IndexOrderByPrice] = sort([Packages.price]);

Packages = Packages(IndexOrderByPrice); %SORTING the Structure Array
printPackages(Packages);%print the SORTED Structure Array


%PackagesByPrice = generalPackSort(Packages,'price');
%printPackages(PackagesByPrice);