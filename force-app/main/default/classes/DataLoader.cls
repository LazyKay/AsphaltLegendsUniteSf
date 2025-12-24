public with sharing class DataLoader {
  // --- WRAPPERS ---

  public class TemplateWrapper {
    public String id;
    public String name;
    public Integer Uncommon_Part_Cost;
    public Integer Rare_Part_Cost;
    public Integer Epic_Part_Cost;
    public Integer Stage_1_Cost;
    public Integer Stage_2_Cost;
    public Integer Stage_3_Cost;
    public Integer Stage_4_Cost;
    public Integer Stage_5_Cost;
    public Integer Stage_6_Cost;
    public Integer Stage_7_Cost;
    public Integer Stage_8_Cost;
    public Integer Stage_9_Cost;
    public Integer Stage_10_Cost;
    public Integer Stage_11_Cost;
    public Integer Stage_12_Cost;
    public Integer Stage_13_Cost;
  }

  public class CarWrapper {
    public String externalId;
    public String name;
    public String classx;
    public Boolean isKeyCar;
    // New Fields
    public String rarity;
    public String imageUrl;
    public Integer maxStars;
    public String templateId;
    public List<StarLevelWrapper> starLevels;
  }

  public class StarLevelWrapper {
    public Integer level;
    public String levelName;
    public Integer rank;
    public Decimal topSpeed;
    public Decimal accel;
    public Decimal handling;
    public Decimal nitro;
    public Integer blueprints;
    public Integer totalCost;
    public Integer maxStageIndex;
    public PartsWrapper parts;
  }

  public class PartsWrapper {
    public SlotsWrapper uncommon;
    public SlotsWrapper rare;
    public SlotsWrapper epic;
  }

  public class SlotsWrapper {
    public Integer speed;
    public Integer accel;
    public Integer handling;
    public Integer nitro;
  }

  // --- METHODS ---

  public static void loadAll() {
    loadTemplates();
    loadCars();
  }

  public static void cleanupBatch() {
    Integer dmlCount = 0;
    Integer MAX_DML = 9000;

    // Star Levels
    Boolean hasMore = true;
    while (hasMore && dmlCount < MAX_DML) {
      // Use Dynamic SOQL to avoid parser ambiguity with Arrays/Lists, and LIMIT before ALL ROWS
      List<Car_Star_Level__c> live = Database.query(
        'SELECT Id FROM Car_Star_Level__c LIMIT 2000'
      );
      if (!live.isEmpty()) {
        delete live;
        dmlCount += live.size();
      }

      if (dmlCount < MAX_DML) {
        List<Car_Star_Level__c> bin = Database.query(
          'SELECT Id FROM Car_Star_Level__c LIMIT 2000 ALL ROWS'
        );
        if (!bin.isEmpty()) {
          Database.emptyRecycleBin(bin);
          dmlCount += bin.size();
        }
        if (live.isEmpty() && bin.isEmpty())
          hasMore = false;
      }
    }

    // Cars
    hasMore = true;
    while (hasMore && dmlCount < MAX_DML) {
      List<Car__c> live = Database.query('SELECT Id FROM Car__c LIMIT 2000');
      if (!live.isEmpty()) {
        delete live;
        dmlCount += live.size();
      }

      if (dmlCount < MAX_DML) {
        List<Car__c> bin = Database.query(
          'SELECT Id FROM Car__c LIMIT 2000 ALL ROWS'
        );
        if (!bin.isEmpty()) {
          Database.emptyRecycleBin(bin);
          dmlCount += bin.size();
        }
        if (live.isEmpty() && bin.isEmpty())
          hasMore = false;
      }
    }

    // Templates
    hasMore = true;
    while (hasMore && dmlCount < MAX_DML) {
      List<Upgrade_Template__c> live = Database.query(
        'SELECT Id FROM Upgrade_Template__c LIMIT 2000'
      );
      if (!live.isEmpty()) {
        delete live;
        dmlCount += live.size();
      }

      if (dmlCount < MAX_DML) {
        List<Upgrade_Template__c> bin = Database.query(
          'SELECT Id FROM Upgrade_Template__c LIMIT 2000 ALL ROWS'
        );
        if (!bin.isEmpty()) {
          Database.emptyRecycleBin(bin);
          dmlCount += bin.size();
        }
        if (live.isEmpty() && bin.isEmpty())
          hasMore = false;
      }
    }
    System.debug('Cleanup Batch Processed DML Rows: ' + dmlCount);
  }

  public static void loadTemplates() {
    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'TemplateJSON'
      LIMIT 1
    ];
    String jsonStr = sr.Body.toString();
    List<TemplateWrapper> wrappers = (List<TemplateWrapper>) JSON.deserialize(
      jsonStr,
      List<TemplateWrapper>.class
    );

    List<Upgrade_Template__c> upsertList = new List<Upgrade_Template__c>();

    for (TemplateWrapper w : wrappers) {
      Upgrade_Template__c t = new Upgrade_Template__c();
      t.Name = w.name;
      t.Uncommon_Part_Cost__c = w.Uncommon_Part_Cost;
      t.Rare_Part_Cost__c = w.Rare_Part_Cost;
      t.Epic_Part_Cost__c = w.Epic_Part_Cost;
      t.Stage_1_Cost__c = w.Stage_1_Cost;
      t.Stage_2_Cost__c = w.Stage_2_Cost;
      t.Stage_3_Cost__c = w.Stage_3_Cost;
      t.Stage_4_Cost__c = w.Stage_4_Cost;
      t.Stage_5_Cost__c = w.Stage_5_Cost;
      t.Stage_6_Cost__c = w.Stage_6_Cost;
      t.Stage_7_Cost__c = w.Stage_7_Cost;
      t.Stage_8_Cost__c = w.Stage_8_Cost;
      t.Stage_9_Cost__c = w.Stage_9_Cost;
      t.Stage_10_Cost__c = w.Stage_10_Cost;
      t.Stage_11_Cost__c = w.Stage_11_Cost;
      t.Stage_12_Cost__c = w.Stage_12_Cost;
      t.Stage_13_Cost__c = w.Stage_13_Cost;
      upsertList.add(t);
    }

    upsert upsertList Name;
    System.debug('Upserted ' + upsertList.size() + ' Templates.');
  }

  public static void loadCars() {
    Map<String, Id> templateMap = new Map<String, Id>();
    for (Upgrade_Template__c t : [SELECT Id, Name FROM Upgrade_Template__c]) {
      templateMap.put(t.Name, t.Id);
    }

    StaticResource tsr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'TemplateJSON'
      LIMIT 1
    ];
    List<TemplateWrapper> tWrappers = (List<TemplateWrapper>) JSON.deserialize(
      tsr.Body.toString(),
      List<TemplateWrapper>.class
    );
    Map<String, String> tmpIdToName = new Map<String, String>();
    for (TemplateWrapper tw : tWrappers) {
      tmpIdToName.put(tw.id, tw.name);
    }

    StaticResource sr = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'CarJSON'
      LIMIT 1
    ];
    String jsonStr = sr.Body.toString().replace('"class":', '"classx":');

    List<CarWrapper> wrappers = (List<CarWrapper>) JSON.deserialize(
      jsonStr,
      List<CarWrapper>.class
    );

    List<Car__c> carUpsertList = new List<Car__c>();
    Map<String, CarWrapper> carWrapperMap = new Map<String, CarWrapper>();

    for (CarWrapper w : wrappers) {
      Car__c c = new Car__c();
      c.Name = w.name;
      c.Class__c = w.classx;
      c.Max_Stars__c = w.maxStars;
      c.Rarity__c = w.rarity;
      c.Image_Url__c = w.imageUrl;
      c.Unlock_Type__c = (w.isKeyCar == true) ? 'Key' : 'Blueprints';

      if (w.templateId != null) {
        String tName = tmpIdToName.get(w.templateId);
        if (tName != null && templateMap.containsKey(tName)) {
          c.Cost_Template__c = templateMap.get(tName);
        }
      }

      carUpsertList.add(c);
      carWrapperMap.put(c.Name, w);
    }

    upsert carUpsertList Name;
    System.debug('Upserted ' + carUpsertList.size() + ' Cars.');

    Map<String, Id> carIdMap = new Map<String, Id>();
    for (Car__c c : [
      SELECT Id, Name
      FROM Car__c
      WHERE Name IN :carWrapperMap.keySet()
    ]) {
      carIdMap.put(c.Name, c.Id);
    }

    // We do NOT do full cleanup here, as we expect cleanupBatch to be run manually if needed.
    // We only clean children of updated cars for consistency during upsert.
    delete [
      SELECT Id
      FROM Car_Star_Level__c
      WHERE Car__r.Name IN :carWrapperMap.keySet()
    ];

    List<Car_Star_Level__c> levelsToInsert = new List<Car_Star_Level__c>();
    for (String carName : carWrapperMap.keySet()) {
      CarWrapper cw = carWrapperMap.get(carName);
      Id carId = carIdMap.get(carName);

      if (cw.starLevels != null) {
        for (StarLevelWrapper sl : cw.starLevels) {
          Car_Star_Level__c csl = new Car_Star_Level__c();
          csl.Car__c = carId;
          csl.Star_Level__c = sl.level;
          csl.Rank_Max__c = sl.rank;
          csl.Top_Speed_Max__c = sl.topSpeed;
          csl.Accel_Max__c = sl.accel;
          csl.Handling_Max__c = sl.handling;
          csl.Nitro_Max__c = sl.nitro;
          csl.Blueprints_Required__c = sl.blueprints;
          csl.Max_Stage_Index__c = sl.maxStageIndex != null
            ? sl.maxStageIndex
            : 0;

          if (sl.parts != null) {
            if (sl.parts.uncommon != null) {
              csl.Speed_Uncommon_Part_Slots__c = sl.parts.uncommon.speed;
              csl.Accel_Uncommon_Part_Slots__c = sl.parts.uncommon.accel;
              csl.Hand_Uncommon_Part_Slots__c = sl.parts.uncommon.handling;
              csl.Nitro_Uncommon_Part_Slots__c = sl.parts.uncommon.nitro;
            }
            if (sl.parts.rare != null) {
              csl.Speed_Rare_Part_Slots__c = sl.parts.rare.speed;
              csl.Accel_Rare_Part_Slots__c = sl.parts.rare.accel;
              csl.Hand_Rare_Part_Slots__c = sl.parts.rare.handling;
              csl.Nitro_Rare_Part_Slots__c = sl.parts.rare.nitro;
            }
            if (sl.parts.epic != null) {
              csl.Speed_Epic_Part_Slots__c = sl.parts.epic.speed;
              csl.Accel_Epic_Part_Slots__c = sl.parts.epic.accel;
              csl.Hand_Epic_Part_Slots__c = sl.parts.epic.handling;
              csl.Nitro_Epic_Part_Slots__c = sl.parts.epic.nitro;
            }
          }
          levelsToInsert.add(csl);
        }
      }
    }

    insert levelsToInsert;
    System.debug('Inserted ' + levelsToInsert.size() + ' Star Levels.');
  }
}
