public class UpdateAllAccountsBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Integer globalRecordsProcessed = 0;
    public Integer globalOrdersProcessed = 0;
    public Decimal globalRevenueUpdated = 0;

    public Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator([
            SELECT Id, Name, Chiffre_d_affaire__c
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Ordered')
        ]);
    }

    public void execute(Database.BatchableContext info, List<Account> scope) {
        // Étape 1 : Identifier
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        // Étape 2 : Organiser
        Map<Id, List<OrderItem>> orderItemsByAccountId = new Map<Id, List<OrderItem>>();
        for (OrderItem orderItem : [SELECT Id, Order.AccountId, UnitPrice, Quantity 
                                    FROM OrderItem 
                                    WHERE Order.AccountId IN :accountIds AND Order.Status = 'Ordered']) {
            if (!orderItemsByAccountId.containsKey(orderItem.Order.AccountId)) {
                orderItemsByAccountId.put(orderItem.Order.AccountId, new List<OrderItem>());
            }
            orderItemsByAccountId.get(orderItem.Order.AccountId).add(orderItem);
        }

        // Étape 3 : Calculer
        List<Account> accountsToUpdate = new List<Account>();
        Integer localRecordsProcessed = 0;
        Integer localOrdersProcessed = 0;
        Decimal localRevenueUpdated = 0;

        for (Account acc : scope) {
            List<OrderItem> orderItems = orderItemsByAccountId.get(acc.Id);
            if (orderItems != null && !orderItems.isEmpty()) {
                Decimal newRevenue = UpdateAllAccounts.calculateAccountRevenue(orderItems);
                updateAccountRevenue(acc, newRevenue, accountsToUpdate, localRevenueUpdated, localRecordsProcessed, localOrdersProcessed);
            }
        }

        // Étape 4 : Mettre à jour
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }

        // Mise à jour des compteurs globaux
        globalRecordsProcessed += localRecordsProcessed;
        globalOrdersProcessed += localOrdersProcessed;
        globalRevenueUpdated += localRevenueUpdated;
    }

    public void finish(Database.BatchableContext info) {
        AsyncApexJob job = [SELECT Status, CreatedDate, CompletedDate FROM AsyncApexJob WHERE Id = :info.getJobId()];
        // Code additionnel pour la fin (logs, notification, etc.) peut être ajouté ici
    }

    // Méthode pour gérer la mise à jour des comptes
    public void updateAccountRevenue(Account acc, Decimal newRevenue, List<Account> accountsToUpdate, 
                                     Decimal localRevenueUpdated, Integer localRecordsProcessed, 
                                     Integer localOrdersProcessed) {
        Decimal oldRevenue = acc.Chiffre_d_affaire__c != null ? acc.Chiffre_d_affaire__c : 0;
        if (acc.Chiffre_d_affaire__c != newRevenue) {
            acc.Chiffre_d_affaire__c = newRevenue;
            accountsToUpdate.add(acc);
            localRevenueUpdated += newRevenue - oldRevenue;
            localRecordsProcessed++;
            localOrdersProcessed++;
        }
    }
}
