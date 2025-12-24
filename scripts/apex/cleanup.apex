// Hard Delete Star Levels (Batch 2000)
List<Car_Star_Level__c> levels = [SELECT Id FROM Car_Star_Level__c ALL ROWS LIMIT 2000];
if (!levels.isEmpty()) {
    Database.emptyRecycleBin(levels);
    
    List<Car_Star_Level__c> live = [SELECT Id FROM Car_Star_Level__c LIMIT 2000];
    if(!live.isEmpty()) delete live;
    
    levels = [SELECT Id FROM Car_Star_Level__c ALL ROWS LIMIT 2000];
    if(!levels.isEmpty()) Database.emptyRecycleBin(levels);
    
    System.debug('Processed batch of Star Levels');
}

// Hard Delete Cars (Batch 2000)
List<Car__c> cars = [SELECT Id FROM Car__c ALL ROWS LIMIT 2000];
if (!cars.isEmpty()) {
     List<Car__c> live = [SELECT Id FROM Car__c LIMIT 2000];
    if(!live.isEmpty()) delete live;
    
    cars = [SELECT Id FROM Car__c ALL ROWS LIMIT 2000];
    if(!cars.isEmpty()) Database.emptyRecycleBin(cars);
     System.debug('Processed batch of Cars');
}

// Hard Delete Templates (Batch 2000)
List<Upgrade_Template__c> templates = [SELECT Id FROM Upgrade_Template__c ALL ROWS LIMIT 2000];
if (!templates.isEmpty()) {
    List<Upgrade_Template__c> live = [SELECT Id FROM Upgrade_Template__c LIMIT 2000];
    if(!live.isEmpty()) delete live;
    
    templates = [SELECT Id FROM Upgrade_Template__c ALL ROWS LIMIT 2000];
    if(!templates.isEmpty()) Database.emptyRecycleBin(templates);
     System.debug('Processed batch of Templates');
}
