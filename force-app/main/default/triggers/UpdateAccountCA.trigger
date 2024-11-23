trigger UpdateAccountCA on Order (after update) {
    OrderTriggerHandler.afterUpdate(Trigger.new);
    // Utilisation d'un ensemble pour stocker les IDs des comptes et une carte pour les montants totaux
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Decimal> accountSalesMap = new Map<Id, Decimal>();

    // Parcours des commandes mises à jour pour collecter les IDs des comptes et totaliser le montant
    for (Order newOrder : Trigger.new) {
        if (newOrder.AccountId != null) {
            accountIds.add(newOrder.AccountId); // Collecte tous les AccountId

            // Ajout des montants totaux des ventes
            Decimal totalAmount = (newOrder.TotalAmount == null) ? 0 : newOrder.TotalAmount;
            if (accountSalesMap.containsKey(newOrder.AccountId)) {
                accountSalesMap.put(newOrder.AccountId, accountSalesMap.get(newOrder.AccountId) + totalAmount);
            } else {
                accountSalesMap.put(newOrder.AccountId, totalAmount);
            }
        }
    }

    // Récupérer les comptes concernés en une seule requête
    List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];

    // Mettre à jour le chiffre d'affaires de chaque compte
    for (Account acc : accountsToUpdate) {
        Decimal currentSales = (acc.Chiffre_d_affaire__c == null) ? 0 : acc.Chiffre_d_affaire__c;
        acc.Chiffre_d_affaire__c = currentSales + accountSalesMap.get(acc.Id); // Mise à jour du CA
    }

    // Mise à jour en masse des comptes
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
