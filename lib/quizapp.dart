import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'cal2.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: QuizScreen(),
  ));
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  SharedPreferences? sharedPreferences;
  int highestScore = 0;
  int quizNumber = 1;
  int questionIndex = 0;
  int score = 0;
  int maxTime = 180; // 3 minutes
  int currentTime = 180;
  double timerProgress = 1.0;
  late Timer timer;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    startCountdown();
  }

  void initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      highestScore = sharedPreferences?.getInt('highestScore') ?? 0;
    });
  }

  void updateHighestScore() async {
    final currentScore = await sharedPreferences?.getInt('highestScore');
    if (currentScore != null) {
      if (score > currentScore) {
        await sharedPreferences?.setInt('highestScore', score);
        setState(() {
          highestScore = score;
        });
      }
    } else {
      await sharedPreferences?.setInt('highestScore', score);
      setState(() {
        highestScore = score;
      });
    }
  }

  void startCountdown() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (currentTime <= 0) {
        t.cancel();
        // Quiz completed, perform any desired actions
        updateHighestScore();
      } else {
        setState(() {
          currentTime--;
          timerProgress = currentTime / maxTime;
        });
      }
    });
  }

  List<String> questions = [
    'What is the capital of France?',
    'Who painted the Mona Lisa?',
    'What is the largest planet in our solar system?',
    'What is the capital of Japan?',
    'Who wrote the play "Romeo and Juliet"?',
    'What is the largest mammal in the world?',
    'What is the currency of Australia?',
    'Who is known as the father of modern physics?',
    'What is the chemical symbol for gold?',
    'Which gas do plants absorb from the atmosphere?',
    'What is the largest organ in the human body?',
    'Which gas is most abundant in Earth\'s atmosphere?',
    'Which country is famous for the ancient city of Petra?',
    'What is the largest species of shark?',
    'What is the largest desert in the world?',
  ];

  List<List<String>> options = [
    ['Paris', 'London', 'Madrid', 'Rome'],
    ['Leonardo da Vinci', 'Pablo Picasso', 'Vin\'cent van Gogh', 'Claude Monet'],
    ['Saturn', 'Mars', 'Earth', 'Jupiter'],
    ['Tokyo', 'Beijing', 'Seoul', 'Bangkok'],
    ['William Shakespeare', 'Charles Dickens', 'Mark Twain', 'Jane Austen'],
    ['Blue whale', 'African elephant', 'Giraffe', 'Kangaroo'],
    ['Australian Dollar', 'Euro', 'Yen', 'Pound Sterling'],
    ['Albert Einstein', 'Isaac Newton', 'Galileo Galilei', 'Stephen Hawking'],
    ['Au', 'Ag', 'Pt', 'Fe'],
    ['Carbon dioxide', 'Oxygen', 'Nitrogen', 'Hydrogen'],
    ['Skin', 'Heart', 'Liver', 'Lungs'],
    ['Nitrogen', 'Oxygen', 'Carbon Dioxide', 'Helium'],
    ['Jordan', 'Egypt', 'Greece', 'Italy'],
    ['Whale Shark', 'Great White Shark', 'Hammerhead Shark', 'Tiger Shark'],
    ['Sahara Desert', 'Arctic Desert', 'Gobi Desert', 'Kalahari Desert'],
  ];

  List<String> correctAnswers = ['Paris', 'Leonardo da Vinci', 'Jupiter','Tokyo', 'William Shakespeare', 'Blue whale', 'Australian Dollar',
    'Albert Einstein', 'Au', 'Carbon dioxide', 'Skin','Nitrogen', 'Jordan', 'Whale Shark', 'Sahara Desert'];

  List<String> selectedAnswers = [];

  void checkAnswer(String selectedOption) {
    if (isAnswered) {
      return; // Prevent multiple answer selections
    }

    String correctAnswer = correctAnswers[questionIndex];
    bool isCorrect = selectedOption == correctAnswer;

    setState(() {
      selectedAnswers.add(selectedOption);
      isAnswered = true;

      if (isCorrect) {
        score++;
        sharedPreferences?.setInt('highestScore', score);
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (questionIndex < questions.length - 1) {
          questionIndex++;
          isAnswered = false;
        } else {

          updateHighestScore();
        }
      });
    });
  }

  void resetQuiz() {
    setState(() {
      selectedAnswers.clear();
      questionIndex = 0;
      quizNumber++;
      score = 0;
      isAnswered = false;
      currentTime = maxTime;
      timerProgress = 1.0;
    });
    startCountdown();
  }

  void shareScore() {
    String message =
        'I scored $score out of ${questions.length} in the quiz app!';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Quiz App", style: TextStyle(fontSize: 30,color: Colors.orangeAccent),),
          ],
        ),
        elevation: 0,
        titleSpacing: 20,
        toolbarHeight: 60,
        toolbarOpacity: 1,
        backgroundColor: Colors.transparent,

      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quiz $quizNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'High Score: $highestScore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          CircularTimer(
            progress: timerProgress,
            size: 80,
            currentTime: currentTime,
          ),
          SizedBox(height: 30),
          Text(
            'Question ${questionIndex + 1}: ${questions[questionIndex]}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: options[questionIndex].length,
            itemBuilder: (context, index) {
              bool isSelected =
              selectedAnswers.contains(options[questionIndex][index]);
              bool isCorrect = options[questionIndex][index] ==
                  correctAnswers[questionIndex];
              bool showCorrectAnswer = isAnswered && isCorrect;

              Color backgroundColor = Colors.transparent;
              if (isSelected) {
                backgroundColor = isCorrect ? Colors.green : Colors.red;
              } else if (showCorrectAnswer) {
                backgroundColor = Colors.green;
              }

              return GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    checkAnswer(options[questionIndex][index]);
                  }
                },
                child: Container(
                  color: backgroundColor,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        '${String.fromCharCode(65 + index)}.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        options[questionIndex][index],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 50),
          Text(
            'Score: $score / ${questions.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 80),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 10),

                IconButton(
                  icon: Icon(Icons.share, color: Colors.orangeAccent,),
                  alignment: Alignment.bottomLeft,
                  onPressed: shareScore,
                ),
                SizedBox(width: 30),
                IconButton(
                  icon: Icon(Icons.calculate,color: Colors.orangeAccent, size: 40),
                  alignment: Alignment.bottomRight,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalculatorScreen()),
                    );
                  },
                ),
                SizedBox(width: 15),

              ],
            ),

          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 200,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                resetQuiz();
              },
              child: Text('Next Quiz'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent), // Change the button color here
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularTimer extends StatelessWidget {
  final double progress;
  final double size;
  final int currentTime;

  CircularTimer({
    required this.progress,
    required this.size,
    required this.currentTime,
  });

  String getFormattedTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (currentTime * progress).toInt();
    final timeText = getFormattedTime(totalSeconds);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                color: Colors.red,
                backgroundColor: Colors.grey[300],
              ),
            ),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
