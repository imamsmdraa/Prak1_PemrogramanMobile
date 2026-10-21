import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'view_model.dart';
import 'dart:math' as math;

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late VoidCallback _openGameOver;
  late final QuizViewModel viewModel = QuizViewModel(
    onGameOver: _handleGameOver,
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              TextButton(
                onPressed:
                    viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                    ? () {
                        viewModel.getNextQuestion();
                      }
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
// =========================================================================
// ======== LANGKAH 4 - Transisi Navigasi Kustom ===========================
// =========================================================================
                OpenContainer<void>(
                  closedColor: Theme.of(context).colorScheme.surface,
                  openColor: Theme.of(context).colorScheme.surface,
                  transitionDuration: const Duration(milliseconds: 700),
                  tappable: false,
                  closedBuilder: (context, openContainer) {
                    _openGameOver = openContainer;
                    return QuestionCard(
                      question: viewModel.currentQuestion?.question,
                    );
                  },
                  openBuilder: (context, closeContainer) {
                    return GameOverScreen(score: viewModel.score);
                  },
                ),
  // =================== LANGKAH 4 - end ===================================
                Spacer(),
                AnswerCards(
                  onTapped: (index) {
                    viewModel.checkAnswer(index);
                  },
                  answers: viewModel.currentQuestion?.possibleAnswers ?? [],
                  correctAnswer: viewModel.didAnswerQuestion
                      ? viewModel.currentQuestion?.correctAnswer
                      : null,
                ),
               
                StatusBar(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========= langkah 4 ===========
  void _handleGameOver() {
    _openGameOver();
  }
  // ===============================
}

class QuestionCard extends StatelessWidget {
  final String? question;
// =========================================================================
// ======== LANGKAH 2 - Animasi Eksplisit pada soal pergantian soal ========
// =========================================================================
  const QuestionCard({required this.question, super.key});

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      layoutBuilder: (entries) {
        return Stack(
          alignment: Alignment.topCenter,
          children: entries,
        );
      },
      child: Card(
        key: ValueKey(question),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            question ?? '',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ),
    );
  }
}

// ========= langkah 4 ===========
class GameOverScreen extends StatelessWidget {
  final int score;

  const GameOverScreen({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: Center(
        child: Text(
          'Score: $score',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
// =================
  
class AnswerCards extends StatelessWidget {
  
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;

  const AnswerCards({
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    super.key,
  });

  
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 5 / 2,
      children: List.generate(answers.length, (index) {
        var color = Theme.of(context).colorScheme.primaryContainer;
        if (correctAnswer == index) {
          color = Theme.of(context).colorScheme.tertiaryContainer;
        }
          
        return CardFlipEffect(
          delayAmount: index.toDouble() / 2,
          child: _HoverAnswerCard(
            key: ValueKey(answers),
            answer: answers[index],
            baseColor: color,
            isCorrect: correctAnswer == index,
            onTapped: () => onTapped(index),
          ),
        );
      }),
    );
  }
}

class _HoverAnswerCard extends StatefulWidget {
  final String answer;
  final Color baseColor;
  final bool isCorrect;
  final VoidCallback onTapped;

  const _HoverAnswerCard({
    required this.answer,
    required this.baseColor,
    required this.isCorrect,
    required this.onTapped,
    super.key,
  });

  @override
  State<_HoverAnswerCard> createState() => _HoverAnswerCardState();
}

class _HoverAnswerCardState extends State<_HoverAnswerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 200),
        tween: ColorTween(
          begin: widget.baseColor,
          end: _isHovered ? Colors.yellow : widget.baseColor,
        ),
        builder: (context, color, child) {
          return AnimatedScale(
            scale: widget.isCorrect ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Card.filled(
              color: color,
              elevation: 2,
              margin: const EdgeInsets.all(8),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: widget.onTapped,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      widget.answer,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =========================================================================
// =======Langkah 3 — Mengontrol Status Animasi (Efek Kartu Dibalik)========
// ========================================================================= 
class CardFlipEffect extends StatefulWidget {
  final double delayAmount;
  final Widget child;
  const CardFlipEffect({
    required this.delayAmount,
    required this.child,
    super.key,
  });

  @override
  State<CardFlipEffect> createState() => _CardFlipEffectState();
}
class _CardFlipEffectState extends State<CardFlipEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animationWithDelay;
  Widget? _previousChild;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationWithDelay = _createAnimation();
  }

  Animation<double> _createAnimation() {
    return TweenSequence<double>([
      if (widget.delayAmount > 0)
        TweenSequenceItem(
          tween: ConstantTween<double>(0.0),
          weight: widget.delayAmount,
        ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 1.0,
      ),
    ]).animate(_animationController);
  }

  @override
  void didUpdateWidget(covariant CardFlipEffect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.child.key != widget.child.key) {
      _previousChild = oldWidget.child;
      _animationWithDelay = _createAnimation();
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationWithDelay,
      child: widget.child,
      builder: (context, child) {
        final animationValue = _animationWithDelay.value;
        final displayedChild = _animationController.isAnimating
            ? animationValue < 0.5
                ? _previousChild
                : Transform.flip(flipY: true, child: child)
            : child;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateX(
              _animationController.isAnimating ? animationValue * math.pi : 0,
            ),
          child: displayedChild,
        );
      },
    );
  }
}
// ===========================================================================
// =========================================================================== 

// ===========================================================================
// ================ LANGKAH 1 - Animasi Implisit pada Score ==================
// ===========================================================================
class AnimatedScoreIcon extends StatelessWidget {
  final bool isActive;

  const AnimatedScoreIcon({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 1000);
    const curve = Curves.elasticOut;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.5,
      curve: curve,
      duration: duration,
      child: TweenAnimationBuilder<Color?>(
        curve: curve,
        duration: duration,
        tween: ColorTween(
          begin: Colors.grey.shade400,
          end: isActive ? const Color.fromARGB(255, 20, 228, 72) : Colors.grey.shade400,
        ),
        builder: (context, color, child) {
          return Icon(Icons.emoji_events, size: 50, color: color);
        },
      ),
    );
  }
}
// =========================================================================
// =========================================================================

class StatusBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const StatusBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Question ${viewModel.answeredQuestionCount} / ${viewModel.totalQuestions}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Score: ${viewModel.score}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: List.generate(
            viewModel.totalQuestions,
            (index) => AnimatedScoreIcon(isActive: index < viewModel.score),
          ),
        ),
      ],
    ),
    );
  }
}
