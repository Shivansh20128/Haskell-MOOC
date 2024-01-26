power :: Integer -> Integer -> Integer
power n 0 = 1
power n 1 = n
power n k = n * power n (k-1)

main = do
    print(power 2 3)