global class UpdateAllAccounts implements Database.Batchable<sObject>, Database.Stateful {

    private Integer globalRecordsProcessed = 0;
    private Integer globalOrdersProcessed = 0;
    private Decimal globalRevenueUpdated = 0;
    private String updatedAccountNames = '';

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator([
            SELECT Id, Name, Chiffre_d_affaire__c
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Ordered')
        ]);
    }

    global void execute(Database.BatchableContext info, List<Account> scope) {
        Integer localRecordsProcessed = 0;
        Integer localOrdersProcessed = 0;
        Decimal localRevenueUpdated = 0;

        // Récupérer tous les OrderItems pour tous les comptes en une seule requête
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }
        Map<Id, List<OrderItem>> orderItemsByAccountId = new Map<Id, List<OrderItem>>();
        for (OrderItem orderItem : [SELECT Id, Order.AccountId, UnitPrice, Quantity FROM OrderItem WHERE Order.AccountId IN :accountIds AND Order.Status = 'Ordered']) {
            if (!orderItemsByAccountId.containsKey(orderItem.Order.AccountId)) {
                orderItemsByAccountId.put(orderItem.Order.AccountId, new List<OrderItem>());
            }
            orderItemsByAccountId.get(orderItem.Order.AccountId).add(orderItem);
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : scope) {
            List<OrderItem> orderItems = orderItemsByAccountId.get(acc.Id);
            if (orderItems != null) {
                Decimal newRevenue = calculateAccountRevenue(orderItems);
                if (acc.Chiffre_d_affaire__c != newRevenue) {
                    Decimal oldRevenue = acc.Chiffre_d_affaire__c != null ? acc.Chiffre_d_affaire__c : 0;
                    acc.Chiffre_d_affaire__c = newRevenue;
                    accountsToUpdate.add(acc);

                    updatedAccountNames += (updatedAccountNames.length() > 0 ? ', ' : '') + acc.Name;
                    localRevenueUpdated += newRevenue - oldRevenue;

                    localRecordsProcessed++;
                    localOrdersProcessed++;
                }
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }

        globalRecordsProcessed += localRecordsProcessed;
        globalOrdersProcessed += localOrdersProcessed;
        globalRevenueUpdated += localRevenueUpdated;
    }

    global void finish(Database.BatchableContext info) {
        AsyncApexJob job = [SELECT Status, CreatedDate, CompletedDate FROM AsyncApexJob WHERE Id = :info.getJobId()];
    }
    private Decimal calculateAccountRevenue(List<OrderItem> orderItems) {
        Decimal totalRevenue = 0;
        for (OrderItem orderItem : orderItems) {
            if (orderItem.UnitPrice != null && orderItem.Quantity != null) {
                totalRevenue += orderItem.UnitPrice * orderItem.Quantity;
            }
        }
        return totalRevenue;
    }
}
