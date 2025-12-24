public with sharing class CarDataController {
  @AuraEnabled(cacheable=true)
  public static List<Car__c> getCarList() {
    return [
      SELECT
        Id,
        Name,
        Class__c,
        Rarity__c,
        Max_Stars__c,
        (SELECT Id FROM Car_Star_Levels__r)
      FROM Car__c
      WITH SECURITY_ENFORCED
      ORDER BY Name ASC
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Car__c getCarDetail(Id carId) {
    return [
      SELECT
        Id,
        Name,
        Class__c,
        Rarity__c,
        Max_Stars__c,
        Release_Date__c,
        Unlock_Type__c,
        Image_Url__c,
        Cost_Template__r.Name,
        (
          SELECT
            Id,
            Star_Level__c,
            Blueprints_Required__c,
            Rank_Min__c,
            Rank_Max__c,
            Top_Speed_Max__c,
            Accel_Max__c,
            Handling_Max__c,
            Nitro_Max__c
          FROM Car_Star_Levels__r
          ORDER BY Star_Level__c ASC
        )
      FROM Car__c
      WHERE Id = :carId
      WITH SECURITY_ENFORCED
    ];
  }
}
