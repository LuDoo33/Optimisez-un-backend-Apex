trigger UpdateAccountCA on Order (after update) {
    // Utilisez un ensemble pour stocker les IDs des comptes et une carte pour l'utilisation groupée
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Decimal> accountSalesMap = new Map<Id, Decimal>();

    // Parcourez les commandes mises à jour pour collecter les IDs de comptes et totaliser le montant
    for (Order newOrder : Trigger.new) {
        if (newOrder.AccountId != null) {
            accountIds.add(newOrder.AccountId); // Collectez tous les AccountId

            // Ajoutez à la map les montants totaux des ventes
            Decimal totalAmount = (newOrder.TotalAmount == null) ? 0 : newOrder.TotalAmount;
            if (accountSalesMap.containsKey(newOrder.AccountId)) {
                accountSalesMap.put(newOrder.AccountId, accountSalesMap.get(newOrder.AccountId) + totalAmount);
            } else {
                accountSalesMap.put(newOrder.AccountId, totalAmount);
            }
        }
    }

    // Récupérez les comptes concernés d'une manière groupée
    List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];

    // Mettez à jour le champ Chiffre_d_affaire__c dans chaque compte
    for (Account acc : accountsToUpdate) {
        Decimal currentSales = (acc.Chiffre_d_affaire__c == null) ? 0 : acc.Chiffre_d_affaire__c;
        acc.Chiffre_d_affaire__c = currentSales + accountSalesMap.get(acc.Id);
    }

    // Mettez à jour en masse les comptes
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
