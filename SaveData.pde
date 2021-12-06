
class SaveData {
  private Table dataStore;

  public SaveData() {
    this.load();
  }

  void load() {
    dataStore = loadTable("savedata.bin", "bin");
    if (dataStore == null) {
      this.initDefault();
      this.save();
    }
  }

  void initDefault() {
    dataStore = new Table();
    dataStore.addColumn("high_score");

    for (int i = 0; i < 4; i++) {
      var row = dataStore.addRow();
      row.setInt(0, 0);
    }
  }
  
  int getHighScore(Difficulty difficulty) {
     return dataStore.getRow(difficulty.getValue()).getInt(0);
  }
  
  void setHighScore(Difficulty difficulty, int score) {
     dataStore.getRow(difficulty.getValue()).setInt(0, score);
     this.save();
  }

  void save() {
    saveTable(dataStore, "savedata.bin", "bin");
  }
}
