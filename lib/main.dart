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
  String selectedPatternName = 'Select one';
  late List<List<bool>> grid;

  Map<String, List<List<bool>>> customPatterns = {
    "Select one": [],
    "Osc: Oscilador": [
      [false, false, false, false, false],
      [false, false, true, false, false],
      [false, true, true, true, false],
      [false, false, true, false, false],
      [false, false, false, false, false],
    ],
    "Osc: Blinker": [
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, true, true, true, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
    ],
    "Osc: Toad": [
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, true, true, true],
      [false, true, true, true, false],
      [false, false, false, false, false],
    ],
    "Osc: Beacon": [
      [false, false, false, false, false],
      [false, true, true, false, false],
      [false, true, false, false, false],
      [false, false, false, false, true],
      [false, false, false, true, true],
    ],
    "SLifes: Block": [
      [false, false, false, false, false],
      [false, true, true, false, false],
      [false, true, true, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
    ],
    "SLifes: Beehive": [
      [false, false, false, false, false],
      [false, false, true, true, false],
      [false, true, false, false, true],
      [false, false, true, true, false],
      [false, false, false, false, false],
    ],
    "SLifes: Loaf": [
      [false, false, false, false, false],
      [false, false, true, true, false],
      [false, true, false, false, true],
      [false, false, true, false, true],
      [false, false, false, true, false],
    ],
    "SLifes: Boat": [
      [false, false, false, false, false],
      [false, true, true, false, false],
      [false, true, false, true, false],
      [false, false, true, false, false],
      [false, false, false, false, false],
    ],
    "SLifes: Tub": [
      [false, false, false, false, false],
      [false, false, true, false, false],
      [false, true, false, true, false],
      [false, false, true, false, false],
      [false, false, false, false, false],
    ],
    "SpSh: Glider": [
      [false, false, false, false, false],
      [false, false, true, false, false],
      [false, false, false, true, false],
      [false, true, true, true, false],
      [false, false, false, false, false],
    ],
    "SpSh: Lightweight": [
      [false, false, false, false, false],
      [false, true, false, false, true],
      [false, false, false, false, true],
      [false, true, false, true, true],
      [false, false, true, true, true],
    ],
    "SpSh: Middleweight": [
      [false, false, false, false, false],
      [false, false, true, true, false],
      [false, true, false, false, true],
      [false, true, false, false, true],
      [false, true, true, true, true],
    ],
    "SpSh: Heavyweight": [
      [false, false, false, false, false],
      [false, true, true, true, false],
      [false, true, false, false, true],
      [false, true, false, false, true],
      [false, true, true, true, true],
    ],
    "Guns: Gosper": [
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, true, true, false],
      [false, true, false, false, false],
      [false, true, false, false, false],
    ],
  };

  List<List<bool>>? selectedPattern;

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    grid = List.generate(numRows, (i) => List.filled(numCols, false));
  }

  void clearGrid() {
    grid = List.generate(numRows, (i) => List.filled(numCols, false));
    setState(() {});
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

  bool isClear = true;

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
                        if (isPlaying) {
                          setGameBeingPlayed(false);
                        } else {
                          setGameBeingPlayed(true);
                        }
                      },
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
                  SizedBox(width: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.grey[900],
                    ),
                    onPressed: () {
                      if (isClear) {
                        autofillGrid(20);
                        isClear = false;
                      } else {
                        clearGrid();
                        isClear = true;
                      }
                    },
                    child: Text('Autofill/Clear'),
                  ),
                  SizedBox(width: 5),
                  DropdownButton<String>(
                    value: selectedPatternName,
                    items: customPatterns.keys.map((String patternName) {
                      return DropdownMenuItem<String>(
                        value: patternName,
                        child: Text(patternName,
                            style: TextStyle(color: Colors.blue)),
                      );
                    }).toList(),
                    onChanged: (selectedPatternName) {
                      clearGrid();
                      // Obtén el patrón seleccionado del Map usando su nombre
                      List<List<bool>> selectedPattern =
                          customPatterns[selectedPatternName] ?? [];

                      // Coloca el patrón seleccionado en el centro de la cuadrícula
                      int startRow = (numRows - selectedPattern.length) ~/ 2;
                      int startCol = (numCols - selectedPattern[0].length) ~/ 2;

                      for (int row = 0; row < selectedPattern.length; row++) {
                        for (int col = 0;
                            col < selectedPattern[0].length;
                            col++) {
                          grid[startRow + row][startCol + col] =
                              selectedPattern[row][col];
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
