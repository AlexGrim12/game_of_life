import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(GameOfLifeApp());

class GameOfLifeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameOfLifeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameOfLifeScreen extends StatefulWidget {
  @override
  _GameOfLifeScreenState createState() => _GameOfLifeScreenState();
}

class _GameOfLifeScreenState extends State<GameOfLifeScreen> {
  static const int numRows = 78;
  static const int numCols = 40;
  static const int blockSize = 10;
  static const int movesPerSecond = 10; // Increase the update rate

  bool isPlaying = false;
  late List<List<bool>> grid;

  List<List<List<bool>>> predefinedPatterns = [
// Patrón 3: Oscilador (5x5)
    [
      [false, false, false, false, false],
      [false, false, true, false, false],
      [false, true, true, true, false],
      [false, false, true, false, false],
      [false, false, false, false, false],
    ],
  ];

  List<List<bool>>? selectedPattern;

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    grid = List.generate(numRows, (i) => List.filled(numCols, false));
  }

  void toggleCell(int row, int col) {
    setState(() {
      grid[row][col] = !grid[row][col];
    });
  }

  void setGameBeingPlayed(bool playing) {
    if (playing) {
      setState(() {
        isPlaying = true;
      });
      runGame();
    } else {
      setState(() {
        isPlaying = false;
      });
    }
  }

  void runGame() {
    if (!isPlaying) return;
    List<List<bool>> newGrid =
        List.generate(numRows, (i) => List.filled(numCols, false));

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        int neighbors = countNeighbors(row, col);

        if (grid[row][col]) {
          if (neighbors < 2 || neighbors > 3) {
            newGrid[row][col] = false;
          } else {
            newGrid[row][col] = true;
          }
        } else {
          if (neighbors == 3) {
            newGrid[row][col] = true;
          }
        }
      }
    }

    setState(() {
      grid = newGrid;
    });

    Future.delayed(Duration(milliseconds: 1000 ~/ movesPerSecond), runGame);
  }

  int countNeighbors(int row, int col) {
    int count = 0;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;

        int newRow = (row + i + numRows) % numRows;
        int newCol = (col + j + numCols) % numCols;

        if (grid[newRow][newCol]) {
          count++;
        }
      }
    }

    return count;
  }

  void autofillGrid(int percent) {
    Random random = Random();
    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        grid[row][col] = random.nextInt(100) < percent;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: numCols * blockSize.toDouble(),
                height: numRows * blockSize.toDouble(),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numCols,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    int row = index ~/ numCols;
                    int col = index % numCols;
                    return GestureDetector(
                      onTap: () {
                        toggleCell(row, col);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              grid[row][col] ? Colors.amber : Colors.grey[900],
                          border: Border.all(
                              color: const Color.fromARGB(0, 255, 255, 255)),
                        ),
                      ),
                    );
                  },
                  itemCount: numRows * numCols,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.grey[900],
                    ),
                    onPressed: () {
                      setGameBeingPlayed(true);
                    },
                    child: Text('Play'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.grey[900],
                    ),
                    onPressed: () {
                      setGameBeingPlayed(false);
                    },
                    child: Text('Stop'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.grey[900],
                    ),
                    onPressed: () {
                      autofillGrid(30);
                    },
                    child: Text('Autofill'),
                  ),
                  SizedBox(width: 20),
                  DropdownButton<List<List<bool>>>(
                    value: selectedPattern,
                    items: predefinedPatterns.map((pattern) {
                      return DropdownMenuItem<List<List<bool>>>(
                        value: pattern,
                        child: Text(
                            'Patrón ${predefinedPatterns.indexOf(pattern) + 1}'),
                      );
                    }).toList(),
                    onChanged: (selectedPattern) {
                      for (int row = 0; row < 5; row++) {
                        for (int col = 0; col < 5; col++) {
                          grid[row][col] = selectedPattern![row][col];
                        }
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
