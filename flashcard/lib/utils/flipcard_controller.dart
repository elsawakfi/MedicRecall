import 'package:flip_card/flip_card_controller.dart';

class MyFlipCardController extends FlipCardController{
  DateTime madeAt = DateTime.now();

  @override
  Future<void> toggleCard() async {
    if (madeAt.add(const Duration(seconds:50)).compareTo(DateTime.now()) < 0) {
      await state?.toggleCard();
    }
  }
}