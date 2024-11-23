public class OrderTriggerHandler {

    public static void beforeUpdate(List<Order> newOrders) {
        // Étape 1 : Calcul du montant net pour chaque commande
        calculateNetAmount(newOrders);
    }

    public static void afterUpdate(List<Order> newOrders) {
        // Étape 1 : Identifier les comptes concernés
        Set<Id> accountIds = getAccountIds(newOrders);

        // Étape 2 : Calculer les ventes totales par compte et mettre à jour les comptes
        if (!accountIds.isEmpty()) {
            updateAccountSales(accountIds);
        }
    }

    // **Méthodes auxiliaires**

    /**
     * Calcule le montant net pour chaque commande.
     * Montant net = TotalAmount - ShipmentCost.
     */
    private static void calculateNetAmount(List<Order> orders) {
        for (Order order : orders) {
            Decimal totalAmount = (order.TotalAmount == null) ? 0 : order.TotalAmount;
            Decimal shipmentCost = (order.ShipmentCost__c == null) ? 0 : order.ShipmentCost__c;
            order.NetAmount__c = totalAmount - shipmentCost;

            // Logs de débogage
            System.debug('Order ID: ' + order.Id);
            System.debug('TotalAmount: ' + totalAmount);
            System.debug('ShipmentCost: ' + shipmentCost);
            System.debug('NetAmount: ' + order.NetAmount__c);
        }
    }

    /**
     * Récupère l'ensemble des IDs de comptes liés aux commandes.
     */
    private static Set<Id> getAccountIds(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order order : orders) {
            if (order.AccountId != null) {
                accountIds.add(order.AccountId);
            }
        }
        return accountIds;
    }

    /**
     * Met à jour les ventes totales (chiffre d'affaires) des comptes.
     * Se base sur les commandes liées ayant le statut 'Ordered'.
     */
    private static void updateAccountSales(Set<Id> accountIds) {
        // Étape 1 : Récupérer les commandes liées aux comptes concernés
        Map<Id, Decimal> accountSalesMap = new Map<Id, Decimal>();
        List<Order> relatedOrders = [
            SELECT AccountId, TotalAmount
            FROM Order
            WHERE AccountId IN :accountIds AND Status = 'Ordered'
        ];

        // Étape 2 : Calcul des ventes totales pour chaque compte
        for (Order order : relatedOrders) {
            if (order.TotalAmount != null) {
                Decimal currentTotal = accountSalesMap.containsKey(order.AccountId)
                    ? accountSalesMap.get(order.AccountId)
                    : 0;
                accountSalesMap.put(order.AccountId, currentTotal + order.TotalAmount);
            }
        }

        // Étape 3 : Mise à jour des comptes avec les chiffres d'affaires calculés
        List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];

        for (Account acc : accountsToUpdate) {
            Decimal updatedSales = accountSalesMap.containsKey(acc.Id) 
                ? accountSalesMap.get(acc.Id)
                : 0;
            acc.Chiffre_d_affaire__c = updatedSales;
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
