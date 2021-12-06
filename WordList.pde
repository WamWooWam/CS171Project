
//
// because humans are not computers, randomness is a *feeling* to us. we can't easily tell
// if something is or is not truly random, for example, if you take the list of numbers from 0-10
// and pick 5 at random without removing from the list, you may get multiple 4s, and to the casual
// observer, this doesn't *feel* random
//
// to alleviate this problem somewhat, we don't choose a random word from the list each and every
// game. we start by shuffling the list, then iterating through it one by one, meaning duplicates
// can't happen.
//

// this class is based on my own work at:
// https://github.com/WamWooWam/WamBot.Twitch/blob/main/WamBot.Twitch/RandomList.cs
class WordList {
  private int idx;
  private String[] words;
  private Random random;
  public WordList(String name) {
    this.words = loadStrings("words/" + name + ".txt");
    this.random = new Random();
    this.shuffle();
  }

  public String next() {
    var item = words[idx];
    if (idx++ >= (words.length - 1)) {
      this.shuffle();
      idx = 0;
    }

    return item;
  }

  // adapted from: https://stackoverflow.com/questions/273313/randomize-a-listt
  private void shuffle() {
    int n = words.length;
    while (n > 1) {
      n--;
      int k = random.nextInt(n + 1);
      String value = words[k];
      words[k] = words[n];
      words[n] = value;
    }
  }
}
