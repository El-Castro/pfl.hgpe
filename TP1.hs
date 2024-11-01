import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

-- cities

removeDups :: [City] -> [City]
removeDups [] = []
removeDups (x:xs) = x : removeDups (filter (/= x) xs)

cities :: RoadMap -> [City]
cities [] = []
cities ((city1,city2,distance):xs) = removeDups(city1 : city2 : cities xs)

-- areAdjacent

areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent [] _ _ = False;
areAdjacent ((city1,city2,distance):xs) x y
  | city1 == x && city2 == y = True
  | city1 == y && city2 == x = True
  | otherwise = areAdjacent xs x y

-- distance

distance :: RoadMap -> City -> City -> Maybe Distance
distance [] _ _ = Nothing
distance ((city1, city2, d):xs) x y
    | city1 == x && city2 == y = Just d
    | city1 == y && city2 == x = Just d
    | otherwise = distance xs x y

-- adjacent

adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ = []
adjacent ((city1, city2, d):xs) x
    | city1 == x = (city2, d) : adjacent xs x
    | city2 == x = (city1, d) : adjacent xs x
    | otherwise = adjacent xs x

-- pathDistance

pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance roadmap (y1:y2:ys) = do
    a <- distance roadmap y1 y2
    b <- pathDistance roadmap (y2:ys)
    return (a + b)

-- rome

maxDegree :: RoadMap -> Int
maxDegree [] = 0
maxDegree ((city1, city2, d):xs) = do
    let a = maxDegree xs
    let b =  length (adjacent ((city1, city2, d):xs) city1)
    let c = length (adjacent ((city1, city2, d):xs) city2)
    maximum [a, b, c]

rome :: RoadMap -> [City]
rome [] = []
rome ((city1, city2, d):xs)
    | length (adjacent ((city1, city2, d):xs) city1) == maxDegree ((city1, city2, d):xs) = removeDups(city1 : rome xs)
    | length (adjacent ((city1, city2, d):xs) city2) == maxDegree ((city1, city2, d):xs) = removeDups(city2 : rome xs)
    | otherwise = removeDups (rome xs)

-- isStronglyConnected

getNeighbors :: RoadMap -> City -> [City]
getNeighbors [] _ = []
getNeighbors ((city1, city2, d):xs) x
    | city1 == x = city2 : getNeighbors xs x
    | city2 == x = city1 : getNeighbors xs x
    | otherwise = getNeighbors xs x

reachable :: RoadMap -> City -> [City] -> [City]
reachable roadmap city visited
    | city `elem` visited = visited  -- If city has already been visited, return visited list
    | otherwise =
        let newVisited = city : visited  -- Mark the city as visited
            neighbors = getNeighbors roadmap city  -- Get neighboring cities
        in foldl (\acc neighbor -> reachable roadmap neighbor acc) newVisited neighbors

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected [] = False
isStronglyConnected roadmap =
    let (x:xs) = cities roadmap  -- Get list of all unique cities in the roadmap
        startCity = x  -- Choose an arbitrary starting city
        reachableFromStart = reachable roadmap startCity []  -- Find all cities reachable from startCity
    in length reachableFromStart == length (x:xs)  -- If all cities are reachable from startCity, the graph is strongly connected
    
-- shortestPath

shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath roadmap start end
    | start == end = [[start]]  -- Return the path containing just the start city
    | otherwise = bfs [[start]]  -- Start BFS with the initial city

    where
        -- Perform BFS to find all paths
        bfs :: [Path] -> [Path]
        bfs [] = []  -- No paths left to explore
        bfs paths = 
            let extendedPaths = concatMap extend paths  -- Extend each path
                allValidPaths = filter (\path -> last path == end) extendedPaths  -- Keep all paths that reach the end city
                remainingPaths = filter (\path -> last path /= end) extendedPaths  -- Paths that haven't reached the end yet
            in if null remainingPaths  -- If there are no more paths to explore, return all valid paths found
            then shortestPaths (allValidPaths)  -- Return all paths that reach the end city
            else shortestPaths (allValidPaths ++ bfs remainingPaths)  -- Continue searching and concatenate results


        -- Extend the path by adding neighbors
        extend :: Path -> [Path]
        extend path = 
            let currentCity = last path  -- Get the last city in the path
                neighbors = getNeighbors roadmap currentCity  -- Get neighboring cities and distances
            in [path ++ [n] | n <- neighbors, n `notElem` path]  -- Create new paths, avoiding cycles

        -- Get the shortest paths from valid paths
        shortestPaths :: [Path] -> [Path]
        shortestPaths paths =
            let distances = map (pathDistance roadmap) paths  -- Calculate distances for all valid paths
                minDistance = minimum (map (maybe maxBound id) distances)  -- Find minimum distance (handling Maybe)
            in filter (\p -> pathDistance roadmap p == Just minDistance) paths  -- Filter paths by minimum distance

-- travelSales

travelSales :: RoadMap -> Path
travelSales = undefined

-- tspBruteForce

tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]
