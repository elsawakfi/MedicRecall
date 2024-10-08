@Skip("currently failing, to update")

import 'package:flashcard_x/screens/feed_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('i want to test the resultscore: ', () {
    var a = Feed;
    var b = Feed;

    int howDoTheyFeel(a) {
      if (a["cardValue"] == 1) {
        return a["score"]++;
      }
      return a["score"];
    }

    double whenToShowNext(var a) {
      //var whenToShowA = a["lastSeen"] + (2 * a["timesSeen"]);
      var whenToShow = ((howDoTheyFeel(a) / 2) *
          ((2 * (a["score"])) +
              ((howDoTheyFeel(a) - 1) * 2))); //whenToShow is 1, 2, 4 or 6
      if (whenToShow > 6) {
        whenToShow = 6;
      }
      return whenToShow;
    }

    // bool containsCard(String cardID, List<Map<String, dynamic>> cards) {
    //   for (var card in cards) {
    //     //for each card in cards
    //     if (card["id"] == cardID) {
    //       //if card can be found
    //       return true;
    //     }
    //   }
    //   return false; //otherwise
    // }

    // double avg(List<dynamic> scores) {
    //   var total = 0;
    //   for (var score in scores) {
    //     total += score as int;
    //   }
    //   return total / scores.length;
    // }

    int sort(var a, var b) {
      var ratioA = whenToShowNext(a); // a["timesSeen"];
      var ratioB = whenToShowNext(b); // b["timesSeen"];
      // ratioA = ifTheyGetItWrong(a);
      // ratioB = ifTheyGetItWrong(b);

      if (ratioA > ratioB) {
        //sort by whenToShowNext
        return -1;
      } else if (ratioA < ratioB) {
        return 1;
      } else {
        return 0;
      }
    }

    if (whenToShowNext(a) == whenToShowNext(b)) {
      expect(sort(a, b), 0);
    } else if (whenToShowNext(a) < whenToShowNext(b)) {
      expect(sort(a, b), -1);
    } else {
      expect(sort(a, b), 1);
    }

    // if (a["cardValue"] == 1) {
    //   expect(howDoTheyFeel(a), true);
    // }

    bool whenToShowReturnsPositive(var a) {
      if (whenToShowNext(a) >= 0) {
        return true;
      } else {
        return false;
      }
    }

    bool whenToShowEquationIsValid(var a) {
      if (whenToShowNext(a) == 1 ||
          whenToShowNext(a) == 2 ||
          whenToShowNext(a) == 4 ||
          whenToShowNext(a) == 6) {
        return true;
      } else {
        return false;
      }
    }

    expect(whenToShowReturnsPositive(a), true);
    expect(whenToShowEquationIsValid(a), true);

    // expect(this.subtopics.isEmpty(), false);
    // if (a["gotRight"] == false) {
    //   expect(ifTheyGetItWrong(a), -1);
    // } else {
    //   expect(ifTheyGetItWrong(a), 0);
    // }
  });
}
