factorial :: Int -> Int
factorial 0 = 1
factorial 1 = 1
factorial x = if x<0 then -1 else x * factorial(x-1)
-- factorial n = n * factorial(n-1)
main = do
    print(factorial (0))