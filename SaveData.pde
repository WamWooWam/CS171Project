
// 
// this class handles save data for high scores
//
class SaveData {
  private Table dataStore;

  public SaveData() {
    this.load();
  }

  void load() {
    // load the table
    dataStore = loadTable("savedata.bin", "bin");
    
    // if it's not found, create it
    if (dataStore == null) {
      this.initDefault();
      this.save();
    }
  }
  
  // creates the high score table if needed
  void initDefault() {
    dataStore = new Table();
    dataStore.addColumn("high_score");

    for (int i = 0; i < 4; i++) {
      var row = dataStore.addRow();
      row.setInt(0, 0);
    }
  }
  
  // gets the high score for a given difficulty
  int getHighScore(Difficulty difficulty) {
     return dataStore.getRow(difficulty.getValue()).getInt(0);
  }
  
  // sets a high score for a given difficulty and saves
  void setHighScore(Difficulty difficulty, int score) {
     dataStore.getRow(difficulty.getValue()).setInt(0, score);
     this.save();
  }
  
  // saves the table to disk
  void save() {
    saveTable(dataStore, "savedata.bin", "bin");
  }
}
