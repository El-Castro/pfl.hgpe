import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]


-- removeDups is a auxiliar function that removes duplicates from a list. 
-- It receives a list of cities and returns a list of cities without any duplicates.
removeDups :: [City] -> [City]
removeDups [] = []
removeDups (x:xs) = x : removeDups (filter (/= x) xs)


-- cities is a function that lists all the cities in a roadmap.
-- It receives a roadmap and returns a list of all the cities in that roadmap.

cities :: RoadMap -> [City]
cities [] = []
cities ((city1,city2,distance):xs) = removeDups(city1 : city2 : cities xs)

-- areAdjacent is a function that checks if two cities are adjacent in a roadmap.
-- It receives a roadmap and two cities. Returns True if the cities are adjacent and False otherwise.

areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent [] _ _ = False;
areAdjacent ((city1,city2,distance):xs) x y
  | city1 == x && city2 == y = True
  | city1 == y && city2 == x = True
  | otherwise = areAdjacent xs x y

-- distance is a function that returns the distance between two adjacent cities in a roadmap.
-- It receives a roadmap and two cities. Returns the distance between the cities if they are adjacent and Nothing otherwise.

distance :: RoadMap -> City -> City -> Maybe Distance
distance [] _ _ = Nothing
distance ((city1, city2, d):xs) x y
    | city1 == x && city2 == y = Just d
    | city1 == y && city2 == x = Just d
    | otherwise = distance xs x y

-- adjacent is a function that lists all the cities adjacent to a given city in a roadmap.
-- It receives a roadmap and a city. Returns a list of tuples with the adjacent cities and their respective distances.

adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ = []
adjacent ((city1, city2, d):xs) x
    | city1 == x = (city2, d) : adjacent xs x
    | city2 == x = (city1, d) : adjacent xs x
    | otherwise = adjacent xs x

-- pathDistance is a function that calculates the distance of a path in a roadmap.
-- It receives a roadmap and a path. Returns the distance of the path if it is a valid path and Nothing otherwise.

pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance roadmap (y1:y2:ys) = do
    a <- distance roadmap y1 y2
    b <- pathDistance roadmap (y2:ys)
    return (a + b)

-- maxDistance is an auxiliar function that calculates the maximum degree that any city in the roadmap has.
-- It receives a roadmap and returns the maximum degree between all cities in the roadmap.

maxDegree :: RoadMap -> Int
maxDegree [] = 0
maxDegree ((city1, city2, d):xs) = do
    let a = maxDegree xs
    let b =  length (adjacent ((city1, city2, d):xs) city1)
    let c = length (adjacent ((city1, city2, d):xs) city2)
    maximum [a, b, c]

-- rome is a function that returns the cities with the maximum degree in a roadmap.
-- It receives a roadmap and returns a list of all cities with the highest degree.

rome :: RoadMap -> [City]
rome [] = []
rome ((city1, city2, d):xs)
    | length (adjacent ((city1, city2, d):xs) city1) == maxDegree ((city1, city2, d):xs) = removeDups(city1 : rome xs)
    | length (adjacent ((city1, city2, d):xs) city2) == maxDegree ((city1, city2, d):xs) = removeDups(city2 : rome xs)
    | otherwise = removeDups (rome xs)

-- getNeighbors is an auxiliar function that returns the neighbors of a city in a roadmap.
-- It receives a roadmap and a city. Returns a list of all neighbors of the city.
-- It's a similar function to adjacent, but it only returns the cities, not the distances.

getNeighbors :: RoadMap -> City -> [City]
getNeighbors [] _ = []
getNeighbors ((city1, city2, d):xs) x
    | city1 == x = city2 : getNeighbors xs x
    | city2 == x = city1 : getNeighbors xs x
    | otherwise = getNeighbors xs x

-- reachable is an auxiliar function that returns all cities reachable from a given city in a roadmap.
-- It receives a roadmap, a city and a list of visited cities (used in recursion). Returns a list of all cities reachable from the given city.

reachable :: RoadMap -> City -> [City] -> [City]
reachable roadmap city visited
    | city `elem` visited = visited  -- If city has already been visited, return visited list
    | otherwise =
        let newVisited = city : visited  -- Mark the city as visited
            neighbors = getNeighbors roadmap city  -- Get neighboring cities
        in foldl (\acc neighbor -> reachable roadmap neighbor acc) newVisited neighbors

-- isStronglyConnected is a function that checks if a roadmap is strongly connected.
-- It receives a roadmap and returns True if the roadmap is strongly connected and False otherwise.

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected [] = False
isStronglyConnected roadmap =
    let (x:xs) = cities roadmap  -- Get list of all unique cities in the roadmap
        reachableFromStart = reachable roadmap x []  -- Find all cities reachable from x
    in length reachableFromStart == length (x:xs)  -- If both lists have the same length the graph is strongly connected
    
-- shortestPath is a function that finds the shortest path between two cities in a roadmap.
-- It receives a roadmap, a start city and an end city. Returns a list of all shortest paths between the two cities.

shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath roadmap start end
    | start == end = [[start]]  -- If the start and end cities are the same, return a list with the start city
    | otherwise = bfs [[start]]  -- Otherwise start BFS with the initial city

    where
        -- bfs recursively explores all paths in the roadmap
        bfs :: [Path] -> [Path]
        bfs [] = []  -- No paths left to explore
        bfs paths = 
            let extendedPaths = concatMap extend paths  -- Extend each path by adding all possible paths (unexplored neighbors)
                allValidPaths = filter (\path -> last path == end) extendedPaths  -- Keep all paths that reach the end city
                remainingPaths = filter (\path -> last path /= end) extendedPaths  -- Paths that haven't reached the end yet
            in if null remainingPaths  -- If all paths are complete (at the end city or no more neighbors)...
            then shortestPaths (allValidPaths)  -- ... return the shortest valid paths
            else shortestPaths (allValidPaths ++ bfs remainingPaths)  -- ... otherwise continue exploring on the remaining paths


        -- extend adds all neighbors to a path
        -- It receives a path and returns a list of all possible paths that can be extended from the given path

        extend :: Path -> [Path]
        extend path = 
            let currentCity = last path  -- Get the last city in the path
                neighbors = getNeighbors roadmap currentCity  -- Get neighboring cities
            in [path ++ [n] | n <- neighbors, n `notElem` path]  -- Create new paths, avoiding without revisiting cities

        -- Get the shortest paths from valid paths
        -- It receives a list of paths and returns a list of the shortest paths
        shortestPaths :: [Path] -> [Path]
        shortestPaths paths =
            let distances = map (pathDistance roadmap) paths  -- Calculate distances for all valid paths
                minDistance = minimum (map (maybe maxBound id) distances)  -- Calculate the minimum distance
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
